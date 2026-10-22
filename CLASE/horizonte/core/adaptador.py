"""Adaptador al core bancario simulado. El core conserva la autoridad sobre los saldos."""
from horizonte.ordenes.modelo import Orden

CLIENTES_SIN_RESPUESTA = {"marta"}  # simula una respuesta perdida del core


class CoreNoResponde(Exception):
    pass


def contabilizar(orden: Orden) -> str:
    if orden.cliente in CLIENTES_SIN_RESPUESTA:
        raise CoreNoResponde("sin respuesta del core")
    return "CONTABILIZADO"
