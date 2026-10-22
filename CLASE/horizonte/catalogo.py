"""Catálogo de estados de la clase 3: un nombre por significado.

Traduce el estado interno de una orden al texto que ve el cliente en el canal móvil.
"""
from horizonte.ordenes.modelo import Estado

TEXTO_CANAL = {
    Estado.CREADA: "Esperando respuesta",
    Estado.VALIDADA: "Validada",
    Estado.EN_LIQUIDACION: "En liquidación",
    Estado.CONTABILIZADA: "Confirmada por el cliente",
    Estado.VALIDACION_FALLIDA: "Error mostrado",
    Estado.SIN_RESPUESTA_CORE: "Verificando",
}


def texto_para_canal(estado: Estado) -> str:
    return TEXTO_CANAL[estado]
