-- =====================================================================
-- EJECUTAR_TODO.SQL
-- Ejecuta los scripts del taller en orden lógico.
-- =====================================================================

\set ON_ERROR_STOP on

-- 1. Crear base de datos
\i 01_setup_inicial.sql

-- 2. Conectarse a la nueva base de datos (¡Este es el paso clave!)
\c empresa_db

-- 3. Crear roles, tablas y permisos dentro de empresa_db
\i 02_creacion_roles.sql
\i 03_grupos_y_herencia.sql
\i 04_tablas_ejemplo.sql
\i 05_asignacion_permisos.sql
\i 06_auditoria_monitoreo.sql
\i 07_seguridad_avanzada.sql

-- Para borrar todo y volver a empezar (descomentar cuando se necesite):
-- \i 99_limpieza_opcional.sql
