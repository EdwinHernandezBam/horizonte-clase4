#!/usr/bin/env bash
# Clase 4 · Instalador y verificador para macOS y Linux. Cuenta lo que va encontrando y haciendo.
#
# Uso:
#   instalar.sh                  PREPARACIÓN (antes de la clase): revisa e instala Git, Python y Docker,
#                                crea el entorno de Python con sus librerías, descarga Floci y su consola web
#                                y comprueba que funcionan. Después de esto no hace falta internet.
#   instalar.sh --clase          EL DÍA DE LA CLASE (necesita la carpeta CLASE): solo verifica y enciende lo que
#                                esté apagado; crea el punto de partida y corre las pruebas del taller.
#                                Si faltara algo, lo instala o lo descarga (lo normal es que ya esté de la preparación).
#   --solo-verificar             solo revisa, no instala nada
#   --simular                    muestra qué instalaría, sin ejecutarlo
#   --con-editor                 también revisa/instala Visual Studio Code (solo Mac)

HERR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"      # esta carpeta (_interno)
PREP="$(cd "$HERR/.." && pwd)"                            # carpeta del sistema (MAC o LINUX)
RAIZ="$PREP/../CLASE"                                     # CLASE: el proyecto (llega el día de la clase)
LOG="$PREP/instalacion.log"
: >"$LOG"
# shellcheck disable=SC1091
source "$HERR/versiones.txt"

SOLO_VERIFICAR=0; SIMULAR=0; CON_EDITOR=0; MODO=preparar; SIN_INSTALAR=0
for a in "$@"; do
  case "$a" in
    --clase) MODO=clase ;;
    --solo-verificar) SOLO_VERIFICAR=1 ;;
    --simular) SIMULAR=1 ;;
    --con-editor) CON_EDITOR=1 ;;
    -h|--help) sed -n 2,13p "$0"; exit 0 ;;
    *) echo "Opción desconocida: $a"; exit 2 ;;
  esac
done

[ "$SOLO_VERIFICAR" = 1 ] && SIN_INSTALAR=1
if [ "$MODO" = clase ]; then
  if [ ! -d "$RAIZ" ]; then
    echo "Todavía no tiene la carpeta CLASE."
    echo "Se entrega el día de la clase. Descomprímala dentro de horizonte-clase4, junto a las carpetas WINDOWS, MAC y LINUX,"
    echo "y vuelva a ejecutar este archivo."
    exit 1
  fi
  RAIZ="$(cd "$RAIZ" && pwd)"; TOTAL=8
else
  TOTAL=7
fi
VENV="$(cd "$PREP/.." && pwd)/.venv"   # entorno de Python: en horizonte-clase4 (junto a WINDOWS, MAC, LINUX y CLASE)

RES_NOMBRE=(); RES_ESTADO=(); RES_DETALLE=()
resumen() { RES_NOMBRE+=("$1"); RES_ESTADO+=("$2"); RES_DETALLE+=("$3"); }
# shellcheck disable=SC1091
source "$HERR/registro.sh"   # registro de lo que instala este paquete (para la limpieza)
log() { printf '%s\n' "$*" >>"$LOG"; }
say() { printf '%s\n' "$*"; log "$*"; }
N=0
paso() { N=$((N+1)); say ""; say "[$N/$TOTAL] $1"; }

ejecutar() {   # ejecuta un comando mostrando lo que va pasando (o solo lo muestra en modo simulación)
  log "\$ $*"
  if [ "$SIMULAR" = 1 ]; then say "   [simulación] $*"; return 0; fi
  "$@" 2>&1 | tee -a "$LOG" | sed 's/^/    /'
  return "${PIPESTATUS[0]}"
}

# Compara versiones: ver_ge 3.12 3.10  -> verdadero si 3.12 >= 3.10
ver_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }

SO="$(uname -s)"
GESTOR=""
if [ "$SO" = "Darwin" ]; then
  command -v brew >/dev/null 2>&1 && GESTOR="brew"
else
  if command -v apt-get >/dev/null 2>&1; then GESTOR="apt"
  elif command -v dnf >/dev/null 2>&1; then GESTOR="dnf"; fi
fi
SUDO=""; [ "$(id -u)" != "0" ] && command -v sudo >/dev/null 2>&1 && SUDO="sudo"

