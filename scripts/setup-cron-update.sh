#!/bin/bash

# Obtiene la ruta completa del directorio actual
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Comprueba si el crontab ya tiene el trabajo, para evitar duplicados
if ! crontab -l | grep -q "$DIR/update.sh"; then
  # Copia el crontab actual
  crontab -l > mycron
  # Agrega el nuevo trabajo al crontab
  echo "0 5 * * 6 $DIR/update.sh" >> mycron
  # Instala el nuevo crontab
  crontab mycron
  # Elimina el archivo temporal
  rm mycron
fi
