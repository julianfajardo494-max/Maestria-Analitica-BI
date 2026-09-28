-- ==========================================
-- 05. ASIGNACIÓN DE PRIVILEGIOS
-- ==========================================

-- 1. Privilegios a nivel de Base de Datos
GRANT CONNECT ON DATABASE empresa_db TO gerentes, desarrolladores, analistas, lectores;

-- 2. Privilegios a nivel de Esquema
GRANT USAGE ON SCHEMA public TO gerentes, desarrolladores, analistas, lectores;

-- 3. Privilegios específicos por grupo (Nivel Tabla y Secuencia)

-- Gerentes: acceso completo
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO gerentes;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO gerentes;

-- Desarrolladores: lectura/escritura general
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO desarrolladores;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO desarrolladores;

-- Analistas: solo lectura/escritura en tablas específicas
GRANT SELECT, INSERT, UPDATE ON empleados, departamentos TO analistas;

-- Lectores: solo lectura en todo
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;

-- 4. Ejemplos de permisos a nivel de Columna (Granularidad fina)
GRANT SELECT (id, nombre, email) ON empleados TO usuario_app;
GRANT UPDATE (nombre, email) ON empleados TO desarrollador_senior;