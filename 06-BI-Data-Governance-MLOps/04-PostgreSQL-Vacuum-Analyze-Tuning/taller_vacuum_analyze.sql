-- ============================================================================
-- 🏛️ TALLER PRÁCTICO: VACUUM, ANALYZE Y AUTOVACUUM TUNING EN POSTGRESQL
-- Asignatura: Administración de Bases de Datos (Semestre III - Univalle)
-- Autor: Julián Andrés Fajardo Salcedo | M.Sc.(c) Analítica e Inteligencia de Negocios
-- ============================================================================

-- ============================================================================
-- FASE 1: CONFIGURACIÓN INICIAL DEL ENTORNO
-- ============================================================================

-- 1.1 Crear la base de datos de prueba
DROP DATABASE IF EXISTS taller_vacuum;
CREATE DATABASE taller_vacuum;

-- Conectarse a la nueva base de datos
\c taller_vacuum

-- 1.2 Crear tabla principal de 'empleados'
CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    departamento VARCHAR(50),
    salario DECIMAL(10,2),
    fecha_contratacion DATE,
    activo BOOLEAN DEFAULT true
);

-- 1.3 Crear tabla transaccional para simulación de alto tráfico y bloat
CREATE TABLE log_transacciones (
    id SERIAL PRIMARY KEY,
    empleado_id INTEGER REFERENCES empleados(id),
    accion VARCHAR(50),
    fecha TIMESTAMP DEFAULT NOW(),
    datos TEXT
);

-- ============================================================================
-- FASE 2: INSERCIÓN DE DATOS MASIVOS DE PRUEBA
-- ============================================================================

-- 2.1 Insertar 1,000 empleados con departamentos y salarios aleatorios
INSERT INTO empleados (nombre, departamento, salario, fecha_contratacion)
SELECT
    'Empleado ' || generate_series(1, 1000),
    CASE (random() * 4)::int
        WHEN 0 THEN 'Ventas'
        WHEN 1 THEN 'TI'
        WHEN 2 THEN 'RH'
        WHEN 3 THEN 'Finanzas'
        ELSE 'Operaciones'
    END,
    (random() * 10000) + 30000,
    CURRENT_DATE - (random() * 3650)::int
FROM generate_series(1, 1000);

-- 2.2 Insertar 5,000 registros transaccionales aleatorios
INSERT INTO log_transacciones (empleado_id, accion, datos)
SELECT
    (random() * 999)::int + 1,
    CASE (random() * 3)::int
        WHEN 0 THEN 'INSERT'
        WHEN 1 THEN 'UPDATE'
        WHEN 2 THEN 'DELETE'
        ELSE 'SELECT'
    END,
    'Datos de prueba transaccional registro #' || generate_series(1, 5000)
FROM generate_series(1, 5000);

-- ============================================================================
-- FASE 3: MONITOREO INICIAL Y SIMULACIÓN DE BLOAT (TUPLAS MUERTAS)
-- ============================================================================

-- 3.1 Consultar espacio inicial de tablas e índices
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS tamaño_total,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS tamaño_tabla,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS tamaño_indices
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 3.2 Inducir tuplas muertas (n_dead_tup) mediante transacciones abortadas (ROLLBACK)
BEGIN;
    -- Actualizar masivamente salarios del área de Ventas
    UPDATE empleados
    SET salario = salario * 1.15
    WHERE departamento = 'Ventas';

    -- Eliminar registros antiguos de logs
    DELETE FROM log_transacciones
    WHERE id % 2 = 0;
ROLLBACK; -- ¡El ROLLBACK deja las versiones antiguas como tuplas muertas!

-- 3.3 Consultar el ratio y porcentaje de tuplas muertas por tabla
SELECT
    schemaname,
    relname AS tabla,
    n_live_tup AS tuplas_vivas,
    n_dead_tup AS tuplas_muertas,
    round(n_dead_tup::numeric / GREATEST(n_live_tup + n_dead_tup, 1) * 100, 2) AS porcentaje_muertas
