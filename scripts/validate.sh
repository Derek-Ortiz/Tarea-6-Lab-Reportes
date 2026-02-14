#!/bin/sh
# ============================================
# SCRIPT DE VALIDACIÓN PRE-DOCKER
# ============================================
# Este script valida que todo esté configurado correctamente
# antes de iniciar docker compose

set -e

echo "================================"
echo "Verificación de configuración"
echo "================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de errores
ERRORS=0

# 1. Verificar que Git está instalado
echo "✓ Verificando Git..."
if ! command -v git &> /dev/null; then
    echo "${RED}✗ Git no está instalado${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo "${GREEN}✓ Git está instalado${NC}"
fi

# 2. Verificar que Docker está instalado
echo "✓ Verificando Docker..."
if ! command -v docker &> /dev/null; then
    echo "${RED}✗ Docker no está instalado${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo "${GREEN}✓ Docker está instalado${NC}"
fi

# 3. Verificar que Docker Compose está instalado
echo "✓ Verificando Docker Compose..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "${RED}✗ Docker Compose no está instalado${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo "${GREEN}✓ Docker Compose está disponible${NC}"
fi

# 4. Verificar que Docker está corriendo
echo "✓ Verificando que Docker está activo..."
if ! docker info &> /dev/null; then
    echo "${RED}✗ Docker no está ejecutándose${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo "${GREEN}✓ Docker está ejecutándose${NC}"
fi

# 5. Verificar que existe .env
echo "✓ Verificando archivo .env..."
if [ ! -f .env ]; then
    echo "${YELLOW}⚠ Archivo .env no encontrado${NC}"
    echo "  Creando .env a partir de .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "${GREEN}✓ .env creado correctamente${NC}"
    else
        echo "${RED}✗ No se puede crear .env (falta .env.example)${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "${GREEN}✓ Archivo .env existe${NC}"
fi

# 6. Verificar que .gitattributes existe
echo "✓ Verificando .gitattributes..."
if [ ! -f .gitattributes ]; then
    echo "${YELLOW}⚠ .gitattributes no encontrado (líneas de fin de archivo podrían ser incorrectas)${NC}"
else
    echo "${GREEN}✓ .gitattributes existe${NC}"
fi

# 7. Cargar variables desde .env
echo "✓ Verificando variables de entorno..."
if [ -f .env ]; then
    # Cargar .env sin exportar para verificación
    . .env
    
    # Verificar variables críticas
    if [ -z "$DB_USER" ]; then
        echo "${RED}✗ DB_USER no está configurado en .env${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo "${GREEN}✓ DB_USER=$DB_USER${NC}"
    fi
    
    if [ -z "$DB_PASSWORD" ]; then
        echo "${RED}✗ DB_PASSWORD no está configurado en .env${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo "${GREEN}✓ DB_PASSWORD configurado${NC}"
    fi
    
    if [ -z "$DB_NAME" ]; then
        echo "${RED}✗ DB_NAME no está configurado en .env${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo "${GREEN}✓ DB_NAME=$DB_NAME${NC}"
    fi
    
    if [ -z "$DB_USER_VW" ]; then
        echo "${RED}✗ DB_USER_VW no está configurado en .env${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo "${GREEN}✓ DB_USER_VW=$DB_USER_VW${NC}"
    fi
    
    if [ -z "$DB_PASSWORD_VW" ]; then
        echo "${RED}✗ DB_PASSWORD_VW no está configurado en .env${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo "${GREEN}✓ DB_PASSWORD_VW configurado${NC}"
    fi
fi

# 8. Verificar que existen los archivos SQL
echo "✓ Verificando archivos SQL..."
for sql_file in db/sql-files/01_schema.sql db/sql-files/02_seed.sql db/sql-files/03_reports_vw.sql db/sql-files/04_roles.sql db/sql-files/05_indexes.sql; do
    if [ ! -f "$sql_file" ]; then
        echo "${RED}✗ Falta el archivo: $sql_file${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo "${GREEN}✓ Encontrado: $sql_file${NC}"
    fi
done

# 9. Verificar que existe el script init
echo "✓ Verificando script de inicialización..."
if [ ! -f db/00_init.sh ]; then
    echo "${RED}✗ Falta db/00_init.sh${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo "${GREEN}✓ db/00_init.sh existe${NC}"
    
    # Verificar que tiene permisos de ejecución (no aplica en Windows)
    if file db/00_init.sh | grep -q "CRLF"; then
        echo "${YELLOW}⚠ Líneas CRLF detectadas en db/00_init.sh (deberían ser LF)${NC}"
        # No es error crítico porque .gitattributes lo debería arreglar
    fi
fi

# 10. Resumen
echo ""
echo "================================"
if [ $ERRORS -eq 0 ]; then
    echo "${GREEN}✓ Todas las verificaciones pasaron${NC}"
    echo "Puedes ejecutar: docker compose up --build${NC}"
    echo ""
    exit 0
else
    echo "${RED}✗ Se encontraron $ERRORS error(es)${NC}"
    echo "Por favor aréglalos antes de continuar"
    echo ""
    exit 1
fi
