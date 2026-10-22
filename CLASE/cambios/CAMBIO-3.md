# Cambio 3 · Un canal nuevo: «web»

**Pedido del negocio:** abrir el canal **web** con la misma lógica que el móvil, pero:
- el aviso al cliente va **por correo** (no push): el texto debe empezar con `correo a <cliente>:`
- el límite por orden es **2 000** (el móvil sigue en 5 000)

Debe existir un punto de entrada para el canal web: `horizonte/canal/web.py` con `crear_orden(cliente, monto)`.

## Qué hacer

1. Crea tu rama:  `git switch -c cambio-3`
2. La orden debe saber por qué canal llegó. ¿Dónde se guarda ese dato y quién lo necesita después? Pista: `git grep Orden`.
3. Haz el cambio y comprueba:  `pytest cambios/pruebas/test_cambio_3.py`  y  `pytest tests`
4. Mide:  `python tools/medir_cambio.py`  y anota **módulos tocados** y **archivos tocados** en `resultados.md`.
5. Guarda y vuelve al inicio:  `git add -A`  ·  `git commit -m "cambio 3"`  ·  `git switch main`

## Para pensar

Un dato nuevo (el canal) viaja por varios módulos. ¿Cuántos tuvieron que enterarse? ¿Podría haberse hecho de otra forma?
