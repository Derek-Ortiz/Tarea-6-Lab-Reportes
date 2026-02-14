#!/bin/sh
set -e

echo "=========================================="
echo "INICIALIZACIÓN DE BASE DE DATOS"
echo "=========================================="
echo ""

# Verificar que las variables requeridas están definidas
echo "[1/6] Verificando variables de entorno..."
MISSING_VARS=""

if [ -z "$DB_USER" ]; then
    echo "✗ ERROR: DB_USER no está definido"
    MISSING_VARS="$MISSING_VARS DB_USER"
fi

if [ -z "$DB_PASSWORD" ]; then
    echo "✗ ERROR: DB_PASSWORD no está definido"
    MISSING_VARS="$MISSING_VARS DB_PASSWORD"
fi

if [ -z "$DB_NAME" ]; then
    echo "✗ ERROR: DB_NAME no está definido"
    MISSING_VARS="$MISSING_VARS DB_NAME"
fi

if [ -z "$DB_USER_VW" ]; then
    echo "✗ ERROR: DB_USER_VW no está definido"
    MISSING_VARS="$MISSING_VARS DB_USER_VW"
fi

if [ -z "$DB_PASSWORD_VW" ]; then
    echo "✗ ERROR: DB_PASSWORD_VW no está definido"
    MISSING_VARS="$MISSING_VARS DB_PASSWORD_VW"
fi

if [ ! -z "$MISSING_VARS" ]; then
    echo ""
    echo "=========================================="
    echo "✗ FATAL: Variables faltantes:$MISSING_VARS"
    echo "=========================================="
    exit 1
fi

echo "✓ Todas las variables están definidas"
echo ""

# Mostrar configuración (sin exponer contraseñas)
echo "[2/6] Configuración detectada:"
echo "  - Base de datos: $DB_NAME"
echo "  - Usuario admin: $DB_USER"
echo "  - Usuario app: $DB_USER_VW"
echo "  - Script dir: /docker-entrypoint-initdb.d/sql-files"
echo ""

SCRIPT_DIR="/docker-entrypoint-initdb.d/sql-files"
SQL_FILES="01_schema.sql 02_seed.sql 03_reports_vw.sql 04_roles.sql 05_indexes.sql"

# Ejecutar scripts SQL
echo "[3/6] Ejecutando scripts SQL..."
for file in $SQL_FILES; do
    filepath="$SCRIPT_DIR/$file"

    if [ ! -f "$filepath" ]; then
        echo "✗ ADVERTENCIA: Archivo no encontrado: $file"
        continue
    fi

    echo "  → Ejecutando $file..."
    
    if [ "$file" = "04_roles.sql" ]; then
        # Para 04_roles.sql, sustituir variables
        echo "    - Sustituyendo: APP_USER=$DB_USER_VW, APP_DB=$DB_NAME"
        
        # Escapar caracteres especiales en la contraseña
        ESCAPED_PASSWORD=$(printf '%s\n' "$DB_PASSWORD_VW" | sed 's/[&/\]/\\&/g')
        
        # Crear archivo temporal con variables sustituidas
        sed \
            -e "s/{APP_USER}/$DB_USER_VW/g" \
            -e "s/{APP_PASSWORD}/$ESCAPED_PASSWORD/g" \
            -e "s/{APP_DB}/$DB_NAME/g" \
            "$filepath" > /tmp/04_roles_rendered.sql
        
        if ! psql -v ON_ERROR_STOP=1 --username "$DB_USER" --dbname "$DB_NAME" -f /tmp/04_roles_rendered.sql; then
            echo "✗ ERROR al ejecutar $file"
            rm -f /tmp/04_roles_rendered.sql
            exit 1
        fi
        rm -f /tmp/04_roles_rendered.sql
    else
        if ! psql -v ON_ERROR_STOP=1 --username "$DB_USER" --dbname "$DB_NAME" -f "$filepath"; then
            echo "✗ ERROR al ejecutar $file"
            exit 1
        fi
    fi
    
    echo "  ✓ $file completado"
done

echo ""
echo "[4/6] Validando usuario de aplicación..."
# Verificar que el usuario de aplicación se creó correctamente
if psql -U "$DB_USER" -d "$DB_NAME" --no-password -c "SELECT 1 FROM pg_user WHERE usename='$DB_USER_VW'" | grep -q 1; then
    echo "✓ Usuario $DB_USER_VW existe"
else
    echo "✗ ADVERTENCIA: Usuario $DB_USER_VW no encontrado (pero esto puede ser normal si ya existía)"
fi

echo ""
echo "[5/6] Validando vistas..."
# Verificar que las vistas se crearon
for view in vista_cat_promedio vista_ranking_usuarios_gastos vista_ordenes_por_status vista_productos_mas_vendidos vista_analisis_desempeno_usuarios; do
    if psql -U "$DB_USER" -d "$DB_NAME" --no-password -c "SELECT 1 FROM information_schema.tables WHERE table_name='$view' AND table_type='VIEW'" | grep -q 1; then
        echo "✓ Vista $view existe"
    else
        echo "✗ ADVERTENCIA: Vista $view no encontrada"
    fi
done

echo ""
echo "=========================================="
echo "[6/6] ✓ INICIALIZACIÓN COMPLETADA"
echo "=========================================="
echo ""
echo "Base de datos: $DB_NAME"
echo "Usuario admin: $DB_USER"
echo "Usuario app: $DB_USER_VW (permisos SELECT ONLY)"
echo ""
echo "Puedes conectar desde la app con:"
echo "  - Host: postgres"
echo "  - Port: 5432"
echo "  - User: $DB_USER_VW"
echo "  - Database: $DB_NAME"
echo ""
