#!/usr/bin/env bash
# Registro de lo que instala ESTE paquete. La limpieza de después solo quita lo registrado como «nuestro».
# Se carga con «source» desde los demás scripts (necesita PREP definido).
INSTALADO="${INSTALADO:-$PREP/.instalado-por-el-paquete.txt}"

registrar() {   # registrar <nombre>: herramienta que instalamos nosotros
  [ "${SIMULAR:-0}" = 1 ] && return 0
  grep -qx "$1" "$INSTALADO" 2>/dev/null || printf '%s\n' "$1" >>"$INSTALADO"
}

registrar_imagen() {   # registrar_imagen <imagen:tag>: llamar ANTES de «docker pull»
  [ "${SIMULAR:-0}" = 1 ] && return 0
  grep -qE "^imagen-(nuestra|previa):$1\$" "$INSTALADO" 2>/dev/null && return 0   # ya se registró la primera vez
  if docker image inspect "$1" >/dev/null 2>&1; then printf 'imagen-previa:%s\n' "$1" >>"$INSTALADO"
  else printf 'imagen-nuestra:%s\n' "$1" >>"$INSTALADO"; fi
}

estado_imagen() {   # imprime: nuestra | previa | sinregistro
  if grep -qx "imagen-nuestra:$1" "$INSTALADO" 2>/dev/null; then echo nuestra
  elif grep -qx "imagen-previa:$1" "$INSTALADO" 2>/dev/null; then echo previa
  else echo sinregistro; fi
}

olvidar_imagen() {  # quita la imagen del registro
  [ -f "$INSTALADO" ] || return 0
  grep -vx -e "imagen-nuestra:$1" -e "imagen-previa:$1" "$INSTALADO" >"$INSTALADO.tmp"; mv "$INSTALADO.tmp" "$INSTALADO"
}

confirmar() {   # confirmar "pregunta" -> 0 si el usuario acepta (o si SI=1)
  [ "${SI:-0}" = 1 ] && return 0
  read -r -p "$1 [s/N] " r </dev/tty || return 1
  [[ "$r" =~ ^[sSyY] ]]
}
