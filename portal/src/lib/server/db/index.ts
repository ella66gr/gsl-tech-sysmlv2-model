import Database from 'better-sqlite3';
import { mkdirSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join, resolve } from 'path';
import schema from './schema.sql?raw';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Resolve data directory relative to portal root (4 levels up from src/lib/server/db)
const portalRoot = resolve(__dirname, '../../../..');
const dataDir = join(portalRoot, 'data');
const dbPath = join(dataDir, 'portal.db');

mkdirSync(dataDir, { recursive: true });

const db = new Database(dbPath);

db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

db.exec(schema);

// ---------------------------------------------------------------------------
// Migration 001 (S514, OP-125, ADR-011 §4.2): module_instances.epistemic_character
// -> reality_context, with value mapping production -> real, projection ->
// simulation (hypothesis unchanged); module_state_transitions.lifecycle_type
// 'epistemic' -> 'reality_context'. Idempotent: runs only while the old column
// exists. Databases created after S514 get the new column from schema.sql.
// ---------------------------------------------------------------------------
function migrateEpistemicCharacterToRealityContext(d: Database.Database): void {
    const cols = d.prepare("PRAGMA table_info('module_instances')").all() as { name: string }[];
    const hasOld = cols.some((c) => c.name === 'epistemic_character');
    const hasNew = cols.some((c) => c.name === 'reality_context');
    if (!hasOld) return;
    const run = d.transaction(() => {
        if (hasNew) {
            // Partial earlier run: carry values across, then drop the old column.
            d.exec(`UPDATE module_instances SET reality_context = CASE epistemic_character
                        WHEN 'production' THEN 'real' WHEN 'projection' THEN 'simulation' ELSE epistemic_character END`);
            d.exec('ALTER TABLE module_instances DROP COLUMN epistemic_character');
        } else {
            d.exec('ALTER TABLE module_instances RENAME COLUMN epistemic_character TO reality_context');
            d.exec(`UPDATE module_instances SET reality_context = CASE reality_context
                        WHEN 'production' THEN 'real' WHEN 'projection' THEN 'simulation' ELSE reality_context END`);
        }
        d.exec(`UPDATE module_state_transitions SET lifecycle_type = 'reality_context' WHERE lifecycle_type = 'epistemic'`);
        d.exec(`UPDATE module_state_transitions SET
                    from_state = CASE from_state WHEN 'production' THEN 'real' WHEN 'projection' THEN 'simulation' ELSE from_state END,
                    to_state   = CASE to_state   WHEN 'production' THEN 'real' WHEN 'projection' THEN 'simulation' ELSE to_state   END
                WHERE lifecycle_type = 'reality_context'`);
    });
    run();
    console.log('[portal db] migrated module_instances.epistemic_character -> reality_context (ADR-011)');
}
migrateEpistemicCharacterToRealityContext(db);

// Seed catalogue data (idempotent — INSERT OR IGNORE)
import { seedModuleDefinitions } from './seed.js';
seedModuleDefinitions(db);

export default db;
