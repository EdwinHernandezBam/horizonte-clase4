"""Matriz de dependencias entre módulos (quién importa a quién).

Uso:  python tools/matriz.py            muestra la matriz y las métricas
      python tools/matriz.py --csv      además guarda matriz.csv

Un módulo es cada carpeta de horizonte/ (ordenes, pagos, core, ...) más catalogo y separado.
Una fila A con un número en la columna B significa: A importa B (A depende de B).
"""
import argparse
import ast
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent


def modulo_de(ruta: Path) -> str | None:
    rel = ruta.relative_to(RAIZ)
    partes = rel.parts
    if partes[0] == "horizonte":
        if len(partes) == 2:
            nombre = partes[1][:-3]
            return None if nombre in ("__init__", "demo") else nombre
        return partes[1]
    if partes[0] == "separado":
        return "separado"
    return None


def destino_de(nombre_importado: str) -> str | None:
    p = nombre_importado.split(".")
    if p[0] == "horizonte" and len(p) > 1:
        return p[1]
    if p[0] == "separado":
        return "separado"
    return None


def construir() -> tuple[list[str], dict[tuple[str, str], int]]:
    cuenta: dict[tuple[str, str], int] = {}
    modulos: set[str] = set()
    for ruta in sorted(list((RAIZ / "horizonte").rglob("*.py")) + list((RAIZ / "separado").rglob("*.py"))):
        origen = modulo_de(ruta)
        if not origen:
            continue
        modulos.add(origen)
        arbol = ast.parse(ruta.read_text(encoding="utf-8"))
        for nodo in ast.walk(arbol):
            nombres: list[str] = []
            if isinstance(nodo, ast.Import):
                nombres = [a.name for a in nodo.names]
            elif isinstance(nodo, ast.ImportFrom) and nodo.module:
                nombres = [nodo.module]
                if nodo.module == "horizonte":
                    nombres = [f"horizonte.{a.name}" for a in nodo.names]
            for n in nombres:
                destino = destino_de(n)
                if destino and destino != origen:
                    cuenta[(origen, destino)] = cuenta.get((origen, destino), 0) + 1
    return sorted(modulos), cuenta


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", action="store_true")
    args = ap.parse_args()
    modulos, cuenta = construir()
    ancho = max(len(m) for m in modulos) + 2
    print("\nMATRIZ DE DEPENDENCIAS  (fila importa a columna)\n")
    print(" " * ancho + "".join(f"{m[:6]:>8}" for m in modulos) + "   sale  entra")
    filas = []
    for a in modulos:
        sale = sum(1 for b in modulos if cuenta.get((a, b)))
        entra = sum(1 for b in modulos if cuenta.get((b, a)))
        celdas = "".join(f"{(cuenta.get((a, b)) or '·'):>8}" for b in modulos)
        print(f"{a:<{ancho}}{celdas}   {sale:>4}  {entra:>5}")
        filas.append((a, sale, entra))
    print("\nsale  = de cuántos módulos depende (acoplamiento hacia fuera)")
    print("entra = cuántos módulos dependen de él (cuánto arrastra si cambia)\n")
    peor = max(filas, key=lambda f: f[2])
    print(f"El módulo más usado por los demás: {peor[0]} ({peor[2]} módulos dependen de él).")
    if args.csv:
        salida = RAIZ / "matriz.csv"
        with salida.open("w", encoding="utf-8") as f:
            f.write("modulo," + ",".join(modulos) + ",sale,entra\n")
            for a, sale, entra in filas:
                f.write(a + "," + ",".join(str(cuenta.get((a, b), 0)) for b in modulos) + f",{sale},{entra}\n")
        print(f"Guardada en {salida.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
