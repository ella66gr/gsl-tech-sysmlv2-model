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

// Seed catalogue data (idempotent — INSERT OR IGNORE)
import { seedModuleDefinitions } from './seed.js';
seedModuleDefinitions(db);

export default db;
