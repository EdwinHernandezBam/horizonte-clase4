"""El contrato: qué mensaje viaja y qué estados acepta el seguimiento.

Esta lista es una COPIA deliberada: el seguimiento vive en otro proceso y no debe
importar el código del monolito para saber qué es válido. Si el monolito crea un
estado nuevo, hay que actualizar el contrato y reiniciar el trabajador.
"""
import time
import uuid

VERSION = 1
ESTADOS_V1 = {
    "CREADA",
    "VALIDADA",
    "EN_LIQUIDACION",
    "CONTABILIZADA",
    "VALIDACION_FALLIDA",
    "SIN_RESPUESTA_CORE",
}


class ContratoInvalido(Exception):
    pass


def crear_evento(orden_id: int, estado: str) -> dict:
    return {
        "id": str(uuid.uuid4()),
        "version": VERSION,
        "orden_id": orden_id,
        "estado": estado,
        "momento": time.time(),
    }


def validar(evento: dict) -> None:
    for campo in ("id", "version", "orden_id", "estado", "momento"):
        if campo not in evento:
            raise ContratoInvalido(f"falta el campo «{campo}»")
    if evento["version"] != VERSION:
        raise ContratoInvalido(f"versión {evento['version']} no soportada")
    if evento["estado"] not in ESTADOS_V1:
        raise ContratoInvalido(f"estado desconocido «{evento['estado']}»")
