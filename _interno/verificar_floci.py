"""Prueba de humo del emulador: cola (SQS) y tabla (DynamoDB). Uso: verificar_floci.py [--rapido]"""
import os
import sys
import uuid

import boto3

ENDPOINT = os.environ.get("AWS_ENDPOINT_URL", "http://localhost:4566")


def cliente(servicio):
    return boto3.client(
        servicio, endpoint_url=ENDPOINT, region_name="us-east-1",
        aws_access_key_id="test", aws_secret_access_key="test",
    )


def rapido():
    cliente("sqs").list_queues()
    return 0


def completo():
    ok = True
    try:
        sqs = cliente("sqs")
        url = sqs.create_queue(QueueName=f"humo-{uuid.uuid4().hex[:8]}")["QueueUrl"]
        sqs.send_message(QueueUrl=url, MessageBody="hola")
        m = sqs.receive_message(QueueUrl=url, WaitTimeSeconds=1).get("Messages", [])
        assert m and m[0]["Body"] == "hola"
        sqs.delete_queue(QueueUrl=url)
        print("  OK  cola (SQS): enviar y recibir un mensaje")
    except Exception as e:  # noqa: BLE001
        ok = False
        print(f"  ERROR  cola (SQS): {e}")
    try:
        ddb = cliente("dynamodb")
        nombre = f"humo{uuid.uuid4().hex[:8]}"
        ddb.create_table(
            TableName=nombre,
            KeySchema=[{"AttributeName": "k", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "k", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        ddb.put_item(TableName=nombre, Item={"k": {"S": "a"}})
        assert ddb.get_item(TableName=nombre, Key={"k": {"S": "a"}}).get("Item")
        ddb.delete_table(TableName=nombre)
        print("  OK  tabla (DynamoDB): guardar y leer un registro")
    except Exception as e:  # noqa: BLE001
        ok = False
        print(f"  ERROR  tabla (DynamoDB): {e}")
    return 0 if ok else 1


if __name__ == "__main__":
    try:
        sys.exit(rapido() if "--rapido" in sys.argv else completo())
    except Exception as e:  # noqa: BLE001
        print(f"  ERROR  no responde {ENDPOINT}: {e}")
        sys.exit(1)
