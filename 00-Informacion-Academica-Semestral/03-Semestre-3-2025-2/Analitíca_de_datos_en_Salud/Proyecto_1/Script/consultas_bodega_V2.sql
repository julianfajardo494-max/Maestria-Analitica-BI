SELECT *  FROM hecho_atencion;
SELECT *  FROM dim_fecha;

--- Tiempo promedio de espera en toda la BD
SELECT AVG(tiempo_espera_horas)
FROM hecho_atencion;

--- Tiempo promedio de espera en toda la BD
SELECT AVG(tiempo_espera_horas)
FROM hecho_atencion;

---- Tiempo promedio de espera agrupado por IPS
SELECT  dim_ips.nombre, AVG(tiempo_espera_horas) AS tiempo_espera
FROM  hecho_atencion, dim_ips
WHERE hecho_atencion.key_dim_ips = dim_ips.key_dim_ips
GROUP BY dim_ips.nombre
ORDER BY tiempo_espera DESC;

---- Tiempo promedio de espera agrupado por IPS
SELECT  dim_ips.nombre, AVG(tiempo_espera_horas) AS tiempo_espera
FROM hecho_atencion, dim_ips
WHERE hecho_atencion.key_dim_ips = dim_ips.key_dim_ips
GROUP BY dim_ips.nombre
ORDER BY tiempo_espera DESC;


----- Centros hospitalarios que más pacientes atienden
SELECT  dim_ips.nombre, COUNT(*) AS cantidad_pacientes
FROM hecho_atencion, dim_ips
WHERE hecho_atencion.key_dim_ips = dim_ips.key_dim_ips
GROUP BY dim_ips.nombre
ORDER BY cantidad_pacientes DESC;


----- Centros hospitalarios que más pacientes atienden por region
SELECT  dim_ips.nombre, dim_ips.municipio, COUNT(*) AS cantidad_pacientes
FROM hecho_atencion, dim_ips
WHERE hecho_atencion.key_dim_ips = dim_ips.key_dim_ips
GROUP BY dim_ips.nombre, dim_ips.municipio
ORDER BY cantidad_pacientes DESC;


--- Municipios que más atienden
SELECT   dim_ips.municipio, COUNT(*) AS cantidad_pacientes
FROM hecho_atencion, dim_ips
WHERE hecho_atencion.key_dim_ips = dim_ips.key_dim_ips
GROUP BY  dim_ips.municipio
ORDER BY cantidad_pacientes DESC;
