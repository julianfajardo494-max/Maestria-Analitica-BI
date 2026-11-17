-- ==============================================================================
-- TALLER 3: DATA VAULT 2.0 Y ARQUITECTURA MEDALLION EN RETAILNOVA
-- Maestría en Analítica e Inteligencia de Negocios - Universidad del Valle
-- Autores: Julián Andrés Fajardo Salcedo & Nicolás Galeano
-- Motor: PostgreSQL 16
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. CONFIGURACIÓN DE BASE DE DATOS Y ESQUEMAS (MEDALLION)
-- ------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- ------------------------------------------------------------------------------
-- 2. CAPA BRONZE (RAW STORE - INGESTA TEXTUAL APPEND-ONLY CON AUDITORÍA)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.crm_clientes CASCADE;
CREATE TABLE bronze.crm_clientes (
    cliente_id  TEXT,
    nombre      TEXT,
    ciudad      TEXT,
    segmento    TEXT,
    _archivo    TEXT DEFAULT current_setting('taller.archivo', true),
    _cargado    DATE DEFAULT current_setting('taller.lote', true)::date
);

DROP TABLE IF EXISTS bronze.erp_productos CASCADE;
CREATE TABLE bronze.erp_productos (
    producto_id TEXT,
    nombre      TEXT,
    categoria   TEXT,
    marca       TEXT,
    precio      TEXT,
    _archivo    TEXT DEFAULT current_setting('taller.archivo', true),
    _cargado    DATE DEFAULT current_setting('taller.lote', true)::date
);

DROP TABLE IF EXISTS bronze.erp_tiendas CASCADE;
CREATE TABLE bronze.erp_tiendas (
    tienda_id   TEXT,
    nombre      TEXT,
    ciudad      TEXT,
    region      TEXT,
    _archivo    TEXT DEFAULT current_setting('taller.archivo', true),
    _cargado    DATE DEFAULT current_setting('taller.lote', true)::date
);

DROP TABLE IF EXISTS bronze.pos_ventas CASCADE;
CREATE TABLE bronze.pos_ventas (
    ticket      TEXT,
    fecha       TEXT,
    tienda_id   TEXT,
    producto_id TEXT,
    cliente_id  TEXT,
    cantidad    TEXT,
    precio_unit TEXT,
    monto       TEXT,
    _archivo    TEXT DEFAULT current_setting('taller.archivo', true),
    _cargado    DATE DEFAULT current_setting('taller.lote', true)::date
);

-- ------------------------------------------------------------------------------
-- 3. CAPA SILVER: RAW VAULT (HUBS, LINKS Y SATÉLITES)
-- ------------------------------------------------------------------------------

-- HUBS (Claves de Negocio)
DROP TABLE IF EXISTS silver.hub_cliente CASCADE;
CREATE TABLE silver.hub_cliente (
    hk_cliente     CHAR(32) PRIMARY KEY,
    cliente_id     TEXT NOT NULL UNIQUE,
    load_date      DATE NOT NULL,
    record_source  TEXT NOT NULL
);

DROP TABLE IF EXISTS silver.hub_producto CASCADE;
CREATE TABLE silver.hub_producto (
    hk_producto    CHAR(32) PRIMARY KEY,
    producto_id    TEXT NOT NULL UNIQUE,
    load_date      DATE NOT NULL,
    record_source  TEXT NOT NULL
);

DROP TABLE IF EXISTS silver.hub_tienda CASCADE;
CREATE TABLE silver.hub_tienda (
    hk_tienda      CHAR(32) PRIMARY KEY,
    tienda_id      TEXT NOT NULL UNIQUE,
    load_date      DATE NOT NULL,
    record_source  TEXT NOT NULL
);

-- LINK (Transacciones / Asociaciones M:N)
DROP TABLE IF EXISTS silver.link_venta CASCADE;
CREATE TABLE silver.link_venta (
    hk_venta       CHAR(32) PRIMARY KEY,
    hk_cliente     CHAR(32) NOT NULL REFERENCES silver.hub_cliente(hk_cliente),
    hk_producto    CHAR(32) NOT NULL REFERENCES silver.hub_producto(hk_producto),
    hk_tienda      CHAR(32) NOT NULL REFERENCES silver.hub_tienda(hk_tienda),
    ticket         TEXT NOT NULL,
    load_date      DATE NOT NULL,
    record_source  TEXT NOT NULL
);

