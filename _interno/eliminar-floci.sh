#!/usr/bin/env bash
# Quita Floci de este equipo: apaga el contenedor y borra la imagen SOLO si la descargó el paquete.
# Uso: eliminar-floci.sh [--si] [--simular] [--forzar]
#   --forzar   borra la imagen aunque ya existiera antes de la clase (o no haya registro)
HERR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREP="$(cd "$HERR/.." && pwd)"
# shellcheck disable=SC1091
source "$HERR/versiones.txt"; source "$HERR/registro.sh"
SI=0; SIMULAR=0; FORZAR=0
for a in "$@"; do case "$a" in --si) SI=1;; --simular) SIMULAR=1;; --forzar) FORZAR=1;;
  -h|--help) sed -n 2,5p "$0"; exit 0;; *) echo "Opción desconocida: $a"; exit 2;; esac; done

if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "Docker no está encendido. Ábrelo y repite."; exit 1
fi
echo "Docker: encendido (motor $(docker version --format '{{.Server.Version}}' 2>/dev/null))."
IMG="floci/floci:$FLOCI_VERSION"
ESTADO="$(estado_imagen "$IMG")"
case "$ESTADO" in nuestra) echo "Imagen $IMG: la descargó el paquete.";; previa) echo "Imagen $IMG: ya la tenía antes de la clase.";; *) echo "Imagen $IMG: no hay registro de quién la descargó.";; esac
DESC=(); CMD=()
for c in floci-clase4 floci-ui-clase4; do
  docker ps -a --format '{{.Names}}' | grep -qx "$c" && { DESC+=("Quitar el contenedor $c"); CMD+=("docker rm -f $c"); }
done
if docker image inspect "$IMG" >/dev/null 2>&1; then
  if [ "$ESTADO" = nuestra ] || [ "$FORZAR" = 1 ]; then
    DESC+=("Borrar la imagen $IMG ($([ "$ESTADO" = nuestra ] && echo 'la descargó el paquete' || echo 'FORZADO: ya existía antes'))")
    CMD+=("docker rmi $IMG && olvidar_imagen $IMG")
  else
    echo "Se conserva la imagen $IMG: $([ "$ESTADO" = previa ] && echo 'ya la tenías antes de la clase' || echo 'no hay registro de que la descargara el paquete')."
    echo "Si de todos modos quiere borrarla: eliminar-floci.sh --forzar"
  fi
else
  echo "La imagen $IMG no está en este equipo."
fi
if [ ${#DESC[@]} -eq 0 ]; then echo "No hay nada que quitar."; exit 0; fi
echo; echo "Esto es lo que se va a hacer:"; for d in "${DESC[@]}"; do echo "  - $d"; done; echo
[ "$SIMULAR" = 1 ] && { echo "(simulación: no se hizo nada)"; exit 0; }
confirmar "¿Continuar?" || { echo "Cancelado. No se cambió nada."; exit 0; }
for i in "${!CMD[@]}"; do
  if eval "${CMD[$i]}" >/dev/null 2>&1; then echo "  OK  ${DESC[$i]}"; else echo "  NO SE PUDO  ${DESC[$i]} (¿otro contenedor usa la imagen?)"; fi
done
