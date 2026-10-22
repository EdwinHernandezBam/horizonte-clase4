"""Cambio 2: límite diario de 6000 por cliente (suma de sus órdenes)."""
import pytest

from horizonte.canal import api
from horizonte.ordenes import repositorio
from horizonte.seguimiento import historial


@pytest.fixture(autouse=True)
def limpio(monkeypatch):
    monkeypatch.delenv("SEGUIMIENTO_MODO", raising=False)
    repositorio.limpiar()
    historial.limpiar()


def test_la_suma_del_dia_no_puede_pasar_de_6000():
    assert api.crear_orden("ana", 4000.0)["estado"] == "Confirmada por el cliente"
    segunda = api.crear_orden("ana", 3000.0)
    assert segunda["estado"] == "Error mostrado"


def test_dentro_del_limite_se_confirma():
    api.crear_orden("ana", 2000.0)
    assert api.crear_orden("ana", 3000.0)["estado"] == "Confirmada por el cliente"
