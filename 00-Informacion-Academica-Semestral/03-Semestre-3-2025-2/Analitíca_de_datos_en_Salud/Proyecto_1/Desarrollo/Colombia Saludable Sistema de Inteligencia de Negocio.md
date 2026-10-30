# Colombia Saludable: Sistema de Inteligencia de Negocios para la Gestión y Análisis de la Salud en Colombia

**Documento de sustentación de trabajo de grado**

Autores: Julian Andrés Fajardo – Nicolás Galeano

Maestría en Analítica e Inteligencia de Negocios | Universidad del Valle, 2026

## 1. Resumen ejecutivo

Colombia Saludable es un sistema de inteligencia de negocios (BI) que integra datos de afiliados, atenciones, servicios, medicamentos y retiros de la nueva EPS Colombia Saludable (sustituta del antiguo ISS) en un modelo dimensional (data warehouse) y los expone mediante un tablero analítico de seis páginas. El sistema permite monitorear la oportunidad asistencial, la cobertura hospitalaria, los costos, la farmacología, la estacionalidad operativa y el perfil de morbilidad de la población atendida.

Sobre una base de **25.269 atenciones** y **57 IPS** activas en la red, el sistema reporta un tiempo promedio de espera de **7,7 días** para cita general, **5,6 días** para cirugías y **8,8 días** para especialistas, con una oportunidad quirúrgica del **96,9 %** y un costo total acumulado de **$6.761,73 millones COP**.

El aporte central del trabajo es convertir datos transaccionales dispersos en indicadores accionables para la toma de decisiones de gestión en salud: dónde se concentra la demanda, qué servicios presentan cuellos de botella, qué empresas y grupos familiares generan mayor costo, y cuándo es necesario reforzar la capacidad operativa.

## 2. Contexto y planteamiento del problema

El sistema de salud colombiano opera con múltiples actores (EPS, IPS, empresas contratantes, afiliados y proveedores de medicamentos) que generan grandes volúmenes de información en sistemas separados. Esta fragmentación dificulta:

- Medir de forma consistente la **oportunidad en la atención** (tiempo entre la solicitud y la prestación del servicio).
- Conocer la **carga financiera** por empresa, grupo familiar y territorio.
- Identificar **patrones de morbilidad** y de prescripción por edad, sexo y estrato.
- Anticipar **picos de demanda** asociados a temporadas (Semana Santa, vacaciones, Navidad).

**Pregunta de investigación:** ¿Cómo puede un sistema de inteligencia de negocios basado en un modelo dimensional integrar y analizar los datos de atención, costos y prescripción de una red de salud para apoyar decisiones de gestión asistencial y financiera?

### 2.1 Alcance según el enunciado del cliente

El gobierno contrató el proyecto para poner en marcha la EPS Colombia Saludable, sustituta del antiguo ISS. El enunciado exige dos entregables: (1) un dashboard sobre una bodega de datos que responda diez preguntas de gestión y (2) un dashboard sobre la base de datos transaccional que responda las tres primeras. De las diez preguntas, el tablero actual cubre cinco por completo y cinco de forma parcial.

| # | Pregunta del cliente | Vista del tablero | Estado | Ajuste sugerido |
| --- | --- | --- | --- | --- |
| 1 | Tiempo promedio de espera entre asignación de cita y atención | Oportunidad asistencial (7,7 días) | Cubierto | Ninguno |
| 2 | Tiempos de espera en cirugías | Oportunidad asistencial (5,6 días y espera por servicio) | Cubierto | Ninguno |
| 3 | Centros hospitalarios que más atienden por región y ciudad | Demografía y cobertura (mapa y Top 10 IPS) | Cubierto | Agregar filtro por departamento o región |
| 4 | Pagos por afiliado, grupo familiar, empresa, ciudad y regional | Analítica financiera | Parcial | Falta gráfico por ciudad y regional; recalcular costo por afiliado único |
| 5 | Medicinas que se formulan con más frecuencia | Farmacología (Top 10) | Cubierto | Distinguir genéricos y comerciales con el campo `tipo` de `dim_medicamentos` |
| 6 | Utilización promedio de servicios por paciente, sexo y edad | Farmacología (demanda por edad y sexo) | Parcial | Mostrar promedio de atenciones por paciente, no solo conteo |
| 7 | Ocupación de hospitales y médicos según época del año | Estacionalidad (atenciones por mes y época) | Parcial | Agregar carga por médico y por IPS; la ocupación de camas no está en el modelo |
| 8 | Épocas con más espera y más enfermos; días de mayor demanda | Estacionalidad (día de la semana y mes) | Parcial | Agregar tiempo de espera y diagnósticos por época |
| 9 | Regiones con más demanda de servicios | Demografía y cobertura (mapa) | Cubierto | Ninguno |
| 10 | Enfermedades más frecuentes por género, edad y estrato | Enfermedades por sexo y estrato | Parcial | Falta la dimensión de edad (grupos etarios) |

