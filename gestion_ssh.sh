#!/bin/bash

# Función para obtener los datos de red (CABEZERA)
mostrar_info_sistema() {
    # Extraemos la IP de la interfaz enp0s3
    IP_LOCAL=$(ip -4 addr show enp0s3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

    # Comprobamos si el contenedor Docker está corriendo
    if [ "$(docker ps -q -f name=mi-contenedor)" ]; then
        ESTADO="ACTIVO (Docker)"
    else
        ESTADO="DETENIDO"
    fi

    echo "============================================================"
    echo "           SISTEMA DE GESTIÓN SSH - CARLOS"
    echo "============================================================"
    echo " INTERFAZ: enp0s3 | IP: ${IP_LOCAL:-Desconectado} "
    echo " ESTADO DEL SERVICIO: $ESTADO"
    echo "============================================================"
}

# --- FUNCION DE INSTALACIÓN ---
instalacion() {
    echo "--- Menú de Instalación ---"
    echo "1) Manual (Paquete) | 2) Docker"
    read -p "Opción: " metodo
    if [ "$metodo" == "1" ]; then
        sudo apt update && sudo apt install openssh-server -y
    else
        if ! command -v docker &> /dev/null; then
	    echo "Instalando Docker en el host..."
            sudo apt update && sudo apt install docker.io -y
        fi
        echo "Docker listo."
	read -p "Presiona Enter para continuar..."
    fi
}

# --- FUNCION DE PUESTA EN MARCHA ---
puesta_en_marcha() {
    echo "Reiniciando contenedor..."
    docker rm -f mi-contenedor 2>/dev/null
    docker build -t mi-servidor-ssh .
    docker run -d -p 2222:2222 --name mi-contenedor mi-servidor-ssh
    sleep 2 # Pausa de 2 segundos para que el mensaje sea visible
}

# --- FUNCION DE PARADA ---
parada() {
    docker stop mi-contenedor
    echo "Contenedor detenido."
    sleep 2
}

# --- MENÚ PRINCIPAL ---
while true; do
    clear
    mostrar_info_sistema
    echo " 1) INSTALACIÓN"
    echo " 2) PUESTA EN MARCHA"
    echo " 3) PARADA"
    echo " 4) CONSULTAR LOGS"
    echo " 5) EDITAR CONFIGURACIÓN"
    echo " 6) ELIMINAR SERVICIO"
    echo " 0) SALIR"
    read -p "Seleccione: " opcion
    case $opcion in
        1)  instalacion ;;
        2)  puesta_en_marcha ;;
        3)  parada ;;
        4)  ;;
        5)  ;;
        6)  ;;
        0) exit 0 ;;
    esac
done

