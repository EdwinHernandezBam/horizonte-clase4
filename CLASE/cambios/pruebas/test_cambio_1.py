"""Cambio 1: nuevo estado «En revisión» para montos de 3000 o más."""
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


def test_monto_alto_pasa_por_revision():
    r = api.crear_orden("ana", 4000.0)
    assert r["historial"] == [
        "Esperando respuesta", "Validada", "En revisión", "En liquidación", "Confirmada por el cliente",
    ]


def test_monto_bajo_no_pasa_por_revision():
    r = api.crear_orden("ana", 1000.0)
    assert "En revisión" not in r["historial"]


def test_el_cliente_es_avisado_de_la_revision():
    api.crear_orden("ana", 4000.0)
    assert any("revis" in m for m in push.ENVIADAS)


def test_el_avance_sigue_siendo_coherente():
    r = api.crear_orden("ana", 4000.0)
    assert r["avance"] == 100


def test_el_avance_cuenta_la_revision():
    from horizonte.ordenes.modelo import Estado
    assert historial.avance(Estado.EN_REVISION) == 50
