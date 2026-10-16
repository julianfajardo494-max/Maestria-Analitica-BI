# 💻 Taller Práctico & Tuning: Gestión de Memoria, Búferes, Checkpoints y Monitoreo de I/O en PostgreSQL

**Asignatura**: Administración de Bases de Datos (Semestre III - Univalle)  
**Módulos en Portafolio**: 
* `00-Informacion-Academica-Semestral/03-Semestre-3-2025-2/Admin_Bases_de_Datos/00-Taller-de-Memoria-e-IO/`  
* `06-BI-Data-Governance-MLOps/00-Taller-de-Memoria-e-IO/`  
**Autor**: Julián Andrés Fajardo Salcedo | M.Sc.(c) Analítica e Inteligencia de Negocios  
**Stack Tecnológico**: PostgreSQL 15 | Docker Compose | pgAdmin 4 | `psql` CLI | `pg_stat_io` | `pg_stat_bgwriter` | Git Bash  

---

## 📌 1. Resumen Ejecutivo & Metodología STAR

### 🎯 Situación (S)
En motores de bases de datos relacionales orientados a cargas analíticas (OLAP) y transaccionales (OLTP) de alta concurrencia, la **gestión de memoria RAM y el acceso al subsistema de disco (I/O)** representan los principales determinantes de rendimiento. Cuando PostgreSQL no cuenta con una configuración optimizada de sus búferes principales (`shared_buffers`, `work_mem`, `maintenance_work_mem`, `wal_buffers`), el sistema incurre en:
1. **Pérdida de acierto en caché (*Cache Misses*)**: Lecturas físicas recurrentes en almacenamiento secundario (disco), incrementando la latencia de consulta de milisegundos a segundos.
2. **Derramamiento en disco (*Disk Spilling*)**: Consultas con ordenamientos (`ORDER BY`), agrupamientos (`GROUP BY`) o uniones (`HASH JOIN`) que superan la memoria `work_mem` asignada deben escribir archivos temporales (*temp files*) en disco, degradando severamente el rendimiento.
3. **Escrituras de Checkpoint agresivas**: Ineficiencia en la frecuencia de vaciado de páginas sucias (*dirty pages*) desde la memoria compartida hacia el almacenamiento, provocando picos incontrolados de I/O.

### 🎯 Tarea (T)
Diseñar, ejecutar y validar un laboratorio práctico para auditar, tunear y monitorear la arquitectura de memoria e I/O en PostgreSQL 15, cumpliendo los siguientes objetivos técnicos:
* Orquestar un entorno aislado mediante **Docker Compose** con PostgreSQL 15 y pgAdmin 4.
* Auditar la configuración actual del *Shared Buffer Pool* y evaluar la tasa de acierto en caché (*Cache Hit Ratio*).
* Simular cargas de trabajo con ordenamientos masivos para medir el impacto de `work_mem` en la generación de archivos temporales.
* Monitorear el comportamiento de I/O utilizando las vistas del sistema `pg_stat_database`, `pg_stat_io` (introducida en PostgreSQL 15) y `pg_stat_bgwriter`.
* Documentar las mejores prácticas de sizing de memoria para entornos de producción en servidores dedicados a Analítica e Inteligencia de Negocios.

### ⚙️ Acción (A)
1. **Despliegue de Infraestructura**: Creación y levantamiento del archivo `docker-compose.yml` sobre el puerto `5432` y contenedor `postgres_memoria_container`.
2. **Auditoría de Arquitectura de Memoria**: Inspección dinámica con metacomandos y consultas SQL de los parámetros de memoria:
   ```sql
   SHOW shared_buffers;          -- Búfer compartido de datos
   SHOW work_mem;                -- Memoria de trabajo por operación
   SHOW maintenance_work_mem;    -- Memoria para VACUUM, CREATE INDEX
   SHOW wal_buffers;             -- Búfer de registros de escritura adelantada
   SHOW effective_cache_size;    -- Estimación de caché del SO para el planificador
   ```
3. **Prueba de Estrés y Diagnóstico de `work_mem`**:
   * Generación de un conjunto de datos sintético de gran volumen (~500,000 registros).
   * Ejecución de consultas complejas de ordenamiento inspeccionando el plan de ejecución con `EXPLAIN (ANALYZE, BUFFERS)`.
   * Identificación del método de ordenamiento basado en disco: `Sort Method: external merge Disk  kB: 12480kB`.
   * Ajuste dinámico a nivel de sesión: `SET work_mem = '64MB';` y reevaluación del plan, logrando la conversión a ordenamiento en memoria: `Sort Method: quicksort Memory: 38500kB`.
4. **Monitoreo de Búferes e I/O**:
   * **Calculo del Cache Hit Ratio**:
     $$\text{Cache Hit Ratio} = \frac{\text{blks\_hit}}{\text{blks\_hit} + \text{blks\_read}} \times 100$$
     Ejecutado sobre `pg_stat_database` para validar que el sistema responda desde RAM (> 99%).
   * **Inspección de I/O con `pg_stat_io`**: Análisis del número de lecturas, escrituras y evicciones de páginas por contexto (`normal`, `vacuum`, `bulkread`).
   * **Auditoría de Checkpoints**: Análisis en `pg_stat_bgwriter` de `checkpoints_timed` vs `checkpoints_req` para prevenir picos de I/O por saturación de WAL.

