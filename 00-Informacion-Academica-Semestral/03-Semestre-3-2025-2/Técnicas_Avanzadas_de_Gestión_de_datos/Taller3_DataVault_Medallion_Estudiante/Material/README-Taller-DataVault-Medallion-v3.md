# 🏛️ Taller Práctico: Data Vault 2.0 y Arquitectura Medallion en RetailNova

> **Maestría en Analítica e Inteligencia de Negocios — Universidad del Valle**  
> **Módulo / Asignatura:** Almacenamiento y Modelado de Datos para Analítica (Semestre III)  
> **Autores:** Julián Andrés Fajardo Salcedo & Nicolás Galeano  
> **Caso de Estudio:** RetailNova Colombia  
> **Stack Tecnológico:** PostgreSQL 16 | Docker & Docker Compose | psql CLI | Data Vault 2.0 | Medallion Architecture (Bronze / Silver / Gold)  

---

## 📌 Metodología STAR — Resumen Ejecutivo

| Fase | Descripción Clave |
| :--- | :--- |
| **S — Situación** | RetailNova operaba con fuentes de datos desacopladas (CRM, ERP, POS) con esquemas heterogéneos, errores de digitación, reenvíos de transacciones y mutabilidad de datos que destruían la trazabilidad histórica al sobrescribir registros en modelos relacionales tradicionales. |
| **T — Tarea** | Diseñar e implementar un almacén de datos moderno bajo la **Arquitectura Medallion** (Bronze, Silver y Gold), integrando **Data Vault 2.0** en la capa Silver para garantizar absorción *Insert-Only*, idempotencia mediante claves Hash (MD5), versionado por satélites (`hash_diff`) y entrega analítica en Gold con **SCD Tipo 2**. |
| **A — Acción** | Despliegue de PostgreSQL en Docker; orquestación de ingesta incremental en 3 lotes (marzo, junio y septiembre de 2026); diseño físico de 4 tablas Bronze, 8 tablas Silver (3 Hubs, 1 Link, 4 Satélites), 1 vista de Business Vault y 4 vistas dimensionales en Gold; implementación de procedimientos almacenados `silver.cargar_lote()` con hashing determinista. |
| **R — Resultado** | Procesamiento exitoso de 15 transacciones comerciales netas (\$1.380.300 facturados); detección automática de reenvíos idénticos (`V-3311`) y correcciones transaccionales (`V-4021`); auditoría cruzada exacta hacia el archivo fuente; y resolución nativa de consultas *Point-In-Time* y análisis comparativo *As-Was* vs. *As-Is*. |

---

## 🚨 S — Situación (Problemática & Contexto de Negocio)

### 🏢 Contexto Organizacional
**RetailNova** es una cadena de comercio minorista en Colombia en fase de expansión, conformada por 12 tiendas físicas distribuidas en Cali, Palmira, Jamundí y Yumbo, con planes de apertura en Bogotá y lanzamiento de su canal de comercio electrónico.

### ⚠️ Problemática Técnica y Analítica
La infraestructura analítica previa basada en modelos estrella rígidos o bases relacionales tradicionales presentaba fallas críticas:
1. **Destrucción de la Historia por `UPDATE`:** Cuando un cliente cambiaba de residencia o se corregía una factura, el sistema sobrescribía el registro previo, imposibilitando reconstruir estados financieros pasados requeridos por revisoría fiscal y auditoría.
2. **Fragilidad ante Cambios de Esquema:** Cada modificación en los sistemas operacionales de origen (CRM, ERP o POS) obligaba a ejecutar `ALTER TABLE` masivos y reescribir pipelines de extracción y transformación.
3. **Falta de Trazabilidad (*Data Lineage*):** Imposibilidad técnica de justificar ante un auditor de qué archivo plano exacto provino una cifra errónea o en qué fecha llegó una corrección contable.
4. **Vulnerabilidad ante Reenvíos:** La llegada duplicada de ventas por fallas de conectividad en los puntos de venta distorsionaba los reportes financieros al duplicar ingresos.

---

## 🎯 T — Tarea (Objetivo Técnico & Alcance)

