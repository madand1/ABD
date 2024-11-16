# Introducción

En esta ocasión vamos a llevar a cabo una interconexión entre dos servidores *Oracle 21c* y ** los cuales se situan en máquinas con _sistemas operativos_ *Debian 12*, cuya finalidad será la de permitir el acceso desde un mismo cliente a dos bases de datos distinta, como ya hemos visto con anterioridad en:

- [Conexión entre dos servidores Oracle](dblink-Oraclex2.md)
- [Conexión entre dos servidores PostgreSQL](dblink-Postgres.md)
- [Conexión entre los servidores de Oracle y PostgreSQL](dblink-OraclexPostgre.md)
  
Esto al igual que anteriormente se hará de manera unilateral, por lo que el primer servidor se conectará es el que después abre la conexión al segundo de ellos.

Para esta demostración voy a usar dos máquinas que ya tenia hecha, de la interconexion entre las misma maquinas:

- [Interconexión entre servidores PostgreSQL](./dblink-Postgres.md)
- [Interconexión entre servidores Oracle](./dblink-Oraclex2.md)

Aunque si teneis duda de la instalación por aqui os dejo los links de instalación:

- [Instalación de servidor Mariadb en Debian 12](./mysql.md)
- [Intalación de servidor Oracle en Debian 12](./oracle-debian.md)

Las máquinas que voy a usar son las siguientes:

- *oracle19* cuya dirección es:*192.168.1.152*
- *mariadb* cuya dirección es:*192.168.1.154*

# Oracle 19c a mariadb

Como ya partimos de la maquina de la máquina de oracle 19c instalada, la cual tenemos en el siguiente [articulo](dblink-OraclexPostgre.md) en el apartado:

- Instalación de Oracle 19c sobre sistema Operativo Debian 12

Lo primero que vamso a hacer en nuestra máquina oracle será instalar los paquetes necesarios, con los siguientes comandos:

```
sudo apt update
sudo apt install mariadb-client unixodbc unixodbc-dev -y
```
Ahora vamos a descargarnos el siguiente archivo .deb:

```
wget https://dlm.mariadb.com/3680409/Connectors/odbc/connector-odbc-3.1.20/mariadb-connector-odbc-3.1.20-debian-bookworm-amd64.deb 
```
Instalaremos el paquete .deb para poder instalar el conector ODBC:

```
root@madand1:/home/andy# sudo dpkg -i mariadb-connector-odbc-3.1.20-debian-bookworm-amd64.deb 
Seleccionando el paquete mariadb-connector-odbc previamente no seleccionado.
(Leyendo la base de datos ... 77024 ficheros o directorios instalados actualmente.)
Preparando para desempaquetar mariadb-connector-odbc-3.1.20-debian-bookworm-amd64.deb ...
Desempaquetando mariadb-connector-odbc (3.1.20) ...
Configurando mariadb-connector-odbc (3.1.20) ...

```
y hacemos lo siguiente:

```
root@madand1:/home/andy# sudo find / -name odbcinst.ini
/etc/odbcinst.ini
root@madand1:/home/andy# sudo find /usr -name libmaodbc.so
/usr/lib/x86_64-linux-gnu/libmaodbc.so
```

Que lo que he hecho ha sido buscar donde se alojan mis ficheros para tener la configuración oportuna, por lo que mi fichero */etc/odbcinst.ini* quedará de la siguiente manera:

```
root@madand1:/home/andy# cat /etc/odbcinst.ini 
[PostgreSQL]
Description     = ODBC for PostgreSQL
Driver          = /usr/lib/x86_64-linux-gnu/odbc/psqlodbcw.so
Setup           = /usr/lib/x86_64-linux-gnu/odbc/libodbcpsqlS.so
Driver64        = /usr/lib/x86_64-linux-gnu/odbc/psqlodbcw.so
Setup64         = /usr/lib/x86_64-linux-gnu/odbc/libodbcpsqlS.so
FileUsage       = 1

[MariaDB]
Description     = MariaDB ODBC Driver
Driver          = /usr/lib/x86_64-linux-gnu/odbc/libmaodbc.so
Setup           = /usr/lib/x86_64-linux-gnu/odbc/libmaodbc.so
Driver64        = /usr/lib/x86_64-linux-gnu/odbc/libmaodbc.so

```

Ahora procedemos a configurar el archivo */etcodbc.ini* con el siguiente comando:

```
root@madand1:/home/andy# cat /etc/odbc.ini 
[PSQLU]
Debug           = 0
CommLog         = 0
ReadOnly        = 0
Driver          = PostgreSQL 
Servername      = 192.168.1.153
Username        = andy
Password        = andy
Port            = 5432
Database        = testeo
Trace           = 0
TraceFile       = /tmp/sql.log

[Maria_DSN]  # Nombre de la fuente de datos
Driver          = MariaDB        # El driver que configuraste en odbcinst.ini
Server          = 192.168.1.154  # Dirección IP o nombre del host de tu servidor MariaDB
Database        = alegria    # Nombre de la base de datos a la que te quieres conectar
User            = andy        # Nombre de usuario para la conexión
Password        = andy     # Contraseña de la base de datos
Port            = 3306

```

Ahora haremos una pequeña prueba nos podemos conectar a la base de datos que tenemos en *MariaDB,* con el siguiente comando:

```isql Maria_DSN ```

