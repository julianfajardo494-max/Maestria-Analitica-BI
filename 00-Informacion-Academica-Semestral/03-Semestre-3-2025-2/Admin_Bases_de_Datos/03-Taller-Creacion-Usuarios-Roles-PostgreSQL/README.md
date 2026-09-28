# 🏛️ Taller Práctico: Gestión de Usuarios, Roles y Permisos en PostgreSQL

**Asignatura**: Administración de Bases de Datos (Semestre III - Univalle)  
**Autor**: Julián Andrés Fajardo Salcedo | M.Sc.(c) Analítica e Inteligencia de Negocios  

---

## 📌 1. Objetivo del Taller
Implementar un sistema de autenticación y autorización en PostgreSQL aplicando el modelo de Seguridad Basada en Roles (RBAC), herencia de permisos y consultas de auditoría sobre esquemas y tablas.

## 🗂️ 2. Archivos del Entregable
* `Taller Práctico Creacion de Usuarios y Roles.docx`: Enunciado original de la guía docente.
* `taller_usuarios_roles.sql`: Script SQL ejecutable completo con creación de base de datos (`empresa_db`), roles (`carlos`, `maria`, `pedro`, `ana`), asignación a grupos y permisos.
* `README.md`: Guía de contexto y ejecución del taller.
* `evidencias/`: Capturas de pantalla con la ejecución exitosa del script.

## ⚙️ 3. Instrucciones de Ejecución
1. Abrir la terminal integrada en VS Code en esta ubicación.
2. Conectarse a PostgreSQL y ejecutar el script completo:
   ```bash
   psql -U postgres -d postgres -f taller_usuarios_roles.sql
Verificar la creación de la base de datos empresa_db, los roles y los privilegios en la consola.

*(Guarda los cambios con `Ctrl + S`)*.

---

#### 3️⃣ Sincronizar y publicar en GitHub

```bash
cd D:\Maestria-Analitica-BI
git add .
git commit -m "docs(s3-db): estructurar entregable academico con README, script SQL y carpeta de evidencias"
git push origin main
```