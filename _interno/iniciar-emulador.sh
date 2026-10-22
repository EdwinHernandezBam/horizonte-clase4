#!/usr/bin/env bash
# Enciende Floci (emulador local de AWS) y espera a que responda. Cuenta lo que va pasando.
HERR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREP="$(cd "$HERR/.." && pwd)"
# shellcheck disable=SC1091
source "$HERR/versiones.txt" 2>/dev/null
export FLOCI_VERSION
PY="$PREP/../.venv/bin/python"; [ -x "$PY" ] || PY="python3"

esperar() {
  for _ in $(seq 1 40); do
    "$PY" "$HERR/verificar_floci.py" --rapido >/dev/null 2>&1 && return 0
    sleep 1
  done
  return 1
}

if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "  Docker no está encendido. Ábralo (macOS: aplicación Docker; Linux: sudo systemctl start docker) y repita."; exit 1
fi
OTRO="$(docker ps --format '{{.Names}}|{{.Image}}|{{.Ports}}' | grep ':4566->' | grep -v '^floci-clase4|' | head -1)"
if [ -n "$OTRO" ]; then
  IFS='|' read -r ONOM OIMG _ <<<"$OTRO"
  echo "  El puerto 4566 ya lo está usando otro contenedor suyo: «$ONOM» (imagen $OIMG)."
  echo "  No lo apago. Uso ese emulador tal como está."
  if esperar; then echo "  El emulador responde."; exit 0; fi
  echo "  Ese contenedor no responde como Floci. Apáguelo (docker stop $ONOM) y repita."; exit 1
fi
if docker ps --format '{{.Names}}' | grep -qx floci-clase4; then echo "  Floci $FLOCI_VERSION ya estaba encendido; lo reinicio para partir limpio."; fi
docker rm -f floci-clase4 >/dev/null 2>&1
echo "  Encendiendo Floci $FLOCI_VERSION en http://localhost:4566 ..."
if ! docker compose -f "$HERR/docker-compose.yml" up -d 2>&1 | sed 's/^/    /'; then echo "  No pude encender Floci."; exit 1; fi
echo "  Esperando a que responda (hasta 40 segundos) ..."
if esperar; then echo "  Floci responde."; exit 0; fi
echo "  Floci no respondió a tiempo. Revise: docker logs floci-clase4"; exit 1