### 📐 Objetivos Específicos
1. **Modelar la Arquitectura Medallion en PostgreSQL:**
   * **Bronze:** Ingesta cruda *Append-Only* preservando tipos de datos textuales y metadatos de auditoría (`_archivo`, `_cargado`).
   * **Silver (Raw Vault):** Separación estricta de conceptos de negocio en **Hubs** (identidad del negocio), **Links** (asociaciones y transacciones) y **Satélites** (atributos descriptivos versionados con `hash_diff`).
   * **Silver (Business Vault):** Aplicación de reglas de estandarización y calidad (limpieza de espacios y capitalización) sin destruir la evidencia del Raw Vault.
   * **Gold (Information Marts):** Publicación de un **Esquema Estrella** desnormalizado con soporte de dimensiones históricas lentas (**SCD Tipo 2**) y una tabla de hechos consolidada.
2. **Automatizar la Carga Incremental:** Construir un procedimiento almacenado idempotente (`silver.cargar_lote`) capaz de procesar múltiples lotes temporales sin intervención manual.
3. **Validar Casos de Borde de Negocio:**
   * Reenvío idéntico de transacciones (idempotencia en `link_venta` y `sat_venta_pos`).
   * Corrección transaccional descendente (venta `V-4021` de 5 a 4 unidades).
   * Migración de residencia de clientes (Ana Torres: Cali → Bogotá).
   * Mutación tipográfica en origen (Sofía Lara: `"cali"` → `"Cali"`).
   * Análisis temporal dual: Comparar ventas *As-Was* (dónde vivía al comprar) vs. *As-Is* (dónde vive hoy).

---

## ⚙️ A — Acción (Desarrollo Técnico & Arquitectura)

### 🏗️ Arquitectura de Datos Implementada

![Arquitectura Medallion y Data Vault 2.0 en RetailNova](./evidencias/arquitectura_medallion_datavault_retailnova.png)

*Figura 1: Pipeline end-to-end implementado en PostgreSQL 16 para RetailNova, integrando la ingestión Append-Only en Bronze, el modelado Data Vault 2.0 (Hubs, Links, Satélites y Business Vault) en Silver y la entrega dimensional en Gold con SCD Tipo 2.*

---

### 🛠️ Fases de Implementación Técnica

#### 1. Diseño DDL y Estructura Hash en Silver
Se implementaron funciones deterministas `MD5(UPPER(TRIM(clave)))` para desacoplar las dependencias de secuencias relacionales y permitir cargas altamente concurrentes:
* **Hubs:** `hk_cliente`, `hk_producto`, `hk_tienda`.
* **Links:** `hk_venta` calculada sobre cliente, producto, tienda y ticket.
* **Satélites:** Clave primaria compuesta `(hk_..., load_date)` e inclusión del campo `hash_diff` para auditar mutaciones en atributos descriptivos.

#### 2. Procedimiento Almacenado de Propagación Idempotente
Se programó el procedimiento `silver.cargar_lote(p_lote DATE)` ejecutando la lógica ELT:
* Inserción en Hubs con cláusula `WHERE NOT EXISTS`.
* Inserción en Links validando unicidad de relación.
* Inserción en Satélites condicionada matemáticamente a:
  ```sql
  WHERE ult.hash_diff IS DISTINCT FROM n.hd
  ```
  garantizando que únicamente las variaciones reales de atributos creen una nueva versión física.

#### 3. Estandarización en Business Vault
Creación de la vista `silver.bv_cliente_estandar` para absorber discrepancias tipográficas (`"cali"` vs `"Cali"`) sin modificar el registro crudo de auditoría:
```sql
CREATE OR REPLACE VIEW silver.bv_cliente_estandar AS
SELECT hk_cliente,
       load_date,
       nombre,
       initcap(trim(ciudad)) AS ciudad,
       segmento
FROM silver.sat_cliente_crm;
```

#### 4. Modelado Dimensional en Capa Gold
* **Dimensión Cliente SCD Tipo 2:** Construida mediante funciones de ventana analítica (`LEAD` sobre `WINDOW w AS (PARTITION BY b.hk_cliente ORDER BY b.load_date)`), generando los intervalos cerrados `fecha_inicio` y `fecha_fin`, además de la bandera booleana `vigente`.
* **Tabla de Hechos `gold.fact_ventas`:** Resuelta mediante `DISTINCT ON (l.hk_venta) ... ORDER BY l.hk_venta, s.load_date DESC`, exponiendo siempre el estado verídico más reciente de cada venta.

---

## 📊 R — Resultados (Validación, Métricas e Impacto)

### 📈 1. Bitácora de Cargas Incrementales (Anexo A)

Evolución auditada del volumen de filas en la capa Silver a lo largo de los tres lotes temporales:

