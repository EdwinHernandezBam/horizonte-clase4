"""Prueba corta de humo: ¿responde el emulador como necesitamos? (cola + tabla)"""
import sys as _sys
from pathlib import Path as _Path

_sys.path.insert(0, str(_Path(__file__).resolve().parent.parent))

import sys
import uuid

from separado import aws


def main() -> int:
    ok = True
    try:
        sqs = aws.cliente("sqs")
        nombre = f"humo-{uuid.uuid4().hex[:8]}"
        url = sqs.create_queue(QueueName=nombre)["QueueUrl"]
        sqs.send_message(QueueUrl=url, MessageBody="hola")
        m = sqs.receive_message(QueueUrl=url, WaitTimeSeconds=1).get("Messages", [])
        assert m and m[0]["Body"] == "hola"
        sqs.delete_queue(QueueUrl=url)
        print("  OK  cola (SQS): enviar y recibir")
    except Exception as e:  # noqa: BLE001
        ok = False
        print(f"  ERROR  cola (SQS): {e}")
    try:
        ddb = aws.cliente("dynamodb")
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
        print("  OK  tabla (DynamoDB): guardar y leer")
    except Exception as e:  # noqa: BLE001
        ok = False
        print(f"  ERROR  tabla (DynamoDB): {e}")
    print(f"Emulador en {aws.ENDPOINT}: {'LISTO' if ok else 'CON PROBLEMAS'}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
