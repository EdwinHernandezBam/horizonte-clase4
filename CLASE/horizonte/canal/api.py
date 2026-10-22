"""Canal móvil: lo que la app le pide al backend."""
from horizonte.catalogo import texto_para_canal
from horizonte.ordenes import repositorio, servicio
from horizonte.ordenes.modelo import Estado
from horizonte.seguimiento import historial

ESTADOS_FINALES = {Estado.CONTABILIZADA, Estado.VALIDACION_FALLIDA}


def crear_orden(cliente: str, monto: float) -> dict:
    orden = servicio.crear_y_procesar(cliente, monto)
    return respuesta(orden.id)


def respuesta(orden_id: int) -> dict:
    orden = repositorio.buscar(orden_id)
    return {
        "orden": orden.id,
        "estado": texto_para_canal(orden.estado),
        "final": orden.estado in ESTADOS_FINALES,
        "avance": historial.avance(orden.estado),
        "historial": historial.consultar(orden.id),
    }
