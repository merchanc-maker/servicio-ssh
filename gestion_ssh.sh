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
    echo "Reiniciando contenedor con persistencia de datos..."

    docker rm -f mi-contenedor 2>/dev/null

    # Creamos la carpeta en tu PC si no existe para evitar errores
    mkdir -p ~/datos_ssh_contenedor

    docker build -t mi-servidor-ssh .

    # Añadimos el parámetro -v para los datos de /home
    docker run -d \
      -p 2222:2222 \
      --name mi-contenedor \
      -v ~/datos_ssh_contenedor:/home \
      mi-servidor-ssh

    sleep 2 # Pausa de 2 segundos para que el mensaje sea visible
}

# --- FUNCION DE PARADA ---
parada() {
    docker stop mi-contenedor
    echo "Contenedor detenido."

    echo "Creando copia de seguridad de los datos..."
    tar -cvfz backup_ssh_$(date +%Y%m%d).tar.gz ~/datos_ssh_contenedor
    echo "Servicio detenido y backup realizado."

    sleep 2
}

# --- FUNCION DE LOGS ---
gestionar_logs() {
    echo "1) Tiempo real | 2) Búsqueda"
    read -p "Opción: " opcion
    if [ "$opcion" == "1" ]; then
        docker logs -f mi-contenedor
    else
        read -p "Palabra a buscar: " palabra
        docker logs mi-contenedor | grep -i "$palabra"
        read -p "Presiona Enter..."
    fi
}

# --- FUNCION DE EDITAR ---
editar_configuracion() {
    nano sshd_config.pro
    read -p "¿Reiniciar servicio ahora? (s/n): " reiniciar
    [ "$reiniciar" == "s" ] && puesta_en_marcha
}

# --- FUNCION DE ELIMINAR ---
eliminar() {
    docker rm -f mi-contenedor
    echo "Servicio eliminado"
    sleep 2
}

# --- FUNCIÓN DE AYUDA ---
mostrar_ayuda() {
    echo "Uso: $0 {instalar|start|stop|logs|config|eliminar|help}"
    echo
    echo "Comandos disponibles:"
    echo "  instalar   → Instala y configura el entorno"
    echo "  start      → Inicia el contenedor"
    echo "  stop       → Detiene el contenedor"
    echo "  logs       → Muestra los logs"
    echo "  config     → Edita la configuración"
    echo "  eliminar   → Elimina el contenedor"
    echo "  help, -h   → Muestra esta ayuda"
}

# --- LÓGICA DE PARÁMETROS DIRECTOS ---
if [ ! -z "$1" ]; then
    case "$1" in
        instalar) instalacion ; exit 0 ;;
        start) puesta_en_marcha ; exit 0 ;;
        stop) parada ; exit 0 ;;
        logs) gestionar_logs ; exit 0 ;;
        config) editar_configuracion ; exit 0 ;;
        eliminar) docker rm -f mi-contenedor 2>/dev/null ; exit 0 ;;
        help|-h|--help) mostrar_ayuda ; exit 0 ;;
        *) echo "Comando no válido" ; mostrar_ayuda ; exit 1 ;;
    esac
fi


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
        1) instalacion ;;
        2) puesta_en_marcha ;;
        3) parada ;;
        4) gestionar_logs ;;
        5) editar_configuracion ;;
        6) eliminar ;;
        0) exit 0 ;;
    esac
done

