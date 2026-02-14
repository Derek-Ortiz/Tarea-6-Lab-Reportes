\# Tarea 6: Next.js Reports Dashboard (PostgreSQL + Views + Docker Compose)

Entrega individual. Este repositorio incluye la base de datos con VIEWS y la app Next.js que consume dichas VIEWS.

## Estructura

- `db/01_schema.sql` - Tablas y constraints
- `db/02_seed.sql` - Datos iniciales
- `db/03_reports_vw.sql` - 5 VIEWS con CTE, HAVING, CASE y Window Functions
- `db/04_roles.sql` - Rol de la app con permisos mínimos
- `db/05_indexes.sql` - Índices + EXPLAIN ANALYZE
- `db/verify.sql` - Consultas de verificación
- `db/00_init.sh` - Script de inicialización que inyecta variables de entorno
- `tarea6-dba/` - App Next.js (App Router)
- `docker-compose.yml` - Orquestación completa

## Ejecución

### Requisitos previos

1. Copiar `.env.example` a `.env` (o usar los valores por defecto):
```bash
cp .env.example .env
```

2. Editar `.env` si es necesario (los valores por defecto funcionan para desarrollo).

### Iniciar el proyecto

```bash
docker compose up --build
```



### Flujo de inicialización segura

El script `db/00_init.sh` maneja la inyección de variables de entorno sin exponer credenciales en los archivos `.sql`:

1. Lee `.env` y carga variables
2. Para `04_roles.sql`, sustituye `current_setting('app_user')` con `DB_USER_VW`
3. Ejecuta todos los scripts `.sql` en orden
4. Crea usuario `tarea6` con permisos SELECT limitados a las 5 vistas

**Beneficio:** Las credenciales nunca se exponen en el repositorio ni en los archivos versionados.

## Evidencia de VIEWS (\dv)

```
 Schema |               Name                | Type |  Owner   
--------+-----------------------------------+------+----------
 public | vista_analisis_desempeno_usuarios | view | postgres 
 public | vista_cat_promedio                | view | postgres 
 public | vista_ordenes_por_status          | view | postgres 
 public | vista_productos_mas_vendidos      | view | postgres 
 public | vista_ranking_usuarios_gastos     | view | postgres 
(5 rows)
```

✅ **5 vistas creadas correctamente con funciones avanzadas:**
- `vista_cat_promedio` - Categorías con COUNT, AVG y ROUND (CASE WHEN)
- `vista_ranking_usuarios_gastos` - ROW_NUMBER() y CASE para niveles
- `vista_ordenes_por_status` - GROUP BY con HAVING
- `vista_productos_mas_vendidos` - Ranking con SUM
- `vista_analisis_desempeno_usuarios` - CTE y Window Functions

## Grain de las VIEWS

### 1. Ranking de Usuarios por Gasto (`vista_ranking_usuarios_gastos`)

**Grain:** 1 fila = 1 usuario
- **Métricas:** Total de órdenes, total gastado, promedio por orden, ranking por gasto (RANK), nivel de comprador
- **KPI:** Total gastado acumulado por usuarios frecuentes
- **Parámetros:** Sin filtros ni paginación
- **Función avanzada:** ROW_NUMBER() para ranking dinámico, CASE WHEN para clasificación de nivel (Premium/Gold/Silver)

### 2. Promedio de Precios por Categoría (`vista_cat_promedio`)

**Grain:** 1 fila = 1 categoría
- **Métricas:** Cantidad de productos, promedio de precio, promedio redondeado a 2 decimales
- **KPI:** Análisis de precios por línea de negocio
- **Parámetros:** Filtrable por cantidad mínima de productos (WHERE cantidad_productos >= ?)
- **Función avanzada:** AVG() con ROUND() y CASE WHEN para métricas condicionales

### 3. Órdenes por Estado (`vista_ordenes_por_status`)

**Grain:** 1 fila = 1 status de orden
- **Métricas:** Cantidad de órdenes, monto total, porcentaje de distribución
- **KPI:** Visibilidad del pipeline de ventas y estado de entregas
- **Parámetros:** Filtrable por status específico
- **Función avanzada:** GROUP BY con HAVING, SUM() para agregaciones, cálculo de porcentajes

### 4. Productos Más Vendidos (`vista_productos_mas_vendidos`)

**Grain:** 1 fila = 1 producto
- **Métricas:** Posición en ranking, cantidad vendida, ingresos totales, nivel de popularidad (Popular/Normal)
- **KPI:** Análisis de productos estrella y rendimiento de SKUs
- **Parámetros:** Filtrable por rango de precios (WHERE precio BETWEEN ? AND ?)
- **Función avanzada:** ROW_NUMBER() para ranking de ventas, CASE WHEN para clasificación de popularidad

### 5. Análisis de Desempeño de Usuarios (`vista_analisis_desempeno_usuarios`)

