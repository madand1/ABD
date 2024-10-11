# Instalación de oracle 21c 

Intalación de Oracle Database 21c en una máquina Debian, tendremos que tener todas las dependecias u àuquetes ncesarios para hacer su instalación.

Antes de instalar lo que será instalar las librerias y dependencias necesarias, nos aseguraremos que nuetsra maquina creada tenga los reuisitos mínimos:

## Requisitos mínimos

- RAM: Al menos 8 GB.
- Espacio en Disco: Al menos 20 GB de espacio libre.

## Dependendias y paquetes necesarios:

- Librerías necesarias:

```
alien 
libaio1     
libncurses5 
libstdc++6 
unzip 
gcc 
make 
zlib1g 
libc6 
libc6-dev 
libc6-i386 
x11-common 
x11-utils 
x11-xserver-utils 
fontconfig 
libfontconfig1 
libxrender1 
libxi6 
libxrandr2 
libxtst6 
libxext6 
libxau6 
libxdmcp6 
libgomp1 
libnss-sss 
x11-common 
xfonts-encodings 
xfonts-utils
```

## creacion de un usuario y grupo para Oracle

Crearemos un usuario y grupo para la instalación de Oracle:

```
sudo groupadd oinstall
sudo groupadd dba
sudo useradd -g alumno -G dba alumno

```

Configuraremos la contraseña del usuario alumno:

```sudo passwd alumno```

## Ajustar loq ue seran los parámetro del sistema

Para esto ediatremos el siguiente fichero */etc/sysctl.conf* para lo que sera aumentar algunos limites.

```
fs.file-max = 6815744
kernel.shmmax = 4294967295
kernel.shmall = 1073741824
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.core.rmem_default = 262144
net.core.rmem_max = 262144
net.core.wmem_default = 262144
net.core.wmem_max = 262144

```

y aplicamos los cambios:

```sudo syctl -y```

# Instalación de oracle 21 C

## Descarga de Oracle Database 21c
Para esto nos tendremos que ir a la paquina oficial y descargarnos lo que sera el *.zip*

## Descomprimir el archivo

-Descomprimiremos sus ficheros en el directorio /opt/oracle-install
 
 - Sugerencia: línea de comandos unzip

- Directorio /opt/oracle-install/

y una vez hecho esto lo arrancaremos con ./runInstaller

A continuación nos saldra lo siguiente:


![Oracle](/Instalaciones/img/1.png)
![Oracle](/Instalaciones/img/2.png)
![Oracle](/Instalaciones/img/3.png)

## Directorios de Oracle

Dejamos los directorios por defecto:

- Oracle Base: /opt/app/alumno
- Software en /opt/oracle-install
- Inventory en /opt/app/oraInventory
- Dejamos el grupo a alumno
  

![Oracle](/Instalaciones/img/5.png)
![Oracle](/Instalaciones/img/6.png)

## Ejecución de scripts como root
La instalación necesitará modificar el sistema, pero se ha lanzado como alumno

No dejaremos que el instalador ejecute nada como root, lo haremos manualmente
![Oracle](/Instalaciones/img/7.png)

## Comprobaciones

Ignoramos la falta de memoria
El instalador detectará algunos errores, pero genera unos scripts de fix
Son parámetros del kernel de Linux
Los scripts se ejecutan como administrador
sudo bash runfixup.sh
Se necesitan instalar varios paquetes de software
sudo yum install paquete
Es necesario que la máquina virtual tenga acceso a internet (debería estar en Bridged, pero también funciona NAT)

![Oracle](/Instalaciones/img/8.png)

## Resumen

Se debe grabar la información de la hoja de resumen

![Oracle](/Instalaciones/img/9.png)

## definir variables de entornos

Ficheros:

ficheros ~/.profile, ~/.bash_profile, ~/.bashrc

- ORACLE_HOME: /opt/oracle-install
- Incluir $ORACLE_HOME/bin en el PATH
