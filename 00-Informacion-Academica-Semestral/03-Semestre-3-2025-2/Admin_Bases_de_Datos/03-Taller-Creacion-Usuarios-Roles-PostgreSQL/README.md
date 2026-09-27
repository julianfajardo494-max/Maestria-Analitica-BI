# 🗄️ Taller Práctico: Gestión de Usuarios, Roles y Permisos en PostgreSQL

**Asignatura**: Administración de Bases de Datos (Semestre III) [cite: 41, 44]  
**Autor**: Julián Andrés Fajardo Salcedo | M.Sc.(c) Analítica e Inteligencia de Negocios [cite: 1, 161]  
**Tecnología**: PostgreSQL 15+ / SQL

---

## 📌 Situación (S)

En entornos corporativos y aplicaciones de alto tráfico, la gestión inadecuada de privilegios en bases de datos genera vulnerabilidades de seguridad, accesos no autorizados y riesgos de fuga de información crítica.

## 🎯 Tarea (T)

Diseñar e implementar una arquitectura de seguridad basada en **Roles y Herencia en PostgreSQL**, estableciendo un control de acceso basado en el principio de mínimo privilegio (_Least Privilege_) para un sistema de gestión empresarial.

## ⚙️ Acción (A)

1. **Configuración de Roles Base y Grupos**: Creación de grupos gerenciales, desarrolladores, analistas y lectores [cite: 139].
2. **Control de Acceso Granular**: Asignación de permisos a nivel de Base de Datos, Esquema, Tablas y Secuencias [cite: 135, 136, 137].
3. **Mecanismos de Herencia**: Asociación de usuarios individuales a grupos de permisos estandarizados (`GRANT grupo TO usuario`) [cite: 138, 140].
4. **Consultas de Auditoría**: Implementación de scripts de monitoreo sobre las tablas del sistema `pg_roles`, `pg_auth_members` e `information_schema` [cite: 143, 144].

## 📈 Resultados (R)

- **Seguridad Garantizada**: Aislamiento efectivo entre entornos de lectura, analítica y administración [cite: 140, 141].
- **Estructura Escalable**: Administración simplificada mediante grupos en lugar de asignaciones individuales.
- **Auditoría Transparente**: Trazabilidad completa de privilegios concedidos en el motor PostgreSQL [cite: 143].
  🚀 Paso 3: Subir los cambios a GitHub desde la terminal de VS Code
