# ==============================================================================
# ARCHIVO 3 — Cargue automático de pacientes (carpetas SANOS y ENFERMOS)
# Estructura esperada:  <RAIZ_DATASET>/<GRUPO>/<PACIENTE>/  con, dentro de cada paciente,
#   un *.tt.gz (obligatorio), un *.fz (opcional) y, si existe, un *.tt.gz.txt (nombres de Autotrack).
# ==============================================================================
import os, re, io, gzip, sys, zlib
import numpy as np
import pandas as pd
import scipy.io as sio

# ------------------------------ CONFIGURACIÓN ---------------------------------
# Colab NO puede leer la unidad D:\ de tu PC. Opciones:
#   (a) Copiar la carpeta DATASET_NEUROIMAGEN a Google Drive y montarla (recomendado para Colab).
#   (b) Ejecutar este código en tu PC (Jupyter local) con la ruta de Windows.
EN_COLAB = "google.colab" in sys.modules
if EN_COLAB:
    from google.colab import drive
    drive.mount("/content/drive")
    RAIZ_DATASET = "/content/drive/MyDrive/DATASET_NEUROIMAGEN"   # <-- ajustar a donde lo subas en Drive
else:
    RAIZ_DATASET = r"D:\Maestria-Analitica-BI\08-Trabaja-Integrador\DATASET_NEUROIMAGEN"

GRUPOS = {"SANOS": 0, "ENFERMOS": 1}   # nombre de carpeta -> etiqueta de clase para la CNN
VERIFICAR_INTEGRIDAD = True            # lee cada .tt.gz/.fz completo para detectar archivos truncados (más lento)
CARPETA_SALIDA_A3 = "./salida_archivo3/"
os.makedirs(CARPETA_SALIDA_A3, exist_ok=True)


# ------------------------------- INVENTARIO -----------------------------------
def _clave_natural(nombre):
    """Ordena S1, S2, S10 (y no S1, S10, S2)."""
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r"(\d+)", nombre)]


def verificar_gzip(ruta):
    """True si el .gz se lee completo (sin truncar); False y mensaje si está dañado."""
    try:
        with gzip.open(ruta, "rb") as f:
            while f.read(1 << 24):
                pass
        return True, ""
    except (EOFError, OSError, zlib.error) as e:
        return False, str(e)


def _buscar(carpeta, sufijo, excluir=()):
    return sorted(f for f in os.listdir(carpeta)
                  if f.lower().endswith(sufijo) and not any(f.lower().endswith(x) for x in excluir))


def construir_inventario(raiz=RAIZ_DATASET, grupos=GRUPOS, verificar=VERIFICAR_INTEGRIDAD):
    """Recorre <raiz>/<grupo>/<paciente> y devuelve un DataFrame con una fila por paciente."""
    filas = []
    for grupo, etiqueta in grupos.items():
        carpeta_grupo = os.path.join(raiz, grupo)
        if not os.path.isdir(carpeta_grupo):
            print(f"⚠ No existe la carpeta del grupo: {carpeta_grupo}")
            continue
        pacientes = sorted((d for d in os.listdir(carpeta_grupo) if os.path.isdir(os.path.join(carpeta_grupo, d))),
                           key=_clave_natural)
        for pid in pacientes:
            carpeta = os.path.join(carpeta_grupo, pid)
            tts = _buscar(carpeta, ".tt.gz")
            fzs = _buscar(carpeta, ".fz")
            txts = _buscar(carpeta, ".tt.gz.txt")
            problemas = []
            if len(tts) == 0: problemas.append("falta_tt")
            if len(tts) > 1:  problemas.append(f"varios_tt({len(tts)})")
            if len(fzs) == 0: problemas.append("falta_fz")
            if len(fzs) > 1:  problemas.append(f"varios_fz({len(fzs)})")
            ruta_tt = os.path.join(carpeta, tts[0]) if len(tts) == 1 else ""
            ruta_fz = os.path.join(carpeta, fzs[0]) if len(fzs) == 1 else ""
            ruta_txt = os.path.join(carpeta, txts[0]) if len(txts) == 1 else ""
            if verificar and ruta_tt:
                ok, msg = verificar_gzip(ruta_tt)
                if not ok: problemas.append("tt_danado")
            if verificar and ruta_fz:
                ok, msg = verificar_gzip(ruta_fz)
                if not ok: problemas.append("fz_danado")
            # el .tt.gz es imprescindible; el .fz y el .txt son opcionales
            usable = bool(ruta_tt) and "tt_danado" not in problemas
            filas.append({"paciente": pid, "grupo": grupo, "etiqueta": etiqueta,
                          "ruta_tt": ruta_tt, "ruta_fz": ruta_fz, "ruta_nombres": ruta_txt,
                          "tiene_fz": bool(ruta_fz) and "fz_danado" not in problemas,
                          "tiene_nombres": bool(ruta_txt),
                          "usable": usable, "problemas": ";".join(problemas)})
    return pd.DataFrame(filas)


