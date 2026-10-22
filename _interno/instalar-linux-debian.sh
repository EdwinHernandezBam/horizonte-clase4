#!/usr/bin/env bash
# Clase 4 · Instalador para Linux (Debian, Ubuntu y derivados).
# Instala con apt: Git, Python 3 con venv, Docker Engine oficial (repositorio de Docker) y las dependencias del taller.
# Uso:  _interno/instalar-linux-debian.sh [--solo-verificar] [--simular]
HERR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$(uname -s)" != "Linux" ] || ! command -v apt-get >/dev/null 2>&1; then
  echo "Este script es para Debian/Ubuntu (necesita apt). En macOS use la carpeta MAC; en Windows, la carpeta WINDOWS."
  exit 2
fi
if [ "$(id -u)" != "0" ] && ! command -v sudo >/dev/null 2>&1; then
  echo "Necesita ejecutarse como root o tener sudo instalado (su -c 'apt-get install sudo')."
  exit 2
fi
if [ "$(id -u)" != "0" ] && [ "$*" != "--solo-verificar" ]; then
  echo "Se le pedirá la contraseña de sudo para instalar paquetes."
  sudo -v || exit 1
fi
exec "$HERR/instalar.sh" "$@"