## 3. Objetivos

### 3.1 Objetivo general

Diseñar e implementar un sistema de inteligencia de negocios que integre y analice datos de salud en Colombia para apoyar la toma de decisiones de gestión asistencial, financiera y operativa.

### 3.2 Objetivos específicos

1. Diseñar un modelo dimensional (esquema de constelación de hechos) a partir de las fuentes transaccionales de afiliación, servicios, entrega de medicamentos y retiros.
2. Construir los procesos de extracción, transformación y carga (ETL) que alimenten el data warehouse.
3. Definir indicadores clave (KPIs) de oportunidad, cobertura, costo, farmacología y estacionalidad.
4. Desarrollar un tablero interactivo de seis vistas sobre la bodega de datos y un tablero complementario sobre la base transaccional que responda las tres primeras preguntas del cliente.
5. Aplicar técnicas de minería de datos (reglas de asociación) para identificar patrones de co-prescripción de medicamentos.
6. Validar los resultados e identificar hallazgos, limitaciones y recomendaciones.

## 4. Marco conceptual

- **Inteligencia de negocios (BI):** conjunto de procesos, arquitecturas y herramientas que transforman datos en información útil para la decisión.
- **Data warehouse y modelado dimensional (Kimball):** organización de los datos en tablas de hechos (eventos medibles) y dimensiones (contexto descriptivo) para facilitar el análisis multidimensional.
- **ETL:** proceso de extracción, transformación y carga de datos desde las fuentes hacia el almacén analítico.
- **KPI:** indicador clave de desempeño que permite medir el cumplimiento de metas.
- **Oportunidad asistencial:** tiempo transcurrido entre la solicitud de un servicio y su prestación; es un indicador de calidad reconocido en el sistema de salud colombiano.
- **Reglas de asociación (Apriori / FP-Growth):** técnica de minería de datos que identifica conjuntos de ítems que ocurren frecuentemente juntos, medidos por soporte, confianza y lift.

## 5. Arquitectura de la solución

La solución sigue una arquitectura por capas:

1. **Fuentes:** datos de afiliados (demografía y persona), servicios solicitados y atendidos, entrega de medicamentos, diagnósticos, IPS, médicos y retiros.
2. **Capa de integración (ETL):** limpieza, estandarización, cálculo de tiempos de espera y asignación de llaves sustitutas. Las tablas incluyen un campo `saved` que registra la fecha de carga y permite trazabilidad.
3. **Data warehouse (PostgreSQL):** modelo dimensional con dimensiones y tablas de hechos.
4. **Capa analítica:** consultas SQL, cálculo de métricas y minería de patrones (tabla `mas_recetados`).
5. **Capa de visualización:** tablero de seis páginas con navegación lateral, filtros y mapa geográfico (Google Maps).

### 5.1 Fuentes de datos: base transaccional (OLTP) y bodega (OLAP)

El proyecto trabaja con dos bases de datos PostgreSQL que cumplen funciones distintas. La **base OLTP** (Online Transaction Processing) es el sistema operacional: registra el día a día de la EPS (afiliaciones, citas, remisiones, fórmulas y pagos). La **bodega OLAP** (Online Analytical Processing) es la base analítica: reorganiza esos datos en un modelo dimensional para responder preguntas de gestión.

| Aspecto | OLTP (operacional) | OLAP (bodega) |
| --- | --- | --- |
| Propósito | Registrar y gestionar la operación | Analizar y apoyar decisiones |
| Diseño | Normalizado, con llaves naturales (cédula, código) | Dimensional (hechos y dimensiones), con llaves sustitutas `key_*` |
| Operaciones típicas | Insertar, actualizar y consultar registros individuales | Agregar y cruzar muchas filas por tiempo, lugar y persona |
| Datos | Estado actual, una fila por transacción | Histórico consolidado, con calendario y medidas derivadas (espera, costo) |
| Usuarios | Personal administrativo y asistencial | Directivos y analistas |
| En el proyecto | `colombia_saludable_OLTP.sql`: 18 tablas | `bodega_23_10_2026`: 13 tablas y 7 vistas (el volcado del 23/10/2026, PostgreSQL 14.13, solo incluye las tablas) |

**Tablas de la base OLTP** (filas entre paréntesis):

| Dominio | Tablas |
| --- | --- |
| Afiliación | `cotizante` (1.100), `beneficiario` (3.316), `cotizante_beneficiario` (3.316), `empresa` (21), `empresa_cotizante` (925), `preexistencias` (4.416), `retiros` (89) |
| Prestación de servicios | `citas_generales` (3.013), `urgencias` (559), `hospitalizaciones` (893), `remisiones` (16.742), `servicios_pos` (67) |
| Red prestadora | `ips` (86), `medico` (720) |
| Medicamentos | `formulas_medicas` (7.484), `drogueria` (35), `ips_drogueria` (73) |
| Pagos | `pagos` (22.938) |

**Tablas de la bodega OLAP:**

