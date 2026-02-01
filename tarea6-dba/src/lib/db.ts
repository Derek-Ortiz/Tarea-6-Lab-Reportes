import { Pool } from 'pg';

console.log('DB Config:', {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER
});

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'actividad_db',
    user: process.env.DB_USER || 'tarea6',
    password: process.env.DB_PASSWORD || 't4r34s313s'
});

export default pool;