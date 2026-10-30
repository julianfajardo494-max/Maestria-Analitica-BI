# Colombia Saludable: Sistema de Inteligencia de Negocios (BI)

**Documentación Técnica y Guía de Implementación en Docker**  
**Maestría en Analítica e Inteligencia de Negocios | Universidad del Valle, 2026**  
**Autores:** Julian Andrés Fajardo – Nicolás Galeano

---

## 1. Resumen Ejecutivo

**Colombia Saludable** es un sistema de inteligencia de negocios (BI) diseñado para integrar datos de afiliados, atenciones médicas, servicios, medicamentos y retiros de la EPS Colombia Saludable en un modelo dimensional (Data Warehouse en PostgreSQL). El sistema expone analítica avanzada a través de un tablero de seis vistas para monitorear la oportunidad asistencial, la cobertura hospitalaria, los costos, la farmacología, la estacionalidad operativa y el perfil de morbilidad.

Sobre una base de **25.269 atenciones** y **57 IPS** activas, el sistema procesa indicadores clave como un tiempo promedio de espera de 7,7 días para cita general, 5,6 días para cirugías y una oportunidad quirúrgica del 96,9 %, con un costo total acumulado de $6.761,73 millones COP.

---

## 2. Esquema y Estructura de la Base de Datos

A continuación se detalla la estructura actual del esquema público de la bodega de datos (`public`), compuesta por tablas base (dimensiones, hechos y tablas transaccionales/apoyo) y vistas analíticas normalizadas.

### 2.1 Tablas Base del Esquema (`BASE TABLE`)

| Nombre de la Tabla | Descripción / Rol en el Modelo |
| :--- | :--- |
| `dim_fecha` | Dimensión de calendario (año, mes, día, trimestre, festivos, fines de semana). |
| `dim_ips` | Dimensión de Instituciones Prestadoras de Salud (nombre, nivel, municipio, departamento). |
| `dim_diag` | Dimensión de diagnósticos clínicos y fechas asociadas. |
| `dim_medicamentos` | Catálogo farmacéutico (código, nombre, forma, presentación, laboratorio, precio, tipo). |
| `dim_medico` | Información del cuerpo médico (especialidad, subespecialidad, licencia). |
| `dim_persona` | Datos maestros de identificación y grupo familiar de los afiliados. |
| `dim_servicio` | Catálogo de servicios POS (descripción y costo base). |
| `dim_demografia` | Atributos sociodemográficos (edad, sexo, estrato, tipo de usuario, empresa, salario base). |
| `hecho_atencion` | Tabla de hechos principal (métricas de tiempo de espera y costos asociados a las atenciones). |
| `hecho_entrega` | Tabla de hechos de trazabilidad de entrega de medicamentos formulados. |
| `hecho_retiros` | Tabla de hechos para control de retiros de afiliados y portabilidad o fugas a otras EPS. |
| `trans_servicio` | Tabla operacional/transaccional que unifica las solicitudes y atenciones originales del OLTP. |
| `mas_recetados` | Tabla de apoyo con resultados de minería de reglas de asociación (`itemsets` frecuentes y soporte). |

### 2.2 Columnas y Tipos de Datos Principales

*   **`dim_demografia`**: `key_dim_demo` (integer), `numero_identificacion` (text), `fecha_nacimiento` (text), `sexo` (character), `edad` (integer), `estado_civil` (text), `tipo_discapacidad` (text), `tipo_usuario` (text), `nivel_escolaridad` (text), `estracto` (text), `proviene_otra_eps` (text), `salario_base` (text), `municipio` (text), `departamento` (text), `empresa` (text), `id_ips` (text).
*   **`dim_diag`**: `key_dim_diag` (integer), `numero_identificacion` (text), `diagnostico` (text), `fecha_diagnostico` (date).
*   **`dim_fecha`**: `key_dim_fecha` (integer), `date` (timestamp), `year` (integer), `month` (integer), `day` (integer), `weekday` (integer), `quarter` (integer), `day_of_year` (integer), `day_of_month` (integer), `month_str` (text), `day_str` (text), `date_str` (text), `"is_Holiday"` (boolean), `holiday` (text), `saved` (date), `weekend` (boolean).
*   **`dim_ips`**: `key_dim_ips` (integer), `id_ips` (text), `tipo_ips` (text), `nombre` (text), `direccion` (text), `nivel` (text), `municipio` (text), `departamento` (text), `saved` (date).
*   **`dim_medicamentos`**: `key_dim_medicamentos` (integer), `codigo` (integer), `nombre` (text), `forma` (text), `presentacion` (text), `laboratorio` (text), `precio` (double precision), `tipo` (text).
*   **`dim_medico`**: `key_dim_medico` (integer), `cedula` (text), `nombre` (text), `especialidad` (text), `subespecialidad` (text), `licencia` (text), `direccion_consultorio` (text), `id_ips` (text), `saved` (date).
*   **`dim_persona`**: `key_dim_persona` (integer), `tipo_documento` (text), `numero_identificacion` (text), `nombre` (text), `fecha_nacimiento` (timestamp), `sexo` (text), `estado_civil` (text), `tipo_discapacidad` (text), `tipo_usuario` (text), `grupo_familiar` (text), `saved` (date).
*   **`dim_servicio`**: `key_dim_servicio` (integer), `id_servicio_pos` (integer), `descripcion` (text), `costo` (integer), `saved` (date).
*   **`hecho_atencion`**: `key_hecho_atencion` (integer), `key_trans_servicio` (bigint), `key_dim_diag` (integer), `key_dim_demo` (integer), `key_fecha_atencion` (bigint), `key_fecha_solicitud` (bigint), `key_dim_persona` (bigint), `key_dim_medico` (bigint), `key_dim_ips` (bigint), `key_dim_servicio` (bigint), `tiempo_espera_dias` (bigint), `tiempo_espera_minutos` (integer), `tiempo_espera_horas` (integer), `tiempo_espera_segundos` (integer), `costo` (integer), `saved` (date).
*   **`hecho_entrega`**: `key_hecho_entrega` (integer), `codigo_formula` (integer), `key_dim_demo` (integer), `key_dim_medicamentos` (integer), `key_dim_persona` (integer), `key_dim_medico` (integer), `key_dim_fecha` (integer), `precio` (double precision).