| Tipo | Tablas |
| --- | --- |
| Hechos | `hecho_atencion` (25.269), `hecho_entrega` (14.622), `hecho_retiros` (925) |
| Dimensiones | `dim_demografia` (4.241), `dim_diag` (21.055), `dim_fecha` (1.462), `dim_ips` (86), `dim_medicamentos` (262), `dim_medico` (720), `dim_persona` (4.416), `dim_servicio` (67) |
| Apoyo | `trans_servicio` (21.207, atenciones unificadas del OLTP), `mas_recetados` (7, conjuntos frecuentes de la minería de reglas) |

**Cómo se alimenta la bodega desde el OLTP** (proceso ETL):

| Origen (OLTP) | Destino (OLAP) |
| --- | --- |
| `citas_generales`, `urgencias`, `hospitalizaciones`, `remisiones` | `trans_servicio` y luego `hecho_atencion` (21.207 = 3.013 + 559 + 893 + 16.742) |
| `cotizante`, `beneficiario`, `cotizante_beneficiario` | `dim_persona` (4.416 = 1.100 + 3.316) y `dim_demografia` |
| `ips`, `medico`, `servicios_pos` | `dim_ips` (86), `dim_medico` (720), `dim_servicio` (67) |
| Campo `diagnostico` de las cuatro tablas de atención | `dim_diag` |
| `formulas_medicas` | `hecho_entrega`; el catálogo de `dim_medicamentos` no aparece en el script OLTP |
| `retiros` | `hecho_retiros` |
| `empresa` | Atributo `empresa` de `dim_demografia` |
| `pagos`, `preexistencias`, `drogueria` | Sin tabla de hechos propia en la bodega |

El script `bodega_OLAP.sql` (7 tablas y 4.465 atenciones) es una versión anterior de la bodega y no debe usarse como referencia.

## 6. Modelo de datos

Se implementó un **esquema de constelación de hechos**: varias tablas de hechos comparten dimensiones conformadas.

### 6.1 Tablas de hechos

| Tabla | Proceso de negocio | Medidas principales |
| --- | --- | --- |
| `hecho_atencion` | Atención de servicios de salud | `tiempo_espera_dias/horas/minutos/segundos`, `costo` |
| `hecho_entrega` | Entrega de medicamentos formulados | `precio`, `codigo_formula` |
| `hecho_retiros` | Retiro de afiliados y cambio de EPS | `retirado`, `cambio_a_eps` |

### 6.2 Dimensiones

| Dimensión | Descripción |
| --- | --- |
| `dim_demografia` | Edad, sexo, estado civil, discapacidad, tipo de usuario, escolaridad, estrato, salario base, municipio, departamento, empresa e IPS asignada |
| `dim_persona` | Datos de identificación y grupo familiar |
| `dim_diag` | Diagnóstico y fecha de diagnóstico |
| `dim_fecha` | Calendario: año, mes, día, trimestre, día de la semana, festivos y fin de semana |
| `dim_ips` | Tipo, nombre, nivel de complejidad, dirección y ubicación de la IPS |
| `dim_medico` | Especialidad, subespecialidad y licencia |
| `dim_medicamentos` | Código, nombre, forma, presentación, laboratorio, precio y tipo |
| `dim_servicio` | Descripción y costo del servicio POS |

La tabla transaccional `trans_servicio` conserva las fechas y horas de solicitud y atención, a partir de las cuales se calcula el tiempo de espera en `hecho_atencion` (diferencia entre `fecha_hora_atencion` y `fecha_hora_solicitud`). `hecho_atencion` tiene dos llaves de fecha (`key_fecha_atencion` y `key_fecha_solicitud`), lo que corresponde a una dimensión de rol múltiple.

### 6.3 Justificación del diseño

- El modelo en estrella/constelación reduce el número de uniones y mejora el desempeño de las consultas analíticas.
- Las dimensiones conformadas (`dim_persona`, `dim_demografia`, `dim_fecha`, `dim_medico`) permiten análisis cruzados entre atenciones, medicamentos y retiros.
- La granularidad de `hecho_atencion` es una atención (un servicio prestado a una persona por un médico en una IPS).

### 6.4 Vistas analíticas (capa semántica del tablero)

Sobre las 13 tablas de la bodega hay **7 vistas** (`vw_*`). Una vista es una consulta guardada que une y resume tablas de hechos y dimensiones; el tablero lee las vistas en lugar de las tablas crudas, de modo que la lógica de cálculo queda centralizada en la base de datos y no en cada gráfico.

