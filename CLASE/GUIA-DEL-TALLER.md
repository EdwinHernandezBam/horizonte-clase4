# Clase 4 · Guía del taller «El juego del cambio»

**Pregunta guía:** ¿cuándo conviene dejar las piezas juntas y cuándo separarlas?
**Trabajo:** en equipo (una laptop por persona; una persona escribe los resultados en `resultados.md`).
**Entrega:** `resultados.md` completo y un borrador de ADR-002 (`ADR-002-borrador.md`), empaquetados con `python tools/empaquetar_entrega.py`. Los detalles están en `ENTREGA.md`.

## Horario

| Hora | Qué |
|---|---|
| 9:17–9:20 | Paso 0 · Antes de empezar |
| 9:20–9:30 | Paso 1 · Medir el acoplamiento |
| 9:30–9:45 | **Pausa** (dejen la consola abierta) |
| 9:45–10:10 | Paso 2 · El juego del cambio |
| 10:10–10:33 | Paso 3 · Separar el seguimiento |
| 10:33–10:43 | Paso 4 · Decidir y documentar |

## Paso 0 · Antes de empezar (3 min)

Abre una consola en esta carpeta (`CLASE`) y activa el entorno de Python:

| Sistema | Comando |
|---|---|
| Windows (Símbolo del sistema) | `..\.venv\Scripts\activate.bat` |
| macOS / Linux | `source ../.venv/bin/activate` |

Comprueba que todo funciona:

```
pytest
python -m horizonte.demo
```

Verás tres órdenes de ejemplo: una confirmada, una con error por fondos y una con respuesta perdida del core («Verificando»).

## Paso 1 · Medir el acoplamiento (10 min)

```
python tools/matriz.py
```

Lee la matriz: es una tabla de quién usa a quién. Una fila A con un número en la columna B significa que **A usa código de B** (depende de B).
Responde en `resultados.md` qué módulo es el más usado por los demás y cuál depende de más módulos.

> **Pausa 9:30–9:45.** Dejen su consola abierta. Si al volver el emulador (Floci) se apagó, ejecuten de nuevo `2-INICIAR-LA-CLASE` (en la carpeta de su sistema) y sigan.

## Paso 2 · El juego del cambio (25 min)

En cada mesa, **cada persona toma un cambio distinto** (si son cuatro, la cuarta persona revisa y anota):

| Persona | Archivo |
|---|---|
| 1 | `cambios/CAMBIO-1.md` · Estado nuevo |
| 2 | `cambios/CAMBIO-2.md` · Regla nueva |
| 3 | `cambios/CAMBIO-3.md` · Canal nuevo |

Cada archivo trae los pasos. Al final, **cada cambio se mide** con `python tools/medir_cambio.py`. Junten los tres números en `resultados.md` y comparen: ¿por qué unos cambios tocan más módulos que otros?

## Paso 3 · Separar el seguimiento (23 min)

Ahora sacamos el seguimiento del monolito: el monolito publica un evento en una **cola** y otro proceso (el **trabajador**) lo guarda en una **tabla**. Todo corre en el emulador (Floci) en su laptop.

- **Cola:** un buzón donde el monolito deja mensajes (eventos) y otro proceso los recoge después.
- **Trabajador:** un programa aparte que corre en su propia consola, lee los mensajes de la cola y los guarda en la tabla. Mientras esté apagado, los mensajes esperan en la cola.
- **Tabla:** donde queda guardado el historial de cada orden.

1. Enciende el emulador (si no está): en la carpeta de tu sistema (`WINDOWS`, `MAC` o `LINUX`, un nivel arriba), ejecuta `2-INICIAR-LA-CLASE`.
2. Prepara la cola y la tabla: `python tools/floci_preparar.py`
3. En **otra** consola (con el entorno activado), arranca el trabajador: `python -m separado.trabajador`
4. En la primera consola, activa el modo separado y corre la demo:

| Sistema | Comando |
|---|---|
| Windows (cmd) | `set SEGUIMIENTO_MODO=separado` |
| macOS / Linux | `export SEGUIMIENTO_MODO=separado` |

```
python -m horizonte.demo
```

**Observa:** ¿el historial de cada orden está completo en el momento? Espera unos segundos y consulta de nuevo.

5. Mide la diferencia: `python tools/medir_separacion.py`
6. **Apaga el trabajador:** ve a la consola donde corre (la segunda) y presiona **Ctrl+C**; el cursor vuelve a aparecer y deja de procesar. Crea órdenes con la demo (consola 1) y consulta el historial. Luego enciéndelo otra vez en la consola 2 con `python -m separado.trabajador`. ¿Qué pasó mientras estuvo apagado?
7. **Repite el cambio 1 en modo separado** (lo hace quien implementó el cambio 1; los demás miran su pantalla): `git switch cambio-1`, deja el trabajador encendido y corre la demo con una orden de 4 000. Mira qué dice el trabajador. Arréglalo y vuelve a medir con `python tools/medir_cambio.py`.

8. **Qué se gana y qué se paga.** Con lo que vieron en los pasos anteriores, escriban en `resultados.md` **dos cosas que se pagan** (con su número cuando lo haya: milisegundos, procesos, piezas que pueden fallar) y **dos cosas que se ganan** al separar. Lo que se gana no lo mide ningún script: piensen en despliegue independiente, escala propia, aislamiento de fallos o un equipo dueño de la pieza, y respondan **¿qué problema real de Horizonte lo justificaría?** Si no hay un problema real, lo que se gana no cuenta.

Anota todo en `resultados.md` (sección Paso 3).

## Paso 4 · Decidir y documentar (10 min)

1. Complete la matriz de decisión de `resultados.md` con los pesos de la clase 2, usando **sus números**.
2. Escriba la decisión, **la medida que más pesó en ella** (por ejemplo, módulos tocados por un cambio o la demora al separar) y la **condición de revisión medible** (el número que los haría reconsiderar).
3. Pase lo esencial a `ADR-002-borrador.md` (después lo llevan a su plantilla oficial).
4. Armen la entrega: `python tools/empaquetar_entrega.py --equipo "Mesa N"` y súbanla a la plataforma. Si no alcanzan en clase, tienen hasta el lunes 26 de octubre. Vean `ENTREGA.md`.

## Si algo falla

| Síntoma | Qué hacer |
|---|---|
| `No module named horizonte` | Estás fuera de la carpeta del taller o no activaste el entorno. |
| `No pude hablar con el emulador` | Enciéndelo (paso 3.1) y repite. |
| `No encuentro la etiqueta base` | Ejecuta `git tag base` **solo** si aún no has cambiado nada; si no, pide ayuda. |
| Cambiaste algo y quieres empezar de cero | `git switch main` y, si hace falta, `git checkout -- .` |

> Todos los datos son ilustrativos. El sistema es una versión mínima para poder medir; en un banco real habría muchos más módulos.