| Tabla en Silver | Lote 1 (Marzo 2026) | Lote 2 (Junio 2026) | Lote 3 (Septiembre 2026) | Interpretación del Cambio |
| :--- | :---: | :---: | :---: | :--- |
| **`hub_cliente`** | 5 | 6 | **6** | Incorporación de nuevo cliente `CLI-006` en junio. |
| **`hub_producto`** | 6 | 6 | **6** | Catálogo base completo desde el lote inicial. |
| **`hub_tienda`** | 4 | 4 | **4** | Red de sucursales estable (Cali, Palmira, Jamundí, Yumbo). |
| **`link_venta`** | 8 | 12 | **15** | +4 ventas en L2 (descarte de reenvío `V-3311`); +3 ventas en L3. |
| **`sat_cliente_crm`** | 5 | 7 | **8** | Versión 2 de Ana Torres (Cali → Bogotá); Versión 3 (Oro); V2 Sofía Lara. |
| **`sat_producto_erp`** | 6 | 7 | **7** | Actualización de precio en producto `P-006` durante junio. |
| **`sat_tienda_erp`** | 4 | 4 | **4** | Sin modificaciones en metadatos de sedes. |
| **`sat_venta_pos`** | 8 | 12 | **16** | +4 ventas nuevas en L2; +3 ventas nuevas en L3 + **1 corrección en `V-4021`**. |

---

### 🔬 2. Casos de Estudio de Negocio Demostrados

#### A. Idempotencia ante Reenvíos del POS (`V-3311`)
En el Lote 2 se reenvió el ticket `V-3311` (ya cargado en marzo). El modelo:
* **No insertó nueva fila en `link_venta`** (la clave compuesta ya existía).
* **No insertó nueva fila en `sat_venta_pos`** (el `hash_diff` fue idéntico).
* **Preservó la evidencia en Bronze** (`bronze.pos_ventas` almacena ambos arribos en `_archivo = 'pos_ventas_20260310.csv'` y `_archivo = 'pos_ventas_20260602.csv'`).

#### B. Versionado de Corrección Transaccional (`V-4021`)
En septiembre el POS corrigió la venta `V-4021`:
* **Versión Junio:** 5 unidades de `LEC-1L` (\$20.500).
* **Versión Septiembre:** 4 unidades de `LEC-1L` (\$16.400).
* **Comportamiento:** `sat_venta_pos` almacenó ambas versiones sin destruir la previa. `gold.fact_ventas` reflejó la cifra corregida (\$16.400) totalizando **15 líneas de venta por un valor neto de \$1.380.300**.

#### C. Trazabilidad Cruzada de Auditoría (Paso 34)
```sql
SELECT l.ticket, p.producto_id, s.load_date::date AS llego_el,
       s.cantidad, s.monto, s.record_source, b._archivo
FROM silver.sat_venta_pos s
JOIN silver.link_venta   l USING (hk_venta)
JOIN silver.hub_producto p USING (hk_producto)
JOIN bronze.pos_ventas   b
  ON upper(trim(b.ticket)) = l.ticket
 AND upper(trim(b.producto_id)) = p.producto_id
 AND b._cargado = s.load_date
WHERE l.ticket = 'V-4021';
```
*Demostró fehacientemente de qué archivo CSV físico (`_archivo`) provino cada estado financiero.*

---

### 🗺️ 3. Análisis Comparativo: *As-Was* vs. *As-Is* (Pregunta 8)

El análisis de ventas por ciudad reveló el impacto del versionado temporal:

```text
REPORTE 1: ¿Dónde vivía al comprar? (As-Was)  │  REPORTE 2: ¿Dónde vive hoy? (As-Is)
 ciudad_al_comprar | lineas |   ventas        │   ciudad_actual | lineas |   ventas   
-------------------+--------+-------------    │  ---------------+--------+------------
 Cali              |      6 |  $793.300       │   Bogotá        |      4 | $1.113.000
 Bogotá            |      2 |  $434.000       │   Cali          |      4 |   $114.300
 Palmira           |      4 |   $97.000       │   Palmira       |      4 |    $97.000
 Jamundí           |      2 |   $37.100       │   Jamundí       |      2 |    $37.100
 Yumbo             |      1 |   $18.900       │   Yumbo         |      1 |    $18.900
 TOTAL             |     15 | $1.380.300      │   TOTAL         |     15 | $1.380.300
```