| Vista | Cols. | Tablas que une | Qué entrega | Página del tablero |
| --- | --- | --- | --- | --- |
| `vw_tiempos_espera_oportunidad` | 9 | `hecho_atencion`, `dim_servicio`, `dim_fecha` | Servicio, espera (días, horas, minutos), costo y fecha de atención | Oportunidad asistencial |
| `vw_analitica_ips_demografia` | 17 | `hecho_atencion`, `dim_ips`, `dim_demografia`, `dim_diag` | IPS (nombre, tipo, nivel, municipio, departamento), paciente (sexo, edad, estrato, tipo de usuario, empresa, municipio, departamento) y diagnóstico | Demografía y cobertura |
| `vw_analitica_financiera_detallada` | 10 | `hecho_atencion`, `dim_persona`, `dim_demografia`, `dim_ips` | Costo por afiliado, grupo familiar, empresa, estrato, municipio y departamento de la IPS | Analítica financiera |
| `vw_farmacologia_entregas` | 9 | `hecho_entrega`, `dim_medicamentos` | Fórmula, precio y datos del medicamento (nombre, forma, presentación, laboratorio, tipo) | Farmacología (Top 10) |
| `vw_utilizacion_servicios_tiempo` | 4 | `hecho_atencion`, `dim_fecha`, `dim_persona` | Día de la semana, sexo y costo | Demanda por día de la semana |
| `vw_estacionalidad_atenciones` | 33 | `hecho_atencion`, `dim_fecha`, `dim_persona`, `hecho_entrega`, `dim_medicamentos` | Calendario completo, época estacional, rango de edad y sexo, medicamento y costo | Estacionalidad y demanda por edad y sexo |
| `vw_mortalidad_epidemiologia` | 8 | `hecho_atencion`, `dim_persona`, `dim_diag`, `dim_demografia`, `dim_fecha` | Diagnóstico por sexo, estrato y fecha, y costo | Enfermedades por sexo y estrato |

Seis de las siete vistas parten de `hecho_atencion` con `LEFT JOIN` por llave sustituta; la de farmacología parte de `hecho_entrega`. Por eso las vistas no multiplican filas, pero heredan los duplicados del hecho (sección 8.8). Las atenciones cubren solo 2006–2008 (4.626, 10.983 y 9.660 filas por año). Hallazgos de la revisión de sus definiciones:

- **Unión incorrecta de medicamentos.** `vw_estacionalidad_atenciones` une `hecho_atencion` con `hecho_entrega` mediante `key_hecho_atencion = key_hecho_entrega`. Son dos hechos distintos y sus llaves sustitutas no se corresponden, por lo que el medicamento asociado a cada atención no tiene sentido. Debe unirse por paciente y fecha, o por fórmula, o retirarse de la vista.
- **Etiquetas de día de la semana.** En `dim_fecha`, `weekday` empieza en 0 = lunes (verificado contra las fechas), pero la vista asigna 1 = domingo, así que `dia_espanol` rotula mal los días (un sábado saldría como "5. Jue"). El tablero muestra lunes a domingo con pico el jueves, que sí coincide con el calendario real (4.058 filas, 3.202 sin duplicados); por tanto usa otro campo y conviene unificar la lógica.
- **Edad calculada a la fecha actual.** `edad` y `rango_edad` usan `CURRENT_DATE`, no la fecha de atención. Como las atenciones son de 2006–2008, la edad queda unos 18 a 20 años desplazada y cambia cada año; debe calcularse con la fecha de atención.
- **Época estacional por mes completo.** Navidad es diciembre, vacaciones junio y julio, y Semana Santa marzo y abril; la Semana Santa real dura unos ocho días y su fecha cambia cada año. Conviene usar `holiday` de `dim_fecha` o las fechas reales.
- **Nombre de `vw_mortalidad_epidemiologia`.** No contiene defunciones: es la frecuencia de diagnósticos por sexo, estrato y fecha. Se recomienda renombrarla (por ejemplo, `vw_morbilidad_diagnosticos`).
- **Vista financiera.** `municipio` y `departamento` son los de la IPS, no los del afiliado, y el "pago" es el costo de las atenciones (`costo`); la tabla `pagos` del OLTP (22.938 aportes) no se usa. Además la vista expone nombre e identificación del afiliado, por lo que su acceso debe restringirse.
- **Duplicados.** Las vistas no son la causa: ya están duplicadas las filas de la propia tabla `hecho_atencion` (sección 8.8).

## 7. Indicadores y definición de KPIs

| KPI | Definición | Valor observado |
| --- | --- | --- |
| Promedio de espera cita general | Promedio de `tiempo_espera_dias` de todas las atenciones | 7,7 días |
| Promedio de espera en cirugías | Promedio de espera para servicios quirúrgicos | 5,6 días |
| Espera de especialistas | Promedio de espera para consulta especializada | 8,8 días |
| Total de citas asignadas | Conteo de atenciones | 25.269 |
| Oportunidad quirúrgica | Porcentaje de cirugías atendidas dentro del umbral definido | 96,9 % |
| IPS activas en la red | Conteo de IPS con atenciones | 57 |
| Costo total acumulado | Suma de `costo` en `hecho_atencion` | $6.761,73 M COP |
| Costo promedio | Costo total dividido por la unidad de análisis | $267.589,90 COP |

## 8. Resultados y hallazgos por página del tablero

