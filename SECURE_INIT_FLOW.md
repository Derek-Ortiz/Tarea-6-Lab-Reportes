# Flujo seguro de inicialización de BD con inyección de variables

## Problema original
Los archivos `.sql` ejecutados por Postgres al inicializar un contenedor necesitaban variables como `DB_USER_VW` y `DB_PASSWORD_VW`. Las opciones tradicionales exponían credenciales:

1. **Renderizar .sql con sed/envsubst** → Credenciales en archivos versionados ❌
2. **Pasar variables como -v de psql** → Sintaxis de psql (`:'var'`) no funciona dentro de bloques PL/pgSQL ❌
3. **Hardcodear credenciales** → Seguridad comprometida ❌

## Solución implementada

### Componentes

1. **`db/00_init.sh`** - Script de inicialización
   - Se ejecuta PRIMERO al iniciar Postgres (nombre alfabético: `00_`)
   - Lee `.env` desde el contenedor (montado vía `docker-compose.yml`)
   - Para `04_roles.sql`, sustituye `current_setting('app_user')` con el valor real
   - Ejecuta scripts en orden: `01_schema.sql`, `02_seed.sql`, `03_reports_vw.sql`, `04_roles.sql`, `05_indexes.sql`

2. **`db/04_roles.sql`** - Uses `current_setting()` placeholders
   ```sql
   DO $$
   BEGIN
       IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles 
                      WHERE rolname = current_setting('app_user')) THEN
           EXECUTE format('CREATE USER %I WITH PASSWORD %L', 
               current_setting('app_user'), 
               current_setting('app_password'));
       END IF;
   ...
   ```

3. **`docker-compose.yml`** - Monta todo el directorio `db/`
   ```yaml
   volumes:
     - ./db:/docker-entrypoint-initdb.d:ro
   ```

### Flujo de ejecución

```
1. docker compose up --build
   ├─ Postgres: Init database
   │  └─ /docker-entrypoint-initdb.d/00_init.sh (alfabéticamente primero)
   │     ├─ Lee .env (DB_USER_VW=tarea6, etc.)
   │     ├─ Ejecuta 01_schema.sql
   │     ├─ Ejecuta 02_seed.sql
   │     ├─ Ejecuta 03_reports_vw.sql
   │     ├─ Ejecuta 04_roles.sql (con sustitución de variables)
   │     │  └─ Sustituye current_setting('app_user') → 'tarea6'
   │     │  └─ Crea usuario tarea6 con permisos limitados
   │     └─ Ejecuta 05_indexes.sql
   │
   ├─ Next.js: Inicia app
   └─ pgAdmin: Inicia interfaz
```

## Beneficios de seguridad

| Aspecto | Solución |
|---------|----------|
| **Credenciales expuestas en .git** | ✅ `.env` en `.gitignore`; solo `.env.example` versionado |
| **Credenciales en archivos .sql** | ✅ `db/04_roles.sql` usa placeholders `current_setting()` |
| **Sincronización de variables** | ✅ Todas desde `.env`, única fuente de verdad |
| **Reproducibilidad** | ✅ Mismo flujo en dev y prod (solo cambiar `.env`) |

## Modificar credenciales

Para cambiar credenciales:

1. Editar `.env`:
   ```env
   DB_USER_VW=new_user
   DB_PASSWORD_VW=new_secure_password
   ```

2. Detener y limpiar volumen:
   ```bash
   docker compose down -v
   ```

3. Reiniciar:
   ```bash
   docker compose up --build
   ```

El script `00_init.sh` reejecutará todo con los nuevos valores.

## Troubleshooting

**Error: "syntax error at or near ':'**
- Causa: Sintaxis de psql (`:'var'`) usada dentro de `DO $$...$$`
- Solución: Usar `current_setting('app_user')` + sustitución en el shell

**Error: "Role 'tarea6' does not exist"**
- Causa: `04_roles.sql` no se ejecutó o falló
- Solución: Revisar logs con `docker compose logs tarea6_postgres`

**Cambios en .env no aplican**
- Causa: Volumen de Postgres persiste (`postgres_data`)
- Solución: `docker compose down -v` (destruye volumen) + `docker compose up`
