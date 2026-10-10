-- 1. Crear base de datos de prueba
CREATE DATABASE taller_test;

-- 2. Conectarse a la nueva base de datos
\c taller_test

-- 3. Crear tabla de usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100)
);

-- 4. Insertar registros de prueba
INSERT INTO usuarios (nombre, email) VALUES
('Julián Fajardo', 'andresfajardosalcedo@gmail.com'),
('Carlos Pérez', 'carlos.perez@example.com'),
('María Rodríguez', 'maria.rodriguez@example.com');