/*
View numero : 1
-- Que devuelve: Promedio de precios por categoría
-- Grain: Una fila representa una categoría
-- Metricas: AVG, COUNT
-- Por qué usa GROUP BY/HAVING: Agrupa por categoría y filtra las que tienen más de 2 productos
*/

CREATE OR REPLACE VIEW vista_cat_promedio AS
SELECT 
    c.nombre,
    COUNT(p.id) AS cantidad_productos,
    AVG(p.precio) AS promedio_precio,
    ROUND(AVG(p.precio)::numeric, 2) AS promedio_redondeado
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
GROUP BY c.id, c.nombre
HAVING COUNT(p.id) > 2
ORDER BY promedio_precio DESC;

-- VERIFY 1: Verificar directamente desde las tablas base (sin usar el VIEW)
SELECT 
    c.nombre,
    COUNT(p.id) AS cantidad_productos,
    ROUND(AVG(p.precio)::numeric, 2) AS promedio_redondeado
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
GROUP BY c.id, c.nombre
HAVING COUNT(p.id) > 2
ORDER BY AVG(p.precio) DESC;

-- VERIFY 2: Confirmar que Electrónica tiene más de 2 productos con su promedio
SELECT 
    c.nombre,
    COUNT(p.id) AS cantidad_productos,
    ROUND(AVG(p.precio)::numeric, 2) AS promedio_precio
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE c.nombre = 'Electrónica'
GROUP BY c.id, c.nombre;


/*
View numero : 2
-- Que devuelve: Ranking de usuarios por total gastado con clasificación de nivel
-- Grain: Una fila representa un usuario
-- Metricas: SUM, COUNT, RANK (Window Function)
-- Por qué usa GROUP BY/HAVING: Agrupa por usuario y filtra los que tienen más de 0 órdenes
*/

CREATE OR REPLACE VIEW vista_ranking_usuarios_gastos AS
SELECT 
    u.nombre,
    COUNT(o.id) AS total_ordenes,
    SUM(o.total) AS gasto_total,
    RANK() OVER (ORDER BY SUM(o.total) DESC) AS ranking_gastos,
    CASE 
        WHEN SUM(o.total) > 1000 THEN 'Premium'
        WHEN SUM(o.total) > 200 THEN 'Gold'
        ELSE 'Silver'
    END AS nivel_comprador
FROM usuarios u
LEFT JOIN ordenes o ON u.id = o.usuario_id
GROUP BY u.id, u.nombre
HAVING COUNT(o.id) > 0
ORDER BY ranking_gastos;

-- VERIFY 1: Verificar ranking directamente desde tablas base
SELECT 
    u.nombre,
    COUNT(o.id) AS total_ordenes,
    SUM(o.total) AS gasto_total
FROM usuarios u
LEFT JOIN ordenes o ON u.id = o.usuario_id
GROUP BY u.id, u.nombre
HAVING COUNT(o.id) > 0
ORDER BY SUM(o.total) DESC;

-- VERIFY 2: Confirmar el usuario con mayor gasto
SELECT 
    u.nombre,
    SUM(o.total) AS gasto_total
FROM usuarios u
JOIN ordenes o ON u.id = o.usuario_id
GROUP BY u.id, u.nombre
ORDER BY gasto_total DESC
LIMIT 1;


/*
View numero : 3
-- Que devuelve: Órdenes por status con conteo y porcentaje de distribución
-- Grain: Una fila representa un status de orden
-- Metricas: COUNT, SUM, Porcentaje calculado
-- Por qué usa GROUP BY/HAVING: Agrupa por status y filtra los que tienen más de 0 órdenes
*/

CREATE OR REPLACE VIEW vista_ordenes_por_status AS
SELECT 
    o.status,
    COUNT(o.id) AS cantidad_ordenes,
    SUM(o.total) AS monto_total,
    ROUND(COUNT(o.id) * 100.0 / SUM(COUNT(o.id)) OVER (), 2) AS porcentaje_distribucion
FROM ordenes o
GROUP BY o.status
HAVING COUNT(o.id) > 0
ORDER BY cantidad_ordenes DESC;

-- VERIFY 1: Verificar conteo por status directamente
SELECT 
    status,
    COUNT(*) AS cantidad_ordenes,
    SUM(total) AS monto_total
FROM ordenes
GROUP BY status
ORDER BY cantidad_ordenes DESC;

-- VERIFY 2: Verificar el total de órdenes para calcular porcentajes
SELECT 
    COUNT(*) AS total_ordenes,
    SUM(total) AS monto_total_general
FROM ordenes;


/*
View numero : 4
-- Que devuelve: Productos más vendidos con estado de inventario
-- Grain: Una fila representa un producto
-- Metricas: SUM (cantidad vendida), Window Function ROW_NUMBER
-- Por qué usa GROUP BY/HAVING: Agrupa por producto y filtra los vendidos más de 1 vez
*/

