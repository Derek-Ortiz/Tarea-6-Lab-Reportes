-- ============================================
-- ROLES.SQL - Crear usuario con permisos limitados
-- ============================================
-- Variables que se sustituyen desde 00_init.sh:
--   current_setting('app_user') -> DB_USER_VW
--   current_setting('app_password') -> DB_PASSWORD_VW
--   current_setting('app_db') -> DB_NAME

-- Crear usuario de aplicación (si no existe)
DO $$
BEGIN
    -- Crear usuario si no existe
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = current_setting('app_user')) THEN
        EXECUTE format('CREATE USER %I WITH PASSWORD %L', 
            current_setting('app_user'), 
            current_setting('app_password'));
    END IF;
    
    -- Configurar permisos mínimos
    EXECUTE format('ALTER USER %I NOCREATEDB NOCREATEROLE NOSUPERUSER', 
        current_setting('app_user'));
    
    -- Otorgar permisos de conexión
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO %I', 
        current_setting('app_db'), 
        current_setting('app_user'));
    
    -- Otorgar USAGE en schema public
    EXECUTE format('GRANT USAGE ON SCHEMA public TO %I', 
        current_setting('app_user'));
    
    -- Otorgar SELECT en las 5 vistas
    EXECUTE format('GRANT SELECT ON vista_cat_promedio TO %I', 
        current_setting('app_user'));
    EXECUTE format('GRANT SELECT ON vista_ranking_usuarios_gastos TO %I', 
        current_setting('app_user'));
    EXECUTE format('GRANT SELECT ON vista_ordenes_por_status TO %I', 
        current_setting('app_user'));
    EXECUTE format('GRANT SELECT ON vista_productos_mas_vendidos TO %I', 
        current_setting('app_user'));
    EXECUTE format('GRANT SELECT ON vista_analisis_desempeno_usuarios TO %I', 
        current_setting('app_user'));
        
    RAISE NOTICE 'User % created and permissions granted', current_setting('app_user');
END
$$;
