'use server'

import pool from '@/lib/db'
import { 
    categoriaFilterSchema, 
    rankingFilterSchema, 
    ordenesStatusFilterSchema,
    productosVendidosFilterSchema,
    analisisDesempenoFilterSchema,
    type CategoriaFilter,
    type RankingFilter,
    type OrdenesStatusFilter,
    type ProductosVendidosFilter,
    type AnalisisDesempenoFilter
} from '@/lib/validations'

export async function getVistaCatPromedio(rawFilters?: Partial<CategoriaFilter>) {
    try {
        // Validar filtros con Zod
        const filters = categoriaFilterSchema.parse(rawFilters || {});
        
        // Whitelist de columnas permitidas para ORDER BY
        const orderByWhitelist: Record<string, string> = {
            'promedio_precio': 'promedio_precio',
            'cantidad_productos': 'cantidad_productos',
            'nombre': 'nombre'
        };
        
        const orderColumn = orderByWhitelist[filters.orderBy] || 'promedio_precio';
        const orderDirection = filters.orderDir === 'ASC' ? 'ASC' : 'DESC';
        
        // Query parametrizada - Solo SELECT desde VIEW
        const result = await pool.query(
            `SELECT * FROM vista_cat_promedio 
             WHERE cantidad_productos >= $1
             ORDER BY ${orderColumn} ${orderDirection}`,
            [filters.minProductos]
        );
        
        // Calcular dato destacado
        const destacado = result.rows.length > 0 ? {
            categoriaConMayorPromedio: result.rows[0]?.nombre,
            promedioMasAlto: result.rows[0]?.promedio_redondeado,
            totalCategorias: result.rows.length
        } : null;
        
        return { data: result.rows, destacado };
    } catch (error) {
        console.error('Error al obtener vista_cat_promedio', error);
        throw new Error('Error al obtener vista_cat_promedio');
    }
}