-- SATÉLITES (Atributos Descriptivos e Historia)
DROP TABLE IF EXISTS silver.sat_cliente_crm CASCADE;
CREATE TABLE silver.sat_cliente_crm (
    hk_cliente     CHAR(32) NOT NULL REFERENCES silver.hub_cliente(hk_cliente),
    load_date      DATE NOT NULL,
    nombre         TEXT NOT NULL,
    ciudad         TEXT NOT NULL,
    segmento       TEXT NOT NULL,
    hash_diff      CHAR(32) NOT NULL,
    record_source  TEXT NOT NULL,
    PRIMARY KEY (hk_cliente, load_date)
);

DROP TABLE IF EXISTS silver.sat_producto_erp CASCADE;
CREATE TABLE silver.sat_producto_erp (
    hk_producto    CHAR(32) NOT NULL REFERENCES silver.hub_producto(hk_producto),
    load_date      DATE NOT NULL,
    nombre         TEXT NOT NULL,
    categoria      TEXT NOT NULL,
    marca          TEXT NOT NULL,
    precio         NUMERIC(12,2) NOT NULL,
    hash_diff      CHAR(32) NOT NULL,
    record_source  TEXT NOT NULL,
    PRIMARY KEY (hk_producto, load_date)
);

DROP TABLE IF EXISTS silver.sat_tienda_erp CASCADE;
CREATE TABLE silver.sat_tienda_erp (
    hk_tienda      CHAR(32) NOT NULL REFERENCES silver.hub_tienda(hk_tienda),
    load_date      DATE NOT NULL,
    nombre         TEXT NOT NULL,
    ciudad         TEXT NOT NULL,
    region         TEXT NOT NULL,
    hash_diff      CHAR(32) NOT NULL,
    record_source  TEXT NOT NULL,
    PRIMARY KEY (hk_tienda, load_date)
);

DROP TABLE IF EXISTS silver.sat_venta_pos CASCADE;
CREATE TABLE silver.sat_venta_pos (
    hk_venta       CHAR(32) NOT NULL REFERENCES silver.link_venta(hk_venta),
    load_date      DATE NOT NULL,
    fecha          DATE NOT NULL,
    cantidad       INT NOT NULL,
    precio_unit    NUMERIC(12,2) NOT NULL,
    monto          NUMERIC(12,2) NOT NULL,
    hash_diff      CHAR(32) NOT NULL,
    record_source  TEXT NOT NULL,
    PRIMARY KEY (hk_venta, load_date)
);

