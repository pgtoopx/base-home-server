#!/bin/bash

# Encuentra todos los archivos .sh en el directorio actual
# y les otorga permisos de ejecución
for script in $(ls *.sh)
do
  chmod +x $script
done
