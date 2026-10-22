"""Conexión al emulador (Floci)."""
import os

import boto3

ENDPOINT = os.environ.get("AWS_ENDPOINT_URL", "http://localhost:4566")
REGION = os.environ.get("AWS_DEFAULT_REGION", "us-east-1")
COLA = "seguimiento-eventos"
COLA_ERRORES = "seguimiento-eventos-dlq"
TABLA = "seguimiento"


def cliente(servicio: str):
    return boto3.client(
        servicio,
        endpoint_url=ENDPOINT,
        region_name=REGION,
        aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID", "test"),
        aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY", "test"),
    )


def recurso_dynamodb():
    return boto3.resource(
        "dynamodb",
        endpoint_url=ENDPOINT,
        region_name=REGION,
        aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID", "test"),
        aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY", "test"),
    )


def url_cola(nombre: str) -> str:
    return cliente("sqs").get_queue_url(QueueName=nombre)["QueueUrl"]
