# 🎓 Maestría en Analítica e Inteligencia de Negocios — Universidad del Valle

### 📊 Repositorio Central de Portafolio Técnico, Investigación & Arquitectura de Datos (2024 – 2026)

**Autor**: [Julián Andrés Fajardo Salcedo](https://linkedin.com/in/tu-perfil) | **Candidato a Magíster** | **Ingeniero Industrial**  
**Institución**: Universidad del Valle (Cali, Colombia) — Escuela de Ingeniería de Sistemas (EISC) e Ingeniería Industrial  
**Promedio Acumulado**: 🏆 **4.46 / 5.0** (100% créditos aprobados) | **Evolución**: Semestre I (4.36) ➔ Semestre II (4.54)

---

## 📌 Visión del Repositorio (Estructura Orientada a Soluciones & Dominios)

Este repositorio está estructurado siguiendo los estándares de la industria de tecnología (**Domain & Solution-Oriented Architecture**). A diferencia de un archivo puramente académico organizado por aulas o semestres, este código se agrupa por capacidades técnicas avanzadas, motores de solución y dominios de aplicación de negocio:

- 🧠 **HealthTech & Deep Learning**: Redes Neuronales Convolucionales (`CNNs`, `ResNet50`, `Transfer Learning`) aplicadas a neuroimagen médica (`DTI` / `Tractografía`) y Sistemas de Soporte a la Decisión Clínica (`CDSS`).
- 🗣️ **NLP & LLMs**: Procesamiento de Lenguaje Natural avanzado con `Transformers`, `BERT`, `HuggingFace` y `PyTorch`. _(Calificación Destacada: 5.0 / 5.0 ⭐)_
- ⚡ **Big Data & Data Engineering**: Pipelines distribuidos en `PySpark`, `Hadoop`, `SQL Server`, `PostgreSQL`, `ETL/ELT` y arquitecturas `Kafka`.
- 📊 **Business Intelligence & MLOps**: Modelado dimensional (`Star Schema`), Dashboards gerenciales (`Power BI`, `DAX`), pipelines de EDA y gobierno de datos.
- 🎯 **Prescriptive & Predictive ML**: Modelos predictivos (`XGBoost`, `Random Forest`, `SHAP`), simulación `Montecarlo` y optimización con `Optuna`.

---

## 🗂️ Estructura de Directorios del Repositorio

```text
Maestria-Analitica-BI/
├── 📄 README.md                                     # Hub Central & Matriz de Mapeo Académico
├── 📄 PLANTILLA-LABORATORIO-STAR.md                 # Guía estándar de documentación
│
├── 📁 00-Informacion-Academica-Semestral/           # 📚 ARCHIVO ACADÉMICO COMPLETO (Syllabi, notas y entregables por semestre)
│   ├── 📁 01-Semestre-1-2024-2/                     # Promedio 4.36 | Gestión de Datos, Prog. Analítica, Métodos Cuantitativos
│   ├── 📁 02-Semestre-2-2025-1/                     # Promedio 4.54 | PLN (5.0), Tesis I (4.7), Big Data, Minería, Toma Decisiones
│   └── 📁 03-Semestre-3-2025-2/                     # Semestre en curso | Analítica Salud, Financiera, DB Admin, Kafka
│
├── 📁 01-Deep-Learning-HealthTech-Tesis/            # 🧠 Tesis DTI, ResNet50, Tractografía, CDSS [Notas: 4.7 / 5.0]
├── 📁 02-NLP-LLM-Text-Analytics/                    # 🗣️ Transformers, BERT, HuggingFace, PyTorch [Nota: 5.0 ⭐]
├── 📁 03-Data-Engineering-BigData/                  # ⚡ PySpark, Data Warehouse, ETL, Streaming [Notas: 4.6, 4.3]
├── 📁 04-Machine-Learning-Predictive-Analytics/     # 🧠 XGBoost, Random Forest, SHAP, Risk Models [Nota: 4.0]
├── 📁 05-Prescriptive-Analytics-Optimization/       # 🎯 Simulación Montecarlo, Optuna, ARIMA [Notas: 4.4, 3.9]
├── 📁 06-BI-Data-Governance-MLOps/                  # 📊 Power BI, DAX, EDA Pipeline, MLOps [Notas: 4.8, 4.6, 4.4]
└── 📁 07-Financial-Analytics-Credit-Scoring/        # 📈 Credit Scoring, Scorecards & Financial ML
```

---

## 🔬 Proyecto Integrador de Grado (Tesis Principal)

> ### 🧠 Detección de Enfermedad Neurológica Crónica por Neuroimagen (DTI) _(Nota: 4.7 / 5.0)_
>
> **Desarrollo de un Algoritmo de Clasificación Binaria para Sistemas de Soporte a la Decisión Clínica (CDSS)**
>
> - 🎯 **Problema Clínico**: Alta variabilidad en el diagnóstico y planeación prequirúrgica de patologías neurológicas crónicas mediante inspección visual subjetiva de la sustancia blanca cerebral.
> - 💡 **Solución Tecnológica**: Pipeline de **Deep Learning** con Redes Neuronales Convolucionales (`CNNs` - `ResNet50`, `EfficientNet`, `Transfer Learning`) entrenado sobre **560 unidades de tractografía**.
> - 🔬 **Biomarcadores Analizados**: Extracción cuantitativa de Fracción de Anisotropía (`FA`), Difusividad Media (`MD`) y Radial (`RD`) en 8 tractos cerebrales clave del lenguaje hablado.
> - 📈 **Metodología & Alcance**: Metodología **CRISP-DM** para entregar un Sistema de Soporte a la Decisión Clínica (**CDSS**) validado para un centro médico del suroccidente colombiano.
>
> 🔗 [Ver Módulo de Tesis](./01-Deep-Learning-HealthTech-Tesis/)

---

## 🗺️ Matriz de Mapeo: Malla Curricular vs. Módulos por Dominio

| Semestre | Asignatura (Universidad del Valle) |       Nota       | Módulo de Solución en GitHub                                                                | Stack / Algoritmos                |
| :------: | :--------------------------------- | :--------------: | :------------------------------------------------------------------------------------------ | :-------------------------------- |
|  **S1**  | **Programación para Analítica**    |  **4.8 / 5.0**   | [`/06-BI-Data-Governance-MLOps/`](./06-BI-Data-Governance-MLOps/)                           | `Python` `Pandas` `Seaborn`       |
|  **S1**  | **Inteligencia de Negocios**       |  **4.6 / 5.0**   | [`/06-BI-Data-Governance-MLOps/`](./06-BI-Data-Governance-MLOps/)                           | `Power BI` `DAX` `Data Marts`     |
|  **S1**  | **Seminario de Analítica**         |  **4.4 / 5.0**   | [`/06-BI-Data-Governance-MLOps/`](./06-BI-Data-Governance-MLOps/)                           | `MLOps` `Data Governance` `CI/CD` |
|  **S1**  | **Gestión de Datos**               |  **4.3 / 5.0**   | [`/03-Data-Engineering-BigData/`](./03-Data-Engineering-BigData/)                           | `SQL Server` `PostgreSQL` `ETL`   |
|  **S1**  | **Métodos Cuantitativos**          |  **3.9 / 5.0**   | [`/05-Prescriptive-Analytics-Optimization/`](./05-Prescriptive-Analytics-Optimization/)     | `ARIMA` `Holt-Winters` `R`        |
|  **S2**  | **PLN con Deep Learning**          | **5.0 / 5.0 ⭐** | [`/02-NLP-LLM-Text-Analytics/`](./02-NLP-LLM-Text-Analytics/)                               | `Transformers` `BERT` `PyTorch`   |
|  **S2**  | **Trabajo Integrador I (Tesis)**   |  **4.7 / 5.0**   | [`/01-Deep-Learning-HealthTech-Tesis/`](./01-Deep-Learning-HealthTech-Tesis/)               | `CNNs` `ResNet50` `DTI`           |
|  **S2**  | **Ingeniería de Datos**            |  **4.6 / 5.0**   | [`/03-Data-Engineering-BigData/`](./03-Data-Engineering-BigData/)                           | `PySpark` `Hadoop` `AWS S3`       |
|  **S2**  | **Toma de Decisiones**             |  **4.4 / 5.0**   | [`/05-Prescriptive-Analytics-Optimization/`](./05-Prescriptive-Analytics-Optimization/)     | `Montecarlo` `Optuna` `SciPy`     |
|  **S2**  | **Minería de Datos**               |  **4.0 / 5.0**   | [`/04-Machine-Learning-Predictive-Analytics/`](./04-Machine-Learning-Predictive-Analytics/) | `XGBoost` `Random Forest` `SHAP`  |
|  **S3**  | **Trabajo Integrador II (Tesis)**  |    _En Curso_    | [`/01-Deep-Learning-HealthTech-Tesis/`](./01-Deep-Learning-HealthTech-Tesis/)               | `PyTorch` `CNNs` `CRISP-DM`       |
|  **S3**  | **Analítica en Salud**             |    _En Curso_    | [`/04-Machine-Learning-Predictive-Analytics/`](./04-Machine-Learning-Predictive-Analytics/) | `Cox Hazards` `Logistic Reg` `R`  |
|  **S3**  | **Admin. Bases de Datos**          |    _En Curso_    | [`/06-BI-Data-Governance-MLOps/`](./06-BI-Data-Governance-MLOps/)                           | `SQL Server` `MongoDB` `Redis`    |
|  **S3**  | **Técnicas Avanzadas de Datos**    |    _En Curso_    | [`/03-Data-Engineering-BigData/`](./03-Data-Engineering-BigData/)                           | `Apache Kafka` `Event Streams`    |
|  **S3**  | **Analítica Financiera**           |    _En Curso_    | [`/07-Financial-Analytics-Credit-Scoring/`](./07-Financial-Analytics-Credit-Scoring/)       | `Credit Scoring` `Financial ML`   |

---

## 📝 Documentación de Laboratorios (Método STAR)

Cada subcarpeta de proyecto/laboratorio individual contiene un archivo `README.md` documentado bajo la metodología **STAR**:

- **S**ituación: Contexto del desafío de negocio o clínico.
- **T**area: Objetivos cuantitativos y métricas a lograr.
- **A**cción: Pipeline de datos, diseño de arquitectura, algoritmos e implementación de código.
- **R**esultados: Métricas de impacto, matrices de confusión, accuracy y valor entregado.

---

## 🛠️ Entorno de Desarrollo & Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/julianfajardo494-max/Maestria-Analitica-BI.git
cd Maestria-Analitica-BI

# 2. Crear un entorno virtual de Python
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# 3. Instalación de dependencias core
pip install --upgrade pip
pip install -r requirements.txt
```

---

## 📬 Contacto & Redes Profesionales

- **Autor**: Julián Andrés Fajardo Salcedo
- **Correo Electrónico**: [andresfajardosalcedo@gmail.com](mailto:andresfajardosalcedo@gmail.com)
- **LinkedIn**: [linkedin.com/in/tu-perfil](https://linkedin.com/in/tu-perfil)
- **GitHub Profile**: [github.com/julianfajardo494-max](https://github.com/julianfajardo494-max)
- **Plataforma Operativa Mepal**: [planeacion.plantamepal.com](https://planeacion.plantamepal.com)