def resumen_inventario(df):
    print(f"Pacientes encontrados: {len(df)}   |   usables (con .tt.gz íntegro): {int(df['usable'].sum())}")
    print(df.groupby("grupo").agg(pacientes=("paciente", "count"), usables=("usable", "sum"),
                                  con_fz=("tiene_fz", "sum"), con_nombres=("tiene_nombres", "sum")).to_string())
    con_problemas = df[df["problemas"] != ""]
    if len(con_problemas):
        print("\nPacientes con observaciones:")
        print(con_problemas[["grupo", "paciente", "usable", "problemas"]].to_string(index=False))
    if df["paciente"].duplicated().any():
        print("\n⚠ IDs de paciente repetidos entre grupos:", df.loc[df["paciente"].duplicated(keep=False), "paciente"].tolist())


# ---------------------------------- CARGUE ------------------------------------
def cargar_dsi(ruta, obligatorio=True):
    """Descomprime y carga un .tt.gz o .fz de DSI Studio como diccionario (igual que el Archivo 2)."""
    if not ruta or not os.path.exists(ruta):
        if obligatorio:
            raise FileNotFoundError(f"No existe el archivo: {ruta}")
        return None
    try:
        with gzip.open(ruta, "rb") as f:
            return sio.loadmat(io.BytesIO(f.read()))
    except (EOFError, OSError, zlib.error) as e:
        if obligatorio:
            raise
        print(f"⚠ {os.path.basename(ruta)} dañado/truncado ({e}); se continúa sin él.")
        return None


def cargar_paciente(fila, con_fz=True):
    """Carga un paciente (una fila del inventario). Devuelve dict con tt, fz (o None) y metadatos."""
    return {"paciente": fila["paciente"], "grupo": fila["grupo"], "etiqueta": int(fila["etiqueta"]),
            "tt": cargar_dsi(fila["ruta_tt"], obligatorio=True),
            "fz": cargar_dsi(fila["ruta_fz"], obligatorio=False) if (con_fz and fila["tiene_fz"]) else None,
            "ruta_nombres": fila["ruta_nombres"]}


def iterar_pacientes(df, solo_usables=True, con_fz=True):
    """Generador: carga de a un paciente (no mantiene los 76 en memoria). Los errores de un paciente no detienen el lote."""
    for _, fila in df.iterrows():
        if solo_usables and not fila["usable"]:
            print(f"· omitido {fila['grupo']}/{fila['paciente']}: {fila['problemas']}")
            continue
        try:
            yield cargar_paciente(fila, con_fz)
        except Exception as e:
            print(f"✗ {fila['grupo']}/{fila['paciente']}: {type(e).__name__}: {e}")


# ---------------------------------- EJECUCIÓN ---------------------------------
inventario = construir_inventario()
resumen_inventario(inventario)
inventario.to_csv(CARPETA_SALIDA_A3 + "inventario_pacientes.csv", index=False, encoding="utf-8-sig")
print(f"\nInventario guardado en {CARPETA_SALIDA_A3}inventario_pacientes.csv")

# Uso (una vez revisado el inventario):
# for p in iterar_pacientes(inventario):
#     tt, fz = p["tt"], p["fz"]
#     ...  # decodificar, calcular MIP/TDI y guardar por paciente
