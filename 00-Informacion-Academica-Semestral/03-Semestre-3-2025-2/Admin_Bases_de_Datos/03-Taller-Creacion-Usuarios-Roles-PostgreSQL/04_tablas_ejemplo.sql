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