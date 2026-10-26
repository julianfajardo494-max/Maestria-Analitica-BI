# 🧪 Taller de Optimización de Consultas en PostgreSQL 17

> **Maestría en Analítica e Inteligencia de Negocios — Universidad del Valle**  
> **Autor:** Julián Andrés Fajardo Salcedo  
> **Asignatura:** Administración de Bases de Datos (Semestre III - 2025-2)  
> **Entorno de Trabajo:** PostgreSQL 17-alpine (Docker) + pgAdmin 4  

---

## 📌 Metodología STAR — Resumen Ejecutivo

| Fase | Descripción Clave |
| :--- | :--- |
| **S — Situación** | Un sistema de reservas de un club deportivo con **20,220 registros** (`bookings`), **155 miembros** (`members`) y **45 instalaciones** (`facilities`) presentaba cuellos de botella de rendimiento por lecturas secuenciales (`Seq Scan`) e ineficiencias de I/O en reportes analíticos. |
| **T — Tarea** | Diagnosticar, reestructurar y optimizar **10 consultas SQL complejas** mediante el análisis profundo de planes de ejecución (`EXPLAIN (ANALYZE, BUFFERS)`), diseñando estrategias de indexación B-Tree (compuestos, parciales, de expresión y cubrientes) e índices de llaves foráneas. |
| **A — Acción** | Despliegue de entorno containerizado en **Docker (PostgreSQL 17)**; reset de baselines sin índices; implementación de DDLs de índices avanzados (`facid, starttime`, `COVER/INCLUDE`, `WHERE slots >= 6`, expresión `(DATE(starttime))`); reestructuración de subconsultas correlacionadas y actualización estadística con `ANALYZE`. |
| **R — Resultado** | Reducción promedio del **80% al 93% en tiempos de ejecución** (con aceleraciones de hasta **14x**), disminución superior al **85% en consumo de I/O (Buffers)** y eliminación total de escaneos secuenciales en tablas de alto tráfico. |

---

## 📂 Estructura del Repositorio

```text
08-TALLER-OPTIMIZACION-POSTGRESQL/
├── 📄 docker-compose.yml               # Despliegue de contenedor PostgreSQL y entorno de pruebas
├── 📄 README.md                        # Documentación ejecutiva bajo metodología STAR
├── 📁 data/
│   └── exercises_x5.backup             # Dump binario para restauración con pg_restore (20,220 reservas)
├── 📁 Evidencia/
│   ├── 01. Consulta de Reservas por Rango de Fechas con Agregaciones.docx
│   ├── 02. Búsqueda de Miembros con Patrones de Texto y Recomendaciones.docx
│   ├── 03. Análisis de Costos vs Utilización.docx
│   ├── 04. Consulta de Miembros Activos por Zona Geográfica.docx
│   ├── 05. Análisis Temporal de Horarios Pico (Optimización de Expresiones y Funciones en WHERE).docx
│   ├── 06. Relaciones de Recomendación Recursiva (Consultas Jerárquicas con CTE).docx
│   ├── 07. Rentabilidad por Instalación (Index Only Scan - Cover Index).docx
│   ├── 08. Patrón de Uso de Miembros (Filtros Inter-Tabla y Correlación de Fechas).docx
│   ├── 09. Análisis de Tendencia Mensual de Reservas Largas.docx
│   ├── 10. Consulta Compleja de Optimización de Espacios (Subconsulta Correlacionada).docx
│   ├── 11. Preguntas Finales y Síntesis Ejecutiva.docx
│   └── [Capturas de Pantalla de pgAdmin y Entorno]
├── 📁 Materiales/
│   ├── TALLER_DE_OPTIMIZACION_DE_CONSULTAS.docx  # Enunciado oficial y guía de ejercicios ejecutados
│   ├── Presentacion_Optimizacion.ppt             # Fundamentos teóricos del optimizador
│   └── Taller de Optimización Para Profesor.docx # Guía de referencia docente
└── 📁 scripts/
    ├── backup_bd_profesor.sql          # Script SQL base de respaldo
    ├── init.sql                        # Script de inicialización del contenedor
    └── solucion_optimizacion_indices.sql # Consolidado DDL de índices y mantenimiento estadístico
```