if [ "$MODO" = clase ]; then say "Clase 4 · iniciando la clase en su equipo ($SO)"; say "(en este paso se verifica todo y se enciende lo que esté apagado; si faltara algo, se instala o se descarga)"
else say "Clase 4 · preparando su equipo ($SO)"; fi
say "Voy a ir contando lo que encuentro y lo que hago."
[ "$SOLO_VERIFICAR" = 1 ] && say "(modo solo revisar: no se instala nada)"
tarde() { [ "$MODO" = clase ] && say "  Esto debió quedar listo en la preparación; lo hago ahora."; return 0; }
[ "$SIMULAR" = 1 ] && say "(modo simulación: no se instala nada)"

instalar_paquete() {  # instalar_paquete <nombre-brew> <nombres-apt/dnf...>
  case "$GESTOR" in
    brew) ejecutar brew install "$1" ;;
    apt)  shift; ejecutar $SUDO apt-get install -y "$@" ;;
    dnf)  shift; ejecutar $SUDO dnf install -y "$@" ;;
    *) return 1 ;;
  esac
}
if [ "$GESTOR" = "apt" ] && [ "$SIN_INSTALAR" = 0 ] && [ "$SIMULAR" = 0 ]; then
  say ""; say "Actualizando la lista de paquetes (apt) ..."
  if $SUDO apt-get update >>"$LOG" 2>&1; then say "  Lista actualizada."; else say "  No se pudo actualizar del todo (detalle en instalacion.log); sigo."; fi
fi

# Docker Engine oficial para Debian/Ubuntu (docker.io de Debian 12 es de la versión 20, muy vieja)
instalar_docker_debian() {
  # shellcheck disable=SC1091
  . /etc/os-release
  local DIST="$ID" CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"
  case "$DIST" in ubuntu|debian) ;; *) case " $ID_LIKE " in *ubuntu*) DIST=ubuntu ;; *) DIST=debian ;; esac ;; esac
  ejecutar $SUDO apt-get install -y ca-certificates curl \
  && ejecutar $SUDO install -m 0755 -d /etc/apt/keyrings \
  && ejecutar $SUDO curl -fsSL "https://download.docker.com/linux/$DIST/gpg" -o /etc/apt/keyrings/docker.asc \
  && ejecutar $SUDO chmod a+r /etc/apt/keyrings/docker.asc \
  && ejecutar $SUDO sh -c "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DIST $CODENAME stable' > /etc/apt/sources.list.d/docker.list" \
  && ejecutar $SUDO apt-get update \
  && ejecutar $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  || ejecutar $SUDO apt-get install -y docker.io docker-compose-v2
  ejecutar $SUDO systemctl enable --now docker
  ejecutar $SUDO usermod -aG docker "${SUDO_USER:-${USER:-$(id -un)}}"
}

# ---------- Git ----------
paso "Git (se necesita la versión $GIT_MINIMO o superior)"
if command -v git >/dev/null 2>&1; then
  V="$(git --version | awk '{print $3}')"
  say "  Encontrado: Git $V en $(command -v git)"
  if ver_ge "$V" "$GIT_MINIMO"; then say "  Es suficiente. No hay nada que instalar."; resumen "Git" "OK" "versión $V"
  else say "  Es más viejo que $GIT_MINIMO. Actualícelo (macOS: brew upgrade git; Linux: sudo apt install git)."; resumen "Git" "VIEJO" "versión $V (se necesita $GIT_MINIMO o superior)"; fi
elif [ "$SIN_INSTALAR" = 1 ]; then say "  No está instalado."; resumen "Git" "FALTA" "instala Git (archivo 1 de esta carpeta)"
else
  say "  No está instalado. Lo instalo ahora ..."; tarde
  if instalar_paquete git git && { [ "$SIMULAR" = 1 ] || command -v git >/dev/null 2>&1; }; then
    registrar git; say "  Listo: $([ "$SIMULAR" = 1 ] && echo simulado || git --version 2>/dev/null)"
    resumen "Git" "INSTALADO" "$([ "$SIMULAR" = 1 ] && echo simulado || git --version 2>/dev/null)"
  else say "  No pude instalarlo."; resumen "Git" "FALTA" "no pude instalarlo: https://git-scm.com/downloads"; fi
fi

# ---------- Python ----------
paso "Python (se necesita la $PYTHON_MINIMA o superior; recomendada: $PYTHON_RECOMENDADA)"
PYBIN=""; VIEJO=""
for c in python3.12 python3.13 python3.14 python3.11 python3; do
  if command -v "$c" >/dev/null 2>&1; then
    V="$($c --version 2>&1 | awk '{print $2}')"
    if ver_ge "$V" "$PYTHON_MINIMA"; then PYBIN="$c"; break; else VIEJO="$V"; fi
  fi
