# Instalacion MONGODB

## Actualizar el sistema

## imprtar la clave GPC de MongoDB

Antes de agregar lo que sera el repositorio de MongoD, lo que vamos a necesitar es la clave pública:

```wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -```

Verificación por pantalla:

```
andy@servidores:~$ wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
OK

```

## Agregar el repositorio de MongoDB

Ahora agregaremos lo que sera el repo de MongoDB a nuestra lista de fuentes APT:

```echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian $(lsb_release -cs)/mongodb-org/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list```

Verificación:

```
andy@servidores:~$ echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian $(lsb_release -cs)/mongodb-org/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/6.0 main

```

## Instalar MongoDB

Para instalar mongo lo que tendremos que hacer l siguiiente:

- Paso 1

Al hacer lo que es la actualización de lo que seria nuestros repositorios, este nos dara un fallo, el cual será este:

```
andy@servidores:~$ sudo apt install -y mongodb-org
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
No se pudieron instalar algunos paquetes. Esto puede significar que
usted pidió una situación imposible o, si está usando la distribución
inestable, que algunos paquetes necesarios aún no se han creado o se
han sacado de «Incoming».
La siguiente información puede ayudar a resolver la situación:

Los siguientes paquetes tienen dependencias incumplidas:
 mongodb-org-mongos : Depende: libssl1.1 (>= 1.1.0) pero no es instalable
 mongodb-org-server : Depende: libssl1.1 (>= 1.1.0) pero no es instalable
 mongodb-org-shell : Depende: libssl1.1 (>= 1.1.0) pero no es instalable
E: No se pudieron corregir los problemas, usted ha retenido paquetes rotos.


```
Esto sucede porque en nuestro entorno Debian 12, tenemos instalado *ibssl1.3* y nos pide el siguiente *ibssl1.1*.

Por lo que tendremos que proceder a meter su paquete:

```
andy@servidores:~$ sudo apt install libssl1.1
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
Se instalarán los siguientes paquetes NUEVOS:
  libssl1.1
0 actualizados, 1 nuevos se instalarán, 0 para eliminar y 0 no actualizados.
Se necesita descargar 1.566 kB de archivos.
Se utilizarán 4.227 kB de espacio de disco adicional después de esta operación.
Des:1 http://deb.debian.org/debian bullseye/main amd64 libssl1.1 amd64 1.1.1w-0+deb11u1 [1.566 kB]
Descargados 1.566 kB en 16s (99,6 kB/s)                       
Preconfigurando paquetes ...
Seleccionando el paquete libssl1.1:amd64 previamente no seleccionado.
(Leyendo la base de datos ... 39315 ficheros o directorios instalados actualmente.)
Preparando para desempaquetar .../libssl1.1_1.1.1w-0+deb11u1_amd64.deb ...
Desempaquetando libssl1.1:amd64 (1.1.1w-0+deb11u1) ...
Configurando libssl1.1:amd64 (1.1.1w-0+deb11u1) ...

```
Con esto seguiremos lo que sera para la instalación.


- Paso 2

Ya que le hemos agregado el repositorio en *sudo nano /etc/apt/sources.list* procederemos a hacer la actualizacion del sistema y a la isntalación:

```
sudo apt update
sudo apt install -y mongodb-org

```

- Paso 3
Despues de la instlación, lo que haremos será es iniciar el servicio de MongoDB, y habilitarlo para que se inicie automaticamente al momento que arranquemos el sistema:

```
sudo systemctl start mongod
sudo systemctl enable mongod

```

Comprobacion:

![Enable mongo](/Instalaciones/img/enablemongo.png)

## Configuración acceso remoto
Para habilitar lo que sera el acceso remoto tendremos unos pasos que seguir:

1. Abrir el archivo de configuracion de MongoDB:

```sudo nano /etc/mongod.conf```

Buscamos la línea que contiene bindIp y la cambiamos para que MongoDB escuche en todas las interfaces, es decir le ponemos esto:

```
net:
  bindIp: 0.0.0.0  
  port: 27017

```

![Acceso remoto](/Instalaciones//img/remotomongo.png)

## reinciio del servicio de MongoDB

```sudo systemctl restart mongod```

# Instalacion de cliente para mongodb

