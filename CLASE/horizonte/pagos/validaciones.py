"""Validaciones de Pagos: fondos y límites."""
from horizonte.ordenes.modelo import Orden

SALDOS = {"ana": 10_000.0, "luis": 500.0, "marta": 2_000.0}
LIMITE_POR_ORDEN = 5_000.0


def validar(orden: Orden) -> bool:
    saldo = SALDOS.get(orden.cliente, 0.0)
    if orden.monto > saldo:
        return False
    if orden.monto > LIMITE_POR_ORDEN:
        return False
    return True
