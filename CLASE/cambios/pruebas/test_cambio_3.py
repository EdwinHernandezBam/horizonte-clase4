"""Cambio 3: nuevo canal «web»: aviso por correo y límite por orden de 2000."""
import pytest

from horizonte.canal import web
from horizonte.notificaciones import push
from horizonte.ordenes import repositorio
from horizonte.seguimiento import historial


@pytest.fixture(autouse=True)
def limpio(monkeypatch):
    monkeypatch.delenv("SEGUIMIENTO_MODO", raising=False)
    repositorio.limpiar()
    historial.limpiar()
    push.limpiar()


def test_orden_web_confirmada_avisa_por_correo():
    r = web.crear_orden("ana", 1500.0)
    assert r["estado"] == "Confirmada por el cliente"
    assert any(m.startswith("correo a ana") for m in push.ENVIADAS)


def test_orden_web_tiene_limite_de_2000():
    assert web.crear_orden("ana", 2500.0)["estado"] == "Error mostrado"