-- ------------------------------------------------------------------------------
-- 4. PROCEDIMIENTO ALMACENADO DE CARGA INCREMENTAL A SILVER
-- ------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE silver.cargar_lote(p_lote DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. HUBS
    INSERT INTO silver.hub_cliente (hk_cliente, cliente_id, load_date, record_source)
    SELECT DISTINCT
        md5(upper(trim(cliente_id))),
        upper(trim(cliente_id)),
        p_lote,
        'CRM'
    FROM bronze.crm_clientes
    WHERE _cargado = p_lote
      AND NOT EXISTS (
          SELECT 1 FROM silver.hub_cliente h
          WHERE h.hk_cliente = md5(upper(trim(bronze.crm_clientes.cliente_id)))
      );

    INSERT INTO silver.hub_producto (hk_producto, producto_id, load_date, record_source)
    SELECT DISTINCT
        md5(upper(trim(producto_id))),
        upper(trim(producto_id)),
        p_lote,
        'ERP'
    FROM bronze.erp_productos
    WHERE _cargado = p_lote
      AND NOT EXISTS (
          SELECT 1 FROM silver.hub_producto h
          WHERE h.hk_producto = md5(upper(trim(bronze.erp_productos.producto_id)))
      );

    INSERT INTO silver.hub_tienda (hk_tienda, tienda_id, load_date, record_source)
    SELECT DISTINCT
        md5(upper(trim(tienda_id))),
        upper(trim(tienda_id)),
        p_lote,
        'ERP'
    FROM bronze.erp_tiendas
    WHERE _cargado = p_lote
      AND NOT EXISTS (
          SELECT 1 FROM silver.hub_tienda h
          WHERE h.hk_tienda = md5(upper(trim(bronze.erp_tiendas.tienda_id)))
      );

    -- 2. LINKS (Relaciones)
    INSERT INTO silver.link_venta (hk_venta, hk_cliente, hk_producto, hk_tienda, ticket, load_date, record_source)
    SELECT DISTINCT
        md5(upper(trim(cliente_id)) || ';' || upper(trim(producto_id)) || ';' || upper(trim(tienda_id)) || ';' || upper(trim(ticket))),
        md5(upper(trim(cliente_id))),
        md5(upper(trim(producto_id))),
        md5(upper(trim(tienda_id))),
        upper(trim(ticket)),
        p_lote,
        'POS'
    FROM bronze.pos_ventas
    WHERE _cargado = p_lote
      AND NOT EXISTS (
          SELECT 1 FROM silver.link_venta l
          WHERE l.hk_venta = md5(upper(trim(bronze.pos_ventas.cliente_id)) || ';' || upper(trim(bronze.pos_ventas.producto_id)) || ';' || upper(trim(bronze.pos_ventas.tienda_id)) || ';' || upper(trim(bronze.pos_ventas.ticket)))
      );

    -- 3. SATÉLITES (Versionado condicional por hash_diff)
    INSERT INTO silver.sat_cliente_crm (hk_cliente, load_date, nombre, ciudad, segmento, hash_diff, record_source)
    SELECT
        n.hk_cliente, p_lote, n.nombre, n.ciudad, n.segmento, n.hd, 'CRM'
    FROM (
        SELECT DISTINCT ON (md5(upper(trim(cliente_id))))
            md5(upper(trim(cliente_id))) AS hk_cliente,
            trim(nombre) AS nombre,
            trim(ciudad) AS ciudad,
            trim(segmento) AS segmento,
            md5(upper(trim(nombre)) || ';' || upper(trim(ciudad)) || ';' || upper(trim(segmento))) AS hd
        FROM bronze.crm_clientes
        WHERE _cargado = p_lote
    ) n
    LEFT JOIN LATERAL (
        SELECT hash_diff FROM silver.sat_cliente_crm s
        WHERE s.hk_cliente = n.hk_cliente
        ORDER BY s.load_date DESC LIMIT 1
    ) ult ON true
    WHERE ult.hash_diff IS DISTINCT FROM n.hd;

    INSERT INTO silver.sat_producto_erp (hk_producto, load_date, nombre, categoria, marca, precio, hash_diff, record_source)
    SELECT
        n.hk_producto, p_lote, n.nombre, n.categoria, n.marca, n.precio, n.hd, 'ERP'
    FROM (
        SELECT DISTINCT ON (md5(upper(trim(producto_id))))
            md5(upper(trim(producto_id))) AS hk_producto,
            trim(nombre) AS nombre,
            trim(categoria) AS categoria,
            trim(marca) AS marca,
            trim(precio)::numeric(12,2) AS precio,
            md5(upper(trim(nombre)) || ';' || upper(trim(categoria)) || ';' || upper(trim(marca)) || ';' || trim(precio)) AS hd
        FROM bronze.erp_productos
        WHERE _cargado = p_lote
    ) n
    LEFT JOIN LATERAL (
        SELECT hash_diff FROM silver.sat_producto_erp s
        WHERE s.hk_producto = n.hk_producto
        ORDER BY s.load_date DESC LIMIT 1
    ) ult ON true
    WHERE ult.hash_diff IS DISTINCT FROM n.hd;

    INSERT INTO silver.sat_tienda_erp (hk_tienda, load_date, nombre, ciudad, region, hash_diff, record_source)
    SELECT
        n.hk_tienda, p_lote, n.nombre, n.ciudad, n.region, n.hd, 'ERP'
    FROM (
        SELECT DISTINCT ON (md5(upper(trim(tienda_id))))
            md5(upper(trim(tienda_id))) AS hk_tienda,
            trim(nombre) AS nombre,
            trim(ciudad) AS ciudad,
            trim(region) AS region,
            md5(upper(trim(nombre)) || ';' || upper(trim(ciudad)) || ';' || upper(trim(region))) AS hd
        FROM bronze.erp_tiendas
        WHERE _cargado = p_lote
    ) n
    LEFT JOIN LATERAL (
        SELECT hash_diff FROM silver.sat_tienda_erp s
        WHERE s.hk_tienda = n.hk_tienda
        ORDER BY s.load_date DESC LIMIT 1
    ) ult ON true
    WHERE ult.hash_diff IS DISTINCT FROM n.hd;

    INSERT INTO silver.sat_venta_pos (hk_venta, load_date, fecha, cantidad, precio_unit, monto, hash_diff, record_source)
    SELECT
        n.hk_venta, p_lote, n.fecha, n.cantidad, n.precio_unit, n.monto, n.hd, 'POS'
    FROM (
        SELECT DISTINCT ON (md5(upper(trim(cliente_id)) || ';' || upper(trim(producto_id)) || ';' || upper(trim(tienda_id)) || ';' || upper(trim(ticket))))
            md5(upper(trim(cliente_id)) || ';' || upper(trim(producto_id)) || ';' || upper(trim(tienda_id)) || ';' || upper(trim(ticket))) AS hk_venta,
            trim(fecha)::date AS fecha,
            trim(cantidad)::int AS cantidad,
            trim(precio_unit)::numeric(12,2) AS precio_unit,
            trim(monto)::numeric(12,2) AS monto,
            md5(trim(fecha) || ';' || trim(cantidad) || ';' || trim(precio_unit) || ';' || trim(monto)) AS hd
        FROM bronze.pos_ventas
        WHERE _cargado = p_lote
    ) n
    LEFT JOIN LATERAL (
        SELECT hash_diff FROM silver.sat_venta_pos s
        WHERE s.hk_venta = n.hk_venta
        ORDER BY s.load_date DESC LIMIT 1
    ) ult ON true
    WHERE ult.hash_diff IS DISTINCT FROM n.hd;
END;
$$;

-- ------------------------------------------------------------------------------
-- 5. CAPA SILVER: BUSINESS VAULT (ESTANDARIZACIÓN)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE VIEW silver.bv_cliente_estandar AS
SELECT hk_cliente,
       load_date,
       nombre,
       initcap(trim(ciudad)) AS ciudad,
       segmento
FROM silver.sat_cliente_crm;

-- ------------------------------------------------------------------------------
-- 6. CAPA GOLD (INFORMATION MARTS / ESQUEMA ESTRELLA)
-- ------------------------------------------------------------------------------

-- Dimensión Cliente SCD Tipo 2
CREATE OR REPLACE VIEW gold.dim_cliente AS
SELECT h.cliente_id, b.nombre, b.ciudad, b.segmento,
       b.load_date::date AS fecha_inicio,
       COALESCE(LEAD(b.load_date) OVER w - INTERVAL '1 day',
                DATE '9999-12-31')::date AS fecha_fin,
       LEAD(b.load_date) OVER w IS NULL AS vigente
FROM silver.hub_cliente h
JOIN silver.bv_cliente_estandar b USING (hk_cliente)
WINDOW w AS (PARTITION BY b.hk_cliente ORDER BY b.load_date);

-- Dimensión Producto (Vigente Actual)
CREATE OR REPLACE VIEW gold.dim_producto AS
SELECT DISTINCT ON (h.producto_id)
       h.producto_id, s.nombre, s.categoria, s.marca, s.precio AS precio_actual
FROM silver.hub_producto h
JOIN silver.sat_producto_erp s USING (hk_producto)
ORDER BY h.producto_id, s.load_date DESC;

-- Dimensión Tienda (Vigente Actual)
CREATE OR REPLACE VIEW gold.dim_tienda AS
SELECT DISTINCT ON (h.tienda_id)
       h.tienda_id, s.nombre, s.ciudad, s.region
FROM silver.hub_tienda h
JOIN silver.sat_tienda_erp s USING (hk_tienda)
ORDER BY h.tienda_id, s.load_date DESC;

-- Tabla de Hechos Ventas (Estado corregido más reciente)
CREATE OR REPLACE VIEW gold.fact_ventas AS
SELECT DISTINCT ON (l.hk_venta)
       l.ticket,
       s.fecha::date AS fecha_venta,
       c.cliente_id,
       p.producto_id,
       t.tienda_id,
       s.cantidad,
       s.precio_unit,
       s.monto
FROM silver.link_venta l
JOIN silver.sat_venta_pos s USING (hk_venta)
JOIN silver.hub_cliente   c USING (hk_cliente)
JOIN silver.hub_producto  p USING (hk_producto)
JOIN silver.hub_tienda    t USING (hk_tienda)
ORDER BY l.hk_venta, s.load_date DESC;
