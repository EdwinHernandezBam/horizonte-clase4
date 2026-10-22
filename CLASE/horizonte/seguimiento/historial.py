"""Seguimiento: historial de estados de cada orden.

El modo se elige con la variable SEGUIMIENTO_MODO:
  - "interno" (por defecto): se guarda en memoria, dentro del monolito.
  - "separado": se publica un evento y lo guarda otro proceso (ver carpeta separado/).
"""
import os
from collections import defaultdict

from horizonte.catalogo import texto_para_canal
from horizonte.ordenes.modelo import Estado

# Orden en que avanza una orden: sirve para calcular el avance en porcentaje.
ORDEN_DE_AVANCE = [Estado.CREADA, Estado.VALIDADA, Estado.EN_LIQUIDACION, Estado.CONTABILIZADA]

_HISTORIAL: dict[int, list[str]] = defaultdict(list)


def _modo() -> str:
    return os.environ.get("SEGUIMIENTO_MODO", "interno")


def registrar(orden_id: int, estado: Estado) -> None:
    if _modo() == "separado":
        from separado import publicador

        publicador.publicar(orden_id, estado)
        return
    _HISTORIAL[orden_id].append(texto_para_canal(estado))


def consultar(orden_id: int) -> list[str]:
    if _modo() == "separado":
        from separado import consulta

        return consulta.historial(orden_id)
    return list(_HISTORIAL[orden_id])


def avance(estado: Estado) -> int:
    """Porcentaje de avance de la orden (0 a 100)."""
    if estado not in ORDEN_DE_AVANCE:
        return 0
    return int(100 * ORDEN_DE_AVANCE.index(estado) / (len(ORDEN_DE_AVANCE) - 1))


def limpiar() -> None:
    _HISTORIAL.clear()
