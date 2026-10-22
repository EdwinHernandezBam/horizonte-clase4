# Cambio 2 · Una regla nueva: límite diario por cliente

**Pedido del negocio:** un cliente no puede mover más de **6 000 al día** en total (la suma de sus órdenes).
Si una orden hace pasar ese total, se rechaza con el estado de siempre («Error mostrado»).

## Qué hacer

1. Crea tu rama:  `git switch -c cambio-2`
2. Decide **dónde debe vivir la regla**. ¿Quién ya conoce los límites? Pista: `git grep LIMITE`.
3. La regla necesita ver las órdenes anteriores del cliente. ¿Cómo las obtiene sin abrir el código de otros módulos?
4. Haz el cambio y comprueba:  `pytest cambios/pruebas/test_cambio_2.py`  y  `pytest tests`
5. Mide:  `python tools/medir_cambio.py`  y anota **módulos tocados** y **archivos tocados** en `resultados.md`.
6. Guarda y vuelve al inicio:  `git add -A`  ·  `git commit -m "cambio 2"`  ·  `git switch main`

## Para pensar

Compara con el cambio 1. ¿Por qué este toca menos módulos? ¿Qué tiene de distinto una regla frente a un estado nuevo?
