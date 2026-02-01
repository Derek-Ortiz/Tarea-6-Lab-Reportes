This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

# Base de Datos - Tarea 6 DBA

## Estructura de Archivos

| Archivo | Descripción |
|---------|-------------|
| `schema.sql` | Definición de tablas y estructura de la base de datos |
| `seed.sql` | Datos iniciales para pruebas |
| `reports_vw.sql` | Vistas SQL para los reportes |
| `roles.sql` | Definición de roles y permisos |
| `indexes.sql` | Índices de optimización con justificaciones |
| `migrate.sql` | Script de migración |
| `verify.sql` | Scripts de verificación |

## Índices de Optimización

### Justificación de Índices

Los índices fueron creados para optimizar las consultas de las vistas de reportes. A continuación se detalla cada índice y su propósito:

#### 1. `idx_productos_categoria_id`
- **Tabla:** `productos`
- **Columna:** `categoria_id`
- **Propósito:** Optimiza el JOIN entre `productos` y `categorias` en la vista `vista_cat_promedio`
- **Beneficio:** Reduce el tiempo de búsqueda de O(n) a O(log n) para encontrar productos por categoría

#### 2. `idx_ordenes_usuario_id`
- **Tabla:** `ordenes`
- **Columna:** `usuario_id`
- **Propósito:** Acelera los JOINs con la tabla `usuarios` en múltiples vistas
- **Beneficio:** Mejora significativamente las consultas de ranking y análisis de usuarios

#### 3. `idx_ordenes_status`
- **Tabla:** `ordenes`
- **Columna:** `status`
- **Propósito:** Optimiza el agrupamiento por status en `vista_ordenes_por_status`
- **Beneficio:** Permite filtrado eficiente por estado de orden

#### 4. `idx_orden_detalles_producto_id`
- **Tabla:** `orden_detalles`
- **Columna:** `producto_id`
- **Propósito:** Acelera el JOIN para calcular productos más vendidos
- **Beneficio:** Mejora el rendimiento del reporte de productos populares

#### 5. `idx_orden_detalles_orden_id`
- **Tabla:** `orden_detalles`
- **Columna:** `orden_id`
- **Propósito:** Permite localizar rápidamente los ítems de una orden
- **Beneficio:** Optimiza consultas de detalle de órdenes individuales

#### 6. `idx_ordenes_usuario_status` (Índice Compuesto)
- **Tabla:** `ordenes`
- **Columnas:** `usuario_id`, `status`
- **Propósito:** Optimiza consultas que filtran por usuario Y status simultáneamente
- **Beneficio:** Más eficiente que usar dos índices separados para este patrón de consulta

#### 7. `idx_productos_precio`
- **Tabla:** `productos`
- **Columna:** `precio`
- **Propósito:** Facilita filtros y ordenamientos por precio
- **Beneficio:** Permite búsquedas por rango de precio eficientes

### Análisis de Rendimiento (EXPLAIN)

Cada índice incluye un `EXPLAIN ANALYZE` en el archivo `indexes.sql` para demostrar su efectividad. Los resultados típicos muestran:

- **Sin índice:** `Seq Scan` con costo alto
- **Con índice:** `Index Scan` con costo reducido significativamente

### Cuándo usar cada tipo de índice

| Tipo de Índice | Uso Recomendado |
|----------------|-----------------|
| B-tree (default) | Comparaciones de igualdad y rango |
| Compuesto | Consultas que filtran por múltiples columnas |
| Parcial | Cuando solo un subconjunto de filas necesita indexarse |

## Ejecución

Para ejecutar los scripts en orden:

```bash
psql -U postgres -d actividad_db -f schema.sql
psql -U postgres -d actividad_db -f seed.sql
psql -U postgres -d actividad_db -f reports_vw.sql
psql -U postgres -d actividad_db -f roles.sql
psql -U postgres -d actividad_db -f indexes.sql
```