done
if [ -n "$PYBIN" ]; then
  say "  Encontrado: Python $V en $(command -v "$PYBIN")"
  say "  Es suficiente (acepta $PYTHON_MINIMA o superior). No hay nada que instalar."
  if ! "$PYBIN" -c "import venv, ensurepip" >/dev/null 2>&1; then
    say "  Falta el módulo «venv» de Python."
    if [ "$SIN_INSTALAR" = 0 ] && [ "$GESTOR" = "apt" ]; then say "  Lo instalo ..."; ejecutar $SUDO apt-get install -y python3-venv python3-pip && registrar python-venv; fi
  fi
  resumen "Python" "OK" "$($PYBIN --version 2>&1) (recomendada: $PYTHON_RECOMENDADA)"
elif [ "$SIN_INSTALAR" = 1 ]; then
  [ -n "$VIEJO" ] && say "  Encontrado Python $VIEJO, es más viejo que $PYTHON_MINIMA." || say "  No está instalado."
  resumen "Python" "FALTA" "instala Python $PYTHON_RECOMENDADA"
else
  if [ -n "$VIEJO" ]; then say "  Encontrado Python $VIEJO, es más viejo que $PYTHON_MINIMA. Instalo la $PYTHON_RECOMENDADA al lado (no toca la que ya tiene) ..."
  else say "  No está instalado. Instalo Python $PYTHON_RECOMENDADA ..."; fi
  tarde
  if instalar_paquete "python@$PYTHON_RECOMENDADA" python3 python3-venv python3-pip; then
    registrar python
    for c in "python$PYTHON_RECOMENDADA" python3; do command -v "$c" >/dev/null 2>&1 && PYBIN="$c" && break; done
    if [ "$SIMULAR" = 1 ]; then resumen "Python" "INSTALADO" "simulado"
    else say "  Listo: $($PYBIN --version 2>&1)"; resumen "Python" "INSTALADO" "$($PYBIN --version 2>&1)"; fi
  else say "  No pude instalarlo."; resumen "Python" "FALTA" "no pude instalarlo: https://www.python.org/downloads/"; fi
fi

# ---------- Visual Studio Code (opcional, solo en la preparación) ----------
if [ "$MODO" = preparar ]; then
  paso "Editor de código (opcional)"
  if command -v code >/dev/null 2>&1; then say "  Encontrado: Visual Studio Code."; resumen "Editor (VS Code)" "OK" "instalado"
  elif [ "$CON_EDITOR" = 1 ] && [ "$SIN_INSTALAR" = 0 ] && [ "$SO" = "Darwin" ] && [ "$GESTOR" = "brew" ]; then
    say "  No está instalado. Lo instalo ..."
    ejecutar brew install --cask visual-studio-code && registrar vscode && resumen "Editor (VS Code)" "INSTALADO" "" || resumen "Editor (VS Code)" "OPCIONAL" "usa el editor que prefieras"
  else say "  No hace falta: puede usar el editor que prefiera."; resumen "Editor (VS Code)" "OPCIONAL" "usa el editor que prefieras"; fi
fi

# ---------- Docker ----------
paso "Docker (se necesita el motor $DOCKER_MINIMO o superior, con Compose)"
DOCKER_OK=0
if ! command -v docker >/dev/null 2>&1 && [ "$SIN_INSTALAR" = 0 ]; then
  say "  No está instalado. Lo instalo (puede tardar varios minutos) ..."; tarde
  if [ "$SO" = "Darwin" ]; then ejecutar brew install --cask docker
  elif [ "$GESTOR" = "apt" ]; then instalar_docker_debian
  elif [ "$GESTOR" = "dnf" ]; then ejecutar $SUDO dnf install -y docker docker-compose-plugin && ejecutar $SUDO systemctl enable --now docker
  fi
  command -v docker >/dev/null 2>&1 && registrar docker
