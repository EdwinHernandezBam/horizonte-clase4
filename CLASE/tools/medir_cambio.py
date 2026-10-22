"""Cuenta cuántos módulos y archivos toca tu cambio, comparando con la versión base.

Uso:  python tools/medir_cambio.py
Requiere que el repositorio tenga la etiqueta «base» (la crea el instalador).
"""
import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent


def git(*args: str) -> str:
    r = subprocess.run(["git", *args], cwd=RAIZ, capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stderr.strip() or "Error al ejecutar git")
        sys.exit(1)
    return r.stdout


def modulo(ruta: str) -> str:
    p = Path(ruta).parts
    if p[0] == "horizonte":
        return p[1][:-3] if len(p) == 2 else p[1]
    return p[0]


def main() -> int:
    if "base" not in git("tag").split():
        print("No encuentro la etiqueta «base». Ejecuta primero el instalador o: git tag base")
        return 1
    cambiados = set(git("diff", "--name-only", "base").split())
    cambiados |= set(git("ls-files", "--others", "--exclude-standard").split())
    codigo = sorted(f for f in cambiados if f.endswith(".py") and not f.startswith(("tests/", "tools/", ".venv")))
    pruebas = sorted(f for f in cambiados if f.startswith("tests/"))
    if not codigo:
        print("Todavía no hay cambios en el código.")
        return 0
    mods = sorted({modulo(f) for f in codigo})
    print("\nARCHIVOS DE CÓDIGO TOCADOS")
    for f in codigo:
        print("  -", f)
    print(f"\nMÓDULOS TOCADOS: {len(mods)}  ->  {', '.join(mods)}")
    print(f"ARCHIVOS TOCADOS: {len(codigo)}   (pruebas modificadas: {len(pruebas)})")
    print("\nAnota estos números en tu hoja: son la medida del acoplamiento para este cambio.\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
