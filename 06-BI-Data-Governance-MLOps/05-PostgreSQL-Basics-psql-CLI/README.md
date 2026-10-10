# 💻 Taller Práctico & CLI Mastery: Comandos Básicos de Terminal PostgreSQL con `psql`, Backups y Restauración

**Asignatura**: Administración de Bases de Datos (Semestre III - Univalle)  
**Módulo Portafolio**: `06-BI-Data-Governance-MLOps/05-PostgreSQL-Basics-psql-CLI/`  
**Autor**: Julián Andrés Fajardo Salcedo | [se quitó el vínculo sospechoso].(c) Analítica e Inteligencia de Negocios  
**Stack Tecnológico**: PostgreSQL 15 | Docker Compose | pgAdmin 4 | `psql` CLI | `pg_dump` | Git Bash

---

## 📌 1. Resumen Ejecutivo & Metodología STAR

### 🎯 Situación (S)

En entornos de producción, arquitecturas cloud y sistemas distribuidos con contenedores (Docker / Kubernetes), la administración de bases de datos relacionales como **PostgreSQL** requiere un dominio avanzado de la interfaz de línea de comandos (**CLI**). Aunque existen interfaces gráficas como pgAdmin, el acceso remoto a servidores, la automatización en pipelines de CI/CD, las tareas de mantenimiento rápido y las operaciones de **Disaster Recovery (Backups & Restore)** se ejecutan de manera estándar mediante herramientas nativas por consola: `psql` y `pg_dump`.

Sin un conocimiento sólido de los metacomandos de `psql` y de las utilidades de respaldo, los equipos de operaciones y ciencia de datos enfrentan riesgos de:

1. **Ineficiencia en entornos restringidos**: Imposibilidad de diagnosticar o gestionar bases de datos donde no hay interfaz gráfica instalada.
2. **Vulnerabilidad ante pérdida de datos**: Inexistencia o fallo en la validación de estrategias de respaldo estructuradas (esquema vs. datos).
3. **Lentitud en la restauración**: Tiempos elevados de respuesta ante fallos del sistema por falta de rutinas probadas de Disaster Recovery.

### 🎯 Tarea (T)

Diseñar, implementar y validar un laboratorio práctico interactivo que permita:

- Orquestar un entorno aislado de PostgreSQL 15 y pgAdmin 4 mediante **Docker Compose**.
- Desarrollar un script SQL (`taller_psql_comandos.sql`) para inicializar objetos, esquemas y datos de prueba.
- Dominar la navegación y las meta-órdenes avanzadas de `psql` (`\l`, `\c`, `\dt+`, `\d`, `\di`, `\conninfo`, `\timing`, `\x`).
- Implementar estrategias de respaldo diferenciadas usando `pg_dump` (Backup Completo, Solo Esquema, Solo Datos).
- Realizar una prueba de **Simulación de Desastre y Restauración** (`DROP DATABASE` + `psql -f`), verificando la integridad total de los registros restaurados.

### ⚙️ Acción (A)

1. **Despliegue de Infraestructura Docker**: Configuración del archivo `docker-compose.yml` para levantar los contenedores `postgres_psql_container` (puerto `5435`) y `pgadmin_psql_container` (puerto `5051`) dentro de la red enpuentada `psql_net`.
2. **Script de Inicialización SQL**: Creación e ingesta del archivo `taller_psql_comandos.sql`, el cual instancia la base de datos `taller_test` y la tabla relacional `usuarios` con datos iniciales.
3. **Exploración e Inspección en CLI**:
   - Ingreso a la sesión interactiva con `docker exec -it postgres_psql_container psql -U postgres -d taller_test`.
   - Inspección de metadatos del catálogo del sistema: consulta de bases de datos (`\l`), información de sesión (`\conninfo`), descripción detallada de tablas e índices (`\dt+`, `\d usuarios`, `\di`).
   - Activación de utilidades de desarrollo: temporizador de consultas (`\timing`) y formato de salida extendido/vertical (`\x`).
4. **Estrategias de Respaldo (`pg_dump`)**:
   - Ejecución de respaldos físicos evitando la conversión de rutas en Windows Git Bash mediante la bandera `MSYS_NO_PATHCONV=1`.
   - Generación del backup completo: `pg_dump -U postgres -d taller_test -f /tmp/backup_taller_test.sql`.
   - Generación de backup de estructura: `pg_dump --schema-only`.
   - Generación de backup de registros: `pg_dump --data-only`.
5. **Prueba de Recuperación ante Desastres (Disaster Recovery)**:
   - Destrucción forzada de la base de datos de producción mediante `DROP DATABASE taller_test WITH (FORCE);`.
   - Recreación de la base de datos en blanco y restauración con `psql -f /tmp/backup_taller_test.sql`.
   - Validación de la consistencia de los datos restaurados vía consulta de verificación `SELECT * FROM usuarios;`.

### 📈 Resultados (R)

- **Entorno 100% Funcional y Automatizado**: Contenedores desplegados correctamente sin conflictos de puertos ni variables de entorno.
- **Respaldo y Restauración Exitosa**: Generación de los 3 archivos de backup (`backup_taller_test.sql`, `esquema_taller_test.sql`, `datos_taller_test.sql`) en el contenedor.
- **Cero Pérdida de Datos**: Restauración en tiempo récord (< 0.5s) que recuperó la totalidad de los registros de la tabla `usuarios` sin errores sintácticos ni de integridad referencial.
- **Estandarización de Prácticas MLOps/DBA**: Integración de todo el flujo en el repositorio de GitHub dentro del módulo `06-BI-Data-Governance-MLOps/05-PostgreSQL-Basics-psql-CLI/`.

---

## 🗂️ Estructura del Módulo en el Repositorio

```text
05-PostgreSQL-Basics-psql-CLI/
├── 📄 docker-compose.yml              # Configuración de Docker (PostgreSQL 15 + pgAdmin 4)
├── 📄 taller_psql_comandos.sql        # Script de inicialización de la base de datos taller_test
├── 📄 backup_taller_test.sql          # Respaldo completo generado (Esquema + Datos)
├── 📄 esquema_taller_test.sql         # Respaldo de estructura (DDL)
├── 📄 datos_taller_test.sql           # Respaldo de registros (DML)
└── 📄 [se quitó el vínculo sospechoso]                       # Documentación del laboratorio (Metodología STAR)
```
