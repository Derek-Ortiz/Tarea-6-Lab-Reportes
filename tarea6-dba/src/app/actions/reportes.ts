'use server'

import pool from '@/lib/db'

export async function getReporte() {

    try{
        const result = await pool.query('SELECT * FROM vista_cat_promedio');
        return result.rows;

    } catch(error){
        console.error('Error al obtener reportes', error);
        throw new Error('Error al obtener reportes');
    }
}