# Horizonte · Clase 4 · Modularidad y acoplamiento

Monolito modular de **órdenes de pago** de un banco ilustrativo (Banco Horizonte), con un componente
de **seguimiento** que se puede dejar dentro o separar.

```
horizonte/            el monolito, un módulo por carpeta
  canal/              lo que pide la app móvil
  ordenes/            el caso de uso (crear y procesar una orden)
  pagos/              validaciones de fondos y límites
  core/               adaptador al core (simulado)
  seguimiento/        historial de estados de cada orden
  notificaciones/     avisos al cliente
  catalogo.py         catálogo de estados de la clase 3
separado/             el seguimiento fuera del monolito: cola + trabajador + tabla
tools/                scripts de medición (matriz, cambios, separación)
cambios/              instrucciones y pruebas de los tres cambios
tests/                pruebas del monolito y del seguimiento separado
GUIA-DEL-TALLER.md    los pasos del taller
resultados.md         donde su equipo anota los números
ADR-002-borrador.md   borrador de la decisión
ENTREGA.md            qué se entrega, cuándo y cómo empaquetarlo
COMANDOS-FLOCI.md     comandos de uso general de Floci
```

Esta carpeta es **lo que se usa en la clase**. Debe estar dentro de `horizonte-clase4`, junto a las carpetas `WINDOWS`, `MAC` y `LINUX`. Si aún no ejecutó `2-INICIAR-LA-CLASE` (en la carpeta de su sistema), hágalo ahora. En clase sigue `GUIA-DEL-TALLER.md`.

Comando para ver el sistema funcionando:

```
# Windows:       ..\.venv\Scripts\python -m horizonte.demo
# macOS/Linux:   ../.venv/bin/python -m horizonte.demo
```

## Ver las colas y tablas en el navegador

`2-INICIAR-LA-CLASE` deja encendida la consola web de Floci en http://localhost:4500. Si la cerraste o se apagó, vuelve a abrirla con `3-ABRIR-CONSOLA-WEB` (en la carpeta de tu sistema). Ahí ves las colas SQS y las tablas DynamoDB que crea el taller.
