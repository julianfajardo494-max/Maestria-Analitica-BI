# 🏛️ Taller Práctico: Gestión de Usuarios, Roles y Permisos en PostgreSQL

**Asignatura**: Administración de Bases de Datos (Semestre III - Univalle)  
**Autor**: Julián Andrés Fajardo Salcedo | M.Sc.(c) Analítica e Inteligencia de Negocios

---

## 📌 1. Objetivo del Taller

Implementar un sistema de autenticación y autorización en PostgreSQL aplicando el modelo de Seguridad Basada en Roles (RBAC), herencia de permisos y consultas de auditoría sobre esquemas y tablas.

## 🗂️ 2. Archivos del Entregable

- `Taller Práctico Creacion de Usuarios y Roles.docx`: Enunciado original de la guía docente.
- `taller_usuarios_roles.sql`: Script SQL ejecutable completo con creación de base de datos (`empresa_db`), roles web (`web_app`, `web_user`, `web_admin`), usuarios individuales (`carlos`, `maria`, `pedro`, `ana`), asignación a grupos (`gerentes`, `desarrolladores`, `analistas`, `lectores`) y permisos granulares.
- `README.md`: Guía de contexto y ejecución del taller.
- `evidencias/`: Capturas de pantalla con la ejecución exitosa del script y verificación de auditoría.

## ⚙️ 3. Instrucciones de Ejecución

### Opción desde el contenedor Docker

1. Abrir la terminal de Git Bash en la ubicación de este archivo.
2. Cargar y ejecutar el script SQL sobre el contenedor de PostgreSQL:
   ```bash
   docker exec -i postgres_roles_db psql -U postgres -d empresa_db < taller_usuarios_roles.sql
   ficar en la consola la creación de la base de datos empresa_db, la asignación de roles y la matriz de permisos.
   ```

---

### 🚀 Pasos para guardar y publicar en Git Bash:

1. **Guarda el archivo** en VS Code (`Ctrl + S`).
2. **Ejecuta en tu terminal de Git Bash**:

```bash
cd /d/Maestria-Analitica-BI
git add .
git commit -m "Actualizar README Estructura Git"
git push origin main
```
