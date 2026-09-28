-- =====================================================================
-- TALLER: ROLES, GRUPOS Y PERMISOS EN POSTGRESQL (SCRIPT UNIFICADO)
-- Contiene, en orden, los scripts 01 al 07.
--
-- Uso con psql:
--     psql -U postgres -f taller_roles_permisos.sql
--
-- Uso con VS Code (extensión PostgreSQL): el comando \c no está soportado.
-- Ejecuta primero la sección 01, selecciona la base "empresa_db" en el
-- PostgreSQL Explorer (clic derecho > "Select Postgres Database") y luego
-- ejecuta desde la sección 02 en adelante.
-- =====================================================================

\set ON_ERROR_STOP on


-- ==========================================
-- 01. CONFIGURACIÓN INICIAL
-- ==========================================

-- Crear la base de datos principal del taller
CREATE DATABASE empresa_db;

-- Conectarse a la nueva base de datos (solo psql)
\c empresa_db


-- ==========================================
-- 02. CREACIÓN DE ROLES Y USUARIOS
-- ==========================================

-- Rol simple sin login
CREATE ROLE desarrollador;

-- Roles solicitados para el entorno web
CREATE ROLE web_app NOLOGIN;  -- Sin login, exclusivo para la aplicación
CREATE ROLE web_user WITH LOGIN PASSWORD 'user123';
CREATE ROLE web_admin WITH LOGIN PASSWORD 'adminweb123';

-- Roles con login (usuarios del sistema)
CREATE ROLE usuario_app WITH LOGIN PASSWORD 'password123';

-- Rol con opciones de administración
CREATE ROLE admin_bd WITH 
    LOGIN 
    PASSWORD 'admin123'
    CREATEDB
    CREATEROLE
    VALID UNTIL '2026-12-31';

-- Usuarios específicos para el caso empresarial
CREATE ROLE carlos WITH LOGIN PASSWORD 'carlos123';
CREATE ROLE maria WITH LOGIN PASSWORD 'maria123';
CREATE ROLE pedro WITH LOGIN PASSWORD 'pedro123';
CREATE ROLE ana WITH LOGIN PASSWORD 'ana123';

-- Ejemplos de modificación de roles
ALTER ROLE usuario_app PASSWORD 'nueva_password123';
ALTER ROLE desarrollador CREATEDB;
ALTER ROLE desarrollador NOCREATEDB;
ALTER ROLE desarrollador RENAME TO desarrollador_senior;


-- ==========================================
-- 03. GESTIÓN DE GRUPOS Y HERENCIA
-- ==========================================

-- Crear roles que actuarán como grupos
CREATE ROLE grupo_desarrolladores;
CREATE ROLE grupo_lectores;
CREATE ROLE gerentes;
CREATE ROLE desarrolladores;
CREATE ROLE analistas;
CREATE ROLE lectores;

-- Asignar usuarios a los grupos base
GRANT grupo_desarrolladores TO usuario_app;
GRANT grupo_desarrolladores, grupo_lectores TO desarrollador_senior;

-- Asignar usuarios al caso empresarial
GRANT gerentes TO carlos;
GRANT desarrolladores TO maria;
GRANT analistas TO pedro;
GRANT lectores TO ana;


-- ==========================================
-- 04. CREACIÓN DE TABLAS DE EJEMPLO
-- ==========================================

CREATE TABLE departamentos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    presupuesto DECIMAL(15,2)
);

CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    departamento_id INTEGER REFERENCES departamentos(id),
    salario DECIMAL(10,2)
);

CREATE TABLE proyectos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE
);


-- ==========================================
-- 05. ASIGNACIÓN DE PRIVILEGIOS
-- ==========================================

-- 1. Privilegios a nivel de Base de Datos
GRANT CONNECT ON DATABASE empresa_db TO gerentes, desarrolladores, analistas, lectores, web_user, web_admin;

-- 2. Privilegios a nivel de Esquema
GRANT USAGE ON SCHEMA public TO gerentes, desarrolladores, analistas, lectores, web_user, web_admin;

-- 3. Privilegios específicos por grupo (Nivel Tabla y Secuencia)

-- Gerentes: acceso completo
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO gerentes;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO gerentes;

-- Desarrolladores: lectura/escritura general
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO desarrolladores;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO desarrolladores;

-- Analistas: solo lectura/escritura en tablas específicas
GRANT SELECT, INSERT, UPDATE ON empleados, departamentos TO analistas;

-- Lectores y web_user: solo lectura en todo
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores, web_user;

-- web_admin: privilegios amplios de gestión operativa
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO web_admin;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO web_admin;

-- 4. Ejemplos de permisos a nivel de Columna (Granularidad fina)
GRANT SELECT (id, nombre, email) ON empleados TO usuario_app;
GRANT UPDATE (nombre, email) ON empleados TO desarrollador_senior;


-- ==========================================
-- 06. AUDITORÍA Y MONITOREO
-- ==========================================

-- Listar todos los roles y sus atributos principales
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin 
FROM pg_roles;

-- Ver permisos aplicados a la tabla 'empleados'
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'empleados';

-- Ver qué usuarios pertenecen a qué grupos
SELECT 
    u.rolname AS usuario,
    g.rolname AS grupo
FROM pg_auth_members m
JOIN pg_roles u ON (m.roleid = u.oid)
JOIN pg_roles g ON (m.member = g.oid);

-- Ver privilegios a nivel de base de datos
SELECT 
    datname as database,
    rolname as role,
    datacl as privileges
FROM pg_database 
JOIN pg_roles ON true
WHERE datname = 'empresa_db';


-- ==========================================
-- 07. BUENAS PRÁCTICAS Y SEGURIDAD
-- ==========================================

-- Configurar expiración de contraseña
ALTER ROLE usuario_app VALID UNTIL '2026-06-30';

-- Forzar cambio de contraseña en el próximo inicio de sesión
ALTER ROLE usuario_app PASSWORD NULL;

-- Limitar número de conexiones simultáneas para evitar saturación
ALTER ROLE usuario_app CONNECTION LIMIT 10;


-- Para borrar todo y volver a empezar, ejecuta el script de limpieza
-- (99_limpieza_opcional.sql) por separado.
