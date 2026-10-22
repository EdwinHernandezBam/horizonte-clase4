"""Notificaciones push al celular del cliente."""
from horizonte.ordenes.modelo import Estado

MENSAJES = {
    Estado.VALIDADA: "Tu orden fue validada.",
    Estado.CONTABILIZADA: "Tu orden fue confirmada.",
    Estado.VALIDACION_FALLIDA: "No pudimos procesar tu orden.",
    Estado.SIN_RESPUESTA_CORE: "Estamos verificando tu orden.",
}

ENVIADAS: list[str] = []


def avisar(cliente: str, estado: Estado) -> None:
    mensaje = MENSAJES.get(estado)
    if mensaje:
        ENVIADAS.append(f"{cliente}: {mensaje}")


def limpiar() -> None:
    ENVIADAS.clear()