---

## 3. Vistas Analíticas (Capa Semántica)

Las vistas centralizan la lógica de negocio y uniones dimensionales para alimentar de forma limpia el tablero de control:

| Vista Analítica (`VIEW`) | Definición SQL de la Vista |
| :--- | :--- |
| **`vw_analitica_ips_demografia`** | `SELECT h.key_hecho_atencion, h.costo, h.tiempo_espera_dias, i.nombre AS nombre_ips, i.tipo_ips, i.municipio AS municipio_ips, i.departamento AS departamento_ips, i.nivel AS nivel_ips, d.sexo, d.edad, d.estracto, d.tipo_usuario, d.empresa, d.municipio AS municipio_paciente, d.departamento AS departamento_paciente, dg.diagnostico, dg.fecha_diagnostico FROM (((hecho_atencion h LEFT JOIN dim_ips i ON ((h.key_dim_ips = i.key_dim_ips))) LEFT JOIN dim_demografia d ON ((h.key_dim_demo = d.key_dim_demo))) LEFT JOIN dim_diag dg ON ((h.key_dim_diag = dg.key_dim_diag)));` |
| **`vw_tiempos_espera_oportunidad`** | `SELECT h.key_hecho_atencion, h.key_dim_ips, h.key_dim_servicio, s.descripcion AS nombre_servicio, h.costo, h.tiempo_espera_dias, h.tiempo_espera_horas, h.tiempo_espera_minutos, f.date AS fecha_atencion_date FROM ((hecho_atencion h LEFT JOIN dim_servicio s ON ((h.key_dim_servicio = s.key_dim_servicio))) LEFT JOIN dim_fecha f ON ((h.key_fecha_atencion = f.key_dim_fecha)));` |
| **`vw_analitica_financiera_detallada`** | `SELECT h.key_hecho_atencion, h.costo, p.numero_identificacion, p.nombre AS nombre_afiliado, p.grupo_familiar, d.empresa, d.estracto, d.tipo_usuario, i.municipio, i.departamento FROM (((hecho_atencion h LEFT JOIN dim_persona p ON ((h.key_dim_persona = p.key_dim_persona))) LEFT JOIN dim_demografia d ON ((h.key_dim_demo = d.key_dim_demo))) LEFT JOIN dim_ips i ON ((h.key_dim_ips = i.key_dim_ips)));` |
| **`vw_utilizacion_servicios_tiempo`** | `SELECT h.key_hecho_atencion, f.day_str AS dia_semana, p.sexo, h.costo FROM ((hecho_atencion h LEFT JOIN dim_fecha f ON ((h.key_fecha_atencion = f.key_dim_fecha))) LEFT JOIN dim_persona p ON ((h.key_dim_persona = p.key_dim_persona)));` |
| **`vw_farmacologia_entregas`** | `SELECT h.key_hecho_entrega, h.codigo_formula, h.precio AS precio_entrega, m.codigo AS codigo_medicamento, m.nombre AS nombre_medicamento, m.forma, m.presentacion, m.laboratorio, m.tipo AS tipo_medicamento FROM (hecho_entrega h LEFT JOIN dim_medicamentos m ON ((h.key_dim_medicamentos = m.key_dim_medicamentos)));` |
| **`vw_estacionalidad_atenciones`** | `SELECT h.key_hecho_atencion, f.date AS fecha_atencion_date, f.year, f.month, f.day, f.weekday, f.quarter, f.day_of_year, f.day_of_month, f.month_str, f.day_str, f.date_str, f."is_Holiday", f.holiday, f.saved, f.weekend, h.costo, p.sexo, p.fecha_nacimiento, EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) AS edad, CASE WHEN (p.fecha_nacimiento IS NULL) THEN 'Sin Rango'::text WHEN ((EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) >= (0)::numeric) AND (EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) <= (18)::numeric)) THEN '01. 0-18 años'::text WHEN ((EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) >= (19)::numeric) AND (EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) <= (30)::numeric)) THEN '02. 19-30 años'::text WHEN ((EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) >= (31)::numeric) AND (EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) <= (50)::numeric)) THEN '03. 31-50 años'::text ELSE '04. 51+ años'::text END AS rango_edad, ((CASE WHEN (p.fecha_nacimiento IS NULL) THEN 'Sin Rango'::text WHEN ((EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) >= (0)::numeric) AND (EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) <= (18)::numeric)) THEN '01. 0-18 años'::text WHEN ((EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) >= (19)::numeric) AND (EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) <= (30)::numeric)) THEN '02. 19-30 años'::text WHEN ((EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) >= (31)::numeric) AND (EXTRACT(year FROM age((CURRENT_DATE)::timestamp without time zone, p.fecha_nacimiento)) <= (50)::numeric)) THEN '03. 31-50 años'::text ELSE '04. 51+ años'::text END \|\| ' - '::text) \|\| COALESCE(p.sexo, 'N/D'::text)) AS rango_edad_sexo, CASE f.weekday WHEN 1 THEN '1. Dom'::text WHEN 2 THEN '2. Lun'::text WHEN 3 THEN '3. Mar'::text WHEN 4 THEN '4. Mié'::text WHEN 5 THEN '5. Jue'::text WHEN 6 THEN '6. Vie'::text WHEN 7 THEN '7. Sáb'::text ELSE 'Otro'::text END AS dia_espanol, he.key_hecho_entrega, he.codigo_formula, he.precio AS precio_entrega, m.codigo AS codigo_medicamento, m.nombre AS nombre_medicamento, m.forma, m.presentacion, m.laboratorio, m.tipo AS tipo_medicamento, CASE WHEN (f.month = 12) THEN 'Navidad'::text WHEN (f.month = ANY (ARRAY[6, 7])) THEN 'Vacaciones'::text WHEN (f.month = ANY (ARRAY[3, 4])) THEN 'Semana Santa'::text ELSE 'Operación Normal'::text END AS epoca_estacional FROM ((((hecho_atencion h LEFT JOIN dim_fecha f ON ((h.key_fecha_atencion = f.key_dim_fecha))) LEFT JOIN dim_persona p ON ((h.key_dim_persona = p.key_dim_persona))) LEFT JOIN hecho_entrega he ON ((h.key_hecho_atencion = he.key_hecho_entrega))) LEFT JOIN dim_medicamentos m ON ((he.key_dim_medicamentos = m.key_dim_medicamentos)));` |
| **`vw_mortalidad_epidemiologia`** | `SELECT h.key_hecho_atencion, p.sexo, d.diagnostico, dem.estracto, f.date AS fecha_atencion_date, f.year, f.month, h.costo FROM ((((hecho_atencion h LEFT JOIN dim_persona p ON ((h.key_dim_persona = p.key_dim_persona))) LEFT JOIN dim_diag d ON ((h.key_dim_diag = d.key_dim_diag))) LEFT JOIN dim_demografia dem ON ((h.key_dim_demo = dem.key_dim_demo))) LEFT JOIN dim_fecha f ON ((h.key_fecha_atencion = f.key_dim_fecha)));` |

