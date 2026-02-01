/*
View numero : 1
-- Que devuelve: Promedio de precios por categoría
-- Grain: Una fila representa una categoría
-- Metricas: AVG, COUNT
-- Por qué usa GROUP BY/HAVING: Agrupa por categoría y filtra las que tienen más de 2 productos
*/

CREATE VIEW vista_cat_promedio AS
SELECT 
    c.nombre,
    COUNT(p.id) AS cantidad_productos,
    AVG(p.precio) AS promedio_precio,
    ROUND(AVG(p.precio), 2) AS promedio_redondeado
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
GROUP BY c.id, c.nombre
HAVING COUNT(p.id) > 2
ORDER BY promedio_precio DESC;

-- VERIFY 1: Ver todas las categorías con sus promedios
SELECT * FROM vista_cat_promedio;

-- VERIFY 2: Confirmar que Electrónica tiene 5 productos con promedio ~555.99
SELECT nombre, cantidad_productos, promedio_redondeado 
FROM vista_cat_promedio 
WHERE nombre = 'Electrónica';


/*
View numero : 2
-- Que devuelve: Ranking de usuarios por total gastado con clasificación de nivel
-- Grain: Una fila representa un usuario
-- Metricas: SUM, COUNT, RANK (Window Function)
-- Por qué usa GROUP BY/HAVING: Agrupa por usuario y filtra los que tienen más de 0 órdenes
*/

CREATE VIEW vista_ranking_usuarios_gastos AS
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

-- VERIFY 1: Ver ranking completo de usuarios
SELECT * FROM vista_ranking_usuarios_gastos;

-- VERIFY 2: Confirmar que Margaret está en primer lugar con 1299.99
SELECT nombre, gasto_total, ranking_gastos, nivel_comprador 
FROM vista_ranking_usuarios_gastos 
WHERE ranking_gastos = 1;


/*
View numero : 3
-- Que devuelve: Órdenes por status con conteo y porcentaje de distribución
-- Grain: Una fila representa un status de orden
-- Metricas: COUNT, SUM, Porcentaje calculado
-- Por qué usa GROUP BY/HAVING: Agrupa por status y filtra los que tienen más de 0 órdenes
*/

CREATE VIEW vista_ordenes_por_status AS
SELECT 
    o.status,
    COUNT(o.id) AS cantidad_ordenes,
    SUM(o.total) AS monto_total,
    ROUND(COUNT(o.id) * 100.0 / SUM(COUNT(o.id)) OVER (), 2) AS porcentaje_distribucion
FROM ordenes o
GROUP BY o.status
HAVING COUNT(o.id) > 0
ORDER BY cantidad_ordenes DESC;

-- VERIFY 1: Ver distribución de órdenes por status
SELECT * FROM vista_ordenes_por_status;

-- VERIFY 2: Confirmar que 'pagado' tiene 3 órdenes (33.33%)
SELECT status, cantidad_ordenes, porcentaje_distribucion 
FROM vista_ordenes_por_status 
WHERE status = 'pagado';


/*
View numero : 4
-- Que devuelve: Productos más vendidos con estado de inventario
-- Grain: Una fila representa un producto
-- Metricas: SUM (cantidad vendida), Window Function ROW_NUMBER
-- Por qué usa GROUP BY/HAVING: Agrupa por producto y filtra los vendidos más de 1 vez
*/

CREATE VIEW vista_productos_mas_vendidos AS
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

-- VERIFY 1: Ver productos más vendidos
SELECT * FROM vista_productos_mas_vendidos;

-- VERIFY 2: Confirmar que Camiseta Básica está en primer lugar con 2 ventas
SELECT posicion_ventas, nombre, cantidad_vendida 
FROM vista_productos_mas_vendidos 
WHERE nombre = 'Camiseta Básica';


/*
View numero : 5
-- Que devuelve: Análisis de desempeño de usuarios por estado de órdenes
-- Grain: Una fila representa un usuario
-- Metricas: COUNT con CASE, AVG, Window Function SUM OVER
-- Por qué usa GROUP BY/HAVING: Agrupa por usuario y filtra los que tienen órdenes entregadas
*/

CREATE VIEW vista_analisis_desempeño_usuarios AS
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

-- VERIFY 1: Ver análisis de desempeño de usuarios
SELECT * FROM vista_analisis_desempeño_usuarios;

-- VERIFY 2: Confirmar que Ada tiene 1 orden entregada
SELECT nombre, ordenes_entregadas, monto_total, clasificacion 
FROM vista_analisis_desempeño_usuarios 
WHERE nombre = 'Ada Lovelace';  