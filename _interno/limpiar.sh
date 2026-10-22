#!/usr/bin/env bash
# Limpia lo que el paquete de la clase 4 dejó en este equipo, SIN tocar Floci, Docker, Git ni Python.
# Uso: limpiar.sh [--si] [--simular]
#   --si                no pregunta (confirma todo)
#   --simular           muestra lo que haría, sin hacerlo
HERR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREP="$(cd "$HERR/.." && pwd)"
RAIZ="$PREP/../CLASE"
# shellcheck disable=SC1091
source "$HERR/versiones.txt"; source "$HERR/registro.sh"
SI=0; SIMULAR=0
for a in "$@"; do case "$a" in --si) SI=1;; --simular) SIMULAR=1;;
  -h|--help) sed -n 2,5p "$0"; exit 0;; *) echo "Opción desconocida: $a"; exit 2;; esac; done

DESC=(); CMD=()
plan() { DESC+=("$1"); CMD+=("$2"); }
DOCKER=0; command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 && DOCKER=1
UI="floci/floci-ui:$FLOCI_UI_VERSION"

echo "Revisando qué dejó el paquete en este equipo ..."
if [ "$DOCKER" = 1 ]; then echo "  Docker: encendido (motor $(docker version --format '{{.Server.Version}}' 2>/dev/null))."; fi
if [ "$DOCKER" = 1 ]; then
  docker ps -a --format '{{.Names}}' | grep -qx floci-ui-clase4 && plan "Quitar el contenedor de la consola de Floci (floci-ui-clase4)" "docker rm -f floci-ui-clase4"
  if docker image inspect "$UI" >/dev/null 2>&1; then
    case "$(estado_imagen "$UI")" in
      nuestra) plan "Borrar la imagen $UI (la descargó el paquete)" "docker rmi $UI && olvidar_imagen $UI" ;;
      *) echo "  Se conserva la imagen $UI: ya la tenías antes de la clase (o no hay registro de quién la descargó)." ;;
    esac
  fi
else
  echo "  Docker está apagado o no está instalado: no puedo revisar contenedores ni imágenes. Ábrelo y repite si quieres limpiarlos."
fi
VENV="$PREP/../.venv"
[ -d "$VENV" ] && plan "Borrar el entorno de Python y sus librerías (horizonte-clase4/.venv)" "rm -rf '$VENV'"
[ -d "$RAIZ" ] && find "$RAIZ" -name __pycache__ -type d -not -path '*/.venv/*' 2>/dev/null | grep -q . && plan "Borrar archivos temporales de Python (__pycache__)" "find '$RAIZ' -name __pycache__ -type d -prune -exec rm -rf {} +"
[ -d "$RAIZ/.pytest_cache" ] && plan "Borrar .pytest_cache" "rm -rf '$RAIZ/.pytest_cache'"
if [ ! -d "$RAIZ" ]; then echo "  La carpeta CLASE no está: no hay nada del taller que limpiar."; fi
for f in instalacion.log; do [ -f "$PREP/$f" ] && plan "Borrar $f" "rm -f '$PREP/$f'"; done

if [ ${#DESC[@]} -eq 0 ]; then echo "No hay nada que limpiar."; else
  echo; echo "Esto es lo que se va a hacer:"
  for i in "${!DESC[@]}"; do echo "  - ${DESC[$i]}"; done
  echo
  if [ "$SIMULAR" = 1 ]; then echo "(simulación: no se hizo nada)"
  elif confirmar "¿Continuar?"; then
    for i in "${!CMD[@]}"; do
      if eval "${CMD[$i]}" >/dev/null 2>&1; then echo "  OK  ${DESC[$i]}"; else echo "  NO SE PUDO  ${DESC[$i]}"; fi
    done
  else echo "Cancelado. No se cambió nada."; fi
fi

# Herramientas que instaló el paquete: solo se listan, NO se desinstalan.
if [ -f "$INSTALADO" ] && grep -qxE 'git|python|python-venv|docker|vscode|homebrew' "$INSTALADO"; then
  echo
  echo "El paquete también instaló estas herramientas. No las desinstalo porque otras cosas de su equipo pueden usarlas."
  echo "Si quiere quitarlas, hágalo usted:"
  while read -r h; do case "$h" in
    git) echo "  Git:             $([ "$(uname -s)" = Darwin ] && echo 'brew uninstall git' || echo 'sudo apt remove git')";;
    python) echo "  Python 3.12:     $([ "$(uname -s)" = Darwin ] && echo 'brew uninstall python@3.12' || echo 'sudo apt remove python3')";;
    docker) echo "  Docker:          $([ "$(uname -s)" = Darwin ] && echo 'brew uninstall --cask docker' || echo 'sudo apt remove docker-ce docker-ce-cli containerd.io')";;
    vscode) echo "  Visual Studio Code: brew uninstall --cask visual-studio-code";;
    homebrew) echo "  Homebrew:        ver https://github.com/Homebrew/install#uninstall-homebrew";;
  esac; done <"$INSTALADO"
fi
echo
echo "Su carpeta CLASE (su trabajo y resultados) no se borró: solo se quitaron el entorno técnico y los temporales."
echo "Floci no se tocó. Para quitarlo use el archivo 5-ELIMINAR-FLOCI."
