-- ==========================================
-- 07. BUENAS PRÁCTICAS Y SEGURIDAD
-- ==========================================

-- Configurar expiración de contraseña
ALTER ROLE usuario_app VALID UNTIL '2026-06-30';

-- Forzar cambio de contraseña en el próximo inicio de sesión
ALTER ROLE usuario_app PASSWORD NULL;

-- Limitar número de conexiones simultáneas para evitar saturación
ALTER ROLE usuario_app CONNECTION LIMIT 10;