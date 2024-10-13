---
title: "Instalación de Servidor PostgreSQL en Debian 12"
geometry: margin=1in
output: pdf_document
---

# Instalación de Servidor PostgreSQL en Debian 12

![Logo de MySQL](Instalaciones/img/postgres-debian.jpg)

## Autor :computer:
* Andrés Morales González
* :school:I.E.S. Gonzalo Nazareno :round_pushpin:(Dos Hermanas, Sevilla).


<div style="page-break-after: always;"></div>


# Índice

- [Instalación de Servidor PostgreSQL en Debian 12](#instalación-de-servidor-postgresql-en-debian-12)
  - [Autor :computer:](#autor-computer)
- [Índice](#índice)
- [Instalacion de servidor Postgres en Debian12](#instalacion-de-servidor-postgres-en-debian12)
- [Instalación y configuracion de PostgreSQL](#instalación-y-configuracion-de-postgresql)
  - [1. Instalar PostgreSQL](#1-instalar-postgresql)
  - [2. Configuracion para el acceso remoto](#2-configuracion-para-el-acceso-remoto)
    - [Paso a:](#paso-a)
    - [Paso b:](#paso-b)
    - [Paso c:](#paso-c)
- [Creacion de un cliente en postgres](#creacion-de-un-cliente-en-postgres)


<div style="page-break-after: always;"></div>

# Instalacion de servidor Postgres en Debian12

Para ello lo primero que haremos sera la creación de una maquina debian, sin entorno gráfico.

Una vez realizada procedermos a la instalación por comandos de dicho servidor:

# Instalación y configuracion de PostgreSQL

## 1. Instalar PostgreSQL

Para ello tendremos que meter los siguientes comandos:

Este coamndo que meteremos a continuación será para actualizar lo que sera el sistema:

```sudo apt update```

Este comando sera para la instalación de nuestro servidor:

```sudo apt install postgresql postgresql-contrib -y```



## 2. Configuracion para el acceso remoto

### Paso a:

Modificamso el archivo de configuración postgresql.conf para permitir conexiones desde la red local:

```sudo nano /etc/postgresql/15/main/postgresql.conf```

Tenemos que buscar la linea *listen_addresses* y le añadiremso la siguiente linea:

```listen_addresses = '*'```

![Acceso remoto](/Instalaciones/img/postgresaccesoremoto.png)

### Paso b:

Ahora editamos el control de acceso *pg_hba.conf* para añadir permisos en nuetsra red local:

```sudo nano /etc/postgresql/15/main/pg_hba.conf```

En este caso en el fichero si indagamos un poco hacia abajo, lo que podemos ver es la siguiente linea:

```
# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256
```

y yo en este caso voy a permitir la conexión desde cualquier red, ya que trabajamos tanto en clase, como en casa, asi que pondremos lo siguiente:

```

# Permitir conexiones desde cualquier red
host    all             all             0.0.0.0/0               scram-sha-256
```

Con lo que quedaria asi:

![Acceso remoto](/Instalaciones/img/red-permiso.png)

### Paso c:

Reiniciamos el servicio PostgreSQL:

```sudo systemctl restart postgresql```

y una vez reiniciado vemos su estado con el comando:

```sudo systemctl status postgresql```

![Acceso remoto](/Instalaciones/img/postgrestatus.png)

# Creacion de un cliente en postgres

Se creara un cliente que pueda entrar desde cualquier host:

```

andy@servidores:~$ sudo -u postgres psql 
could not change directory to "/home/andy": Permiso denegado
psql (15.8 (Debian 15.8-0+deb12u1))
Type "help" for help.

postgres=# CREATE USER andy WITH PASSWORD 'andy';
CREATE ROLE
postgres=# ALTER USER andy CREATEDB;
ALTER ROLE
postgres=# 

```

Pero este cliente si lo intentamos conectar nos dara este error :

```
andy@cliente-mariadb:~$ psql -U andy -h 192.168.1.159
Contraseña para usuario andy: 
psql: error: falló la conexión al servidor en «192.168.1.159», puerto 5432: FATAL:  no existe la base de datos «andy»

```
ya que no hay ninguna bases de datos con ese nombre, ya que solo hemos creado el usuario, para ello nos iremos al servidor y crearemos una bases de datos, la cual llamaremos testeo, de la siguiente manera:

```
andy@servidores:~$ sudo -u postgres psql
could not change directory to "/home/andy": Permiso denegado
psql (15.8 (Debian 15.8-0+deb12u1))
Type "help" for help.

postgres=# \l
postgres=# CREATE DATABASE testeo;
CREATE DATABASE
postgres=# 

```
Y ahroa probamos a conectarnos:

```
andy@cliente-mariadb:~$ psql -U andy -h 192.168.1.159 -d testeo
Contraseña para usuario andy: 
psql (15.8 (Debian 15.8-0+deb12u1))
Conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, compresión: desactivado)
Digite «help» para obtener ayuda.

testeo=> 

```

y como vemos estamos conectaod y con todas la funcionalidades.