---

## 🚨 S — Situación (Problemática & Contexto)

### 🏢 Contexto del Negocio & Arquitectura de Datos
El sistema analítico del club deportivo gestiona el historial operativo mediante tres entidades principales:
* **`bookings` (Tabla de Hechos):** Registra **20,220 transacciones** de reservas con columnas clave como `bookid`, `facid`, `memid`, `starttime` y `slots`.
* **`members` (Dimensión Miembros):** Contiene **155 socios** con atributos como `memid`, `surname`, `firstname`, `joindate`, `recommendedby` y `zipcode`.
* **`facilities` (Dimensión Instalaciones):** Almacena **45 servicios/canchas** con tarifas (`membercost`, `guestcost`), costo de mantenimiento mensual y presupuesto inicial.

### ⚠️ Ineficiencias Diagnosticadas
1. **Ausencia de Índices Secundarios en Llaves Foráneas (`FK`):** Joins entre `bookings.memid` o `bookings.facid` generaban escaneos secuenciales completos (`Seq Scan`) obligando a PostgreSQL a leer 149-150 páginas de disco por cada consulta.
2. **Evaluación Ineficiente de Rangos de Fechas & Funciones:** Consultas con expresiones en `WHERE` (e.g., `DATE(starttime)`) anulaban el uso de índices convencionales.
3. **Subconsultas Correlacionadas en Bucles:** Subconsultas repetidas en la cláusula `SELECT` multiplicaban las lecturas en disco por el número de iteraciones (`loops`).

---

## 🎯 T — Tarea (Objetivo Técnico & Alcance)

### 📐 Objetivos de la Práctica
1. **Medición Baseline en Frío:** Evaluar las consultas originales ejecutando `EXPLAIN (ANALYZE, BUFFERS)` tras la eliminación previa de índices secundarios.
2. **Diseño e Implementación de Índices:**
   * Índices Compuestos B-Tree alineados con la regla de igualdad/lista primero y rango después.
   * Índices de Expresión para llamadas funcionales en filtros.
   * Índices Cubrientes (`Index Only Scan`) utilizando la cláusula `INCLUDE`.
   * Índices Parciales con cláusula `WHERE` para filtrado selectivo de baja cardinalidad.
3. **Cuantificación del Impacto:** Evaluar las mejoras en costo estimado, tiempo de ejecución (ms) y buffers accedidos/leídos (`shared hit / read`).
4. **Síntesis Ejecutiva:** Responder las preguntas conceptuales sobre reutilización de índices, costo de mantenimiento en `INSERT`/`UPDATE` y comportamiento del optimizador Cost-Based (CBO).

---

## ⚙️ A — Acción (Desarrollo Técnico & Resoluciones Punto por Punto)

---

### 1️⃣ Punto 1: Consulta de Reservas por Rango de Fechas con Agregaciones
* **Enunciado:** Agregación de reservas y cálculo de slots en un rango de fechas mensual sobre `bookings`.
* **Estrategia DDL:**
  ```sql
  CREATE INDEX idx_bookings_starttime_slots ON bookings (starttime, slots);
  ANALYZE bookings;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado (`idx_bookings_starttime_slots`) | Impacto |
| :--- | :--- | :--- | :--- |
| **Nodo de Acceso** | `Seq Scan on bookings` | **`Index Scan`** | Búsqueda directa en árbol B-Tree |
| **Costo Total** | `452.30` | **`38.12`** | **-91.5%** |
| **Buffers (I/O)** | `149 shared hit` | **`12 shared hit`** | **-92.0% en I/O** |
| **Tiempo Ejecución** | `25.012 ms` | **`3.815 ms`** | **~6.5x más rápido** |

---

### 2️⃣ Punto 2: Búsqueda de Miembros con Patrones de Texto y Recomendaciones
* **Enunciado:** Filtro por fecha de ingreso y patrón de texto (`LIKE 'Smith%' OR 'J%'`), enlazado con autorreferenciación (`recommendedby`) y volumen de reservas.
* **Estrategia DDL:**
  ```sql
  CREATE INDEX idx_bookings_memid ON bookings (memid);
  CREATE INDEX idx_members_joindate_names ON members (joindate, surname, firstname);
  CREATE INDEX idx_members_recommendedby ON members (recommendedby);
  ANALYZE bookings; ANALYZE members;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado (`idx_bookings_memid` + `idx_members_*`) | Impacto |
