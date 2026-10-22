import pytest

from horizonte.canal import api
from horizonte.notificaciones import push
from horizonte.ordenes import repositorio
from horizonte.seguimiento import historial


@pytest.fixture(autouse=True)
def limpio(monkeypatch):
    monkeypatch.delenv("SEGUIMIENTO_MODO", raising=False)
    repositorio.limpiar()
    historial.limpiar()
    push.limpiar()


def test_orden_normal_se_confirma():
    r = api.crear_orden("ana", 1000.0)
    assert r["estado"] == "Confirmada por el cliente"
    assert r["final"] is True
    assert r["avance"] == 100


def test_fondos_insuficientes_muestra_error():
    r = api.crear_orden("luis", 900.0)
    assert r["estado"] == "Error mostrado"
    assert r["final"] is True


def test_respuesta_perdida_del_core_no_se_muestra_como_rechazo():
    r = api.crear_orden("marta", 300.0)
    assert r["estado"] == "Verificando"
    assert r["estado"] != "Error mostrado"
    assert r["final"] is False


def test_el_historial_registra_cada_estado():
    r = api.crear_orden("ana", 1000.0)
    assert r["historial"] == [
        "Esperando respuesta", "Validada", "En liquidación", "Confirmada por el cliente",
    ]


def test_el_cliente_recibe_notificacion():
    api.crear_orden("ana", 1000.0)
    assert any("confirmada" in m for m in push.ENVIADAS)
