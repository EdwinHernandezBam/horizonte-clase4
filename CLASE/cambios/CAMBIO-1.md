# Cambio 1 · Un estado nuevo: «En revisión»

**Pedido del negocio:** las órdenes de **3 000 o más** deben pasar por una revisión antirraude antes de liquidarse.
Mientras dura, el cliente debe ver **«En revisión»** y recibir un aviso.

**Flujo nuevo para montos altos:** Creada → Validada → **En revisión** → En liquidación → Confirmada.

## Qué hacer

1. Crea tu rama:  `git switch -c cambio-1`
2. Descubre **dónde vive el concepto de estado**. Pista: `git grep EN_LIQUIDACION` te muestra todos los lugares que conocen un estado.
3. Haz el cambio. Pregúntate por cada archivo: ¿si no lo toco, qué se rompe?
4. Comprueba que funciona:  `pytest cambios/pruebas/test_cambio_1.py` (debe pasar todo)
5. Comprueba que no rompiste nada:  `pytest tests`
6. Mide el acoplamiento:  `python tools/medir_cambio.py`
7. Anota en `resultados.md`: **módulos tocados** y **archivos tocados**.
8. Guarda tu trabajo y vuelve al inicio:  `git add -A`  ·  `git commit -m "cambio 1"`  ·  `git switch main`

## Pistas si te atoras (de menos a más)

- Un estado nuevo aparece en el modelo, en el flujo de la orden y en todo lugar que tenga un diccionario o lista de estados.
- Un fallo silencioso: si el estado nuevo no está en la lista de avance, `avance` devuelve 0 aunque todo parezca bien. Las pruebas lo detectan.
- Si en 8 minutos no avanzas, pide la pista al facilitador.