CREATE OR REPLACE VIEW vista_productos_mas_vendidos AS
WITH productos_vendidos AS (
    SELECT 
        p.nombre,
        SUM(od.cantidad) AS cantidad_vendida,
        SUM(od.subtotal) AS ingresos_totales,
        ROW_NUMBER() OVER (ORDER BY SUM(od.cantidad) DESC) AS posicion_ventas
    FROM productos p
    JOIN orden_detalles od ON p.id = od.producto_id
    GROUP BY p.id, p.nombre
    HAVING SUM(od.cantidad) > 1
)
SELECT 
    posicion_ventas,
    nombre,
    cantidad_vendida,
    ingresos_totales,
    CASE 
        WHEN cantidad_vendida > 2 THEN 'Muy Popular'
        ELSE 'Popular'
    END AS popularidad
FROM productos_vendidos
ORDER BY posicion_ventas;

-- VERIFY 1: Verificar ventas por producto directamente
SELECT 
    p.nombre,
    SUM(od.cantidad) AS cantidad_vendida,
    SUM(od.subtotal) AS ingresos_totales
FROM productos p
JOIN orden_detalles od ON p.id = od.producto_id
GROUP BY p.id, p.nombre
HAVING SUM(od.cantidad) > 1
ORDER BY cantidad_vendida DESC;

-- VERIFY 2: Confirmar el producto más vendido
SELECT 
    p.nombre,
    SUM(od.cantidad) AS cantidad_vendida
FROM productos p
JOIN orden_detalles od ON p.id = od.producto_id
GROUP BY p.id, p.nombre
ORDER BY cantidad_vendida DESC
LIMIT 1;


/*
View numero : 5
-- Que devuelve: Análisis de desempeño de usuarios por estado de órdenes
-- Grain: Una fila representa un usuario
-- Metricas: COUNT con CASE, AVG, Window Function SUM OVER
-- Por qué usa GROUP BY/HAVING: Agrupa por usuario y filtra los que tienen órdenes entregadas
*/

CREATE OR REPLACE VIEW vista_analisis_desempeno_usuarios AS
SELECT 
    u.nombre,
    COUNT(CASE WHEN o.status = 'entregado' THEN 1 END) AS ordenes_entregadas,
    COUNT(CASE WHEN o.status = 'cancelado' THEN 1 END) AS ordenes_canceladas,
    COALESCE(SUM(o.total), 0) AS monto_total,
    SUM(SUM(o.total)) OVER (ORDER BY u.id) AS monto_acumulado,
    CASE 
        WHEN COUNT(CASE WHEN o.status = 'entregado' THEN 1 END) > 0 THEN 'Cliente Activo'
        ELSE 'Cliente Inactivo'
    END AS clasificacion
FROM usuarios u
LEFT JOIN ordenes o ON u.id = o.usuario_id
GROUP BY u.id, u.nombre
HAVING COUNT(CASE WHEN o.status IN ('entregado', 'pagado', 'enviado') THEN 1 END) > 0
ORDER BY monto_total DESC;

-- VERIFY 1: Verificar conteo de órdenes por usuario y status
SELECT 
    u.nombre,
    o.status,
    COUNT(*) AS cantidad
FROM usuarios u
JOIN ordenes o ON u.id = o.usuario_id
GROUP BY u.nombre, o.status
ORDER BY u.nombre;

-- VERIFY 2: Verificar usuarios con órdenes entregadas
SELECT 
    u.nombre,
    COUNT(*) AS ordenes_entregadas
FROM usuarios u
JOIN ordenes o ON u.id = o.usuario_id
WHERE o.status = 'entregado'
GROUP BY u.nombre;-- ============================================
-- ROLES.SQL - Crear usuario con permisos limitados
-- ============================================

-- Crear usuario de aplicación (si no existe)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'tarea6') THEN
        CREATE USER tarea6 WITH PASSWORD 't4r34s313s';
    END IF;
END
$$;

-- Configurar permisos mínimos (sin privilegios de admin)
ALTER USER tarea6 NOCREATEDB NOCREATEROLE NOSUPERUSER;

-- Otorgar permisos de conexión a la base de datos
GRANT CONNECT ON DATABASE actividad_db TO tarea6;

-- Otorgar USAGE en el schema public
GRANT USAGE ON SCHEMA public TO tarea6;

-- Otorgar SELECT SOLO en las 5 vistas específicas
GRANT SELECT ON vista_cat_promedio TO tarea6;
GRANT SELECT ON vista_ranking_usuarios_gastos TO tarea6;
GRANT SELECT ON vista_ordenes_por_status TO tarea6;
GRANT SELECT ON vista_productos_mas_vendidos TO tarea6;
GRANT SELECT ON vista_analisis_desempeño_usuarios TO tarea6;
