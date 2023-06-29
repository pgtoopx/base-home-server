#!/bin/bash

# Comprobación de privilegios de superusuario
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como superusuario." 
   exit 1
fi

# Variables
USERNAME="futurocloud"  # Nombre de usuario deseado
PASSWORD="futurocloud"  # Contraseña para el nuevo usuario
STACK_DIR="/home/$USERNAME/stack"  # Directorio donde se encuentra el stack

# Instalación de Docker y Docker Compose
install_docker() {
    # Instalar Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh

    # Agregar el usuario al grupo docker
    usermod -aG docker $USERNAME

    # Instalar Docker Compose
    COMPOSE_VERSION=$(curl -sSL "https://api.github.com/repos/docker/compose/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
    curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    echo "Docker y Docker Compose se han instalado correctamente."
}

# Función para configurar y ejecutar el stack
configure_stack() {
    cd $STACK_DIR
    
    # Configurar y ejecutar el stack
    docker-compose up -d
    
    # Esperar a que los servicios se inicien completamente
    sleep 5
    
    # Mostrar los servicios en ejecución
    docker-compose ps
    
    echo "El stack se ha configurado y está en ejecución."
    echo "Puedes acceder a las herramientas en http://<IP_DEL_SERVIDOR>/<nombre-herramienta>"
}

# Función para detener y eliminar el stack
stop_stack() {
    cd $STACK_DIR
    
    # Detener y eliminar el stack
    docker-compose down
    
    echo "El stack se ha detenido y eliminado correctamente."
}

# Opciones del script
case "$1" in
    install)
        # Instalar Docker y Docker Compose
        install_docker

        # Crear el nuevo usuario con contraseña por defecto
        useradd -m -p $(openssl passwd -1 $PASSWORD) $USERNAME

        # Clonar el repositorio
        su - $USERNAME -c "git clone https://github.com/pgtoopx/stack-home.git $STACK_DIR"
        
        # Configurar y ejecutar el stack
        configure_stack
        ;;
    start)
        # Iniciar el stack existente
        configure_stack
        ;;
    stop)
        # Detener y eliminar el stack
        stop_stack
        ;;
    restart)
        # Detener y eliminar el stack, luego configurar y ejecutar nuevamente
        stop_stack
        configure_stack
        ;;
    *)
        echo "Uso: $0 {install|start|stop|restart}"
        exit 1
esac
