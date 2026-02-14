# Quick Start Guide

## Requisitos previos

- Docker (versión 20.10 o superior)
- Docker Compose (versión 1.29 o superior)
- Git (para clonar el repositorio)

## Instalación y ejecución

### 1. Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd Tarea-6-Lab-Reportes
```

### 2. Configurar variables de entorno (OPCIONAL)

El proyecto incluye un archivo `.env` preconfigurado que funcionará inmediatamente. Si deseas hacer cambios:

```bash
# Copiar el archivo de ejemplo (en Windows)
copy .env.example .env

# O en macOS/Linux
cp .env.example .env

# Editar .env si es necesario
# Los valores por defecto funcionan correctamente
```

### 3. Iniciar el proyecto

```bash
docker compose up --build
```

Este comando hará todo automáticamente:
- ✅ Descargará las imágenes de Docker necesarias
- ✅ Construirá la imagen de la aplicación Next.js
- ✅ Creará la base de datos PostgreSQL
- ✅ Ejecutará todos los scripts SQL de inicialización
- ✅ Creará el usuario de aplicación (tarea6) con permisos limitados
- ✅ Iniciará los tres servicios: PostgreSQL, pgAdmin y Next.js

**⚠️ IMPORTANTE:** El archivo `.gitattributes` en la raíz del proyecto es crítico. Asegura que los scripts bash se clonan con saltos de línea Unix (LF) en lugar de Windows (CRLF). Esto es lo que permite que Docker ejecute correctamente los scripts de inicialización. Si experimentas errores de "bad interpreter", verifica que este archivo existe y está comprometido en Git.

### 4. Acceso a la aplicación

Una vez que todo esté corriendo, accede a:

- **App Next.js:** http://localhost:3000
- **pgAdmin (gestor de BD):** http://localhost:5050 (usuario: `admin@admin.com` / contraseña: `admin`)

### 5. Detener el proyecto

```bash
docker compose down
```

Para limpiar volúmenes de la base de datos (reset completo):

```bash
docker compose down -v
```

## Estructura del proyecto

```
.
├── db/
│   ├── 00_init.sh                 # Script de inicialización
│   └── sql-files/
│       ├── 01_schema.sql          # Tablas
│       ├── 02_seed.sql            # Datos iniciales
│       ├── 03_reports_vw.sql      # 5 Views
│       ├── 04_roles.sql           # Usuario con permisos limitados
│       └── 05_indexes.sql         # Índices + Verify
├── tarea6-dba/                    # App Next.js
│   ├── src/
│   │   ├── app/                   # Rutas (App Router)
│   │   ├── lib/                   # Lógica (conexión BD, reportes)
│   │   └── ...
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml             # Orquestación
├── .env                           # Variables (NO COMPARTIR)
├── .env.example                   # Plantilla (compartible)
└── README.md                      # Documentación completa
```

## 5 Views incluidas

1. **vista_cat_promedio** - Precio promedio por categoría
2. **vista_ranking_usuarios_gastos** - Ranking de usuarios por gasto total
3. **vista_ordenes_por_status** - Órdenes agrupadas por estado
4. **vista_productos_mas_vendidos** - Productos más vendidos
5. **vista_analisis_desempeno_usuarios** - Análisis de desempeño de clientes

## Notas importantes

- **Usuario de aplicación:** Automáticamente se crea el usuario `tarea6` con acceso SELECT ONLY a las vistas
- **Credenciales:** El archivo `.env` contiene datos de prueba. NO lo compartas ni comitees a repositorios públicos
- **Hot reload:** La aplicación Next.js recarga automáticamente los cambios en el código
- **Base de datos:** Los cambios en SQL requieren reiniciar: `docker compose down -v && docker compose up --build`

## Troubleshooting

### Puerto ya en uso
Si recibes un error por puerto en uso, modifica `.env`:
```env
DB_PORT_WEB=3001    # Cambia a otro puerto
```

### Permission denied en 00_init.sh
Si experimentas un error como "bad interpreter" o similares, significa que el archivo bash tiene saltos de línea de Windows (CRLF) en lugar de Unix (LF).

**✅ SOLUCIÓN PERMANENTE (Ya implementada):**
- El archivo `.gitattributes` en la raíz del proyecto fuerza automáticamente los saltos de línea correctos
- Asegúrate de que este archivo existe en el repositorio. Si clonaste antes de su creación:
  ```bash
  # Reconvertir el archivo a formato Unix
  # En macOS/Linux:
  dos2unix db/00_init.sh
  
  # En PowerShell (Windows):
  (Get-Content db/00_init.sh -Raw) -replace "`r`n", "`n" | Set-Content db/00_init.sh
  
  # Luego reinicia:
  docker compose down -v
  docker compose up --build
  ```

### Base de datos corrupta
Limpia y reinicia:
```bash
docker compose down -v
docker compose up --build
```

## Información de conexión

**Desde dentro de Docker:**
- Host: `postgres`
- Puerto: `5432`
- Usuario (admin): `postgres` / `postgres123`
- Usuario (app): `tarea6` / `t4r34s313s`
- Base de datos: `actividad_db`

**Desde tu máquina:**
- Host: `localhost`
- Puerto: `5433` (mapeado a 5432)
- Usuarios igual que arriba

Ejemplo con `psql`:
```bash
psql -h localhost -p 5433 -U postgres -d actividad_db
```

## Soporte

Para más información, revisa:
- `README.md` - Documentación técnica completa
- `db/verify.sql` - Consultas de verificación
- `SECURE_INIT_FLOW.md` - Detalles de seguridad y flujo de inicialización