### 8.1 Oportunidad asistencial y tiempos de espera

- La oportunidad quirúrgica es alta (96,9 %) y la espera promedio en cirugías (5,6 días) es menor que la de especialistas (8,8 días).
- Los mayores tiempos de espera por servicio se concentran en procedimientos de alta complejidad: **Laringectomía (\~36,8 días)** y **Trasplante renal (\~31,7 días)**.
- Los tratamientos crónicos (control de embarazo, tensión arterial, diálisis, hemodiálisis y niveles de glucosa) presentan esperas cercanas a **30 días**, lo que sugiere una programación periódica (controles mensuales) más que una demora; se recomienda distinguir ambos conceptos en el análisis.
- Procedimientos como la colocación o retiro de catéter de diálisis peritoneal (\~16,7 días), la hemorroidectomía (\~15,4 días) y la laminectomía (\~13,7 días) muestran esperas intermedias.

### 8.2 Demografía y cobertura hospitalaria

- La atención se concentra geográficamente en el suroccidente: el municipio de mayor volumen alcanza **8.716 pacientes** (Cali), con presencia secundaria en Bogotá, Medellín y la región Caribe.
- Las diez IPS con mayor participación concentran cerca del **50 %** de las atenciones. Lideran el **Hospital Isaías Duarte Cancio (9,77 %)**, el **Hospital Universitario del Valle (6,71 %)** y el **Hospital Infantil Clínica Noel (6,1 %)**, seguidos por Clínica de Occidente (5,24 %), Hospital San Cristóbal (4,99 %), Hospital San Juan de Dios (4,87 %) y Clínica Valle del Lili (4,59 %).
- La alta concentración en pocas IPS es un riesgo de saturación y una oportunidad de redistribuir la demanda hacia otras IPS de la red.

### 8.3 Analítica financiera y pagos

- El costo total acumulado es de **$6.761,73 millones COP**.
- Por empresa contratante, **Asocaña** (cercana a $1.000 M) y **Electronic Data Systems** (~~$730 M) lideran el gasto, seguidas por Abka Colombia (~~$410 M); Axis Ediciones, Alimentos Nutrion, Travel Club y Bolsa y Banca aportan montos menores.
- El detalle por grupo familiar (577 grupos) permite identificar casos de alto costo; el principal supera los **$47 M**, y entre los cinco grupos de mayor costo, el costo promedio va de \~$0,43 M a \~$3,38 M, lo que evidencia alta dispersión.
- Los grupos de mayor costo se ubican principalmente en Bogotá (Cundinamarca) y Cali (Valle del Cauca).

### 8.4 Farmacología y utilización de servicios

- Medicamentos más formulados: **Metamizol (1.622)**, Pentoxifilina (989), Fenitoína sódica (780), Ácido acetilsalicílico (774), Cloruro de sodio (696), Valproato de magnesio (597), Amiodarona (557), Paracetamol (549), Polivitaminas y minerales (536) e Indometacina (508).
- El perfil combina analgésicos y antiinflamatorios (metamizol, paracetamol, indometacina, AAS), fármacos cardiovasculares (pentoxifilina, amiodarona) y anticonvulsivantes (fenitoína, valproato), lo que es coherente con el perfil de morbilidad observado (dolor lumbar, ciática, hipertensión).
- La tabla `mas_recetados` almacena los conjuntos frecuentes (`itemsets`) con su soporte (`support`) y tamaño (`length`), resultado de la minería de reglas de asociación sobre las fórmulas.
- La demanda por edad y sexo se apila por día de la semana; la leyenda visible solo identifica algunos grupos (19-30 y 31-50 años), por lo que se recomienda mostrar todos los grupos etarios antes de sacar conclusiones por edad.

### 8.5 Estacionalidad y operación hospitalaria

- La demanda por día de la semana es relativamente homogénea (entre \~3,4 mil y \~3,8 mil atenciones), con un **pico los jueves (\~4,1 mil)**.
- La evolución mensual separa cuatro regímenes: operación normal, Semana Santa, vacaciones y Navidad. Se observa un incremento de atenciones en Semana Santa (marzo-abril), un pico en vacaciones de mitad de año (junio-julio) y un aumento hacia diciembre, lo que respalda la planeación de capacidad por temporada.

### 8.6 Enfermedades principales por sexo y estrato

- El total analizado es de 25.269 atenciones. Los estratos 3 y 4 concentran cerca de la mitad de la demanda (≈49 %) y el estrato 1 es el de menor volumen (≈14 %).
- Entre los diagnósticos con contenido clínico, destacan la **tensión arterial normal (1.149)**, la **ciática (910)**, el resfriado común (376), la lumbalgia (186) y el SIDA (144) / VIH (48).
- Hay un número elevado de registros con valores del tipo "Sin novedad" (2.533) y "Terapia sin novedad" (2.104), que corresponden a resultados de seguimiento más que a diagnósticos y sugieren la necesidad de depuración semántica de la dimensión `dim_diag`.
- El mapa de calor permite comparar visualmente la carga por estrato y sexo y priorizar programas de promoción y prevención.

