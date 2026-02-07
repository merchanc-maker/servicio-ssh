#!/bin/bash

# Función para obtener los datos de red
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

# Llamada inicial para probar
clear
mostrar_info_sistema
