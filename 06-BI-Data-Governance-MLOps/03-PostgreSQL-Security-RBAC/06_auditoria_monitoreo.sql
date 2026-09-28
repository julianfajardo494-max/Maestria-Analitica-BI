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