### 8.7 Entregable 2: dashboard sobre la base transaccional

El material gráfico revisado corresponde solo al primer entregable. El segundo se construye sobre el script OLTP (`colombia_saludable_OLTP.sql`), cuyas atenciones están repartidas en cuatro tablas: `citas_generales`, `urgencias`, `hospitalizaciones` y `remisiones` (esta última lleva el servicio POS, necesario para identificar cirugías). La vista y las consultas siguientes usan los nombres reales de ese esquema.

```sql
-- Vista base: todas las atenciones con fecha-hora de solicitud y de atención
CREATE VIEW v_atenciones AS
SELECT 'cita' AS tipo, NULL::varchar AS servicio_pos, id_medico, id_usuario,
       fecha_solicitud + hora_solicitud AS solicitud, fecha_atencion + hora_atencion AS atencion
FROM citas_generales
UNION ALL
SELECT 'urgencia', NULL, id_medico, id_usuario,
       fecha_solicitud + hora_solicitud, fecha_atencion + hora_atencion
FROM urgencias
UNION ALL
SELECT 'hospitalizacion', NULL, id_medico, id_usuario,
       fecha_solicitud + hora_solicitud, fecha_atencion + hora_atencion
FROM hospitalizaciones
UNION ALL
SELECT 'remision', servicio_pos, id_medico, id_usuario,
       fecha_remision + hora_remision, fecha_atencion + hora_atencion
FROM remisiones;

-- 1. Espera promedio entre solicitud y atención (días)
SELECT ROUND(AVG(EXTRACT(EPOCH FROM atencion - solicitud) / 86400)::numeric, 1) AS espera_prom_dias
FROM v_atenciones
WHERE atencion >= solicitud;

-- 2. Espera promedio en cirugías (días)
SELECT ROUND(AVG(EXTRACT(EPOCH FROM a.atencion - a.solicitud) / 86400)::numeric, 1) AS espera_cirugias_dias
FROM v_atenciones a
JOIN servicios_pos s ON s.id_servicio_pos = a.servicio_pos
WHERE s.descripcion ILIKE 'Cirug%' AND a.atencion >= a.solicitud;

-- 3. IPS que más atienden, por municipio y departamento
SELECT i.nombre, i.municipio, i.departamento, COUNT(*) AS atenciones
FROM v_atenciones a
JOIN medico m ON m.cedula = a.id_medico
JOIN ips i ON i.id_ips = m.id_ips
GROUP BY i.nombre, i.municipio, i.departamento
ORDER BY atenciones DESC
LIMIT 10;
```

### 8.8 Verificación con los scripts entregados

La bodega final (`bodega_23_10_2026`) reproduce exactamente los indicadores del tablero, pero al compararla con el OLTP aparece un problema de granularidad: `hecho_atencion` tiene 25.269 filas para solo 19.825 atenciones distintas.

| Indicador | Tablero (bodega) | Sin duplicados u OLTP | Lectura |
| --- | --- | --- | --- |
| Filas de `hecho_atencion` | 25.269 | 19.825 atenciones distintas (OLTP: 21.207) | 5.444 filas repetidas; 1.382 atenciones del OLTP no llegaron a la bodega |
| Pacientes distintos | 25.269 rotulado como pacientes | 463 | El indicador cuenta atenciones, no pacientes |
| Espera promedio general (días) | 7,7 | 9,7 (OLTP: 9,7) | El tablero la subestima |
| Espera en cirugías (días) | 5,6 | 8,6 (OLTP: 8,5) | Subestimada por los duplicados |
| Costo total | $6.761,73 M | $4.185,54 M | El tablero está ≈ 62 % por encima |
| Costo promedio | $267.589,90 | $211.124 por atención | Se calcula por fila, no por afiliado |
| IPS líder | Hospital Isaías Duarte Cancio, 9,77 % | Mismo hospital, 9,28 %; el segundo pasa a ser San Juan de Dios (5,66 %) | Cambia el orden del Top 10 |
| Filas con espera negativa | 1.626 (6,4 %) | OLTP: 497 remisiones | Atención registrada antes de la solicitud |
| IPS con atenciones | 57 | 57 | Coincide |

Hallazgos para tener preparados:

- **Duplicación por diagnóstico.** 2.527 atenciones aparecen entre 2 y 4 veces en `hecho_atencion` (7.971 filas), y cada copia trae un `key_dim_diag` distinto. Las vistas no la causan; ocurre al cargar el hecho, donde la atención parece unirse por identificación del paciente con todos sus diagnósticos de `dim_diag`. Esto infla el costo, el conteo de atenciones y las cirugías (5,6 días con 2.199 filas frente a 8,6 días con 889 atenciones distintas).
- **Atenciones sin cargar.** 1.382 de las 21.207 atenciones de `trans_servicio` (6,5 %) no tienen fila en `hecho_atencion`.
- **Fechas inválidas.** 1.626 filas de la bodega y 497 remisiones del OLTP tienen espera negativa; deben depurarse en el ETL o excluirse del indicador y declararse en la metodología.
- **Rótulos del tablero.** "Total de pacientes atendidos" y "Total de citas asignadas" muestran 25.269, que son filas del hecho; los pacientes distintos son 463 y las atenciones distintas, 19.825.

