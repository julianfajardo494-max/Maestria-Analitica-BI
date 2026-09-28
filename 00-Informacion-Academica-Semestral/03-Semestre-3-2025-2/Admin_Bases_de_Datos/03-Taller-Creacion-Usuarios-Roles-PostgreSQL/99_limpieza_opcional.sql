-- ==========================================
-- 99. SCRIPT DE LIMPIEZA
-- ==========================================
-- ADVERTENCIA: Ejecutar este script borrará todo el trabajo del taller.

-- 1. Asegurar que estamos en la base de datos principal (postgres) antes de borrar
\c postgres

-- 2. Eliminar la base de datos (forzando la desconexión de cualquier usuario activo)
DROP DATABASE IF EXISTS empresa_db WITH (FORCE);

-- 3. Eliminar la base de datos principal (forzando la desconexión de cualquier usuario activo)
DROP DATABASE IF EXISTS postgres WITH (FORCE);

-- 3. Eliminar los roles (Sin usar CASCADE)
DROP ROLE IF EXISTS carlos;
DROP ROLE IF EXISTS maria;
DROP ROLE IF EXISTS pedro;
DROP ROLE IF EXISTS ana;

DROP ROLE IF EXISTS gerentes;
DROP ROLE IF EXISTS desarrolladores;
DROP ROLE IF EXISTS analistas;
DROP ROLE IF EXISTS lectores;

DROP ROLE IF EXISTS grupo_desarrolladores;
DROP ROLE IF EXISTS grupo_lectores;

DROP ROLE IF EXISTS usuario_app;
DROP ROLE IF EXISTS admin_bd;
DROP ROLE IF EXISTS desarrollador_senior;