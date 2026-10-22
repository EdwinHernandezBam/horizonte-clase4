# Clase 4 · Linux (Debian, Ubuntu y derivados)

Esta carpeta tiene todo lo que necesita **para su sistema**. Los archivos están numerados en el orden en que se usan. Ignore la carpeta `_interno`: son las piezas que usan los scripts.

> **Importante:** la carpeta **`CLASE`** (el proyecto y la guía del taller) **no viene en este paquete**. Se entrega **el día de la clase**, para que todos partan al mismo tiempo. Antes de la clase solo necesita el archivo 1.

| Cuándo | Archivo | Qué hace |
|---|---|---|
| **Antes de la clase** | `1-PREPARAR-ANTES-DE-LA-CLASE.sh` | Deja **todo instalado y descargado**: Git, Python, Docker, el entorno de Python con sus librerías, la imagen de Floci y la de su consola web. Comprueba que funciona |
| **El día de la clase** (cuando reciba `CLASE`) | `2-INICIAR-LA-CLASE.sh` | Verifica que todo siga en su sitio, enciende Floci **y su consola web** si están apagados, crea el punto de partida del taller y corre las pruebas. Si algo faltara, lo descarga o instala. Si Floci se apaga, vuelva a ejecutarlo |
| **En clase** | `3-ABRIR-CONSOLA-WEB.sh` | Vuelve a abrir la consola web de Floci (http://localhost:4500) si la cerró o se apagó; ahí se ven las colas y tablas |
| **Después de la clase** | `4-LIMPIAR-DESPUES-DE-LA-CLASE.sh` | Quita lo que dejó el paquete (no toca Floci, Docker, Git ni Python) |
| **Después de la clase** | `5-ELIMINAR-FLOCI.sh` | Apaga y elimina Floci |

## 1 · Antes de la clase: preparar su equipo

**Tiempo:** de 10 a 30 minutos, según lo que ya tenga instalado. Necesita internet.

En una terminal, dentro de esta carpeta: **`./1-PREPARAR-ANTES-DE-LA-CLASE.sh`** (o `bash 1-PREPARAR-ANTES-DE-LA-CLASE.sh`). Usa `apt` y le pide su contraseña de sudo.

**Después de este paso ya no necesita internet:** todo lo que se usa en clase queda en su equipo (programas, entorno de Python con sus librerías e imágenes de Docker). Esto incluye la consola web de Floci.

El script **va contando lo que encuentra y lo que hace**, paso a paso: qué versión tiene de Git, Python y Docker (o que no los tiene), si los acepta o los instala, y si Floci ya estaba descargado o lo descarga. Al terminar muestra una tabla como esta:

```
  Git                        OK               versión 2.43.0
  Python                     OK               Python 3.12.x
  Docker                     OK               motor 29.x, compose 2.x
  Entorno de Python          OK               boto3 y pytest en horizonte-clase4/.venv
  Floci 2.2.0                OK               responde y la prueba de cola y tabla pasó
  Consola web de Floci       OK               http://localhost:4500
LISTO: su equipo está preparado.
```

- Si dice **LISTO**, terminó. Vuelva a ejecutarlo el día antes de la clase: es seguro repetirlo, no reinstala lo que ya está y vuelve a comprobar.
- Floci se descarga y se prueba, y luego el script lo **apaga** para dejar su equipo como estaba. En clase se enciende solo.
- Si dice **HAY PENDIENTES**, envíe el archivo **`instalacion.log`** (queda en esta misma carpeta) por el canal del grupo antes de la clase.

### Qué se instala y por qué esas versiones

| Componente | Versión | Para qué lo usamos |
|---|---|---|
| Git | 2.30 o superior | Medir cuántos archivos toca cada cambio (`git diff`) |
| Python | **3.12** (sirve 3.10 o superior) | El código del taller y los scripts de medición |
| Docker | motor 24 o superior, con Compose | Ejecutar Floci, el emulador local de AWS |
| Floci | **2.2.0** (fija) | Simula colas (SQS) y tablas (DynamoDB) en su laptop, sin cuenta de AWS |
| boto3 | 1.43.114 (fija) | Librería de Python para hablar con el emulador |
| Visual Studio Code | la actual (opcional) | Editor; puede usar el que prefiera |

Las versiones están fijas a propósito: así todos tenemos el mismo resultado en clase.

### Qué pasa si ya tiene alguna herramienta

- **Versión más alta que la recomendada:** se acepta (Python 3.10 o superior, Git 2.30 o superior, Docker 24 o superior).
- **Versión más baja o ausente:** Python y Git se instalan (Python se instala al lado, sin tocar el que ya tenía). Si Docker es más viejo, el script avisa pero intenta continuar.
- **Floci y su imagen:** se usa la versión fija 2.2.0. El paquete anota si la imagen ya existía antes de descargarla, para no borrar después lo que era suyo.
- **Otro Floci en el puerto 4566:** si ya tiene un contenedor suyo usando ese puerto, el script no lo apaga: lo usa tal como está.

### Opciones (para quien las necesite)

En la misma terminal, agregue la opción, por ejemplo: `./1-PREPARAR-ANTES-DE-LA-CLASE.sh --solo-verificar`.

| Opción | Qué hace |
|---|---|
| `--solo-verificar` | Solo revisa, no instala nada |
| `--simular` | Muestra lo que instalaría, sin ejecutarlo |

### Si algo falla

- Al instalar Docker se le agrega al grupo `docker`. Si el script dice «REINICIA SESIÓN», cierre sesión y vuelva a entrar (o ejecute `newgrp docker`) y repita.
- **Docker apagado:** `sudo systemctl start docker` y repita.
- **Proxy o firewall:** si falla la descarga de Floci, revise su conexión y la configuración de proxy de Docker.
- Si los archivos `.sh` no se ejecutan, dé permiso con `chmod +x *.sh _interno/*.sh`.

## 2 · El día de la clase

1. Descomprima la carpeta **`CLASE`** que le entregará el facilitador **dentro de `horizonte-clase4`**, junto a `WINDOWS`, `MAC` y `LINUX`.
2. En una terminal, dentro de esta carpeta: **`./2-INICIAR-LA-CLASE.sh`**. Verifica que todo lo de la preparación siga en su sitio, enciende Floci si está apagado, crea el punto de partida del taller y corre las pruebas; al final dice **LISTO**. Si algo faltara, lo descarga o instala, pero lo normal es que no necesite internet.
3. Siga la guía `CLASE/GUIA-DEL-TALLER.md`.
4. La consola web de Floci queda en http://localhost:4500. Si la cierra o se apaga, `3-ABRIR-CONSOLA-WEB.sh` la vuelve a abrir. Para apagarla, ejecútelo con `--apagar`.

## 3 · Después de la clase: devolver el espacio

Hay **dos scripts separados**. Use el que necesite; no hace falta correr los dos.

| Script | Qué quita | Qué NO toca |
|---|---|---|
| `4-LIMPIAR-DESPUES-DE-LA-CLASE.sh` | El entorno de Python con sus librerías (`horizonte-clase4/.venv`), archivos temporales, el registro `instalacion.log`, y la consola web de Floci con su imagen (si la descargó el paquete) | Floci, Docker, Git, Python y su carpeta `CLASE` |
| `5-ELIMINAR-FLOCI.sh` | El contenedor de Floci y su imagen de Docker | Todo lo demás |

**Cómo distinguen lo que ya tenía de lo que instaló el paquete:** al preparar, el paquete anotó (en un archivo oculto de esta carpeta) qué imágenes de Docker no existían antes y las descargó él. Los scripts borran **solo** esas.

- Una imagen que usted ya tenía **se conserva**, y el script se lo dice.
- Si no hay registro, la trata como suya y **no la borra**. Solo con `--forzar` (en el script 5) la borraría.
- Si otro contenedor suyo usa la imagen, Docker no deja borrarla y el script lo indica.

Antes de borrar, cada script muestra **qué va a hacer** y pregunta si continúa. Con `--simular` solo muestra el plan. Para pasar opciones, en la misma terminal, agregue la opción.

**Git, Python y Docker:** si la preparación instaló alguno, el script 4 se lo lista pero **no lo desinstala** (otras cosas de su equipo pueden usarlo). Si quiere quitarlos, hágalo usted:

| Herramienta | Comando |
|---|---|
| Git | `sudo apt remove git` |
| Python | `sudo apt remove python3` (cuidado: el sistema lo usa) |
| Docker | `sudo apt remove docker-ce docker-ce-cli containerd.io` |

**Su carpeta `CLASE`** (sus resultados y su trabajo del taller) **no se borra**: el script 4 solo quita lo técnico que se creó dentro (archivos temporales). Si no quiere conservarla, bórrela usted como cualquier carpeta.
