import { z } from 'zod';


export const categoriaFilterSchema = z.object({
    minProductos: z.number().min(0).max(100).optional().default(2),
    orderBy: z.enum(['promedio_precio', 'cantidad_productos', 'nombre']).optional().default('promedio_precio'),
    orderDir: z.enum(['ASC', 'DESC']).optional().default('DESC'),
});

export const paginationSchema = z.object({
    page: z.number().min(1).optional().default(1),
    limit: z.number().min(1).max(100).optional().default(10),
});

export const rankingFilterSchema = z.object({
    nivelComprador: z.enum(['Premium', 'Gold', 'Silver', 'todos']).optional().default('todos'),
    minGasto: z.number().min(0).optional(),
    maxGasto: z.number().min(0).optional(),
}).merge(paginationSchema);

export const ordenesStatusFilterSchema = z.object({
    status: z.enum(['pendiente', 'pagado', 'enviado', 'entregado', 'cancelado', 'todos']).optional().default('todos'),
}).merge(paginationSchema);

export const productosVendidosFilterSchema = z.object({
    minVentas: z.number().min(1).optional().default(1),
    popularidad: z.enum(['Muy Popular', 'Popular', 'todos']).optional().default('todos'),
}).merge(paginationSchema);

export const analisisDesempenoFilterSchema = z.object({
    clasificacion: z.enum(['Cliente Activo', 'Cliente Inactivo', 'todos']).optional().default('todos'),
    minMonto: z.number().min(0).optional(),
}).merge(paginationSchema);

export type CategoriaFilter = z.infer<typeof categoriaFilterSchema>;
export type PaginationParams = z.infer<typeof paginationSchema>;
export type RankingFilter = z.infer<typeof rankingFilterSchema>;
export type OrdenesStatusFilter = z.infer<typeof ordenesStatusFilterSchema>;
export type ProductosVendidosFilter = z.infer<typeof productosVendidosFilterSchema>;
export type AnalisisDesempenoFilter = z.infer<typeof analisisDesempenoFilterSchema>;
