cat << 'EOF' > "00-Informacion-Academica-Semestral/03-Semestre-3-2025-2/Admin_Bases_de_Datos/04-Taller-Vacuum-Analyze-PostgreSQL/README.md"

# 🧹 Taller Práctico: VACUUM, ANALYZE y Autovacuum Tuning en PostgreSQL

**Asignatura**: Administración de Bases de Datos (Semestre III - Univalle)  
**Autor**: Julián Andrés Fajardo Salcedo | M.Sc.(c) Analítica e Inteligencia de Negocios

---

## 📌 1. Objetivo del Taller

Comprender y aplicar las estrategias de mantenimiento en PostgreSQL para el reciclaje de espacio ocupado por tuplas muertas (_bloat_), actualización de estadísticas del optimizador de consultas (`ANALYZE`) y configuración avanzada de `Autovacuum` por tabla.

## 🗂️ 2. Archivos del Entregable

- `4. Vacuum y Analize.docx`: Guía práctica original de la asignatura.
- `4. Vacuum and Analyze.pptx`: Presentación conceptual de arquitectura PostgreSQL.
- `taller_vacuum_analyze.sql`: Script SQL unificado ejecutable con datos de prueba, simulación de bloat, mantenimiento y vista de monitoreo.
- `evidencias/`: Capturas de pantalla del monitoreo de tuplas muertas y tiempos de ejecución.

## ⚙️️ 3. Instrucciones de Ejecución

1. Conectarse al motor PostgreSQL en la terminal o Docker:
   ```bash
   docker exec -i postgres_roles_db psql -U postgres -d postgres < taller_vacuum_analyze.sql
   Consultar la vista de monitoreo de rendimiento:
   SELECT * FROM vacuum_monitor;
   EOF
   ```

---

#### 4️⃣ Replicar y Paquetizar en el Módulo de Portafolio (`06-BI-Data-Governance-MLOps`)

Copiamos y adaptamos el proyecto al Módulo 06 para presentarlo con el estándar **STAR** [cite: 85, 208]:

```bash
# Copiar el script a la carpeta de portafolio
cp "00-Informacion-Academica-Semestral/03-Semestre-3-2025-2/Admin_Bases_de_Datos/04-Taller-Vacuum-Analyze-PostgreSQL/taller_vacuum_analyze.sql" "06-BI-Data-Governance-MLOps/04-PostgreSQL-Vacuum-Analyze-Tuning/taller_vacuum_analyze.sql"

# Crear el README en formato STAR para el portafolio
cat << 'EOF' > "06-BI-Data-Governance-MLOps/04-PostgreSQL-Vacuum-Analyze-Tuning/README.md"
# ⚡ PostgreSQL Performance Tuning: VACUUM, ANALYZE & Autovacuum Architecture

**Módulo**: 06 - BI, Data Governance & MLOps
**Asignatura**: Administración de Bases de Datos (Univalle)
**Autor**: Julián Andrés Fajardo Salcedo | M.Sc.(c) Analítica e Inteligencia de Negocios
**Stack**: PostgreSQL 15 / Docker / MVCC / Query Optimization

---

## 📌 Situación (S)
En bases de datos relacionales de alto tráfico transaccional (OLTP) bajo el modelo MVCC de PostgreSQL, las operaciones continuas de `UPDATE` y `DELETE` generan tuplas muertas (*dead tuples*). Esto causa degradación en los tiempos de respuesta, consumo excesivo de disco (*table bloat*) y decisiones subóptimas del planificador de consultas.

## 🎯 Tarea (T)
Diseñar e implementar una estrategia integral de mantenimiento de base de datos que incluya:
1. Medición cuantitativa del *bloat* e impacto en almacenamiento.
2. Ejecución controlada de `VACUUM` (recuperación de páginas) y `VACUUM FULL` (compactación física con bloqueo exclusivo).
3. Actualización de estadísticas del catálogo (`pg_stats`) mediante `ANALYZE`.
4. Reconfiguración de umbrales de `Autovacuum` a nivel de tabla para entornos de alta concurrencia.

## ⚙️ Acción (A)
1. **Generación de Carga**: Creación de la base de datos `taller_vacuum` con 1,000 empleados y 5,000 transacciones con dispersión aleatoria.
2. **Inducción de Dead Tuples**: Ejecución de bloques de transacción con `ROLLBACK` forzado para simular hinchazón de páginas.
3. **Mantenimiento Dialéctico**:
   * `VACUUM VERBOSE`: Reciclaje de tuplas muertas para espacio libre reutilizable (FSM).
   * `ANALYZE VERBOSE`: Muestreo aleatorio de tablas para actualización de histogramas en `pg_stats`.
4. **Fine-Tuning de Autovacuum**: Ajuste de `autovacuum_vacuum_scale_factor = 0.05` en tablas transaccionales de rápido crecimiento.
5. **Observabilidad**: Construcción de la vista SQL `vacuum_monitor` para supervisión en tiempo real del porcentaje de degradación.

## 📈 Resultados (R)
* **Optimización de Espacio**: Eliminación total de tuplas muertas acumuladas sin interrumpir la disponibilidad del servicio.
* **Precisión en Planes de Ejecución**: Actualización de la cardinalidad estimada para el optimizador de PostgreSQL.
* **Mantenimiento Automatizado**: Configuración proactiva de fondo que evita bloqueos masivos por `VACUUM FULL`.
EOF
```