Cuando hacemos esto, nos sale por pantalla lo siguiente:

```
root@madand1:~# isql -v MariaDB_DSN
[IM002][unixODBC][Driver Manager]Data source name not found and no default driver specified
[ISQL]ERROR: Could not SQLConnect
root@madand1:~# 
```

Pero si echamos la vista atrás y nos fijamos en los ficheros tanto */etc/obdc.ini* y */etc/obdcinst.ini* nos podemos fijar y ver como tenemros todo con la configuración pertinente, por lo que he obtado por ir a la página oficial de mysql y hacer lo siguiente:

```
root@madand1:~# wget https://dev.mysql.com/get/Downloads/Connector-ODBC/9.1/mysql-connector-odbc-dbgsym_9.1.0-1debian12_amd64.deb
--2024-11-16 14:08:36--  https://dev.mysql.com/get/Downloads/Connector-ODBC/9.1/mysql-connector-odbc-dbgsym_9.1.0-1debian12_amd64.deb
Resolviendo dev.mysql.com (dev.mysql.com)... 2a02:26f0:1380:298::2e31, 2a02:26f0:1380:2ba::2e31, 23.223.95.112
Conectando con dev.mysql.com (dev.mysql.com)[2a02:26f0:1380:298::2e31]:443... conectado.
Petición HTTP enviada, esperando respuesta... 302 Moved Temporarily
Localización: https://cdn.mysql.com//Downloads/Connector-ODBC/9.1/mysql-connector-odbc-dbgsym_9.1.0-1debian12_amd64.deb [siguiendo]
--2024-11-16 14:08:36--  https://cdn.mysql.com//Downloads/Connector-ODBC/9.1/mysql-connector-odbc-dbgsym_9.1.0-1debian12_amd64.deb
Resolviendo cdn.mysql.com (cdn.mysql.com)... 2a02:26f0:1380:2bd::1d68, 2a02:26f0:1380:2a8::1d68, 184.24.13.194
Conectando con cdn.mysql.com (cdn.mysql.com)[2a02:26f0:1380:2bd::1d68]:443... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 26983520 (26M) [application/x-debian-package]
Grabando a: «mysql-connector-odbc-dbgsym_9.1.0-1debian12_amd64.deb.1»

mysql-connector-odbc 100%[===================>]  25,73M  6,82MB/s    en 3,9s    

2024-11-16 14:08:40 (6,64 MB/s) - «mysql-connector-odbc-dbgsym_9.1.0-1debian12_amd64.deb.1» guardado [26983520/26983520]

```

Si lo descomprimimos con el siguiente comando:

```
root@madand1:~# dpkg -i mysql-connector-odbc-dbgsym_9.1.0-1debian12_amd64.deb
Seleccionando el paquete mysql-connector-odbc-dbgsym:amd64 previamente no seleccionado.
(Leyendo la base de datos ... 77030 ficheros o directorios instalados actualmente.)
Preparando para desempaquetar mysql-connector-odbc-dbgsym_9.1.0-1debian12_amd64.deb ...
Desempaquetando mysql-connector-odbc-dbgsym:amd64 (9.1.0-1debian12) ...
dpkg: problemas de dependencias impiden la configuración de mysql-connector-odbc-dbgsym:amd64:
 mysql-connector-odbc-dbgsym:amd64 depende de mysql-connector-odbc (= 9.1.0-1debian12); sin embargo:
  El paquete `mysql-connector-odbc' no está instalado.

dpkg: error al procesar el paquete mysql-connector-odbc-dbgsym:amd64 (--install):
 problemas de dependencias - se deja sin configurar
Se encontraron errores al procesar:
 mysql-connector-odbc-dbgsym:amd64

```

Y si nos fijamos en lo siguiente nos esta fallando el procesamiento del paquete *mysql-connector-odbc-dbgsm:amd64*, para intentar solucionar este problema he agregado los repositores de MySQL, y aún así me sigue fallando, tambien lo intente hacer con el apt install, pero esto no se encuentran en los repositorios, pero aún así nada.

Por lo que esta práctica esta incompleta, si tener el objetivo realizado de enlazar oracle con mariadb.

Ya que cada vez que hago una instalación ya sea por un camino o por otro siempre acabo en el mismo punto:

```
Los siguientes paquetes tienen dependencias incumplidas:
 mysql-connector-odbc-dbgsym : Depende: mysql-connector-odbc (= 9.1.0-1debian12) pero no es instalable
```
# MariaDb

En la máquina correspondiente al gestor de bases de datos MariDB, dejo en el siguiente [script](creacion-usuario-tabla-mariadb.md) los datos del usuario, y la tabla que instale, como se ve la tabla funciona perectamente.


# Links de búsqueda

- [Documetación de instalación mysql](https://dev.mysql.com/doc/connector-odbc/en/connector-odbc-installation-binary-deb.html)
- [Instalación de MariaDB ODBC conector](https://www.youtube.com/watch?v=VBAwZ2MlgTc&ab_channel=LinuxHelp)
- [Configuración de ficheros para MariaDB](https://medium.com/linux-tips-101/instalar-y-configurar-conector-odbc-a-base-de-datos-mariadb-en-ubuntu-20-c2d167f01c3d)
- [Paquete .deb de ODBC para la instalación manual](https://downloads.mysql.com/archives/c-odbc/)