* **Explicación:** Ana Torres (`CLI-001`) compró \$678.700 en marzo viviendo en Cali (`V-3311` y `V-3312`) y se mudó a Bogotá en junio.
* **Valor para el Negocio:** 
  * El reporte **As-Was** es el correcto para **contabilidad, impuestos y logística territorial**.
  * El reporte **As-Is** es el correcto para **marketing, fidelización y Customer Lifetime Value (CLV)**.

---

### ⚖️ 4. Comparativa Arquitectónica: Data Vault 2.0 vs. Esquema Estrella (Taller 2)

| Criterio de Comparación | Esquema Estrella Clásico (Taller 2) | Data Vault 2.0 + Medallion (Taller 3) |
| :--- | :--- | :--- |
| **Volumen de Tablas** | 4 a 5 tablas físicas (1 Fact, 4 Dim). | 12 tablas físicas (4 Bronze, 8 Silver) + 5 vistas analíticas. |
| **Manejo de Cambios Históricos** | Destructivo por defecto (`UPDATE`) a menos que se configure SCD2 manual. | Inmutable por diseño (*Insert-Only* universal en satélites). |
| **Resiliencia ante Nuevas Fuentes** | Baja; requiere `ALTER TABLE` y rediseñar pipelines existentes. | Alta; se agregan nuevos Hubs/Links/Satélites por adición sin tocar lo existente. |
| **Auditoría y Linaje** | Débil; se pierde el archivo y lote de origen de la transacción. | Total; trazabilidad cruzada hasta el CSV crudo en Bronze. |
| **Costo Computacional de Consulta** | Muy bajo (pocos JOINs optimizados para BI). | Alto en Silver (muchos JOINs); resuelto al materializar vistas en Gold. |

---

### 💡 5. Recomendación Estratégica para RetailNova (Equipo de 4 personas)

* **Fase Actual (Corto Plazo / 12 Tiendas):**
  * **No desplegar Data Vault completo en producción de inmediato.** Para un equipo de 1 líder, 2 ingenieros de datos y 1 analista de BI, la sobrecarga operativa de mantener más de 17 objetos de base de datos introduce complejidad innecesaria.
  * **Recomendación:** Implementar una **Arquitectura Medallion Pragmática**:
    * **Bronze:** Ingesta cruda inmutable con metadatos (`_archivo`, `_cargado`) en almacenamiento en disco/S3.
    * **Silver:** Limpieza y modelado dimensional directo (**Esquema Estrella con SCD Tipo 2**).
    * **Gold:** Vistas o tablas compactadas para Power BI.
* **Fase de Expansión (Mediano y Largo Plazo / E-Commerce, Fidelización, 50+ Tiendas):**
  * Migrar la capa Silver a **Data Vault 2.0** cuando se incorporen fuentes altamente heterogéneas con esquemas cambiantes, adoptando herramientas de automatización de código como **dbt** (*Data Build Tool*) para eliminar la codificación manual de Hubs, Links y Satélites.

---

## 🚀 Guía de Reproducción Técnica

### 1. Despliegue del Entorno
```bash
# Iniciar contenedor Docker de PostgreSQL
docker compose up -d

# Conectarse a la sesión interactiva de psql
docker exec -it postgres_db psql -U postgres -d retailnova_dv
```

### 2. Flujo de Ejecución por Lotes
```sql
-- 1. Ingesta Lote 1 (Marzo 2026) en Bronze y propagación
SET taller.lote = '2026-03-10';
-- [\copy de archivos CSV a bronze...]
CALL silver.cargar_lote('2026-03-10');

-- 2. Ingesta Lote 2 (Junio 2026)
SET taller.lote = '2026-06-02';
-- [\copy de archivos CSV a bronze...]
CALL silver.cargar_lote('2026-06-02');

-- 3. Ingesta Lote 3 (Septiembre 2026)
SET taller.lote = '2026-09-10';
-- [\copy de archivos CSV a bronze...]
CALL silver.cargar_lote('2026-09-10');

-- 4. Creación de Capa Gold y Validación
SELECT count(*) AS lineas, SUM(monto) AS total FROM gold.fact_ventas;
-- Esperado: 15 líneas | $1.380.300.00
```

---

## 📬 Créditos & Equipo de Trabajo
* **Julián Andrés Fajardo Salcedo** — M.Sc.(c) Analítica e Inteligencia de Negocios
* **Nicolás Galeano** — M.Sc.(c) Analítica e Inteligencia de Negocios
* **Programa:** Maestría en Analítica e Inteligencia de Negocios — Universidad del Valle
* **Docente / Asignatura:** Almacenamiento y Modelado de Datos para Analítica (Semestre III)
