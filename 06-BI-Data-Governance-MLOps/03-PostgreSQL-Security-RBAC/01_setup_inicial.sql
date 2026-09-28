-- ==========================================
-- 01. CONFIGURACIÓN INICIAL
-- ==========================================

-- Crear la base de datos principal del taller
CREATE DATABASE empresa_db;

/* 
IMPORTANTE PARA VISUAL STUDIO CODE:
La extensión de VS Code no soporta el comando \c. 
Una vez ejecutes esta línea, ve al panel lateral de PostgreSQL Explorer, 
despliega tu conexión de 127.0.0.1, haz clic derecho sobre la nueva base 
de datos "empresa_db" y selecciona "Select Postgres Database".
Todo el código siguiente debe ejecutarse conectado a empresa_db.
*/