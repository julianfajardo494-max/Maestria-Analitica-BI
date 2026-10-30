-- ==========================================================
-- 1. Consultar todas las Tablas y sus Columnas (Estructura)
-- ==========================================================
SELECT t.table_name, c.column_name, c.data_type, c.character_maximum_length, c.is_nullable, c.column_default
FROM information_schema.tables t
    JOIN information_schema.columns c ON t.table_name = c.table_name
    AND t.table_schema = c.table_schema
WHERE
    t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name, c.ordinal_position;

-- ==========================================================
-- 2. Consultar todas las Llaves Foráneas (Relaciones)
-- ==========================================================
SELECT
    tc.table_name AS tabla_origen,
    kcu.column_name AS columna_origen,
    ccu.table_name AS tabla_destino,
    ccu.column_name AS columna_destino
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public';

-- ==========================================================
-- 3. Consultar todas las Vistas y sus Definiciones
-- ==========================================================
SELECT viewname, definition
FROM pg_views
WHERE
    schemaname = 'public';





--Consultar todas las Tablas del Esquema:
-- SQL
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public';

--Consultar todas las Columnas y Tipos de Datos:
-- SQL
SELECT table_name, column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_schema = 'public' 
ORDER BY table_name, ordinal_position;

--Consultar todas las Vistas y sus Definiciones SQL:

-- SQL
SELECT viewname, definition 
FROM pg_views 
WHERE schemaname = 'public';