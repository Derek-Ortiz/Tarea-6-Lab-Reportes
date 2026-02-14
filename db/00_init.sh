#!/bin/sh
set -e

echo "Iniciando configuracion de base de datos..."

if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
    echo "Error: DB_USER, DB_PASSWORD y DB_NAME son requeridos."
    exit 1
fi

if [ -z "$DB_USER_VW" ] || [ -z "$DB_PASSWORD_VW" ]; then
    echo "Error: DB_USER_VW y DB_PASSWORD_VW son requeridos."
    exit 1
fi

SCRIPT_DIR="/docker-entrypoint-initdb.d/sql-files"
SQL_FILES="01_schema.sql 02_seed.sql 03_reports_vw.sql 04_roles.sql 05_indexes.sql"

echo "Environment variables:"
echo "  DB_NAME: $DB_NAME"
echo "  DB_USER: $DB_USER"
echo "  DB_USER_VW: $DB_USER_VW"

for file in $SQL_FILES; do
    filepath="$SCRIPT_DIR/$file"

    if [ -f "$filepath" ]; then
        echo "Ejecutando: $file"
        
        if [ "$file" = "04_roles.sql" ]; then
            # Para 04_roles.sql, hacer sustitución de variables con sed
            echo "  Sustituyendo variables: APP_USER=$DB_USER_VW, APP_PASSWORD=$DB_PASSWORD_VW, APP_DB=$DB_NAME"
            
            # Crear archivo temporal con variables sustituidas
            sed \
                -e "s/{APP_USER}/$DB_USER_VW/g" \
                -e "s/{APP_PASSWORD}/$DB_PASSWORD_VW/g" \
                -e "s/{APP_DB}/$DB_NAME/g" \
                "$filepath" > /tmp/04_roles_rendered.sql
            
            psql -v ON_ERROR_STOP=1 --username "$DB_USER" --dbname "$DB_NAME" -f /tmp/04_roles_rendered.sql
            rm -f /tmp/04_roles_rendered.sql
        else
            psql -v ON_ERROR_STOP=1 --username "$DB_USER" --dbname "$DB_NAME" -f "$filepath"
        fi
        echo "Completado: $file"
    else
        echo "Archivo no encontrado (omitido): $file"
    fi
done

echo "Base de datos configurada exitosamente"