fi
if command -v docker >/dev/null 2>&1; then
  say "  Encontrado: $(docker --version 2>/dev/null) en $(command -v docker)"
  if ! docker info >/dev/null 2>&1; then
    say "  Docker está instalado pero apagado."
    if [ "$SO" = "Darwin" ] && [ "$SOLO_VERIFICAR" = 0 ]; then
      say "  Abriendo Docker Desktop; espero hasta 2 minutos a que arranque ..."
      open -a Docker >/dev/null 2>&1
      for _ in $(seq 1 60); do docker info >/dev/null 2>&1 && break; sleep 2; done
    fi
  fi
  if docker info >/dev/null 2>&1; then
    V="$(docker version --format '{{.Server.Version}}' 2>/dev/null)"; MAJOR="${V%%.*}"
    say "  Motor encendido: versión $V"
    CV="$(docker compose version --short 2>/dev/null)"
    if [ -z "$CV" ]; then
      say "  Falta Docker Compose (comando «docker compose»)."; resumen "Docker" "FALTA" "motor $V, pero sin Docker Compose: instálelo y repita"
    else
      say "  Docker Compose: versión $CV"
      if [ -n "$MAJOR" ] && [ "$MAJOR" -ge "$DOCKER_MINIMO" ] 2>/dev/null; then DOCKER_OK=1; resumen "Docker" "OK" "motor $V, compose $CV"
      else DOCKER_OK=1; say "  Es más viejo que $DOCKER_MINIMO; intentaremos igual."; resumen "Docker" "VIEJO" "motor $V (recomendado $DOCKER_MINIMO o superior); intentaremos igual"; fi
    fi
  elif [ "$SO" != "Darwin" ] && $SUDO docker info >/dev/null 2>&1; then
    say "  Docker funciona con sudo, pero su usuario aún no está en el grupo «docker»."
    resumen "Docker" "REINICIA SESIÓN" "Docker funciona, pero tu usuario aún no está en el grupo docker: cierra sesión y vuelve a entrar (o ejecuta 'newgrp docker') y repite"
  else say "  Docker no responde."; resumen "Docker" "APAGADO" "está instalado pero no responde: ábrelo (macOS) o 'sudo systemctl start docker' (Linux) y repite"; fi
elif [ "$SIMULAR" = 1 ]; then resumen "Docker" "INSTALADO" "simulado"
else say "  No está instalado.$([ "$SIN_INSTALAR" = 1 ] || echo " No pude instalarlo.")"; resumen "Docker" "FALTA" "instala Docker Desktop (ver LEEME-MAC.md o LEEME-LINUX.md)"; fi

# ---------- Entorno de Python ----------
paso "Entorno de Python con boto3 y pytest"
VENV_OK=0
PYV="$VENV/bin/python"
if [ -n "$PYBIN" ] && [ "$SOLO_VERIFICAR" = 0 ] && [ "$SIMULAR" = 0 ]; then
  if [ -x "$PYV" ] && "$PYV" -c "import boto3, pytest" >/dev/null 2>&1; then say "  El entorno ya existe en $VENV y tiene todo lo necesario; no hay nada que instalar."; VENV_OK=1
  else
    tarde
    if [ -x "$PYV" ]; then say "  El entorno existe pero le faltan librerías; las instalo ..."; else say "  Creando el entorno en $VENV ..."; "$PYBIN" -m venv "$VENV" >>"$LOG" 2>&1; fi
    say "  Instalando boto3 y pytest (versiones fijas, de internet) ..."
    "$PYV" -m pip install -q -r "$HERR/requirements.txt" >>"$LOG" 2>&1 && VENV_OK=1
  fi
elif [ -x "$PYV" ] && "$PYV" -c "import boto3, pytest" >/dev/null 2>&1; then VENV_OK=1; say "  El entorno ya existe y tiene todo lo necesario."; fi
if [ "$VENV_OK" = 1 ]; then
  say "  Listo: boto3 $("$PYV" -c 'import boto3;print(boto3.__version__)'), pytest $("$PYV" -c 'import pytest;print(pytest.__version__)')"
  resumen "Entorno de Python" "OK" "boto3 y pytest en horizonte-clase4/.venv"
elif [ "$SIMULAR" = 1 ]; then resumen "Entorno de Python" "SIMULADO" "se crearía el entorno e instalaría boto3 y pytest"
else say "  No pude dejar el entorno listo."; resumen "Entorno de Python" "FALTA" "revisa instalacion.log (¿sin internet o proxy?)"; fi