export async function getVistaRankingUsuarios(rawFilters?: Partial<RankingFilter>) {
    try {
        // Validar filtros con Zod
        const filters = rankingFilterSchema.parse(rawFilters || {});
        
        const offset = (filters.page - 1) * filters.limit;
        const params: (string | number)[] = [];
        const whereConditions: string[] = [];
        let paramIndex = 1;
        
        // Construir condiciones WHERE de forma segura
        if (filters.nivelComprador && filters.nivelComprador !== 'todos') {
            whereConditions.push(`nivel_comprador = $${paramIndex}`);
            params.push(filters.nivelComprador);
            paramIndex++;
        }
        
        if (filters.minGasto !== undefined) {
            whereConditions.push(`gasto_total >= $${paramIndex}`);
            params.push(filters.minGasto);
            paramIndex++;
        }
        
        if (filters.maxGasto !== undefined) {
            whereConditions.push(`gasto_total <= $${paramIndex}`);
            params.push(filters.maxGasto);
            paramIndex++;
        }
        
        const whereClause = whereConditions.length > 0 
            ? `WHERE ${whereConditions.join(' AND ')}` 
            : '';
        
        const dataQuery = `
            SELECT * FROM vista_ranking_usuarios_gastos 
            ${whereClause}
            ORDER BY ranking_gastos
            LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
        `;
        params.push(filters.limit, offset);
        
        const countParams = params.slice(0, -2);
        const countQuery = `
            SELECT COUNT(*) as total FROM vista_ranking_usuarios_gastos ${whereClause}
        `;
        
        const [dataResult, countResult] = await Promise.all([
            pool.query(dataQuery, params),
            pool.query(countQuery, countParams)
        ]);
        
        const total = parseInt(countResult.rows[0]?.total || '0');
        const totalPages = Math.ceil(total / filters.limit);
        
        // Dato destacado
        const topUserQuery = await pool.query(
            'SELECT nombre, gasto_total, nivel_comprador FROM vista_ranking_usuarios_gastos ORDER BY gasto_total DESC LIMIT 1'
        );
        
        const destacado = {
            topComprador: topUserQuery.rows[0]?.nombre,
            mayorGasto: topUserQuery.rows[0]?.gasto_total,
            nivelTopComprador: topUserQuery.rows[0]?.nivel_comprador,
            totalUsuarios: total
        };
        
        return { 
            data: dataResult.rows, 
            destacado,
            pagination: {
                page: filters.page,
                limit: filters.limit,
                total,
                totalPages
            }
        };
    } catch (error) {
        console.error('Error al obtener vista_ranking_usuarios_gastos', error);
        throw new Error('Error al obtener vista_ranking_usuarios_gastos');
    }
}
export async function getVistaOrdenesPorStatus(rawFilters?: Partial<OrdenesStatusFilter>) {
    try {
        const filters = ordenesStatusFilterSchema.parse(rawFilters || {});
        
        let query = 'SELECT * FROM vista_ordenes_por_status';
        const params: string[] = [];
        
        if (filters.status && filters.status !== 'todos') {
            query += ' WHERE status = $1';
            params.push(filters.status);
        }
        
        query += ' ORDER BY cantidad_ordenes DESC';
        
        const result = await pool.query(query, params);
        
        // Calcular datos destacados
        const totalOrdenes = result.rows.reduce((sum, row) => sum + parseInt(row.cantidad_ordenes), 0);
        const montoTotal = result.rows.reduce((sum, row) => sum + parseFloat(row.monto_total || 0), 0);
        const statusMasComun = result.rows[0];
        
        const destacado = {
            totalOrdenes,
            montoTotalGeneral: montoTotal.toFixed(2),
            statusMasComun: statusMasComun?.status,
            porcentajeStatusMasComun: statusMasComun?.porcentaje_distribucion
        };
        
        return { data: result.rows, destacado };
    } catch (error) {
        console.error('Error al obtener vista_ordenes_por_status', error);
        throw new Error('Error al obtener vista_ordenes_por_status');
    }
}
export async function getVistaProductosMasVendidos(rawFilters?: Partial<ProductosVendidosFilter>) {
    try {
        const filters = productosVendidosFilterSchema.parse(rawFilters || {});
        
        const offset = (filters.page - 1) * filters.limit;
        const params: (string | number)[] = [];
        const whereConditions: string[] = [];
        let paramIndex = 1;
        
        if (filters.minVentas > 1) {
            whereConditions.push(`cantidad_vendida >= $${paramIndex}`);
            params.push(filters.minVentas);
            paramIndex++;
        }
        
        if (filters.popularidad && filters.popularidad !== 'todos') {
            whereConditions.push(`popularidad = $${paramIndex}`);
            params.push(filters.popularidad);
            paramIndex++;
        }
        
        const whereClause = whereConditions.length > 0 
            ? `WHERE ${whereConditions.join(' AND ')}` 
            : '';
        
        const dataQuery = `
            SELECT * FROM vista_productos_mas_vendidos 
            ${whereClause}
            ORDER BY posicion_ventas
            LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
        `;
        params.push(filters.limit, offset);
        
        const countParams = params.slice(0, -2);
        const countQuery = `
            SELECT COUNT(*) as total FROM vista_productos_mas_vendidos ${whereClause}
        `;
        
        const [dataResult, countResult] = await Promise.all([
            pool.query(dataQuery, params),
            pool.query(countQuery, countParams)
        ]);
        
        const total = parseInt(countResult.rows[0]?.total || '0');
        const totalPages = Math.ceil(total / filters.limit);
        
        const topProduct = dataResult.rows[0];
        const totalIngresos = dataResult.rows.reduce((sum, row) => sum + parseFloat(row.ingresos_totales || 0), 0);
        
        const destacado = {
            productoMasVendido: topProduct?.nombre,
            cantidadVendida: topProduct?.cantidad_vendida,
            ingresosTotales: totalIngresos.toFixed(2),
            totalProductos: total
        };
        
        return { 
            data: dataResult.rows, 
            destacado,
            pagination: {
                page: filters.page,
                limit: filters.limit,
                total,
                totalPages
            }
        };
    } catch (error) {
        console.error('Error al obtener vista_productos_mas_vendidos', error);
        throw new Error('Error al obtener vista_productos_mas_vendidos');
    }
}
export async function getVistaAnalisisDesempeno(rawFilters?: Partial<AnalisisDesempenoFilter>) {
    try {
        const filters = analisisDesempenoFilterSchema.parse(rawFilters || {});
        
        const params: (string | number)[] = [];
        const whereConditions: string[] = [];
        let paramIndex = 1;
        
        if (filters.clasificacion && filters.clasificacion !== 'todos') {
            whereConditions.push(`clasificacion = $${paramIndex}`);
            params.push(filters.clasificacion);
            paramIndex++;
        }
        
        if (filters.minMonto !== undefined) {
            whereConditions.push(`monto_total >= $${paramIndex}`);
            params.push(filters.minMonto);
            paramIndex++;
        }
        
        const whereClause = whereConditions.length > 0 
            ? `WHERE ${whereConditions.join(' AND ')}` 
            : '';
        
        const query = `
            SELECT * FROM vista_analisis_desempeno_usuarios 
            ${whereClause}
            ORDER BY monto_total DESC
        `;
        
        const result = await pool.query(query, params);
        
        const clientesActivos = result.rows.filter(r => r.clasificacion === 'Cliente Activo').length;
        const clientesInactivos = result.rows.filter(r => r.clasificacion === 'Cliente Inactivo').length;
        const totalEntregadas = result.rows.reduce((sum, r) => sum + parseInt(r.ordenes_entregadas || 0), 0);
        const totalCanceladas = result.rows.reduce((sum, r) => sum + parseInt(r.ordenes_canceladas || 0), 0);
        
        const destacado = {
            clientesActivos,
            clientesInactivos,
            totalOrdenesEntregadas: totalEntregadas,
            totalOrdenesCanceladas: totalCanceladas,
            tasaExito: totalEntregadas + totalCanceladas > 0 
                ? ((totalEntregadas / (totalEntregadas + totalCanceladas)) * 100).toFixed(1) + '%'
                : 'N/A'
        };
        
        return { data: result.rows, destacado };
    } catch (error) {
        console.error('Error al obtener vista_analisis_desempeno_usuarios', error);
        throw new Error('Error al obtener vista_analisis_desempeno_usuarios');
    }
}