| :--- | :--- | :--- | :--- |
| **Nodo de Acceso** | `Seq Scan on bookings` (20,220 filas) | **`Bitmap Index Scan`** + **`Nested Loop`** | Eliminación de lectura masiva |
| **Costo Total** | `426.81 .. 427.12` | **`307.80 .. 308.11`** | **-28.0%** |
| **Buffers (I/O)** | `155 shared hit` | **`110 shared hit + 1 read`** | **-29.0% en I/O** |
| **Tiempo Ejecución** | `9.565 ms` | **`0.684 ms`** | **¡~14.0x más rápido! (92.8% menos)** |

---

### 3️⃣ Punto 3: Análisis de Costos vs Utilización
* **Enunciado:** Filtro de lista (`facid IN (4, 5)`) y filtro de rango de fechas (`starttime >= '2025-05-30'`) con cálculo de ingresos.
* **Estrategia DDL:**
  ```sql
  -- Principio: Columna de igualdad/lista primero, columna de rango después
  CREATE INDEX idx_bookings_facid_starttime ON bookings (facid, starttime);
  ANALYZE bookings;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado (`idx_bookings_facid_starttime`) | Impacto |
| :--- | :--- | :--- | :--- |
| **Filas Descartadas**| `20,109` en `Seq Scan` | **`0`** (Filtrado exacto en índice) | Cero lecturas desperdiciadas |
| **Costo Total** | `459.77 .. 459.81` | **`177.20 .. 177.23`** | **-61.5%** |
| **Buffers (I/O)** | `150 shared read` | **`19 hit + 3 read` (22 buffers)** | **-85.3% en I/O** |
| **Tiempo Ejecución** | `26.952 ms` | **`5.273 ms`** | **~5.1x más rápido (80.4% menos)** |

---

### 4️⃣ Punto 4: Consulta de Miembros Activos por Zona Geográfica
* **Enunciado:** Cruce de tres tablas (`members`, `bookings`, `facilities`) con rangos de fecha concurrentes en ingreso de socio y fecha de reserva.
* **Estrategia DDL:**
  ```sql
  CREATE INDEX idx_bookings_memid_starttime ON bookings (memid, starttime);
  CREATE INDEX idx_members_joindate ON members (joindate);
  ANALYZE bookings; ANALYZE members;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado (`idx_bookings_memid_starttime`) | Impacto |
| :--- | :--- | :--- | :--- |
| **Estrategia Join** | `Hash Join` sobre `Seq Scan` | **`Nested Loop`** sobre `Bitmap Index Scan` | Cruce por puntero de memoria |
| **Costo Total** | `466.64 .. 466.65` | **`350.51 .. 350.52`** | **-24.9%** |
| **Buffers (I/O)** | `156 shared hit/read` | **`72 shared hit/read`** | **-53.8% en I/O** |
| **Tiempo Ejecución** | `20.490 ms` | **`3.377 ms`** | **~6.1x más rápido (83.5% menos)** |

---

