-- ============================================
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
