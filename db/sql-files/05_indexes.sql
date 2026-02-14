-- ============================================================================
-- ÍNDICES PARA OPTIMIZACIÓN DE CONSULTAS
-- ============================================================================
-- Este archivo contiene los índices necesarios para optimizar las consultas
-- de los reportes definidos en las vistas del sistema.
-- ============================================================================

-- ============================================================================
-- ÍNDICE 1: idx_productos_categoria_id
-- ============================================================================
-- JUSTIFICACIÓN:
-- La vista 'vista_cat_promedio' realiza un JOIN entre productos y categorias
-- usando la columna categoria_id. Este índice acelera significativamente
-- la búsqueda de productos por categoría, especialmente cuando hay muchos
-- productos en la base de datos.
-- 
-- CONSULTA BENEFICIADA:
-- SELECT c.nombre, COUNT(p.id), AVG(p.precio)
-- FROM productos p JOIN categorias c ON p.categoria_id = c.id
-- GROUP BY c.id, c.nombre
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_productos_categoria_id ON productos(categoria_id);

-- EXPLAIN ANALYZE de la consulta antes del índice (comentado para referencia):
-- Sin índice: Seq Scan on productos (cost estimado más alto)
-- Con índice: Index Scan using idx_productos_categoria_id (cost reducido)

EXPLAIN ANALYZE 
SELECT c.nombre, COUNT(p.id) AS cantidad, AVG(p.precio) AS promedio
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
GROUP BY c.id, c.nombre;


-- ============================================================================
-- ÍNDICE 2: idx_ordenes_usuario_id
-- ============================================================================
-- JUSTIFICACIÓN:
-- Las vistas 'vista_ranking_usuarios_gastos' y 'vista_analisis_desempeno_usuarios'
-- realizan JOINs frecuentes entre usuarios y ordenes usando usuario_id.
-- Este índice optimiza estas operaciones de JOIN y las agregaciones por usuario.
--
-- CONSULTAS BENEFICIADAS:
-- - Ranking de usuarios por gastos
-- - Análisis de desempeño de usuarios
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_ordenes_usuario_id ON ordenes(usuario_id);

EXPLAIN ANALYZE
SELECT u.nombre, COUNT(o.id), SUM(o.total)
FROM usuarios u
LEFT JOIN ordenes o ON u.id = o.usuario_id
GROUP BY u.id, u.nombre;


-- ============================================================================
-- ÍNDICE 3: idx_ordenes_status
-- ============================================================================
-- JUSTIFICACIÓN:
-- La vista 'vista_ordenes_por_status' agrupa órdenes por status.
-- Este índice permite agrupar y filtrar eficientemente por el campo status,
-- especialmente útil cuando se filtran reportes por estados específicos.
--
-- CONSULTA BENEFICIADA:
-- SELECT status, COUNT(*), SUM(total) FROM ordenes GROUP BY status
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_ordenes_status ON ordenes(status);

EXPLAIN ANALYZE
SELECT status, COUNT(*) AS cantidad, SUM(total) AS monto
FROM ordenes
GROUP BY status;


-- ============================================================================
-- ÍNDICE 4: idx_orden_detalles_producto_id
-- ============================================================================
-- JUSTIFICACIÓN:
-- La vista 'vista_productos_mas_vendidos' realiza un JOIN entre productos
-- y orden_detalles para calcular las cantidades vendidas. Este índice
-- acelera la búsqueda de detalles de orden por producto.
--
-- CONSULTA BENEFICIADA:
-- SELECT p.nombre, SUM(od.cantidad), SUM(od.subtotal)
-- FROM productos p JOIN orden_detalles od ON p.id = od.producto_id
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_orden_detalles_producto_id ON orden_detalles(producto_id);

EXPLAIN ANALYZE
SELECT p.nombre, SUM(od.cantidad) AS vendidos, SUM(od.subtotal) AS ingresos
FROM productos p
JOIN orden_detalles od ON p.id = od.producto_id
GROUP BY p.id, p.nombre;


-- ============================================================================
-- ÍNDICE 5: idx_orden_detalles_orden_id
-- ============================================================================
-- JUSTIFICACIÓN:
-- Cuando se consultan los detalles de una orden específica o se realizan
-- JOINs con la tabla ordenes, este índice permite localizar rápidamente
-- todos los ítems de una orden.
--
-- CONSULTA BENEFICIADA:
-- Consultas que buscan detalles de órdenes específicas
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_orden_detalles_orden_id ON orden_detalles(orden_id);

EXPLAIN ANALYZE
SELECT od.*, p.nombre
FROM orden_detalles od
JOIN productos p ON od.producto_id = p.id
WHERE od.orden_id = 1;


-- ============================================================================
-- ÍNDICE 6: idx_ordenes_usuario_status (Índice compuesto)
-- ============================================================================
-- JUSTIFICACIÓN:
-- La vista 'vista_analisis_desempeno_usuarios' filtra por usuario y status
-- simultáneamente. Un índice compuesto es más eficiente que dos índices
-- separados para este tipo de consultas.
--
-- CONSULTA BENEFICIADA:
-- Análisis de órdenes por usuario y estado
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_ordenes_usuario_status ON ordenes(usuario_id, status);

EXPLAIN ANALYZE
SELECT u.nombre, o.status, COUNT(*)
FROM usuarios u
JOIN ordenes o ON u.id = o.usuario_id
GROUP BY u.nombre, o.status;


-- ============================================================================
-- ÍNDICE 7: idx_productos_precio
-- ============================================================================
-- JUSTIFICACIÓN:
-- Útil para consultas que filtran o ordenan productos por precio,
-- como buscar productos en un rango de precios específico o calcular
-- promedios con filtros de precio.
--
-- CONSULTA BENEFICIADA:
-- Filtros y ordenamientos por precio
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_productos_precio ON productos(precio);

EXPLAIN ANALYZE
SELECT nombre, precio
FROM productos
WHERE precio BETWEEN 100 AND 500
ORDER BY precio;
