# 🗄️ Taller Práctico: Gestión de Usuarios, Roles y Permisos en PostgreSQL

**Asignatura**: Administración de Bases de Datos (Semestre III)  
**Autor**: Julián Andrés Fajardo Salcedo | M.Sc.(c) Analítica e Inteligencia de Negocios  
**Tecnología**: PostgreSQL 15+ / SQL / Docker

---

## 📌 Situación (S)

En entornos corporativos y aplicaciones de alto tráfico, la gestión inadecuada de privilegios en bases de datos genera vulnerabilidades de seguridad, accesos no autorizados y riesgos de fuga de información crítica.

## 🎯 Tarea (T)

Diseñar e implementar una arquitectura de seguridad basada en **Roles y Herencia en PostgreSQL**, estableciendo un control de acceso basado en el principio de mínimo privilegio (_Least Privilege_) para un sistema de gestión empresarial.

## ⚙️ Acción (A)

1. **Despliegue de Infraestructura**: Configuración del motor PostgreSQL a través de contenedores Docker (`docker-compose.yml`) asegurando un entorno aislado.
2. **Configuración de Roles Base y Grupos**: Creación de roles de sistema, roles especializados para entornos web (`web_app`, `web_user`, `web_admin`) y grupos gerenciales, desarrolladores, analistas y lectores.
3. **Control de Acceso Granular**: Asignación de permisos a nivel de Base de Datos, Esquema, Tablas y Secuencias.
4. **Mecanismos de Herencia**: Asociación de usuarios individuales a grupos de permisos estandarizados (`GRANT grupo TO usuario`).
5. **Consultas de Auditoría y Seguridad**: Implementación de scripts de monitoreo sobre las tablas del sistema (`pg_roles`, `pg_auth_members`, `information_schema`) y buenas prácticas de caducidad de contraseñas.

---

## 📁 Estructura de Scripts del Taller

- **`01_setup_inicial.sql`**: Configuración inicial y creación de la base de datos principal (`empresa_db`).
- **`02_creacion_roles.sql`**: Creación de roles del sistema, roles web especializados (`web_app`, `web_user`, `web_admin`) y usuarios empresariales.
- **`03_grupos_y_herencia.sql`**: Definición de roles de grupo y asignación de membresías y herencia.
- **`04_tablas_ejemplo.sql`**: Creación del esquema relacional base (`departamentos`, `empleados`, `proyectos`).
- **`05_asignacion_permisos.sql`**: Concesión de privilegios a nivel de base de datos, esquemas, tablas, secuencias y granularidad por columnas.
- **`06_auditoria_monitoreo.sql`**: Consultas de auditoría sobre los catálogos del sistema.
- **`07_seguridad_avanzada.sql`**: Configuración de políticas de seguridad, caducidad de contraseñas (`VALID UNTIL`) y límites de conexiones.
- **`99_limpieza_opcional.sql`**: Script seguro para la eliminación ordenada de la base de datos y roles creados.

---

## 🚀 Guía de Despliegue Rápido

Sigue estos pasos en tu terminal para poner en marcha el contenedor y poblar la base de datos:

### 1. Levantar el motor con Docker

Inicia el contenedor de PostgreSQL en segundo plano:

````bash
docker-compose up -d
````

### 2. Ejecutar el script maestro de automatización

Despliega la base de datos empresa_db, roles, tablas y permisos ejecutando el script maestro:

```bash
PGPASSWORD=adminpassword psql -h 127.0.0.1 -p 5434 -U postgres -d postgres -f 00_ejecutar_todo.sql
````

## 📈 Resultados (R)

- **Seguridad Garantizada**: Aislamiento efectivo entre entornos de lectura, analítica y administración.
- **Estructura Escalable**: Administración simplificada mediante grupos en lugar de asignaciones individuales.
- **Auditoría Transparente**: Trazabilidad completa de privilegios concedidos en el motor PostgreSQL.
- **Eficiencia en Despliegue**: Uso de un script maestro (`00_ejecutar_todo.sql`) para la inicialización y construcción automatizada de todo el entorno y la base de datos `empresa_db`.
