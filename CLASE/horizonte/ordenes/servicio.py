"""Caso de uso: crear y procesar una orden de pago."""
from horizonte.core import adaptador as core
from horizonte.notificaciones import push
from horizonte.ordenes import repositorio
from horizonte.ordenes.modelo import Estado, Orden
from horizonte.pagos import validaciones
from horizonte.seguimiento import historial


def _cambiar(orden: Orden, estado: Estado) -> None:
    orden.estado = estado
    repositorio.guardar(orden)
    historial.registrar(orden.id, estado)
    push.avisar(orden.cliente, estado)


def crear_y_procesar(cliente: str, monto: float) -> Orden:
    orden = repositorio.guardar(Orden(cliente=cliente, monto=monto))
    historial.registrar(orden.id, Estado.CREADA)

    if not validaciones.validar(orden):
        _cambiar(orden, Estado.VALIDACION_FALLIDA)
        return orden
    _cambiar(orden, Estado.VALIDADA)

    _cambiar(orden, Estado.EN_LIQUIDACION)
    try:
        core.contabilizar(orden)
    except core.CoreNoResponde:
        _cambiar(orden, Estado.SIN_RESPUESTA_CORE)
        return orden
    _cambiar(orden, Estado.CONTABILIZADA)
    return orden
