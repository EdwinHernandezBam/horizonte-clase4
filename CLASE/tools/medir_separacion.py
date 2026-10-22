"""Compara el seguimiento DENTRO del monolito con el seguimiento SEPARADO.

Uso:  python tools/medir_separacion.py            (el trabajador debe estar corriendo)
      python tools/medir_separacion.py --con-trabajador   (lo arranca este mismo script)
"""
import sys as _sys
from pathlib import Path as _Path

_sys.path.insert(0, str(_Path(__file__).resolve().parent.parent))

import argparse
import os
import threading
import time

N = 30


def medir_interno() -> float:
    os.environ["SEGUIMIENTO_MODO"] = "interno"
    from horizonte.seguimiento import historial
    from horizonte.ordenes.modelo import Estado

    historial.limpiar()
    t0 = time.perf_counter()
    for i in range(N):
        historial.registrar(i, Estado.CREADA)
    return (time.perf_counter() - t0) * 1000 / N


def medir_separado(timeout: float = 15.0) -> tuple[float, float]:
    os.environ["SEGUIMIENTO_MODO"] = "separado"
    from horizonte.ordenes.modelo import Estado
    from horizonte.seguimiento import historial

    base = int(time.time()) % 1_000_000 * 100
    t0 = time.perf_counter()
    for i in range(N):
        historial.registrar(base + i, Estado.CREADA)
    publicar_ms = (time.perf_counter() - t0) * 1000 / N
    t1 = time.perf_counter()
    visibles = set()
    while len(visibles) < N and time.perf_counter() - t1 < timeout:
        for i in range(N):
            if i not in visibles and historial.consultar(base + i):
                visibles.add(i)
        time.sleep(0.05)
    if len(visibles) < N:
        print(f"  Aviso: solo {len(visibles)} de {N} eventos llegaron a ser visibles. ¿Está corriendo el trabajador?")
    return publicar_ms, (time.perf_counter() - t0) * 1000


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--con-trabajador", action="store_true")
    args = ap.parse_args()
    if args.con_trabajador:
        from separado import trabajador

        threading.Thread(target=trabajador.ejecutar, kwargs={"segundos": 40, "silencioso": True}, daemon=True).start()
    interno = medir_interno()
    publicar, visibles = medir_separado()
    print(f"\n{'':34}{'dentro del monolito':>22}{'separado':>26}")
    print(f"{'registrar un cambio (ms)':34}{interno:>22.3f}{publicar:>26.1f}")
    print(f"{'todos visibles en consulta (ms)':34}{'inmediato':>22}{visibles:>26.0f}")
    print(f"{'procesos que hay que desplegar':34}{1:>22}{2:>26}")
    print(f"{'piezas que pueden fallar':34}{'ninguna extra':>22}{'cola, trabajador, base':>26}")
    print("\nPregunta para tu equipo: ¿cuánto de este costo vale la pena pagar, y qué señal medible lo justificaría?\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
