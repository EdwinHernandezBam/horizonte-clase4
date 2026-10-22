"""Crea (o reinicia) la cola, la cola de errores y la tabla del seguimiento en el emulador.

Uso:  python tools/floci_preparar.py            crea lo que falte
      python tools/floci_preparar.py --reiniciar  borra y vuelve a crear
"""
import sys as _sys
from pathlib import Path as _Path

_sys.path.insert(0, str(_Path(__file__).resolve().parent.parent))

import argparse
import sys
import time

from botocore.exceptions import ClientError

from separado import aws


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--reiniciar", action="store_true")
    args = ap.parse_args()
    sqs, ddb = aws.cliente("sqs"), aws.cliente("dynamodb")
    try:
        if args.reiniciar:
            for nombre in (aws.COLA, aws.COLA_ERRORES):
                try:
                    sqs.delete_queue(QueueUrl=aws.url_cola(nombre))
                except ClientError:
                    pass
            try:
                ddb.delete_table(TableName=aws.TABLA)
                time.sleep(0.5)
            except ClientError:
                pass
        for nombre in (aws.COLA, aws.COLA_ERRORES):
            sqs.create_queue(QueueName=nombre)
            print(f"  cola lista: {nombre}")
        try:
            ddb.create_table(
                TableName=aws.TABLA,
                KeySchema=[
                    {"AttributeName": "orden_id", "KeyType": "HASH"},
                    {"AttributeName": "evento_id", "KeyType": "RANGE"},
                ],
                AttributeDefinitions=[
                    {"AttributeName": "orden_id", "AttributeType": "N"},
                    {"AttributeName": "evento_id", "AttributeType": "S"},
                ],
                BillingMode="PAY_PER_REQUEST",
            )
            print(f"  tabla creada: {aws.TABLA}")
        except ClientError as e:
            if e.response["Error"]["Code"] in ("ResourceInUseException", "TableAlreadyExistsException"):
                print(f"  tabla lista: {aws.TABLA}")
            else:
                raise
    except Exception as e:  # noqa: BLE001
        print(f"\nNo pude hablar con el emulador en {aws.ENDPOINT}: {e}")
        print("¿Está encendido? Enciéndelo con 2-INICIAR-LA-CLASE (en la carpeta de tu sistema: WINDOWS, MAC o LINUX) y prueba otra vez.")
        return 1
    print("Emulador preparado.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