Recomendación: corregir la granularidad para que haya una fila por atención (con el diagnóstico principal como atributo o una tabla puente), recargar la bodega y actualizar el tablero y las cifras de este documento. Hasta entonces, las cifras del resumen y de las secciones 7 y 8 corresponden al tablero actual y deben presentarse con esta salvedad. Si se reconcilian, la comparación entre ambos tableros pasa de ser un riesgo a un argumento a favor de la bodega: rendimiento, historia consolidada y dimensiones conformadas.

## 9. Discusión

1. **Oportunidad:** los tiempos globales son razonables, pero la cola larga de procedimientos de alta complejidad requiere gestión específica (priorización clínica, referencia y contrarreferencia).
2. **Concentración:** la dependencia de pocas IPS y de una sola ciudad expone a la red a riesgos operativos y financieros.
3. **Costos:** el gasto está concentrado en pocas empresas y grupos familiares, lo que habilita estrategias de gestión del riesgo y de medicina preventiva dirigidas.
4. **Farmacología:** la prescripción dominada por analgésicos y antiinflamatorios invita a revisar la racionalidad en el uso y la adherencia a guías clínicas.
5. **Estacionalidad:** la demanda varía por temporada y día, lo que permite planear turnos, inventarios de medicamentos y camas.

## 10. Limitaciones y consideraciones críticas

Identificar las limitaciones por cuenta propia fortalece la sustentación. Estos puntos conviene tenerlos preparados:

- **Definición del "costo promedio por afiliado".** Al dividir $6.761,73 M entre 25.269 se obtiene aproximadamente $267.590, que es exactamente el valor mostrado. Esto indica que el denominador es el número de atenciones (o registros), no el de afiliados únicos. Se recomienda renombrar el indicador como "costo promedio por atención" o recalcularlo con `COUNT(DISTINCT numero_identificacion)`.
- **"Total de pacientes atendidos" = "Total de citas" = 25.269.** Ambos indicadores muestran el mismo valor, por lo que probablemente se cuentan atenciones y no pacientes únicos. Conviene aclarar la métrica o usar un conteo distinto.
- **Gráfico de estacionalidad.** La línea suavizada genera valores negativos en el eje (hasta -2 mil), que no tienen sentido para conteos de atenciones. Se recomienda usar líneas sin interpolación o barras y un eje que inicie en cero.
- **Calidad de la dimensión diagnóstica.** Existen etiquetas no clínicas ("Sin novedad", "Terapia sin novedad", "Sin mejora") que distorsionan el ranking de enfermedades; se sugiere mapear a una clasificación estándar (CIE-10).
- **Tipos de datos.** Algunos campos numéricos o de fecha están almacenados como texto (por ejemplo, `salario_base`, `fecha_nacimiento` en `dim_demografia`) y varias llaves foráneas tienen tipos distintos (int4 vs int8), lo que debe estandarizarse para garantizar integridad referencial.
- **Naming.** El campo `estracto` aparece con error ortográfico en el modelo (debería ser `estrato`).
- **Esperas de tratamientos periódicos.** Los valores cercanos a 30 días en tratamientos crónicos reflejan frecuencia de control, no necesariamente demora, por lo que deben separarse en el indicador de oportunidad.
- **Ausencia de análisis de retiros.** Aunque `hecho_retiros` está modelada, el tablero actual no incluye una vista de deserción o fuga de afiliados; es una oportunidad de ampliación.
- **Privacidad.** El modelo contiene datos personales y sensibles (identificación, diagnósticos, VIH/SIDA), por lo que se requiere anonimización y cumplimiento de la Ley 1581 de 2012 (Habeas Data) y de la normatividad de reserva de la historia clínica.

Brechas adicionales frente al enunciado:

- El modelo cubre atención, entrega de medicamentos y retiros, pero no incluye aportes y pagos de afiliados, facturación a IPS (pago por capitación o por evento), hospitalización ni encuesta de preexistencias; por eso no se puede medir ocupación de camas ni el costo de enfermedades catastróficas (SIDA, cáncer, insuficiencia renal) por programa.
- El enunciado pide distinguir medicamentos genéricos y comerciales; el campo `tipo` de `dim_medicamentos` permite hacerlo, pero el tablero no lo muestra.
- No hay vista de utilización promedio por paciente ni de edad en la matriz de enfermedades.

## 11. Conclusiones

