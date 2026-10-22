"""Arma el archivo que se sube a la plataforma: Entrega_Clase4_<equipo>.zip

Uso:  python tools/empaquetar_entrega.py
      python tools/empaquetar_entrega.py --equipo "Mesa 2"

Incluye resultados.md, ADR-002-borrador.md y una carpeta evidencia/ con lo que
miden las herramientas (matriz y cambios). Antes de empaquetar le avisa si
todavía quedan campos sin llenar. Se puede ejecutar tantas veces como quiera:
cada vez genera el zip de nuevo con lo último que escribieron.
"""
import argparse
import re
import subprocess
import sys
import zipfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ARCHIVOS = ["resultados.md", "ADR-002-borrador.md"]


def correr(*cmd: str) -> str:
    r = subprocess.run([sys.executable, *cmd], cwd=RAIZ, capture_output=True, text=True)
    return (r.stdout + r.stderr).strip() or "(sin salida)"


def pendientes(texto: str) -> list[str]:
    avisos = []
    if "______" in texto:
        avisos.append(f"{texto.count('______')} línea(s) con ______ sin llenar")
    filas = [f for f in texto.splitlines() if f.startswith("|") and not re.match(r"^\|[-| ]+\|$", f)]
    vacias = [f for f in filas if f.rstrip().endswith("| |") or "|  |" in f]
    if vacias:
        avisos.append(f"{len(vacias)} fila(s) de tabla con celdas vacías")
    return avisos


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--equipo", help="nombre del equipo, por ejemplo «Mesa 2»")
    args = ap.parse_args()
    equipo = args.equipo or input("Nombre del equipo (por ejemplo Mesa 2): ").strip() or "equipo"
    limpio = re.sub(r"[^A-Za-z0-9_-]+", "_", equipo).strip("_") or "equipo"

    faltan = [a for a in ARCHIVOS if not (RAIZ / a).exists()]
    if faltan:
        print("No encuentro: " + ", ".join(faltan) + ". Ejecute este comando desde la carpeta CLASE.")
        return 1

    print("\nRevisión rápida:")
    hay_avisos = False
    for a in ARCHIVOS:
        for aviso in pendientes((RAIZ / a).read_text(encoding="utf-8")):
            hay_avisos = True
            print(f"  - {a}: {aviso}")
    if hay_avisos:
        print("  Puede subirlo así si va a seguir trabajando, pero la entrega final debe estar completa.")
    else:
        print("  Todo parece llenado.")

    evidencia = {
        "evidencia/matriz.txt": correr("tools/matriz.py"),
        "evidencia/medicion_del_cambio.txt": correr("tools/medir_cambio.py"),
    }
    destino = RAIZ / f"Entrega_Clase4_{limpio}.zip"
    with zipfile.ZipFile(destino, "w", zipfile.ZIP_DEFLATED) as z:
        for a in ARCHIVOS:
            z.write(RAIZ / a, a)
        for nombre, texto in evidencia.items():
            z.writestr(nombre, texto + "\n")
    print(f"\nListo: {destino}")
    print("Súbalo a la plataforma. Si corrige algo después, vuelva a ejecutar este comando y suba el nuevo zip.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