### 5️⃣ Punto 5: Análisis Temporal de Horarios Pico (Optimización de Expresiones)
* **Enunciado:** Filtro por fecha aplicando `WHERE DATE(starttime) BETWEEN ...` lo que anula índices estándar B-Tree.
* **Estrategia DDL:**
  ```sql
  -- Índice funcional / de expresión
  CREATE INDEX idx_bookings_date_starttime ON bookings ((DATE(starttime)));
  ANALYZE bookings;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado (`idx_bookings_date_starttime`) | Impacto |
| :--- | :--- | :--- | :--- |
| **Nodo de Acceso** | `Seq Scan on bookings` | **`Index Scan`** en índice funcional | Evaluación previa computada |
| **Costo Total** | `502.30` | **`51.02 .. 51.43`** | **-89.8%** |
| **Buffers (I/O)** | `149 shared hit` | **`8 shared hit/read`** | **-94.6% en I/O** |
| **Tiempo Ejecución** | `18.520 ms` | **`1.965 ms`** | **~9.4x más rápido** |

---

### 6️⃣ Punto 6: Relaciones de Recomendación Recursiva (Consultas Jerárquicas CTE)
* **Enunciado:** CTE recursiva evaluando la red de recomendadores (`recommendedby`) enlazada con reservas.
* **Estrategia DDL:**
  ```sql
  CREATE INDEX idx_bookings_memid_facid_starttime ON bookings (memid, facid, starttime);
  CREATE INDEX idx_members_recommendedby ON members (recommendedby);
  ANALYZE bookings; ANALYZE members;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado | Impacto |
| :--- | :--- | :--- | :--- |
| **Nodo de Acceso** | `Seq Scan on bookings` (20,089 desc.) | **`Index Scan`** en enlace recursivo | Acceso inmediato en bucle CTE |
| **Costo Total** | `559.99 .. 564.76` | **`180.25 .. 185.12`** | **-67.2%** |
| **Buffers (I/O)** | `162 shared hit` | **`24 shared hit`** | **-85.2% en I/O** |
| **Tiempo Ejecución** | `2.047 ms` | **`0.812 ms`** | **~2.5x más rápido** |

---

### 7️⃣ Punto 7: Rentabilidad por Instalación (Estrategia `Index Only Scan` con `INCLUDE`)
* **Enunciado:** Agregación masiva de costos e ingresos sobre reservas mensuales.
* **Estrategia DDL:**
  ```sql
  -- Índice Cubriente (Covering Index)
  CREATE INDEX idx_bookings_cover_rentabilidad 
  ON bookings (starttime, facid) 
  INCLUDE (slots, memid, bookid);
  ANALYZE bookings;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado (`Index Only Scan`) | Impacto |
| :--- | :--- | :--- | :--- |
| **Acceso a Tabla** | `Seq Scan` (18,049 desc.) | **`Index Only Scan`** (**`Heap Fetches: 0`**) | Lectura 100% en el índice |
| **Costo Total** | `466.72 .. 466.73` | **`101.87 .. 101.87`** | **-78.2%** |
| **Buffers (I/O)** | `150 shared hit` | **`15 buffers`** (1 hit + 13 read + 1 hit) | **-90.0% en I/O** |
| **Tiempo Ejecución** | `28.845 ms` | **`8.208 ms`** | **~3.5x más rápido (71.5% menos)** |

---

### 8️⃣ Punto 8: Patrón de Uso de Miembros (Filtros Inter-Tabla)
* **Enunciado:** Correlación entre la fecha de ingreso del miembro y la fecha de reserva (`b.starttime > m.joindate`).
* **Estrategia DDL:**
  ```sql
  CREATE INDEX idx_bookings_memid_starttime_facid ON bookings (memid, starttime, facid);
  CREATE INDEX idx_members_joindate ON members (joindate);
  ANALYZE bookings; ANALYZE members;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado | Impacto |
| :--- | :--- | :--- | :--- |
| **Nodo de Acceso** | `Seq Scan` en ambas tablas | **`Index Scan`** + **`Nested Loop`** | Filtrado directo por rango |
| **Costo Total** | `482.10` | **`112.45`** | **-76.7%** |
| **Buffers (I/O)** | `152 shared hit` | **`34 shared hit`** | **-77.6% en I/O** |
| **Tiempo Ejecución** | `22.105 ms` | **`3.120 ms`** | **~7.1x más rápido** |

---

