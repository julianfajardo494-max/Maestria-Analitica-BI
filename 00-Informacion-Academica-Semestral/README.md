# 📊 Taller 1: Proyecto de Aprendizaje Supervisado y Regresión

**Asignatura:** Minería de Datos / Aprendizaje Automático  
**Autores / Consultores:** 
- Nicolas Galeano
- Julian Fajardo
- Daniel Peña
- Diana Ortega  
**Tecnología:** Python, Scikit-Learn, Pandas, Seaborn, Jupyter Notebook  

---

## 📌 1. Business Understanding (Comprensión del Negocio)
La industria de seguros de salud opera bajo la necesidad crítica de predecir con exactitud los gastos médicos futuros para establecer primas que sean justas para el cliente y rentables para la compañía. El problema central es la alta variabilidad de los costos médicos, influenciados por factores demográficos, geográficos y hábitos de vida. 

El objetivo de este proyecto es aplicar modelos de regresión (Regresión Lineal por Mínimos Cuadrados y Árboles de Decisión) para cuantificar el impacto de variables clave como el tabaquismo, la edad y el IMC en los cargos finales del seguro, permitiendo automatizar la estimación de riesgos basándose en evidencia de datos.

---

## 📂 2. Data Understanding (Comprensión de los Datos)
El conjunto de datos contiene **1,338 observaciones y 7 variables** demográficas y de salud.

### Diccionario de Datos:
| Variable | Descripción Técnica | Impacto en el Modelo |
| :--- | :--- | :--- |
| **age** | Variable numérica continua (18 a 64 años). | Identifica la relevancia del ciclo de vida en el gasto médico. |
| **sex** | Variable categórica nominal. | Detecta diferencias en el uso de servicios de salud por género. |
| **bmi** | Variable numérica continua ($kg/m^2$). | Predictor crítico de salud; valores altos incrementan las primas. |
| **children** | Variable numérica discreta (0 a 5 dependientes). | Evalúa cómo la carga familiar afecta el costo de la póliza. |
| **smoker** | Variable categórica binaria (yes/no). | **Variable de mayor peso** en el incremento del riesgo y costo médico. |
| **region** | Variable categórica nominal (EE. UU.). | Segmenta geográficamente variaciones en redes hospitalarias. |
| **charges** | **Variable Objetivo** (Numérica continua). | Costo final facturado por el seguro a predecir[cite: 3]. |

---

## 📈 3. Hallazgos del Análisis Exploratorio (EDA)
- **Distribución sesgada:** La variable objetivo (`charges`) presenta un sesgo hacia la derecha, el cual puede optimizarse mediante transformaciones logarítmicas[cite: 3].
- **Calidad de datos:** El dataset se encuentra limpio, con **0 valores faltantes**, lo que garantiza una alta calidad para el entrenamiento de los algoritmos[cite: 3].
- **Factores de influencia:** Mediante visualizaciones con Seaborn, se identificó que los clientes fumadores registran los costos más elevados de forma drástica en comparación con los no fumadores, independientemente de la región geográfica.

---

## 🚀 4. Guía de Ejecución
1. Clona el repositorio en tu equipo local.
2. Asegúrate de instalar las librerías base utilizadas en el entorno:
   ```bash
   pip install pandas numpy matplotlib seaborn scikit-learn