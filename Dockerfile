# 1. Usamos la base de Ubuntu
FROM ubuntu:latest

# 2. Instalamos el servidor SSH
RUN apt-get update && apt-get install -y openssh-server

# 3. Creamos el directorio necesario para que SSH funcione
RUN mkdir /var/run/sshd

# 4. Copiamos TU archivo de configuración personalizado al contenedor
COPY sshd_config.pro /etc/ssh/sshd_config

# 5.Esta línea es la CLAVE: permite login de root con contraseña
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 6. Ponemos una contraseña al usuario root para poder entrar
RUN echo 'root:root123' | chpasswd

# 7. Exponemos el puerto que configuraste (el 2222)
EXPOSE 2222

# 8. Iniciamos el servicio al arrancar el contenedor
CMD ["/usr/sbin/sshd", "-D"]
