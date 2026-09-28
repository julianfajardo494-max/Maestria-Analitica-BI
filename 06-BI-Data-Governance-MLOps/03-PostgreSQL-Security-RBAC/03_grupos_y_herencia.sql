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