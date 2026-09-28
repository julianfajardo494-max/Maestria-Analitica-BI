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