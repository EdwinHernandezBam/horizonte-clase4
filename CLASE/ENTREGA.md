# Entrega de la clase 4 · El juego del cambio

**Quién entrega:** un equipo (la mesa), una sola entrega por equipo. La persona escriba la sube.
**Cuándo:** lo ideal es terminarla en clase. Si no alcanzan, **hasta el lunes 26 de octubre**.
**Dónde:** en la plataforma del curso (UVG), como **un solo archivo .zip**.

## Qué se entrega

Un archivo `Entrega_Clase4_<su equipo>.zip` que contiene:

| Archivo | Qué es |
| --- | --- |
| `resultados.md` | Sus mediciones y su decisión (pasos 1 a 4), completo. |
| `ADR-002-borrador.md` | El borrador de la decisión: contexto, decisión, alternativas, consecuencias, condición de revisión y evidencia. |
| `evidencia/matriz.txt` | La matriz de dependencias, generada automáticamente. |
| `evidencia/medicion_del_cambio.txt` | Lo que midió `medir_cambio.py` con el último cambio que dejaron en el código. |

No tiene que armar el zip a mano. Desde la carpeta `CLASE`, con el entorno activo:

```
python tools/empaquetar_entrega.py --equipo "Mesa 2"
```

El comando le avisa si todavía hay campos sin llenar y deja el zip en la misma carpeta. Puede ejecutarlo tantas veces como quiera: cada vez genera el zip de nuevo con lo último que escribieron. Si corrigen algo después de subir, vuelvan a ejecutarlo y suban el nuevo.

## Qué debe estar completo

- [ ] **Paso 1.** Módulo más usado, módulo que depende de más, y a cuántos arrastra.
- [ ] **Paso 2.** Módulos y archivos tocados por cada uno de los tres cambios (si un cambio no se alcanzó a medir, escríbanlo y expliquen por qué).
- [ ] **Paso 3.** Tabla dentro contra separado; qué pasó al apagar el trabajador; **dos cosas que se pagan, dos que se ganan y el problema real** que justificaría separar.
- [ ] **Paso 4.** Matriz de decisión con **sus** números, la decisión, **la medida que más pesó** y la **condición de revisión medible** (número, umbral y ventana de tiempo).
- [ ] **ADR-002.** Las secciones llenas, en prosa corta. Cada consecuencia positiva responde a un problema real y medido.
- [ ] **Nombres.** Equipo y escriba en la primera línea de `resultados.md`; integrantes del equipo debajo.

## Qué se evalúa (propuesta, ajustable por el docente)

| Criterio | Peso | Qué busca quien califica |
| --- | --- | --- |
| Mediciones | 30 % | Los números salen de las herramientas, no de una opinión, y son coherentes con lo esperado (órdenes es el más usado; el cambio de estado toca más módulos que el límite diario). |
| Lo que se gana y lo que se paga | 20 % | Costos con número y ganancias atadas a un problema real de Horizonte. «Escala propia» sin nadie que la necesite no cuenta. |
| Decisión y matriz | 20 % | Los pesos están justificados y la decisión sigue de la matriz. Cualquier decisión es válida si se sostiene con sus números. |
| Condición de revisión | 20 % | Tiene un número, un umbral y una ventana de tiempo, y alguien que no estuvo en la reunión podría verificarla. |
| Claridad del ADR | 10 % | Se entiende sin haber estado en la clase. |

## Después de entregar

El ADR-002 se lleva a la plantilla oficial de su ADR para la próxima clase (29 de octubre, virtual).
