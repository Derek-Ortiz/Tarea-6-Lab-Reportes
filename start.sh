#!/bin/bash
# ============================================
# SCRIPT PRINCIPAL - DOCKER STARTUP
# ============================================
# Este script prepara y ejecuta el proyecto completo

set -e

# Cambiar a directorio del script
cd "$(dirname "$0")"

SCRIPT_DIR="scripts"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate.sh"

echo ""
echo "╔════════════════════════════════════════╗"
echo "║  TAREA 6 - REPORTES BASE DE DATOS      ║"
echo "║  Docker Startup Script                 ║"
echo "╚════════════════════════════════════════╝"
echo ""

# 1. Ejecutar validaciones
if [ ! -f "$VALIDATE_SCRIPT" ]; then
    echo "⚠ Script de validación no encontrado en $VALIDATE_SCRIPT"
    echo "  Continuando sin validaciones..."
else
    echo "Ejecutando validaciones previas..."
    echo ""
    
    # Hacer el script ejecutable
    chmod +x "$VALIDATE_SCRIPT"
    
    if ! "$VALIDATE_SCRIPT"; then
        echo ""
        echo "==========================================="
        echo "✗ Las validaciones fallaron"
        echo "==========================================="
        echo ""
        echo "Por favor arregla los problemas arriba"
        echo "y vuelve a intentar."
        echo ""
        exit 1
    fi
fi

echo ""
echo "==========================================="
echo "Iniciando contenedores con Docker Compose..."
echo "==========================================="
echo ""

# 2. Ejecutar docker compose
docker compose up --build

echo ""
echo "==========================================="
echo "✓ Aplicación iniciada"
echo "==========================================="
echo ""
echo "URLs disponibles:"
echo "  - Aplicación:  http://localhost:3000"
echo "  - PgAdmin:     http://localhost:5050"
echo ""
echo "Credenciales PgAdmin:"
echo "  - Email:       admin@admin.com"
echo "  - Contraseña:  admin"
echo ""
