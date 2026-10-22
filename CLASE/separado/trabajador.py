"""Proceso aparte: lee eventos de la cola y los guarda en la tabla de seguimiento.

Uso:  python -m separado.trabajador
Detener con Ctrl+C. Cada línea impresa es un evento procesado, duplicado o rechazado.
"""
import argparse
import json
import time
from decimal import Decimal

from botocore.exceptions import ClientError

from separado import aws, contrato


def procesar(cuerpo: str, tabla) -> str:
    """Devuelve 'guardado' o 'duplicado'; lanza ContratoInvalido si el mensaje no cumple el contrato."""
    evento = json.loads(cuerpo)
    contrato.validar(evento)
    try:
        tabla.put_item(
            Item={
                "orden_id": int(evento["orden_id"]),
                "evento_id": evento["id"],
                "estado": evento["estado"],
                "momento": Decimal(str(evento["momento"])),
            },
            ConditionExpression="attribute_not_exists(evento_id)",
        )
    except ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return "duplicado"
        raise
    return "guardado"


def ejecutar(segundos: float | None = None, silencioso: bool = False) -> dict:
    sqs = aws.cliente("sqs")
    url = aws.url_cola(aws.COLA)
    url_err = aws.url_cola(aws.COLA_ERRORES)
    tabla = aws.recurso_dynamodb().Table(aws.TABLA)
    contadores = {"guardado": 0, "duplicado": 0, "rechazado": 0}
    limite = time.time() + segundos if segundos else None
    if not silencioso:
        print(f"Trabajador de seguimiento escuchando {aws.COLA} en {aws.ENDPOINT} ... (Ctrl+C para detener)")
    while limite is None or time.time() < limite:
        r = sqs.receive_message(QueueUrl=url, MaxNumberOfMessages=10, WaitTimeSeconds=1)
        for m in r.get("Messages", []):
            try:
                resultado = procesar(m["Body"], tabla)
            except (contrato.ContratoInvalido, json.JSONDecodeError) as e:
                resultado = "rechazado"
                sqs.send_message(
                    QueueUrl=url_err,
                    MessageBody=json.dumps({"motivo": str(e), "mensaje": m["Body"]}),
                )
            contadores[resultado] += 1
            sqs.delete_message(QueueUrl=url, ReceiptHandle=m["ReceiptHandle"])
            if not silencioso:
                print(f"  {resultado:9} {m['Body'][:90]}")
    return contadores


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--segundos", type=float, default=None, help="detenerse tras N segundos")
    args = ap.parse_args()
    try:
        print(ejecutar(args.segundos))
    except KeyboardInterrupt:
        print("\nTrabajador detenido.")
