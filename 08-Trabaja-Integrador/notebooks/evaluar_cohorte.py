"""Evalúa las reglas geométricas (longitud / pares / z-medialidad) contra los nombres
de Autotrack guardados en <paciente>.tt.gz.txt (una línea por clúster, en orden de índice).

Uso:  python evaluar_cohorte.py CARPETA_CON_TT_GZ  [salida.csv]
Requiere: numpy, scipy, pandas.
"""
import sys, io, gzip, struct, glob, os
import numpy as np, pandas as pd
from scipy.io import loadmat
from scipy.optimize import linear_sum_assignment

ABREV = {"arc": "arc", "unc": "unc", "flm": "mdlf", "fli": "ilf"}   # nombres DSI Studio -> códigos del notebook
TRACTOS = ["unc", "arc", "mdlf", "ilf"]

def decodificar(track_bytes):
    out, pos, n = [], 0, len(track_bytes)
    while pos < n:
        c = struct.unpack_from("<I", track_bytes, pos)[0]
        p0 = np.array(struct.unpack_from("<iii", track_bytes, pos + 4), dtype=np.int64)
        d = np.frombuffer(track_bytes, np.int8, count=c - 3, offset=pos + 16).astype(np.int64).reshape(-1, 3)
        out.append(np.vstack([p0, p0 + np.cumsum(d, axis=0)]) / 32.0)
        pos += 13 + c
    return out

def cargar(ruta):
    d = loadmat(io.BytesIO(gzip.open(ruta).read()))
    return d, decodificar(d["track"].astype(np.uint8).tobytes())

def features(d, sl):
    cl = d["cluster"][0].astype(int)
    mid = float(d["dimension"].squeeze()[0]) / 2
    filas = []
    for k in np.unique(cl):
        idx = np.where(cl == k)[0]
        pts = np.vstack([sl[i] for i in idx])
        L = np.mean([np.linalg.norm(np.diff(sl[i], axis=0), axis=1).sum() for i in idx])
        c = pts.mean(0)
        # Convención verificada con nombres de Autotrack: x > línea media = IZQUIERDO
        filas.append(dict(cluster=int(k), n=len(idx), x=c[0], y=c[1], z=c[2],
                          dist_medial=abs(c[0] - mid), lado="l" if c[0] > mid else "r", long_mm=L))
    return pd.DataFrame(filas)

def clasificar(df):
    l, r = df[df.lado == "l"].reset_index(drop=True), df[df.lado == "r"].reset_index(drop=True)
    if len(l) != 4 or len(r) != 4:
        return None, f"lados {len(l)}/{len(r)} (se esperaba 4/4)"
    cost = np.array([[abs(a.y-b.y)+abs(a.z-b.z)+abs(a.dist_medial-b.dist_medial)+abs(a.long_mm-b.long_mm)
                      for b in r.itertuples()] for a in l.itertuples()])
    fi, ci = linear_sum_assignment(cost)
    p = pd.DataFrame([dict(cl_l=int(l.cluster[i]), cl_r=int(r.cluster[j]),
                           long=(l.long_mm[i]+r.long_mm[j])/2,
                           med=(l.dist_medial[i]+r.dist_medial[j])/2,
                           z=(l.z[i]+r.z[j])/2) for i, j in zip(fi, ci)])
    unc = p.long.idxmin(); rest = p.drop(unc)
    arc = rest.long.idxmax(); rest2 = rest.drop(arc)
    mdlf = (rest2.med - rest2.z).idxmin(); ilf = rest2.drop(mdlf).index[0]
    pred = {}
    for idx, t in {unc: "unc", arc: "arc", mdlf: "mdlf", ilf: "ilf"}.items():
        pred[int(p.cl_l[idx])] = (t, "l"); pred[int(p.cl_r[idx])] = (t, "r")
    return pred, "ok"

def main(carpeta, salida="resultados_cohorte.csv"):
    filas = []
    for tt in sorted(glob.glob(os.path.join(carpeta, "**", "*.tt.gz"), recursive=True)):
        txt = tt + ".txt"
        pid = os.path.basename(tt)
        if not os.path.exists(txt):
            print(f"[omitido] {pid}: sin {os.path.basename(txt)}"); continue
        nombres = [s.strip() for s in open(txt) if s.strip()]
        d, sl = cargar(tt)
        if "trans_to_mni" not in d: print(f"[aviso] {pid}: sin trans_to_mni")
        df = features(d, sl)
        if len(nombres) != len(df):
            print(f"[omitido] {pid}: {len(nombres)} nombres vs {len(df)} clústeres"); continue
        pred, estado = clasificar(df)
        if pred is None:
            print(f"[fallo reglas] {pid}: {estado}"); continue
        for r in df.itertuples():
            # nombre p.ej. 's1_arc_l' -> (tracto, lado)
            _, ab, lado = nombres[r.cluster].split("_")
            ver_t, ver_l = ABREV[ab], lado
            pt, pl = pred[r.cluster]
            filas.append(dict(paciente=pid, cluster=r.cluster, n=r.n, x=r.x, long_mm=r.long_mm,
                              verdad_tracto=ver_t, verdad_lado=ver_l, pred_tracto=pt, pred_lado=pl))
    R = pd.DataFrame(filas)
    if R.empty: print("Sin resultados."); return
    R.to_csv(salida, index=False)
    print(f"\nPacientes evaluados: {R.paciente.nunique()}")
    print("\nMatriz de confusión (filas = verdad Autotrack, columnas = reglas):")
    print(pd.crosstab(R.verdad_tracto, R.pred_tracto).reindex(index=TRACTOS, columns=TRACTOS, fill_value=0))
    rec = (R.verdad_tracto == R.pred_tracto).groupby(R.verdad_tracto).mean().round(3)
    print("\nRecall por tracto:\n", rec.to_string())
    print(f"\nExactitud de lado (_l/_r) con la convención x>mid = izquierdo: {(R.verdad_lado == R.pred_lado).mean():.3f}")
    print(f"Exactitud con la convención del notebook (invertida):        {(R.verdad_lado != R.pred_lado).mean():.3f}")

if __name__ == "__main__":
    main(*sys.argv[1:3])