1. Se construyó un sistema de BI funcional que integra las principales dimensiones del proceso asistencial y financiero de una red de salud, con un modelo dimensional que soporta el análisis multidimensional.
2. El tablero entrega seis vistas orientadas a decisiones: oportunidad, cobertura, costos, farmacología, estacionalidad y morbilidad.
3. Los hallazgos muestran buena oportunidad quirúrgica (96,9 %), concentración de la atención en pocas IPS y territorios, alta concentración del costo en pocas empresas y grupos familiares, y patrones estacionales claros.
4. La calidad de los datos (diagnósticos, tipos y definiciones de métricas) es el principal factor que condiciona la confiabilidad del análisis, y se identificaron acciones concretas de mejora.

## 12. Recomendaciones

- Implementar alertas automáticas cuando el tiempo de espera supere umbrales por servicio.
- Redistribuir la demanda desde las IPS más saturadas hacia las de menor participación.
- Diseñar programas de gestión de riesgo para los grupos familiares y empresas de mayor costo.
- Planificar capacidad (turnos, camas e inventario farmacéutico) según estacionalidad y picos de los jueves.
- Estandarizar los diagnósticos con CIE-10 y depurar etiquetas no clínicas.
- Corregir las definiciones de métricas (afiliados únicos vs. atenciones).

## 13. Trabajo futuro

- Modelos predictivos de demanda (series de tiempo: ARIMA, Prophet) y de riesgo de retiro de afiliados (clasificación).
- Segmentación de pacientes mediante clustering para identificar perfiles de alto costo.
- Análisis de reglas de asociación con métricas de confianza y lift para apoyar la gestión farmacéutica.
- Automatización del pipeline con orquestadores (Airflow) y carga incremental.
- Control de acceso por roles y anonimización de datos sensibles.
- Incorporación de datos externos (Open Data de MinSalud, DANE) para contextualizar los resultados.

## 14. Guía de sustentación

### 14.1 Estructura sugerida (20 minutos)

| Minutos | Contenido |
| --- | --- |
| 0–2 | Contexto y problema |
| 2–4 | Objetivos y pregunta de investigación |
| 4–8 | Arquitectura y modelo dimensional |
| 8–10 | ETL y calidad de datos |
| 10–16 | Demostración del tablero y hallazgos |
| 16–18 | Limitaciones y conclusiones |
| 18–20 | Recomendaciones y trabajo futuro |

### 14.2 Preguntas probables del jurado y respuestas sugeridas

**¿Por qué un modelo dimensional y no uno relacional normalizado?** Porque el modelo dimensional está optimizado para consultas analíticas: reduce uniones, simplifica la lógica de agregación y facilita el uso por herramientas de BI.

**¿Cómo se calculó el tiempo de espera?** Como la diferencia entre la fecha-hora de atención y la fecha-hora de solicitud en `trans_servicio`, expresada en días, horas, minutos y segundos en `hecho_atencion`.

**¿Cómo garantizaron la calidad de los datos?** Mediante limpieza y estandarización en el ETL, llaves sustitutas, trazabilidad con el campo `saved` y revisión de inconsistencias. Reconocemos limitaciones en la dimensión de diagnósticos y en tipos de datos, y proponemos su corrección.

**¿Por qué el costo "por afiliado" coincide con el costo por atención?** Porque el denominador usado es el número de registros; reconocemos la imprecisión y proponemos recalcularlo con afiliados únicos.

**¿Qué aporta la minería de reglas de asociación?** Identifica combinaciones de medicamentos que se recetan juntos, útil para gestión de inventarios, detección de prescripciones atípicas y revisión de interacciones.

**¿Cómo se protege la información sensible?** Se recomienda anonimizar identificadores, aplicar control de acceso por roles y cumplir con la Ley 1581 de 2012 y la reserva de la historia clínica.

**¿Qué valor tiene para una EPS o IPS?** Permite monitorear oportunidad, controlar costos, planear capacidad y focalizar programas de prevención con base en evidencia.

**¿Cuál sería el siguiente paso?** Incorporar analítica predictiva (demanda y deserción), automatizar el pipeline y ampliar el tablero con la vista de retiros.

## 15. Referencias sugeridas

- Kimball, R. y Ross, M. (2013). *The Data Warehouse Toolkit: The Definitive Guide to Dimensional Modeling* (3.ª ed.). Wiley.
- Inmon, W. H. (2005). *Building the Data Warehouse* (4.ª ed.). Wiley.
- Agrawal, R. y Srikant, R. (1994). Fast algorithms for mining association rules. *Proceedings of the 20th VLDB Conference*.
- Ministerio de Salud y Protección Social de Colombia. Sistema de Información para la Calidad y Sistema Obligatorio de Garantía de Calidad en Salud (Decreto 1011 de 2006).
- Congreso de Colombia. Ley 1581 de 2012, protección de datos personales.
- Organización Mundial de la Salud. CIE-10: Clasificación Internacional de Enfermedades.

*Nota: verifiquen y ajusten las referencias al formato exigido por su programa (APA, IEEE, etc.) y añadan las fuentes específicas de sus datos.*
