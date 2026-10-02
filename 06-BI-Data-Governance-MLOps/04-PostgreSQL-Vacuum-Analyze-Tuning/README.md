# 🧹 Taller Práctico & Performance Tuning: VACUUM, ANALYZE y Autovacuum en PostgreSQL

**Asignatura**: Administración de Bases de Datos (Semestre III - Univalle)  
**Módulo Portafolio**: `06-BI-Data-Governance-MLOps/04-PostgreSQL-Vacuum-Analyze-Tuning/`  
**Autor**: Julián Andrés Fajardo Salcedo | M.Sc.(c) Analítica e Inteligencia de Negocios  
**Stack Tecnológico**: PostgreSQL 15 | Docker Compose | pgAdmin 4 | psql CLI | Query Optimization

---

## 📌 1. Resumen Ejecutivo & Metodología STAR

### 🎯 Situación (S)

En motores relacionales PostgreSQL basados en la arquitectura **MVCC** (_Multi-Version Concurrency Control_), las operaciones de modificación (`UPDATE`) y eliminación (`DELETE`) no sobreescriben físicamente los datos en disco, sino que generan nuevas versiones de filas y marcan las antiguas como "tuplas muertas" (_dead tuples_).

En entornos transaccionales masivos de alto tráfico, la acumulación no controlada de tuplas muertas provoca:

1. **Hinchazón de tablas e índices (_Table & Index Bloat_)**: Desperdicio masivo de almacenamiento en disco.
2. **Degradación del rendimiento de Lectura/Escritura (I/O)**: Búsquedas más lentas al tener que escanear páginas llenas de tuplas obsoletas.
3. **Decisiones erróneas del Optimizador de Consultas (_Query Planner_)**: Estadísticas desactualizadas en `pg_stats` que conducen a planes de ejecución ineficientes (_Sequential Scans_ innecesarios).

### 🎯 Tarea (T)

Diseñar, ejecutar y documentar una solución integral de mantenimiento de base de datos que contemple:

- Construcción de un script SQL idempotente (`taller_vacuum_analyze.sql`) con esquemas relacionales y generación masiva de datos.
- Simulación técnica de _bloat_ mediante transacciones abortadas (`ROLLBACK`).
- Evaluación comparativa entre `VACUUM` (reciclaje de espacio en FSM sin bloqueo), `VACUUM FULL` (compactación física con bloqueo exclusivo) y `ANALYZE` (actualización de histogramas de frecuencia).
- Fine-tuning de parámetros de `Autovacuum` por tabla para entornos transaccionales intensivos.
- Creación de una vista de observabilidad en tiempo real (`vacuum_monitor`) para la gestión proactiva del DBA.

### ⚙️ Acción (A)

1. **Orquestación en Docker**: Configuración del servicio PostgreSQL 15 en contenedor Docker (`postgres_roles_db` / `postgres_vacuum_container`) enlazado a **pgAdmin 4**.
2. **Poblado Masivo de Datos**: Generación de **1,000,000 de empleados** y **50,000,000 de registros transaccionales** mediante `generate_series()` y distribuciones aleatorias.
3. **Inducción Dialéctica de Bloat**: Ejecución de bloques de actualización y borrado masivo dentro de una transacción finalizada en `ROLLBACK`, forzando la acumulación de `n_dead_tup`.
4. **Mantenimiento Dialéctico**:
   - Ejecución de `VACUUM VERBOSE` para liberar espacio en el Mapa de Espacio Libre (_Free Space Map - FSM_).
   - Inspección de `pg_stats` antes y después de `ANALYZE VERBOSE` para validar la actualización de `n_distinct`, `avg_width` y `null_frac`.
   - Demostración de compactación física con `VACUUM FULL` sobre la tabla `empleados_copia`.
