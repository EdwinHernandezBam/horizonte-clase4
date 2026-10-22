"""Pruebas del seguimiento separado. Necesitan el emulador encendido; si no, se omiten."""
import os
import threading

import pytest

from separado import aws

try:
    aws.cliente("sqs").list_queues()
    EMULADOR = True
except Exception:  # noqa: BLE001
    EMULADOR = False

pytestmark = pytest.mark.skipif(not EMULADOR, reason="el emulador no está encendido")


@pytest.fixture(autouse=True)
def preparar(monkeypatch):
    from tools import floci_preparar

    monkeypatch.setattr("sys.argv", ["x", "--reiniciar"])
    assert floci_preparar.main() == 0
    monkeypatch.setenv("SEGUIMIENTO_MODO", "separado")
    from horizonte.ordenes import repositorio
    from horizonte.seguimiento import historial

    repositorio.limpiar()
    historial.limpiar()


def _drenar(segundos=1.5):
    from separado import trabajador

    return trabajador.ejecutar(segundos=segundos, silencioso=True)


def test_el_evento_llega_a_la_base():
    from horizonte.canal import api

    r = api.crear_orden("ana", 1000.0)
    c = _drenar()
    assert c["guardado"] == 4
    assert api.respuesta(r["orden"])["historial"][-1] == "Confirmada por el cliente"


def test_sin_trabajador_el_historial_queda_atrasado():
    from horizonte.canal import api

    r = api.crear_orden("ana", 1000.0)
    assert api.respuesta(r["orden"])["historial"] == []
    _drenar()
    assert len(api.respuesta(r["orden"])["historial"]) == 4


def test_un_estado_desconocido_va_a_la_cola_de_errores():
    from separado import publicador

    publicador.publicar(999, "ESTADO_NUEVO")
    c = _drenar()
    assert c["rechazado"] == 1


def test_un_mensaje_duplicado_no_se_guarda_dos_veces():
    import json

    from separado import contrato, publicador

    evento = contrato.crear_evento(77, "CREADA")
    sqs = aws.cliente("sqs")
    url = aws.url_cola(aws.COLA)
    for _ in range(2):
        sqs.send_message(QueueUrl=url, MessageBody=json.dumps(evento))
    c = _drenar()
    assert c["guardado"] == 1 and c["duplicado"] == 1
