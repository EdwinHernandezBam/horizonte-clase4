"""Lado del monolito: lee el historial desde la tabla del seguimiento."""
from boto3.dynamodb.conditions import Key

from horizonte.catalogo import texto_para_canal
from horizonte.ordenes.modelo import Estado
from separado import aws


def historial(orden_id: int) -> list[str]:
    tabla = aws.recurso_dynamodb().Table(aws.TABLA)
    items = tabla.query(KeyConditionExpression=Key("orden_id").eq(int(orden_id)))["Items"]
    items.sort(key=lambda i: i["momento"])
    return [texto_para_canal(Estado(i["estado"])) for i in items]