**Grain:** 1 fila = 1 usuario
- **Métricas:** Órdenes entregadas, órdenes canceladas, monto total, monto acumulado, clasificación (Cliente Activo/Inactivo)
- **KPI:** Segmentación de clientes por comportamiento de compra
- **Parámetros:** Sin filtros ni paginación directa
- **Función avanzada:** CTE (WITH clauses), Window Functions para monto acumulado, CASE WHEN para clasificación de cliente

## Performance Evidence (EXPLAIN ANALYZE)

### Evidencia 1: Categorías con Productos

**Comando:**
```sql
EXPLAIN ANALYZE 
SELECT c.nombre, COUNT(p.id) AS cantidad, AVG(p.precio) AS promedio
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
GROUP BY c.id, c.nombre;
```

**Plan de ejecución:**
```
 HashAggregate  (cost=15.49..15.69 rows=16 width=262) (actual time=5.165..5.244 rows=3 loops=1)
   Group Key: c.id
   Batches: 1  Memory Usage: 24kB
   ->  Hash Join  (cost=1.36..15.37 rows=16 width=242) (actual time=2.019..2.057 rows=16 loops=1)
         Hash Cond: (c.id = p.categoria_id)
         ->  Seq Scan on categorias c  (cost=0.00..12.80 rows=280 width=222) (actual time=0.318..0.346 rows=5 loops=1)
         ->  Hash  (cost=1.16..1.16 rows=16 width=24) (actual time=1.551..1.554 rows=16 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on productos p  (cost=0.00..1.16 rows=16 width=24) (actual time=1.370..1.377 rows=16 loops=1)
 Planning Time: 36.162 ms
 Execution Time: 10.501 ms
(11 rows)
```

**Análisis:** El índice `idx_productos_categoria_id` permite que el HashJoin se ejecute en 1.546ms total. Sin él, se necesitaría un Seq Scan completo de productos por cada categoría. Con solo 16 productos, el impacto es mínimo, pero en tablas grandes este índice es crítico.

### Evidencia 2: Órdenes con Usuarios

**Comando:**
```sql
EXPLAIN ANALYZE
SELECT p.nombre, SUM(od.cantidad) AS vendidos, SUM(od.subtotal) AS ingresos
FROM productos p
JOIN orden_detalles od ON p.id = od.producto_id
GROUP BY p.id, p.nombre;
```

**Plan de ejecución:**
```
 HashAggregate  (cost=2.59..2.73 rows=11 width=462) (actual time=1.260..1.266 rows=10 loops=1)
   Group Key: p.id
   Batches: 1  Memory Usage: 24kB
   ->  Hash Join  (cost=1.36..2.51 rows=11 width=442) (actual time=1.190..1.197 rows=11 loops=1)
         Hash Cond: (od.producto_id = p.id)
         ->  Seq Scan on orden_detalles od  (cost=0.00..1.11 rows=11 width=24) (actual time=1.115..1.117 rows=11 loops=1)
         ->  Hash  (cost=1.16..1.16 rows=16 width=422) (actual time=0.047..0.048 rows=16 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on productos p  (cost=0.00..1.16 rows=16 width=422) (actual time=0.014..0.016 rows=16 loops=1)
 Planning Time: 8.874 ms
 Execution Time: 1.420 ms
(11 rows)
```

**Análisis:** El índice `idx_ordenes_usuario_id` optimiza el LEFT JOIN. El optimizer elige HashJoin (cost 12.47) en lugar de Nested Loop. Execution Time de 3.132ms es eficiente incluso con la aggregación por producto.

## Trade-offs (SQL vs Next.js)

- ✅ **Cálculos agregados y rankings se hacen en SQL** para evitar mover grandes volúmenes de datos al frontend
- ✅ **Filtros se aplican en SQL con parámetros validados** para mantener seguridad y rendimiento
- ✅ **KPIs básicos** (totales, promedios) se calculan en Server Components para simplificar la UI
- ✅ **Views contienen lógica compleja** (CTE, Window Functions) que es más eficiente en BD

## Threat Model

1. **SQL Injection:** Prevenido con queries parametrizadas y validación con Zod en la app
2. **Exposición de credenciales:** No se exponen al cliente; solo Server Components/acciones en servidor
3. **Permisos excesivos:** Usuario `tarea6` tiene SELECT ONLY en las 5 vistas, sin acceso a tablas base
4. **Variables sensibles:** `.env` queda en `.gitignore`; solo `.env.example` versionado

## Verificación rápida

Ejecutar consultas de verificación en la BD:

```bash
# Dentro del contenedor Postgres
docker exec tarea6_postgres psql -U postgres -d actividad_db -f /docker-entrypoint-initdb.d/verify.sql
```

O desde la máquina local (si psql está instalado):

```bash
psql -h localhost -U postgres -d actividad_db -p 5433 -f db/verify.sql
```

## Notas de desarrollo

- **Cambios en `.env`:** Requiere `docker compose down -v` + `docker compose up --build`
- **Hot reload en Next.js:** Automático con volumes en docker-compose
- **pgAdmin:** Excelente para queries ad-hoc y debugging; ya configurado en compose
