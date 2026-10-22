from dataclasses import dataclass, field
from enum import Enum
from itertools import count

_ids = count(1)


class Estado(str, Enum):
    CREADA = "CREADA"
    VALIDADA = "VALIDADA"
    EN_LIQUIDACION = "EN_LIQUIDACION"
    CONTABILIZADA = "CONTABILIZADA"
    VALIDACION_FALLIDA = "VALIDACION_FALLIDA"
    SIN_RESPUESTA_CORE = "SIN_RESPUESTA_CORE"


@dataclass
class Orden:
    cliente: str
    monto: float
    estado: Estado = Estado.CREADA
    id: int = field(default_factory=lambda: next(_ids))
