"""Demo: procesa tres órdenes y muestra lo que vería la app."""
import time

from horizonte.canal import api

if __name__ == "__main__":
    for cliente, monto in (("ana", 1000.0), ("luis", 900.0), ("marta", 300.0)):
        r = api.crear_orden(cliente, monto)
        print(f"{cliente:6} -> {r['estado']:28} avance={r['avance']:3}%  historial={r['historial']}")
    time.sleep(0.5)