5. **Sintonización Fina de Autovacuum**: Modificación de parámetros a nivel de tabla con `ALTER TABLE log_transacciones SET (autovacuum_vacuum_scale_factor = 0.05, autovacuum_vacuum_threshold = 100)`.
6. **Desarrollo de Observabilidad**: Creación de la vista `vacuum_monitor` combinando métricas de `pg_stat_all_tables` y `pg_relation_size`.

### 📈 Resultados (R)

- **Procesamiento a Escala de Producción**: Mantenimiento exitoso ejecutado sobre **50,043,944 de registros vivos** en `log_transacciones` (4.2 GB) y **2,000,000 de registros** en `empleados` (138 MB).
- **Eliminación Total de Bloat**: Reducción del porcentaje de tuplas muertas al **0.00%** en todas las tablas objetivo, alcanzando el estado **`OPTIMO`**.
- **Observabilidad Automatizada**: Confirmación del registro automático de contadores (`vacuum_count`, `autovacuum_count`) y estampados de tiempo (`last_vacuum`, `last_autovacuum`, `last_analyze`, `last_autoanalyze`).

---

## 🗂️ Estructura del Proyecto

```text
04-Taller-Vacuum-Analyze-PostgreSQL/
├── 📄 taller_vacuum_analyze.sql       # Script SQL unificado (Fases 1 a 6)
├── 📄 docker-compose.yml             # Orquestación Docker (PostgreSQL 15 + pgAdmin 4)
├── 📄 README.md                      # Documentación del proyecto (Metodología STAR)
└── 📁 evidencias/                    # Capturas de pantalla secuenciales de la ejecución
    ├── Verificar_tuplas_muertas_antes.png
    ├── Actualizar_múltiples_registros.png
    ├── Eliminar_registros.png
    ├── Verificar_tuplas_muertas_despues_ROLLBACK.png
    ├── VACUUM_VERBOSE_empleados.png
    ├── Verificar_estadísticas_de_tablas_antes_VACUUM.png
    ├── Verificar_estadísticas_de_tablas_despues_VACUUM.png
    ├── Inspección_de_estadística_antes _ANALYZE.png
    ├── ANALYZE_manual.png
    ├── ANALYZE_VERBOSE_empleados;.png
    ├── VACUUM_FULL_comparación.png
    ├── Parámetros_Autovacuum.png
    ├── Cambiar_umbral_autovacuum.png
    ├── Crear_vista_monitoreo.png
    └── Verificar_estadísticas_de_tablas.png

```

## 🖼️ Secuencia Completa de Evidencias Técnicas (`evidencias/`)

### 1. Inducción y Medición de Bloat (Tuplas Muertas)

- Verificación de Tuplas Muertas Antes de Operaciones:
- Ejecución de Actualización Múltiple de Registros (`UPDATE`):
- Ejecución de Eliminación Múltiple de Registros (`DELETE`):
- Verificación de Tuplas Muertas Después del `ROLLBACK` (Generación de Bloat):

### 2. Mantenimiento Manual: `VACUUM` y `ANALYZE`

- Ejecución de `VACUUM VERBOSE` sobre la Tabla Empleados:
- Verificación de Estadísticas de Tablas Antes de `VACUUM`:
- Verificación de Estadísticas de Tablas Después de `VACUUM`:
- Inspección de Estadísticas del Catálogo `pg_stats` Antes de `ANALYZE`:
- Ejecución Manual de `ANALYZE`:
- Detalle de Muestreo de `ANALYZE VERBOSE`:
- Comparación de Compactación Física con `VACUUM FULL`:

### 3. Sintonización _Fine-Tuning_ de Autovacuum & Observabilidad

- Inspección de Parámetros Globales de Autovacuum en `pg_settings`:
- Modificación de Umbrales de Autovacuum por Tabla (`ALTER TABLE`):
- Creación de la Vista de Monitoreo Continuo `vacuum_monitor`:
- Consulta Final y Estado Óptimo de las Tablas en `vacuum_monitor`:

---
