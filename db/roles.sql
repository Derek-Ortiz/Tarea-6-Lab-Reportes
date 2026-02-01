\c actividad_db

CREATE USER tarea6 WITH PASSWORD 't4r34s313s';

ALTER USER tarea6 NOCREATEDB NOCREATEROLE NOSUPERUSER NOINHERIT NOBYPASSRLS;

GRANT CONNECT ON DATABASE actividad_db TO tarea6;

GRANT USAGE ON SCHEMA public TO tarea6;

GRANT SELECT ON vista_cat_promedio TO tarea6;
GRANT SELECT ON vista_ranking_usuarios_gastos TO tarea6;
GRANT SELECT ON vista_ordenes_por_status TO tarea6;
GRANT SELECT ON vista_productos_mas_vendidos TO tarea6;
GRANT SELECT ON vista_analisis_desempeño_usuarios TO tarea6;
