"""Lado del monolito: publica un evento por cada cambio de estado."""
import json

from separado import aws, contrato

_url = None


def publicar(orden_id: int, estado) -> dict:
    global _url
    evento = contrato.crear_evento(orden_id, getattr(estado, "value", estado))
    if _url is None:
        _url = aws.url_cola(aws.COLA)
    aws.cliente("sqs").send_message(QueueUrl=_url, MessageBody=json.dumps(evento))
    return evento
