#!/usr/bin/env bash
# Enciende la consola web de Floci (http://localhost:4500). Cuenta lo que va pasando.
# Uso: iniciar-interfaz.sh [--apagar] [--sin-abrir]
HERR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREP="$(cd "$HERR/.." && pwd)"
# shellcheck disable=SC1091
source "$HERR/versiones.txt"; source "$HERR/registro.sh"
export FLOCI_UI_VERSION
APAGAR=0; ABRIR=1
for a in "$@"; do case "$a" in --apagar) APAGAR=1;; --sin-abrir) ABRIR=0;; esac; done

if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "  Docker no está encendido. Ábralo y vuelva a intentarlo."; exit 1
fi
if [ "$APAGAR" = 1 ]; then
  docker rm -f floci-ui-clase4 >/dev/null 2>&1 && echo "  Consola apagada." || echo "  La consola no estaba encendida."
  exit 0
fi
if ! curl -s -m 3 -o /dev/null http://localhost:4566; then
  echo "  Floci no responde en http://localhost:4566. Primero enciéndalo con 2-INICIAR-LA-CLASE (en esta carpeta)."; exit 1
fi
UIIMG="floci/floci-ui:$FLOCI_UI_VERSION"
echo "  Docker: encendido. Floci: responde en http://localhost:4566."
if docker image inspect "$UIIMG" >/dev/null 2>&1; then echo "  Imagen $UIIMG: ya está en su equipo."; registrar_imagen "$UIIMG"
else
  echo "  Imagen $UIIMG: no está en su equipo. La descargo (la primera vez tarda) ..."
  registrar_imagen "$UIIMG"
  docker pull "$UIIMG" || { echo "  No pude descargarla."; exit 1; }
fi
echo "  Encendiendo la consola ..."
docker rm -f floci-ui-clase4 >/dev/null 2>&1
if ! docker compose -f "$HERR/docker-compose-ui.yml" up -d 2>&1 | sed 's/^/    /'; then echo "  No pude encender la consola."; exit 1; fi
echo "  Esperando a que responda (hasta 40 segundos) ..."
for _ in $(seq 1 40); do
  if curl -s -m 2 -o /dev/null http://localhost:4500; then
    echo "  La consola responde: abra http://localhost:4500 en el navegador."
    [ "$ABRIR" = 1 ] && [ "$(uname -s)" = "Darwin" ] && open http://localhost:4500 >/dev/null 2>&1
    exit 0
  fi
  sleep 1
done
echo "  La consola no respondió a tiempo. Revise: docker logs floci-ui-clase4"; exit 1
