import Database from 'better-sqlite3';
import { readFileSync, mkdirSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join, resolve } from 'path';

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

const schema = readFileSync(join(__dirname, 'schema.sql'), 'utf-8');
db.exec(schema);

export default db;