# ---------- Repositorio (Git), solo el día de la clase ----------
if [ "$MODO" = clase ]; then
  paso "Punto de partida del taller (para medir sus cambios con Git)"
  if command -v git >/dev/null 2>&1 && [ "$SOLO_VERIFICAR" = 0 ] && [ "$SIMULAR" = 0 ]; then
    if [ ! -d "$RAIZ/.git" ]; then
      say "  Creando el repositorio y la etiqueta «base» ..."
      ( cd "$RAIZ" && git init -q -b main && git add -A \
        && git -c user.email=taller@horizonte.local -c user.name="Taller Horizonte" commit -qm base && git tag base ) >>"$LOG" 2>&1
    else say "  El repositorio ya existe."; fi
    if git -C "$RAIZ" tag 2>/dev/null | grep -qx base; then say "  Etiqueta «base» lista."; resumen "Repositorio del taller" "OK" "etiqueta «base» lista"
    else say "  No pude crear la etiqueta base."; resumen "Repositorio del taller" "FALTA" "no pude crear la etiqueta base (revisa instalacion.log)"; fi
  elif [ "$SIMULAR" = 1 ]; then resumen "Repositorio del taller" "SIMULADO" "se crearía la etiqueta base"
  else say "  (se omite en este modo)"; fi
fi

# ---------- Floci ----------
paso "Floci $FLOCI_VERSION (emulador local de AWS, corre en Docker)"
IMG="floci/floci:$FLOCI_VERSION"
EMU="NINGUNO"
if [ "$SIMULAR" = 1 ]; then resumen "Floci" "SIMULADO" "no se descarga ni se enciende en modo simulación"
elif [ "$SOLO_VERIFICAR" = 1 ]; then
  if [ "$DOCKER_OK" = 1 ] && docker image inspect "$IMG" >/dev/null 2>&1; then say "  La imagen $IMG ya está en su equipo."
  elif [ "$DOCKER_OK" = 1 ]; then say "  La imagen $IMG todavía no está en su equipo."; fi
  if [ -x "$PYV" ] && "$PYV" "$HERR/verificar_floci.py" --rapido >/dev/null 2>&1; then say "  Algo responde en http://localhost:4566."; resumen "Floci" "OK" "responde en http://localhost:4566"
  else say "  No responde en http://localhost:4566."; resumen "Floci" "APAGADO" "se enciende con el archivo 2 de esta carpeta"; fi
elif [ "$DOCKER_OK" = 1 ] && [ "$VENV_OK" = 1 ]; then
  if docker image inspect "$IMG" >/dev/null 2>&1; then say "  La imagen $IMG ya está en su equipo: no hace falta descargarla."
  else
    say "  La imagen $IMG no está en su equipo. La descargo (la primera vez tarda unos minutos) ..."; tarde
    registrar_imagen "$IMG"
  fi
  PULL_OK=1
  if ! docker image inspect "$IMG" >/dev/null 2>&1; then
    ejecutar docker pull "$IMG" || PULL_OK=0
    [ "$PULL_OK" = 1 ] && say "  Descarga terminada."
  else registrar_imagen "$IMG"; fi
  if [ "$PULL_OK" = 0 ]; then say "  No pude descargar la imagen."; resumen "Floci $FLOCI_VERSION" "FALLA" "no pude descargar la imagen (¿sin internet, proxy o firewall?)"
  elif bash "$HERR/iniciar-emulador.sh" 2>&1 | tee -a "$LOG"; [ "${PIPESTATUS[0]}" = 0 ]; then
    EMU="Floci"
    say "  Probando que el emulador sirve para el taller (cola y tabla) ..."
    if "$PYV" "$HERR/verificar_floci.py" 2>&1 | tee -a "$LOG"; [ "${PIPESTATUS[0]}" = 0 ]; then resumen "Floci $FLOCI_VERSION" "OK" "responde y la prueba de cola y tabla pasó"
    else resumen "Floci $FLOCI_VERSION" "FALLA" "responde pero la prueba de cola y tabla falló: revisa instalacion.log"; fi
  else resumen "Floci $FLOCI_VERSION" "FALLA" "se descargó pero no respondió: revisa instalacion.log"; fi
else say "  Se omite: Docker o el entorno de Python no están listos (mire los pasos anteriores)."; resumen "Floci $FLOCI_VERSION" "FALTA" "necesita Docker y el entorno de Python listos"; fi

# ---------- Consola web de Floci ----------
paso "Consola web de Floci (para ver colas y tablas en el navegador)"
UIIMG="floci/floci-ui:$FLOCI_UI_VERSION"
if [ "$SIMULAR" = 1 ]; then resumen "Consola web" "SIMULADO" "no se descarga ni se enciende en modo simulación"
elif [ "$SOLO_VERIFICAR" = 1 ]; then
  if curl -s -m 3 -o /dev/null http://localhost:4500; then say "  Responde en http://localhost:4500."; resumen "Consola web" "OK" "responde en http://localhost:4500"
  else say "  No responde en http://localhost:4500."; resumen "Consola web" "APAGADO" "se enciende con el archivo 2 o 3 de esta carpeta"; fi
