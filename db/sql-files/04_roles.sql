-- ============================================
-- ROLES.SQL - Crear usuario con permisos limitados
-- ============================================
-- Las variables se sustituyen directamente por el shell
-- Después por sed desde 00_init.sh

-- Crear usuario de aplicación (si no existe)
-- {APP_USER}, {APP_PASSWORD}, {APP_DB} se reemplazan por shell

DO $$
BEGIN
    -- Crear usuario si no existe (manejo de excepciones)
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', 
        '{APP_USER}', 
        '{APP_PASSWORD}');
EXCEPTION 
    WHEN duplicate_object THEN
        -- Usuario ya existe, nada que hacer
        NULL;
END
$$;

-- Configurar permisos mínimos
ALTER USER {APP_USER} NOCREATEDB NOCREATEROLE NOSUPERUSER;

-- Otorgar permisos de conexión
GRANT CONNECT ON DATABASE {APP_DB} TO {APP_USER};

-- Otorgar USAGE en schema public
GRANT USAGE ON SCHEMA public TO {APP_USER};

-- Otorgar SELECT en las 5 vistas
GRANT SELECT ON vista_cat_promedio TO {APP_USER};
GRANT SELECT ON vista_ranking_usuarios_gastos TO {APP_USER};
GRANT SELECT ON vista_ordenes_por_status TO {APP_USER};
GRANT SELECT ON vista_productos_mas_vendidos TO {APP_USER};
GRANT SELECT ON vista_analisis_desempeno_usuarios TO {APP_USER};