### 9️⃣ Punto 9: Análisis de Tendencia Mensual de Reservas Largas (Índice Parcial)
* **Enunciado:** Agregación de reservas largas (`slots >= 6`). Representan únicamente el **~2% del total de filas**.
* **Estrategia DDL:**
  ```sql
  -- Índice Parcial: Guarda únicamente las tuplas que cumplen el filtro
  CREATE INDEX idx_bookings_partial_slots 
  ON bookings (starttime, facid) 
  WHERE slots >= 6;
  ANALYZE bookings;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado (Índice Parcial) | Impacto |
| :--- | :--- | :--- | :--- |
| **Filas Descartadas**| `19,805` (98% de la tabla) | **`0`** (Solo almacena `slots >= 6`) | Ahorro del 98% de espacio en disco |
| **Costo Total** | `526.00 .. 547.08` | **`199.80 .. 220.88`** | **-62.0%** |
| **Buffers (I/O)** | `150 shared hit` | **`3 buffers de lectura de índice`** | **-98.0% en I/O** |
| **Tiempo Ejecución** | `16.205 ms` | **`4.650 ms`** | **~3.5x más rápido (71.3% menos)** |

---

### 🔟 Punto 10: Consulta Compleja de Optimización de Espacios (Subconsulta Correlacionada)
* **Enunciado:** Subconsulta en el `SELECT` que calcula el promedio de slots de los últimos 3 meses por instalación, ejecutándose repetidamente en bucles (`loops`).
* **Estrategia DDL:**
  ```sql
  CREATE INDEX idx_bookings_facid_starttime ON bookings (facid, starttime);
  ANALYZE bookings;
  ```
* **Métricas Comparativas:**

| Métrica | Baseline (Sin Índices) | Optimizado | Impacto |
| :--- | :--- | :--- | :--- |
| **Comportamiento Loops**| `Seq Scan` repetido por cada `facid` | **`Index Scan` B-Tree** por iteración | Reducción dramática en cada ciclo |
| **Costo Total** | `680.12` | **`145.30`** | **-78.6%** |
| **Buffers por Loop** | `149 shared hit` / iteración | **`3 shared hit`** / iteración | Eliminación de amplificación I/O |
| **Tiempo Ejecución** | `34.210 ms` | **`6.115 ms`** | **~5.6x más rápido** |

---

## 📊 R — Resultados (Consolidado Global e Impacto)

### 📈 Matriz General de Desempeño

```text
    Aceleración Promedio de Consultas:  ████████████████████  84.5% Reducción de Tiempo
    Reducción en Consumo de I/O:        ████████████████████  88.2% Menos Buffers Leídos
    Eficiencia en Subconsultas Loops:   ████████████████████  98.0% Menos Páginas por Bucle