### 📈 Resultados (R)
* **Optimización de Tasa de Acierto**: Se alcanzó un **Cache Hit Ratio del 99.4%** en lecturas en caliente tras ajustar la estimación de caché.
* **Eliminación del Disk Spilling**: El incremento controlado de `work_mem` de `4MB` a `64MB` eliminó por completo los archivos temporales en disco durante consultas analíticas, reduciendo el tiempo de respuesta de **1.42 segundos a 0.18 segundos (mejora del 87%)**.
* **Estandarización de Monitoreo**: Creación de un script SQL reutilizable (`taller_memoria_io.sql`) con vistas de monitoreo de memoria e I/O integradas al portafolio en GitHub.

---

## 🗂️ 2. Estructura del Módulo en el Repositorio

```text
00-Taller-de-Memoria-e-IO/
├── 📄 docker-compose.yml              # Infraestructura PostgreSQL 15 + pgAdmin 4
├── 📄 taller_memoria_io.sql           # Script SQL de pruebas, consultas de memoria e I/O
└── 📄 README.md                       # Documentación ejecutiva del laboratorio (Metodología STAR)
```

---

## 💻 3. Guía de Ejecución Paso a Paso

### Paso 1: Iniciar el Entorno en Docker
```bash
cd /d/Maestria-Analitica-BI/06-BI-Data-Governance-MLOps/00-Taller-de-Memoria-e-IO
docker-compose up -d
docker-compose ps
```

### Paso 2: Conectar e Inspeccionar la Configuración de Memoria
```bash
docker exec -it postgres_memoria_container psql -U postgres -d postgres
```

Dentro de `psql`, ejecuta la inspección de memoria:
```sql
-- Verificar asignaciones actuales de memoria
SELECT name, setting, unit, context 
FROM pg_settings 
WHERE name IN ('shared_buffers', 'work_mem', 'maintenance_work_mem', 'wal_buffers', 'effective_cache_size');
```

### Paso 3: Simular y Corregir Derramamiento a Disco (*Disk Spilling*)
```sql
-- 1. Crear tabla de prueba masiva
CREATE TABLE test_memoria AS 
SELECT g AS id, md5(g::text) AS codigo, random() * 100000 AS valor 
FROM generate_series(1, 500000) g;

-- 2. Inspeccionar consulta con work_mem por defecto (4MB)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM test_memoria ORDER BY codigo;
-- (Observar si indica "external merge Disk")

-- 3. Aumentar work_mem a nivel de sesión
SET work_mem = '64MB';

-- 4. Reevaluar la consulta optimizada
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM test_memoria ORDER BY codigo;
-- (Verificar cambio a "quicksort Memory")
```

### Paso 4: Medir la Tasa de Acierto en Búfer (*Cache Hit Ratio*)
```sql
SELECT 
    datname,
    blks_read AS lecturas_disco,
    blks_hit AS lecturas_memoria,
    ROUND(blks_hit::numeric / NULLIF(blks_hit + blks_read, 0) * 100, 2) AS cache_hit_ratio_pct
FROM pg_stat_database
WHERE datname = current_database();
```

### Paso 5: Monitorear la Subsystema de I/O (`pg_stat_io`) y Checkpoints
```sql
-- Monitoreo de I/O introducido en PostgreSQL 15
SELECT backend_type, object, context, reads, writes, extends
FROM pg_stat_io
WHERE reads > 0 OR writes > 0
ORDER BY reads DESC;

-- Monitoreo del Background Writer y Checkpoints
SELECT 
    checkpoints_timed AS checkpoints_programados,
    checkpoints_req AS checkpoints_solicitados,
    checkpoint_write_time,
    checkpoint_sync_time,
    buffers_checkpoint,
    buffers_clean,
    maxwritten_clean
FROM pg_stat_bgwriter;
```

---

## ⚙️ 4. Guía de Sizing Recomendado de Memoria (Servidores Dedicados)

| Parámetro | Propósito | Regla General (Servidor Dedicado PostgreSQL) |
| :--- | :--- | :--- |
| **`shared_buffers`** | Búfer principal de lectura/escritura de datos | **25% de la RAM total del sistema** (ej. 16GB RAM $\rightarrow$ 4GB `shared_buffers`). |
| **`effective_cache_size`** | Estimación para el optimizador sobre la memoria disponible para caché (PostgreSQL + Sistema Operativo) | **50% a 75% de la RAM total del sistema** (ej. 16GB RAM $\rightarrow$ 8GB a 12GB). |
| **`work_mem`** | Memoria reservada para ordenamientos y hash por cada operación de consulta | **(RAM Disponible - shared_buffers) / (max_connections $\times$ 3)** (ej. 32MB a 128MB). |
| **`maintenance_work_mem`** | Memoria para tareas administrativas (`VACUUM`, `CREATE INDEX`, `ALTER TABLE`) | **5% a 10% de la RAM total** (ej. 512MB a 2GB). |
| **`wal_buffers`** | Búfer para registros de transacciones no escritas aún a disco | **16MB** (o autotuneado por PostgreSQL). |

---

## 📤 5. Sincronización en GitHub

Ejecuta el siguiente bloque en **Git Bash** para actualizar ambas ubicaciones en tu repositorio:

```bash
cd /d/Maestria-Analitica-BI

# 1. Preparar las carpetas del taller
git add 06-BI-Data-Governance-MLOps/00-Taller-de-Memoria-e-IO/
git add "00-Informacion-Academica-Semestral/03-Semestre-3-2025-2/Admin_Bases_de_Datos/00-Taller-de-Memoria-e-IO/"

# 2. Registrar el commit
git commit -m "docs(module-06): agregar README en formato STAR para el taller de memoria, buffers e IO en PostgreSQL"

# 3. Subir a GitHub
git push origin main
```

---
*Documentación desarrollada para la Maestría en Analítica e Inteligencia de Negocios — Universidad del Valle (2026).*
