-- ==============================================================================
-- TALLER PRÁCTICO: GESTIÓN DE USUARIOS, ROLES Y PERMISOS EN POSTGRESQL
-- Asignatura: Administración de Bases de Datos
-- Autor: Julián Andrés Fajardo Salcedo
-- ==============================================================================

-- 1. CONFIGURACIÓN INICIAL & CONEXIÓN
-- Conectarse como superusuario postgres
\c postgres postgres;

-- 2. CREACIÓN Y GESTIÓN DE ROLES BASE
CREATE ROLE desarrollador;
CREATE ROLE usuario_app WITH LOGIN PASSWORD 'Password123!';
CREATE ROLE admin_bd WITH LOGIN PASSWORD 'AdminPass123!' CREATEDB CREATEROLE VALID UNTIL '2026-12-31';

-- Modificación de privilegios
ALTER ROLE desarrollador CREATEDB;

-- 3. ESCENARIO PRÁCTICO: SISTEMA EMPRESARIAL
CREATE DATABASE empresa_db;
\c empresa_db;

-- Crear roles de grupo
CREATE ROLE gerentes;
CREATE ROLE desarrolladores;
CREATE ROLE analistas;
CREATE ROLE lectores;

-- Crear usuarios individuales
CREATE ROLE carlos WITH LOGIN PASSWORD 'carlos123';
CREATE ROLE maria WITH LOGIN PASSWORD 'maria123';
CREATE ROLE pedro WITH LOGIN PASSWORD 'pedro123';
CREATE ROLE ana WITH LOGIN PASSWORD 'ana123';

-- Asignar usuarios a grupos (Herencia)
GRANT gerentes TO carlos;
GRANT desarrolladores TO maria;
GRANT analistas TO pedro;
GRANT lectores TO ana;

-- Conceder privilegios de conexión y esquema
GRANT CONNECT ON DATABASE empresa_db TO gerentes, desarrolladores, analistas, lectores;
GRANT USAGE ON SCHEMA public TO gerentes, desarrolladores, analistas, lectores;

-- 4. ESTRUCTURA DE TABLAS DE PRUEBA
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

-- 5. ASIGNACIÓN DE PRIVILEGIOS POR ROL
-- Gerentes: Acceso completo
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO gerentes;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO gerentes;

-- Desarrolladores: Lectura y Escritura
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO desarrolladores;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO desarrolladores;

-- Analistas: Lectura/Escritura limitada
GRANT SELECT, INSERT, UPDATE ON empleados, departamentos TO analistas;

-- Lectores: Solo lectura
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;

-- 6. AUDITORÍA Y MONITOREO DE PERMISOS
-- Listar roles y capacidades de login
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin FROM pg_roles;

-- Verificar permisos en la tabla empleados
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'empleados';

-- Ver membresía de grupos
SELECT u.rolname AS usuario, g.rolname AS grupo
FROM pg_auth_members m
JOIN pg_roles u ON (m.roleid = u.oid)
JOIN pg_roles g ON (m.member = g.oid);