elif [ "$DOCKER_OK" = 1 ] && [ "$EMU" = "Floci" ]; then
  UI_OK=1
  if docker image inspect "$UIIMG" >/dev/null 2>&1; then say "  La imagen $UIIMG ya está en su equipo: no hace falta descargarla."; registrar_imagen "$UIIMG"
  else
    say "  La imagen $UIIMG no está en su equipo. La descargo (la primera vez tarda unos minutos) ..."; tarde
    registrar_imagen "$UIIMG"
    ejecutar docker pull "$UIIMG" && say "  Descarga terminada." || UI_OK=0
  fi
  if [ "$UI_OK" = 0 ]; then say "  No pude descargarla."; resumen "Consola web" "FALLA" "no pude descargar la imagen (¿sin internet, proxy o firewall?)"
  else
    SIN_ABRIR=""; [ "$MODO" = preparar ] && SIN_ABRIR="--sin-abrir"
    if bash "$HERR/iniciar-interfaz.sh" $SIN_ABRIR 2>&1 | tee -a "$LOG"; [ "${PIPESTATUS[0]}" = 0 ]; then resumen "Consola web" "OK" "http://localhost:4500"
    else resumen "Consola web" "FALLA" "se descargó pero no respondió: revisa instalacion.log"; fi
  fi
else say "  Se omite: Floci no está encendido (mire los pasos anteriores)."; resumen "Consola web" "FALTA" "necesita Floci encendido"; fi

# ---------- Pruebas del taller (solo el día de la clase) ----------
if [ "$MODO" = clase ] && [ "$SIMULAR" = 0 ] && [ "$SOLO_VERIFICAR" = 0 ]; then
  paso "Pruebas del taller"
  if [ "$VENV_OK" = 1 ]; then
    say "  Corriendo las pruebas (unos segundos) ..."
    SALIDA="$(cd "$RAIZ" && "$PYV" -m pytest -q 2>&1)"; CODIGO=$?
    printf '%s\n' "$SALIDA" >>"$LOG"
    say "  $(printf '%s' "$SALIDA" | tail -1)"
    if [ "$CODIGO" = 0 ]; then resumen "Pruebas del taller" "OK" "$(printf '%s' "$SALIDA" | tail -1)"
    else resumen "Pruebas del taller" "FALLAN" "revisa instalacion.log"; fi
  else say "  Se omiten: el entorno de Python no está listo."; fi
fi

# En la preparación, Floci solo se verificó: lo apagamos para dejar el equipo como estaba.
if [ "$MODO" = preparar ] && [ "$EMU" = "Floci" ]; then
  docker rm -f floci-clase4 floci-ui-clase4 >/dev/null 2>&1 && say "" && say "Floci y su consola web quedaron verificados y los apagué. Se encienden solos el día de la clase."
fi

# ---------- Resumen ----------
say ""
say "RESULTADO"
say "--------------------------------------------------"
PEND=0
for i in "${!RES_NOMBRE[@]}"; do
  printf '  %-26s %-16s %s\n' "${RES_NOMBRE[$i]}" "${RES_ESTADO[$i]}" "${RES_DETALLE[$i]}" | tee -a "$LOG"
  case "${RES_ESTADO[$i]}" in FALTA|FALLA|FALLAN|APAGADO|VIEJO|"REINICIA SESIÓN") PEND=1 ;; esac
done
say "--------------------------------------------------"
if [ "$PEND" = 0 ]; then
  if [ "$MODO" = clase ]; then say "LISTO: el taller está preparado. Consola web de Floci: http://localhost:4500. Guía: CLASE/GUIA-DEL-TALLER.md."
  else
    say "LISTO: su equipo está preparado."
    say "La carpeta CLASE no viene en este paquete: se entrega el día de la clase."
    say "Ese día, descomprímala dentro de horizonte-clase4 (junto a WINDOWS, MAC y LINUX) y ejecute el archivo 2-INICIAR-LA-CLASE (no necesita internet)."
  fi
  EXIT=0
else say "HAY PENDIENTES. Envíe el archivo instalacion.log (está en esta misma carpeta, junto a los scripts numerados) por el canal del grupo antes de la clase para resolverlo juntos."; EXIT=1; fi
exit $EXIT