---

## 4. Implementación en Docker

Para desplegar este entorno de base de datos analítica por completo utilizando Docker, se proveen los siguientes archivos de configuración.

### 4.1 `Dockerfile`
```dockerfile
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    psycopg2-binary \
    pandas \
    numpy \
    SQLAlchemy

COPY . /app
```

### 4.2 `requirements.txt`
```text
psycopg2-binary>=2.9.0
pandas>=1.3.0
numpy>=1.20.0
SQLAlchemy>=1.4.0
```

### 4.3 `docker-compose.yml`
```yaml
version: '3.8'

services:
  db:
    image: postgres:14-alpine
    container_name: colombia_saludable_postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: colombia_saludable_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./sql:/docker-entrypoint-initdb.d/

  app:
    build: .
    container_name: colombia_saludable_app
    depends_on:
      - db
    environment:
      - DB_HOST=db
      - DB_PORT=5432
      - DB_NAME=colombia_saludable_db
      - DB_USER=postgres
      - DB_PASSWORD=postgres
    volumes:
      - .:/app
    command: python -c "print('Entorno de Colombia Saludable configurado con éxito')"

volumes:
  postgres_data:
```

---

## 5. Instrucciones de Ejecución

1. Organiza tus archivos en la siguiente estructura en tu equipo local:
   ```text
   colombia-saludable-docker/
   ├── Dockerfile
   ├── docker-compose.yml
   ├── requirements.txt
   └── sql/
       └── bodega_23_10_2026.sql (o tus scripts de volcado sql)
   ```
2. Ejecuta el comando de despliegue mediante Docker Compose:
   ```bash
   docker-compose up --build -d
   ```
3. Valida la correcta inicialización interactuando con la base de datos:
   ```bash
   docker exec -it colombia_saludable_postgres psql -U postgres -d colombia_saludable_db
   ```