FROM pg_stat_all_tables
WHERE schemaname = 'public'
  AND (n_live_tup + n_dead_tup) > 0;

-- ============================================================================
-- FASE 4: MANTENIMIENTO MANUAL CON VACUUM, VACUUM FULL Y ANALYZE
-- ============================================================================

-- 4.1 Ejecutar VACUUM estándar (recicla páginas para reutilización interna)
VACUUM VERBOSE empleados;

-- 4.2 Inspección de estadísticas del optimizador antes de ANALYZE
SELECT
    schemaname,
    tablename,
    attname AS columna,
    null_frac,
    avg_width,
    n_distinct
FROM pg_stats
WHERE tablename = 'empleados'
LIMIT 5;

-- 4.3 Actualización manual de estadísticas para el planificador de consultas
ANALYZE VERBOSE empleados;

-- 4.4 Demostración de VACUUM FULL (compactación física con bloqueo exclusivo)
-- Crear tabla de prueba para comparar espacio libre
CREATE TABLE empleados_copia AS SELECT * FROM empleados;

-- Simular degradación en la copia
DELETE FROM empleados_copia WHERE id % 3 = 0;

-- Comparar tamaño antes y después de VACUUM FULL
SELECT 'empleados_copia (Antes FULL)' AS estado, pg_size_pretty(pg_relation_size('empleados_copia')) AS tamaño;

VACUUM FULL VERBOSE empleados_copia;

SELECT 'empleados_copia (Después FULL)' AS estado, pg_size_pretty(pg_relation_size('empleados_copia')) AS tamaño;

-- 4.5 Ejecución combinada VACUUM ANALYZE en tablas críticas
VACUUM ANALYZE VERBOSE log_transacciones;

-- ============================================================================
-- FASE 5: CONFIGURACIÓN AVANZADA Y TUNING DE AUTOVACUUM
-- ============================================================================

-- 5.1 Consultar parámetros globales de Autovacuum en la sesión
SELECT name, setting, unit, context
FROM pg_settings
WHERE name LIKE '%autovacuum%' OR name LIKE '%vacuum%'
ORDER BY name;

-- 5.2 Sintonización fina (Fine-Tuning) para tabla transaccional de alto tráfico
-- Configura un umbral más agresivo (5% de cambios para disparar Autovacuum)
ALTER TABLE log_transacciones SET (
    autovacuum_vacuum_scale_factor = 0.05,
    autovacuum_vacuum_threshold = 100,
    autovacuum_analyze_scale_factor = 0.02
);

-- 5.3 Verificar opciones personalizadas configuradas en pg_class
SELECT relname, reloptions
FROM pg_class
WHERE relname = 'log_transacciones';

-- ============================================================================
-- FASE 6: OBSERVABILIDAD Y VISTA DE MONITOREO CONTINUO
-- ============================================================================

-- 6.1 Crear la vista personalizada 'vacuum_monitor' para administración de la BD
CREATE OR REPLACE VIEW vacuum_monitor AS
SELECT
    schemaname,
    tablename,
    n_live_tup AS tuplas_vivas,
    n_dead_tup AS tuplas_muertas,
    round(n_dead_tup::numeric / GREATEST(n_live_tup + n_dead_tup, 1) * 100, 2) AS dead_percent,
    CASE
        WHEN n_dead_tup > n_live_tup * 0.2 THEN 'CRÍTICO (Requiere VACUUM)'
        WHEN n_dead_tup > n_live_tup * 0.1 THEN 'ADVERTENCIA'
        ELSE 'OPTIMO'
    END AS estado_bloat,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    vacuum_count,
    autovacuum_count,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS tamaño_tabla
FROM pg_stat_all_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
  AND (n_live_tup + n_dead_tup) > 0;

-- 6.2 Consultar el tablero de monitoreo de mantenimiento
SELECT * FROM vacuum_monitor;