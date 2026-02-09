-- ============================================
-- ROLES.SQL - Crear usuario con permisos limitados
-- ============================================

-- Crear usuario de aplicación (si no existe)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USER_VW}') THEN
        CREATE USER ${DB_USER_VW} WITH PASSWORD '${DB_PASSWORD_VW}';
    END IF;
END
$$;

-- Configurar permisos mínimos (sin privilegios de admin)
ALTER USER ${DB_USER_VW} NOCREATEDB NOCREATEROLE NOSUPERUSER;

-- Otorgar permisos de conexión a la base de datos
GRANT CONNECT ON DATABASE actividad_db TO ${DB_USER_VW};

-- Otorgar USAGE en el schema public
GRANT USAGE ON SCHEMA public TO ${DB_USER_VW};

-- Otorgar SELECT SOLO en las 5 vistas específicas
GRANT SELECT ON vista_cat_promedio TO ${DB_USER_VW};
GRANT SELECT ON vista_ranking_usuarios_gastos TO ${DB_USER_VW};
GRANT SELECT ON vista_ordenes_por_status TO ${DB_USER_VW};
GRANT SELECT ON vista_productos_mas_vendidos TO ${DB_USER_VW};
GRANT SELECT ON vista_analisis_desempeno_usuarios TO ${DB_USER_VW};