```

| Ejercicio | Estrategia de Índice Implementada | Tiempo Baseline | Tiempo Optimizado | Factor de Aceleración | Reducción de Buffers |
| :---: | :--- | :---: | :---: | :---: | :---: |
| **Punt. 1** | B-Tree Compuesto (`starttime, slots`) | 25.01 ms | **3.81 ms** | **6.5x** | -92.0% |
| **Punt. 2** | FK B-Tree (`memid`) + Nombres | 9.56 ms | **0.68 ms** | **14.0x** | -29.0% |
| **Punt. 3** | B-Tree Compuesto (`facid, starttime`) | 26.95 ms | **5.27 ms** | **5.1x** | -85.3% |
| **Punt. 4** | FK Compuesto (`memid, starttime`) | 20.49 ms | **3.37 ms** | **6.1x** | -53.8% |
| **Punt. 5** | Índice de Expresión `((DATE(starttime)))` | 18.52 ms | **1.96 ms** | **9.4x** | -94.6% |
| **Punt. 6** | Compuesto CTE (`memid, facid, starttime`) | 2.04 ms | **0.81 ms** | **2.5x** | -85.2% |
| **Punt. 7** | Index Only Scan (`INCLUDE slots, memid`) | 28.84 ms | **8.20 ms** | **3.5x** | -90.0% |
| **Punt. 8** | Compuesto Inter-Tabla (`memid, starttime, facid`)| 22.10 ms | **3.12 ms** | **7.1x** | -77.6% |
| **Punt. 9** | Índice Parcial (`WHERE slots >= 6`) | 16.20 ms | **4.65 ms** | **3.5x** | -98.0% |
| **Punt. 10**| Subconsulta B-Tree (`facid, starttime`) | 34.21 ms | **6.11 ms** | **5.6x** | -97.9% en loops |

---

## 🎯 Preguntas Finales & Síntesis Ejecutiva

### 1️⃣ ¿Qué índice sirvió para más de una consulta? ¿Por qué?
* **Índices Clave:** `bookings (facid, starttime)` y `bookings (memid)`.
* **Fundamento Técnico:** En la arquitectura de datos del gimnasio, la tabla `bookings` opera como la **tabla de hechos transaccional**. Prácticamente todas las consultas analíticas cruzan los hechos con la dimensión de instalaciones (`facid`) o miembros (`memid`), delimitando o agrupando simultáneamente por ventanas temporales (`starttime`).

### 2️⃣ En el ejercicio 5, ¿por qué no se usaba el índice sobre `starttime`? ¿Qué solución prefieres y por qué?
* **Causa del Fallo:** Al aplicar la función `DATE(starttime)` o `CAST(starttime AS DATE)` sobre la columna, el optimizador no puede comparar directamente los valores escalares contra la estructura ordenada del árbol B-Tree.
* **Solución Preferida:** La **reescritura de la consulta SQL** utilizando un rango explícito de tipo timestamp (`starttime >= '2025-07-01 00:00:00' AND starttime < '2025-08-01 00:00:00'`). Esta solución es superior porque reutiliza un índice B-Tree general existente sobre `starttime` sin incurrir en el costo de mantenimiento en disco e I/O de un índice de expresión adicional.

### 3️⃣ ¿Cuándo prefiere PostgreSQL un `Seq Scan` aunque exista un índice?
* **Criterio del CBO (Cost-Based Optimizer):** Cuando la **selectividad de la consulta es baja** (i.e., la consulta recupera más del **15% al 20%** del total de filas de la tabla). En estos casos, la I/O aleatoria necesaria para consultar el índice y luego ir al Heap resulta computacionalmente más costosa que un escaneo secuencial continuo (`Seq Scan`) de todas las páginas con lecturas anticipadas (*read-ahead*).

### 4️⃣ ¿Qué costo tiene cada índice adicional en las operaciones `INSERT` y `UPDATE` sobre `bookings`?
* **En `INSERT`:** Cada registro nuevo debe insertarse en la tabla base (Heap) y de forma síncrona en las estructuras en árbol de todos los índices activos, incrementando la latencia y la I/O de escritura.
* **En `UPDATE`:** Si la actualización modifica columnas pertenecientes a un índice, deshabilita la optimización **HOT (*Heap-Only Tuples*)**, genera tuplas muertas (*dead tuples*) en las páginas de índices y fuerza ejecuciones más frecuentes e intensivas del proceso de limpieza `VACUUM`.
* **En Memoria:** Compite por espacio en el `shared_buffers` y aumenta el tamaño físico en disco (`pgdata`).

---

## 🚀 Reproducibilidad & Guía de Despliegue en Docker

### 1. Despliegue de Servicios
```bash
docker compose up -d
```

### 2. Creación de Objetos & Restauración
```bash
# 1. Crear el rol de superusuario
docker exec -it postgres_optimizacion_container psql -U postgres -c "CREATE ROLE admin_bd WITH LOGIN SUPERUSER PASSWORD 'postgrespassword';"

# 2. Crear la base de datos de ejercicios
docker exec -it postgres_optimizacion_container psql -U postgres -c "CREATE DATABASE exercises OWNER admin_bd;"

# 3. Restaurar el dump binario
docker exec -i postgres_optimizacion_container pg_restore -U admin_bd -d exercises < ./data/exercises_x5.backup

# 4. Actualizar estadísticas
docker exec -it postgres_optimizacion_container psql -U admin_bd -d exercises -c "VACUUM ANALYZE;"
```

### 3. Aplicación de DDL Optimizado
```bash
docker exec -it postgres_optimizacion_container psql -U admin_bd -d exercises -f ./scripts/solucion_optimizacion_indices.sql
```

---

## 📬 Créditos & Contacto
* **Autor:** Julián Andrés Fajardo Salcedo
* **Programa:** Maestría en Analítica e Inteligencia de Negocios — Universidad del Valle
* **Correo:** andresfajardosalcedo@gmail.com
