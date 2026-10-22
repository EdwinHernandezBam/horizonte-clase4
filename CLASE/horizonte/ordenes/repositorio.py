"""Almacén en memoria de órdenes (en un banco real sería una base de datos)."""
from horizonte.ordenes.modelo import Orden

_ORDENES: dict[int, Orden] = {}


def guardar(orden: Orden) -> Orden:
    _ORDENES[orden.id] = orden
    return orden


def buscar(orden_id: int) -> Orden | None:
    return _ORDENES.get(orden_id)


def limpiar() -> None:
    _ORDENES.clear()
