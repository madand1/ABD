# Introducción

En esta ocasión vamos a llevar a cabo una interconexión entre dos servidores *Oracle 21c* y *PostgreSQL* los cuales se situan en máquinas con _sistemas operativos_ *Debian 12*, cuya finalidad será la de permitir el acceso desde un mismo cliente a dos bases de datos distinta, como ya hemos visto con anterioridad en:

- [Conexión entre dos servidores Oracle](dblink-Oraclex2.md)
- [Conexión entre dos servidores PostgreSQL](dblink-Postgres.md)

Esto al igual que anteriormente se hará de manera unilateral, por lo que el primer servidor se conectará es el que después abre la conexión al segundo de ellos.

Para esta demostración voy a usar dos máquinas que ya tenia hecha, de la interconexion entre las misma maquinas:

- [Interconexión entre servidores PostgreSQL](./dblink-Postgres.md)
- [Interconexión entre servidores Oracle](./dblink-Oraclex2.md)

Aunque si teneis duda de la instalación por aqui os dejo los links de instalación:

- [Instalación de servidor PostgreSQL en Debian 12](./Postgres.md)
- [Intalación de servidor Oracle en Debian 12](./oracle-debian.md)

Las máquinas que voy a usar son las siguientes:

- *Oracle-server* cuya dirección es:*192.168.1.144*
- *servidores* cuya dirección es:*192.168.1.159*

Estas direcciones de ip son las que tengo al estar trabajando desde mi hogar, por lo que tengo este direccionamiento.

# Oracle 21c a PostgreSQL

Como hemos visto antes tanto los servidores de Oracle estan preparados ya de serie para hacer interconexiones entre estas mismas, pero, *¿que pasa cuando una parte de bases de datos esta por ejemplo en PostgreSQL?*

Pues para este caso vamos a hacer uso de *ODBC* _(Open Database Connectivity)_, el cual es un estándar de acceso a las bases de datos cuyo objetivo ese hacer posible el acceso a cualquier dato desde cualquier apliocacion, sin importar el sistema de bases de datos donde se almacenen los datos. 

Para esta ocasión, vamos a configurar un enlace a una base de datos *PostgreSQL*, sin embargo, es posible realizar una integración con muchos otros gestores como *MySQL* e incluso gestores no relacionales como *Redis*.

El primer paso será instalar los paquetes necesarios para crear el enlace, específicamente el paquete unixODBC, que es un proyecto de código abierto que implementa la API ODBC mencionada anteriormente.

Además, dado que queremos establecer un enlace con un servidor PostgreSQL, deberemos instalar el controlador específico para ello, llamado *postgresql-odbc*. Antes de hacerlo, aseguraremos que todos los paquetes en la máquina estén actualizados a su última versión ejecutando el siguiente comando:

```andy@oracle-server:~$ sudo apt install odbc-postgresql unixodbc -y```

Cuando la instalación de los paquetes haya finalizado, procederemos a modificar el fichero */etc/odbcinst.ini*, en el que encontraremos la configuración de todos los drivers de ODBC existentes, haciendo para ello uso del comando:

```andy@oracle-server:~$ sudo nano /etc/odbcinst.ini```

Y en él tendremos que modificar el fichero dejando los parametros de configuración de la siguiente manera:

```
andy@oracle-server:~$ cat /etc/odbcinst.ini 
[PostgreSQL ANSI]
Description=PostgreSQL ODBC driver (ANSI version)
Driver=psqlodbca.so
Setup=libodbcpsqlS.so
Debug=0
CommLog=1
UsageCount=1

[PostgreSQL Unicode]
Description=PostgreSQL ODBC driver (Unicode version)
Driver=psqlodbcw.so
Setup=libodbcpsqlS.so
Debug=0
CommLog=1
UsageCount=1
```

En el momento en el que ya hallamos configurado el fichero procederemos a configurar el segundo fichero que se encuentra en el directorio */etc/odbc.ini* y lo mismo que con el fichero anterior, procederemos a realizar la configuración dejando como resultado lo que aparece a continuación:

```
andy@oracle-server:~$ cat /etc/odbc.ini 
[PSQLU]
Debug           = 0
CommLog         = 0
ReadOnly        = 0
Driver          = PostgreSQL 
Servername      = 192.168.1.159
Username        = and2
Password        = and2
Port            = 5432
Database        = prueba_inter
Trace           = 0
TraceFile       = /tmp/sql.log


```
Cuando ya hallamos configurado los dos ficheros anteriores  podremos comprobar que la configuración se ha realizado correctamente con los dos siguientes comando. Si muestra el siguiente contenido quiere decir que la configuración se ha realizado correctamente.

Para ello tebnemos que meter por la consola lo siguiente:

```
andy@oracle-server:~$  odbcinst -q -d
```

Y si nos muestra por consola lo siguiente es que hicimos la configuracióon correctamente:

```
andy@oracle-server:~$  odbcinst -q -d
[PostgreSQL ANSI]
[PostgreSQL Unicode]

```
Si introducimos este segundo comando ```odbcinst -q -s``` comprueba si el fichero *odbc.ini* ha sido configurado correctamente.

```
ndy@oracle-server:~$ odbcinst -q -s 
[PSQLU]
andy@oracle-server:~$ 

```

Como podemos observar lo tenemos bien configurado.


Por lo que una vez que hallamos realizado estas comprobaciones de la sintaxis de los ficheros de configuración que hicimos con anterioridad, vamos a hacer una prueba de conexión, con el siguiente comando:


```
andy@oracle-server:~$ isql -v PSQLU
```

Como nos muestra por pantalla lo que nos muestra es lo siguiente:

```
andy@oracle-server:~$ isql -v PSQLU
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| echo [string]                         |
| quit                                  |
|                                       |
+---------------------------------------+
SQL> 

```

Como se puede apreciar en la salida del comando ejecutado, la conexión ha sido exitosa y actualmente nos encontramos haciendo uso de un cliente en el que podríamos ejecutar órdenes SQL, como por ejemplo listar el contenido de la tabla *Sectores*, haciendo para ello uso de la instrucción:

```
SQL> Select * From Sectores;
+--------------+---------------------+----------------+
| identificador| nombre              | ubicacion      |
+--------------+---------------------+----------------+
| 10           | Marketing           | Madrid         |
| 20           | Ventas              | Barcelona      |
| 30           | Soporte             | Sevilla        |
| 40           | Desarrollo          | Valencia       |
+--------------+---------------------+----------------+
SQLRowCount returns 4
4 rows fetched
SQL> 

```

Efectivamente, la información devuelta concuerda con la almacenada en dicha tabla remota, de manera que podremos salir del cliente ejecutando la instrucción exit para así continuar con la configuración del enlace.

Como anteriormente hemos mencionado, la configuración del driver ha finalizado, sin embargo, Oracle no está todavía configurado para poder utilizar dicho driver, por lo que el siguiente paso consistirá en generar un fichero en el que se especifiquen determinados parámetros necesarios para ello (Heterogeneous Services).

andy@oracle-server:~$ sudo nano /opt/oracle/product/21c/dbhome_1/hs/admin/initPSQLU.ora 

```
            
# needed for the Database Gateway for ODBC

#
# HS init parameters
#
HS_FDS_CONNECT_INFO = <odbc data_source_name>
HS_FDS_TRACE_LEVEL = <trace_level>
HS_FDS_SHAREABLE_NAME = <full path name of odbc driver manager or driver>

#
# ODBC specific environment variables
#
set ODBCINI=<full path name of the odbc initilization file>


#
# Environment variables required for the non-Oracle system
#
set <envvar>=<value>

```

Y se va a quedar asi:

```
HS_FDS_CONNECT_INFO = PSQLU
HS_FDS_TRACE_LEVEL = DEBUG
HS_FDS_SHAREABLE_NAME = /usr/lib64/psqlodbcw.so
HS_LANGUAGE = AMERICAN_AMERICA.WE8ISO8859P1
set ODBCINI=/etc/odbc.ini

```
Como se puede apreciar, dentro del mismo hemos definido determinados parámetros como el nombre del DSN, el driver que debe utilizar que habrá sido previamente especificado en el fichero /etc/odbcinst.ini, el fichero en el que se encuentran definidos los DSN...

```

oracle@oracle-server:~$ cat /opt/oracle/product/21c/dbhome_1/network/admin/listerner.ora 
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
      (SID_DESC =
         (SID_NAME = PSQLU)
         (ORACLE_HOME = /opt/oracle/product/21c/dbhome_1)
         (PROGRAM = dg4odbc)
      )
  )

```

El siguiente paso será modificar el fichero de nombre tnsnames.ora, ubicado en $ORACLE_HOME/network/admin/, que permite facilitar la tarea de acceso a servidores remotos, indicando en el mismo una entrada por cada uno de los servidores a los que se pretende acceder, que en este caso nos servirá para “mapear” la conexión hacia el driver ODBC. Su configuración no es para nada complicada, así que vamos a llevarla a cabo ejecutando para ello el comando:

```
andy@oracle-server:~$ cat /opt/oracle/product/21c/dbhome_1/network/admin/tnsnames.ora
ORCLCDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = oracle-server)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )

LISTENER_ORCLCDB =
  (ADDRESS = (PROTOCOL = TCP)(HOST = oracle-server)(PORT = 1521))

ORACLE-S1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.1.155)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )
PSQLU  =
  (DESCRIPTION=
    (ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521))
    (CONNECT_DATA=(SID = PSQLU))
    (HS=OK)
  )
andy@oracle-se
```

En el momento en el que ya lo tengamos todo configurado guardaremos los cambios y para que se aplique esta configuración procederemos a reiniciar el listener de oracle para que vuelva a leer y de esta manera lea la nueva configuración, con los siguientes comandos:


```
oracle@oracle-server:~$ lsnrctl stop
oracle@oracle-server:~$ lsnrctl start
```

Aqui vemos lo que nos saldrá por consola, con los comandos anteriores:

```
oracle@oracle-server:~$ lsnrctl stop

LSNRCTL for Linux: Version 21.0.0.0.0 - Production on 14-NOV-2024 13:10:42

Copyright (c) 1991, 2021, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=0.0.0.0)(PORT=1521)))
The command completed successfully

```

```
oracle@oracle-server:~$ lsnrctl start

LSNRCTL for Linux: Version 21.0.0.0.0 - Production on 14-NOV-2024 14:51:59

Copyright (c) 1991, 2021, Oracle.  All rights reserved.

Starting /opt/oracle/product/21c/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 21.0.0.0.0 - Production
System parameter file is /opt/oracle/homes/OraDBHome21cEE/network/admin/listener.ora
Log messages written to /opt/oracle/diag/tnslsnr/oracle-server/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle-server)(PORT=1521)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-server)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 21.0.0.0.0 - Production
Start Date                14-NOV-2024 14:51:59
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/homes/OraDBHome21cEE/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/oracle-server/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle-server)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
Services Summary...
Service "PSQLU" has 1 instance(s).
  Instance "PSQLU", status UNKNOWN, has 1 handler(s) for this service...
The command completed successfully

```
Creando un *dblink*:

```
oracle@oracle-server:~$ sqlplus c##and2/and2

SQL*Plus: Release 21.0.0.0.0 - Production on Thu Nov 14 13:12:27 2024
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Hora de Ultima Conexion Correcta: Mar Nov 12 2024 14:44:43 +01:00

Conectado a:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0

SQL> CREATE DATABASE LINK postgreslink
  2  CONNECT TO "and2" IDENTIFIED BY "and2"
  3  USING 'PSQLU';

Enlace con la base de datos creado.
```

Y cuando lo ejecutemos nos saldrá lo siguiente por pantalla:

```
racle@oracle-server:~$ sqlplus c##and2/and2

SQL*Plus: Release 21.0.0.0.0 - Production on Fri Nov 15 14:40:59 2024
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Hora de Ultima Conexion Correcta: Vie Nov 15 2024 12:17:01 +01:00

Conectado a:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0

SQL> select * from sectores@postgresconnect;
select * from sectores@postgresconnect
                       *
ERROR en linea 1:
ORA-28500: la conexion de ORACLE a un sistema no Oracle ha devuelto este
mensaje:
ORA-02063: line precediendo a POSTGRESCONNECT
```

⚠️ **¡Atención!**  
>Este es un problema en el que aún no hay solución para la versión con la que estoy trabajando por lo que lo mejor será bajar la versión en este caso a Oracle 19c, para que esto funcione, por lo que procederé a la instalación, y su configuración.

# Instalación de Oracle 19c sobre sistema Operativo Debian 12

Como estamos usando una versión de oracle 21, esta nos esta fallando, por lo que he decidio hacerlo en oracle 19c, he procedido a la instalación al igual que en la 21, pero ajustando ciertos parametros, los cuales os dejo por aqui al igual que anteriormente os comente la instalación se hara exactamente que con oracle 21c, a diferencias de dos errores que antes no nos aparecian, como son:

## Error [FATAL] [DBT-50000] No se ha podido comprobar la memoria disponible

El cual se arregla, copiando el siguiente [script](dbt-5000.md), la dirección: */etc/init.d/oracledb_ORCLCDB-19c*


# Oracle 19c a PostgreSQL

Una vez que tenemos todo esto listo, lo que haremos al igual que antes será isntalar:

```
sudo apt install odbc-postgresql unixodbc -y
```

Y hacer lo siguiente:

```
root@madand1:~# sudo find / -name odbcinst.ini
/etc/odbcinst.ini
root@madand1:~# sudo find /usr -name psqlodbcw.so
/usr/lib/x86_64-linux-gnu/odbc/psqlodbcw.so
root@madand1:~# sudo find /usr -name libodbcpsqlS.so
root@madand1:~# dpkg -l | grep odbc
ii  libodbc2:amd64               2.3.11-2+deb12u1               amd64        ODBC Driver Manager library for Unix
ii  libodbcinst2:amd64           2.3.11-2+deb12u1               amd64        Support library for accessing ODBC configuration files
ii  odbc-postgresql:amd64        1:13.02.0000-2+b1              amd64        ODBC driver for PostgreSQL
ii  odbcinst                     2.3.11-2+deb12u1               amd64        Helper program for accessing ODBC configuration files
ii  unixodbc                     2.3.11-2+deb12u1               amd64        Basic ODBC tools
ii  unixodbc-common              2.3.11-2+deb12u1               all          Common ODBC configuration files

```
Que lo que he hecho ha sido buscar donde se alojan mis ficheros para tener la configuración oportuna, por lo que mi fichero */etc/odbcinst.ini* quedará de la siguiente manera:

```
root@madand1:~# cat /etc/odbcinst.ini 
[PostgreSQL]
Description     = ODBC for PostgreSQL
Driver          = /usr/lib/x86_64-linux-gnu/odbc/psqlodbcw.so
Setup           = /usr/lib/x86_64-linux-gnu/odbc/libodbcpsqlS.so
Driver64        = /usr/lib/x86_64-linux-gnu/odbc/psqlodbcw.so
Setup64         = /usr/lib/x86_64-linux-gnu/odbc/libodbcpsqlS.so

```
Y el fichero */etc/odbc.ini* quedará de la siguiente manera:
```
root@madand1:~# cat /etc/odbc.ini 
[PSQLU]  #Nombre que le pusismos
Debug           = 0
CommLog         = 0
ReadOnly        = 0
Driver          = PostgreSQL #Vinculado al nombre de los driver que esta en el fichero /etc/odbcinst.ini
Servername      = 192.168.1.153
Username        = andy
Password        = andy
Port            = 5432
Database        = testeo
Trace           = 0
TraceFile       = /tmp/sql.log

```
- Desglose:
  
#### `[PSQLU]`
- **Descripción**: Este es el nombre de la fuente de datos ODBC (DSN, Data Source Name). En este caso, la fuente de datos se llama `PSQLU`.

#### Parámetros de configuración:

- **Debug = 0**  
  **Explicación**: Desactiva el modo de depuración. Si se estableciera a `1`, se activarían los registros detallados para la depuración de problemas de conexión.

- **CommLog = 0**  
  **Explicación**: Desactiva el registro de la comunicación entre el cliente y el servidor de la base de datos. Si se establece en `1`, registra los detalles de la comunicación.

- **ReadOnly = 0**  
  **Explicación**: Indica si la conexión es de solo lectura. `0` significa que la conexión no es de solo lectura, y puedes realizar operaciones de escritura. Si se configurara como `1`, la conexión solo permitiría lecturas.

- **Driver = PostgreSQL**  
  **Explicación**: Especifica el nombre del controlador ODBC que se usará. En este caso, se está usando el controlador de PostgreSQL, que debe estar previamente instalado en el sistema.

- **Servername = 192.168.1.153**  
  **Explicación**: Define la dirección IP o el nombre del host del servidor donde se encuentra la base de datos PostgreSQL.

- **Username = andy**  
  **Explicación**: Nombre de usuario que se usará para autenticarse en el servidor de la base de datos.

- **Password = andy**  
  **Explicación**: Contraseña asociada al nombre de usuario para la autenticación en el servidor de la base de datos.

- **Port = 5432**  
  **Explicación**: Puerto en el que el servidor PostgreSQL está escuchando las conexiones. El puerto por defecto para PostgreSQL es `5432`.

- **Database = testeo**  
  **Explicación**: El nombre de la base de datos a la que se desea conectar en el servidor PostgreSQL.

- **Trace = 0**  
  **Explicación**: Desactiva el registro de trazas detalladas. Si se configurara a `1`, el sistema generaría un archivo de registro con información detallada sobre las operaciones realizadas.

- **TraceFile = /tmp/sql.log**  
  **Explicación**: Especifica la ruta donde se almacenará el archivo de registro de trazas (si se activa el parámetro `Trace = 1`). En este caso, los registros se guardarían en `/tmp/sql.log`.



Ahora haremos una pequeña prueba nos podemos conectar a la base de datos que tenemos en *PostgreSQL,* con el siguiente comando:

```isql PSQLU```

```
root@madand1:~# isql PSQLU
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| echo [string]                         |
| quit                                  |
|                                       |
+---------------------------------------+
SQL> select * from testeo
[ISQL]ERROR: Could not SQLExecute
SQL> select * from empleados
+------------+-----------------------------------------------------------------------------------------------------+------------+---------------------------------------------------+
| id         | nombre                                                                                              | edad       | departamento                                      |
+------------+-----------------------------------------------------------------------------------------------------+------------+---------------------------------------------------+
| 1          | Juan Pérez                                                                                         | 28         | Ventas                                            |
| 2          | María López                                                                                       | 35         | Marketing                                         |
| 3          | Carlos Sánchez                                                                                     | 40         | IT                                                |
| 4          | Laura Gómez                                                                                        | 30         | Recursos Humanos                                  |
+------------+-----------------------------------------------------------------------------------------------------+------------+---------------------------------------------------+
SQLRowCount returns 4
4 rows fetched
SQL> 

```
Y como vemos se ha conseguido conectar a la base de datos de postrgeSQL.

Ahora que hemos configurado el driver, tenemos que modificar la configuración de Oracle para que use ese driver. Para ello, vamos a crear un fichero en *‘$ORACLE_HOME/hs/admin/'*, cuyo nombre será *init[DSN].ora*. Como hemos llamado a n*uestro DSN “PSQLU”*, nuestro fichero se llamará ‘*initPSQLU.ora’*:

```
root@madand1:~# cat /opt/oracle/product/19c/dbhome_1/hs/admin/initPSQLU.ora
# Nuestras

HS_FDS_CONNECT_INFO = PSQLU # El nombre que le hemos puesto en el fichero tnsanme.ora
HS_FDS_TRACE_LEVEL = DEBUG
HS_FDS_SHAREABLE_NAME = /usr/lib/x86_64-linux-gnu/odbc/psqlodbcw.so
HS_LANGUAGE = AMERICAN_AMERICA.WE8ISO8859P1
set ODBCINI=/etc/odbc.ini

```

#### Desglose:

- **HS_FDS_CONNECT_INFO**: Nombre del DSN de ODBC que Oracle utilizará para conectarse a PostgreSQL.
- **HS_FDS_TRACE_LEVEL**: Nivel de registro (logging) que puede ser útil para depurar problemas.
- **HS_FDS_SHAREABLE_NAME**: Ruta al archivo del driver ODBC de PostgreSQL.
- **HS_LANGUAGE**: Idioma y conjunto de caracteres para la conexión.
- **set ODBCINI**: Ubicación del archivo `odbc.ini`, donde se configuran las conexiones ODBC.


Una vez hecho esto, vamos a configurar el listener para que utilice la configuración que acabamos de crear:

```
root@madand1:~# cat /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora 
# listener.ora Network Configuration File: /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
# Generated by Oracle configuration tools.

#Viene por defecto
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = madand1)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

#Esto es lo que tenemos que poner
SID_LIST_LISTENER=
  (SID_LIST=
      (SID_DESC=
         (SID_NAME=PSQLU) # Este nombre lo he puesto por poner, es lo que hay que hacer va puesto en el fichero */etc/odbc.ini*
         (ORACLE_HOME=/opt/oracle/product/19c/dbhome_1)
         (PROGRAM=dg4odbc)
      )
  )

```
Ahora modificaremos el fichero tnsnames.ora, para facilitar la interconexión de los servidores. Añadiremos la siguiente configuración:

```
root@madand1:~# cat /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora 
# tnsnames.ora Network Configuration File: /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

ORCLCDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = madand1)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )

LISTENER_ORCLCDB =
  (ADDRESS = (PROTOCOL = TCP)(HOST = madand1)(PORT = 1521))

# Le tenemos que añadir lo siguiente:
PSQLU  = #El nombre que va cone l fichero de arriba es el que tenemos que usar, como si lo quieres llamar pepe, pero lo hemos cogido del fichero */etc/odbc.ini*
  (DESCRIPTION=
    (ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521))
    (CONNECT_DATA=(SID=PSQLU))
    (HS=OK)
  )

```

Ahora desde el usuario *oracle*, tenemos que hacer lo siguiente:

```
lsnrctl stop

lsnrctl start
```

Ahora lo primero que tenemos que hacer es darle permisos a nuetsro usuario andy, para que pueda *crear DBLink*:

```
oracle@madand1:~$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Nov 15 21:23:40 2024
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> GRANT CREATE DATABASE LINK TO andy;

Concesion terminada correctamente.

SQL> Desconectado de Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
```

Una vez que le he dado permisos, nos conectaremos desde nuestro usuario andy, y lo vamos a crear:

```
oracle@madand1:~$ sqlplus andy/andy

SQL*Plus: Release 19.0.0.0.0 - Production on Fri Nov 15 21:23:51 2024
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Hora de Ultima Conexion Correcta: Vie Nov 15 2024 21:21:33 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> CREATE DATABASE LINK posgrelink
  2  connect to "andy" identified by "andy"
  3  using 'PSQLU';

Enlace con la base de datos creado.
```
```
SQL> select * from "empleados"@posgrelink;

	id
----------
nombre
--------------------------------------------------------------------------------
      edad
----------
departamento
--------------------------------------------------------------------------------
	 1
Juan P??rez
	28
Ventas


	id
----------
nombre
--------------------------------------------------------------------------------
      edad
----------
departamento
--------------------------------------------------------------------------------
	 2
Mar?-a L??pez
	35
Marketing


	id
----------
nombre
--------------------------------------------------------------------------------
      edad
----------
departamento
--------------------------------------------------------------------------------
	 3
Carlos S?!nchez
	40
IT


	id
----------
nombre
--------------------------------------------------------------------------------
      edad
----------
departamento
--------------------------------------------------------------------------------
	 4
Laura G??mez
	30
Recursos Humanos


SQL> 
```

Y como podemos observar se conecta a través del *dblink* que creamos y hemos comprobado que se ve la tabla que nombramos.

# PostgreSQL a Oracle 19c

Como pasa con Oracle, PostrgeSQL no tiene soporte nativo para conexiones con otros gestores de bases de datos, por lo que vamos a usar una herramienta externa. La cual se llama *oracle_fdw*(Foreign Data Wrapper for Oracle).


Esta herramienta también tiene versiones disponibles para otros sistemas de gestión de bases de datos, aunque en este caso nos enfocaremos en Oracle.

El paquete *oracle_fdw* no está disponible de forma predeterminada para Debian 12, por lo que será necesario compilarlo manualmente. Para ello, instalaremos los siguientes paquetes que utilizaremos en el proceso de compilación:.

Para ello lo primero que haremos será usar este comando:

```sudo apt update && apt install libaio1 postgresql-server-dev-all build-essential git -y```

También tendremos que descargarnos los paquetes oficiales de *Oracle Instant Client*, esto nos permitirá hacer uso del cliente Oracle para realizar las conexiones a bases de datos remotas. 

Dejaré por aqui los comandos que he usado:

```
wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basic-linux.x64-21.1.0.0.0.zip

wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sdk-linux.x64-21.1.0.0.0.zip

wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sqlplus-linux.x64-21.1.0.0.0.zip
```

Esto lo haremos con el *usuario postgres*:

```
root@postgreSQL:/home/andy# su - postgres
postgres@postgreSQL:~$ wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basic-linux.x64-21.1.0.0.0.zip
--2024-11-15 23:46:48--  https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basic-linux.x64-21.1.0.0.0.zip
Resolviendo download.oracle.com (download.oracle.com)... 2.21.140.94
Conectando con download.oracle.com (download.oracle.com)[2.21.140.94]:443... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 79250994 (76M) [application/zip]
Grabando a: «instantclient-basic-linux.x64-21.1.0.0.0.zip»

instantclient-basic 100%[===================>]  75,58M  7,52MB/s    en 10s     

2024-11-15 23:47:00 (7,40 MB/s) - «instantclient-basic-linux.x64-21.1.0.0.0.zip» guardado [79250994/79250994]

postgres@postgreSQL:~$ wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sdk-linux.x64-21.1.0.0.0.zip
--2024-11-15 23:47:06--  https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sdk-linux.x64-21.1.0.0.0.zip
Resolviendo download.oracle.com (download.oracle.com)... 2.21.140.94
Conectando con download.oracle.com (download.oracle.com)[2.21.140.94]:443... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 998327 (975K) [application/zip]
Grabando a: «instantclient-sdk-linux.x64-21.1.0.0.0.zip»

instantclient-sdk-l 100%[===================>] 974,93K  6,01MB/s    en 0,2s    

2024-11-15 23:47:08 (6,01 MB/s) - «instantclient-sdk-linux.x64-21.1.0.0.0.zip» guardado [998327/998327]

postgres@postgreSQL:~$ wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sqlplus-linux.x64-21.1.0.0.0.zip
--2024-11-15 23:47:17--  https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sqlplus-linux.x64-21.1.0.0.0.zip
Resolviendo download.oracle.com (download.oracle.com)... 2.21.140.94
Conectando con download.oracle.com (download.oracle.com)[2.21.140.94]:443... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 936169 (914K) [application/zip]
Grabando a: «instantclient-sqlplus-linux.x64-21.1.0.0.0.zip»

instantclient-sqlpl 100%[===================>] 914,23K  5,94MB/s    en 0,2s    

2024-11-15 23:47:19 (5,94 MB/s) - «instantclient-sqlplus-linux.x64-21.1.0.0.0.zip» guardado [936169/936169]

```

Tras esto vamos a listar el contenido del directorio actual para ver que se han descagrados perfectamente:

```
postgres@postgreSQL:~$ ls -l
total 79292
drwxr-xr-x 3 postgres postgres     4096 nov 15 20:49 15
-rw-r--r-- 1 postgres postgres 79250994 dic  1  2020 instantclient-basic-linux.x64-21.1.0.0.0.zip
-rw-r--r-- 1 postgres postgres   998327 dic  1  2020 instantclient-sdk-linux.x64-21.1.0.0.0.zip
-rw-r--r-- 1 postgres postgres   936169 dic  1  2020 instantclient-sqlplus-linux.x64-21.1.0.0.0.zip

```

Como podemos ver se han bajado los ficheros:

- *instantclient-basic-linux.x64-21.1.0.0.0.zip*
- *instantclient-sdk-linux.x64-21.1.0.0.0.zip*
- *instantclient-sqlplus-linux.x64-21.1.0.0.0.zip*

Como podemos ver los paquetes están comprimidos por lo que vamos a proceder  adescromprimirlo y elimiar los *.zip*:

```
postgres@postgreSQL:~$ unzip instantclient-basic-linux.x64-21.1.0.0.0.zip
postgres@postgreSQL:~$ unzip instantclient-sqlplus-linux.x64-21.1.0.0.0.zip
postgres@postgreSQL:~$ unzip instantclient-sdk-linux.x64-21.1.0.0.0.zip

postgres@postgreSQL:~$ rm *.zip

```

Y vemos como lo hemos eliminado, así que lo vamos a verificar:

```
postgres@postgreSQL:~$ ls -l
total 8
drwxr-xr-x 3 postgres postgres 4096 nov 15 20:49 15
drwxr-xr-x 4 postgres postgres 4096 nov 16 00:14 instantclient_21_1

```
Todo el contenido se ha descomprimido correctamente en un directorio llamado instantclient_21_1. Este directorio incluye todos los binarios proporcionados por el cliente de Oracle, incluido el valioso *sqlplus*.

Para verificarlo, podemos listar los ejecutables de dicho directorio, estableciendo un filtro por nombre para no mostrar las librerías compartidas, ejecutando para ello el comando:

```
postgres@postgreSQL:~$ find instantclient_21_1/ -executable -type f | egrep -v '.so.*$'
instantclient_21_1/sdk/ott
instantclient_21_1/sqlplus
instantclient_21_1/adrci
instantclient_21_1/uidrvci
instantclient_21_1/genezi

```

Actualmente, para utilizar cualquiera de esos binarios, sería necesario proporcionar la ruta completa, ya que el sistema no los encontraría por sí solo. Esto se debe a que en Linux existe una variable de entorno llamada PATH ($PATH), que define las rutas donde se buscan los binarios, así como el orden de búsqueda. En este caso, la ruta */home/postgres/instantclient_21_1* no está incluida en dicha variable.

Por lo que vamos a solucionar este problema, que será definiendo las variables de entornos que vamso a necesitar pasa que funcione perfectamente estos binarios, entre las que vamso a encontrar *$ORACLE_HOME*, la cual va a ser la ruta que se encuentra ubicado estos binarios.

Y por último uniremos el valor de dicha variable a *$LD_LIBRARY_PATH* y *PATH*, por lo que tenemos que usar lo siguiente:

```
postgres@postgreSQL:~$ export ORACLE_HOME=/var/lib/postgresql/instantclient_21_1
postgres@postgreSQL:~$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME
postgres@postgreSQL:~$ export PATH=$PATH:$ORACLE_HOME

```

Al haber añadido la nueva ruta a la variable *$PATH*, ya será posible encontrar dicho binario sin indicar su ruta completa, así que vamos a comprobarlo haciendo uso de which, que nos devolverá la ruta en la que se ubica un binario en cuestión, por ejemplo sqlplus, ejecutando para ello el comando:

```
postgres@postgreSQL:~$ which sqlplus 
/var/lib/postgresql/instantclient_21_1/sqlplus

```
Una vez que hemos añadido las rutas, esto nos lo localiza extraordinariamente.

Pero esto que he hecho ha sido de manera temporal, por lo que para hacerlo de manera persistente lo haremos de la siguiente forma:

```
postgres@postgreSQL:~$ nano ~/.bashrc

postgres@postgreSQL:~$ cat ~/.bashrc
# VAriables de entorno

export ORACLE_HOME=/var/lib/postgresql/instantclient_21_1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME
export PATH=$PATH:$ORACLE_HOME

postgres@postgreSQL:~$ source ~/.bashrc
postgres@postgreSQL:~$ which sqlplus 
/var/lib/postgresql/instantclient_21_1/sqlplus

```

Para verificar el correcto funcionamiento del mismo, vamos a llevar a cabo una conexión remota real a la base de datos, como si de una situación normal y corriente se tratase, haciendo para ello uso del comando:

```
postgres@postgreSQL:~$ sqlplus andy/andy@192.168.1.152/ORCLCDB

SQL*Plus: Release 21.0.0.0.0 - Production on Sat Nov 16 00:51:27 2024
Version 21.1.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.

Hora de Ultima Conexion Correcta: Vie Nov 15 2024 21:23:51 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> 

```

⚠️ **¡Atención!** 
> Si no carga lo que tienes qe hacer es hacer source ~./bashrc y listo

Ahora lo que debemos de hacer es descargarnos el fichero ene lq ue se encuentra el *código fuente* de *oracle_fdw*, la dirección es la siguiente:

```
git clone https://github.com/laurenz/oracle_fdw.git
```

Por lo que haremos será clonar el repositorio:

```
postgres@postgreSQL:~$ git clone https://github.com/laurenz/oracle_fdw.git
Clonando en 'oracle_fdw'...
remote: Enumerating objects: 2870, done.
remote: Counting objects: 100% (968/968), done.
remote: Compressing objects: 100% (95/95), done.
remote: Total 2870 (delta 906), reused 917 (delta 873), pack-reused 1902 (from 1)
Recibiendo objetos: 100% (2870/2870), 1.54 MiB | 4.01 MiB/s, listo.
Resolviendo deltas: 100% (2019/2019), listo.

```

Una vez clonado vamos a listar el contenido para verificar si hemos tenido una clonación exitosa:

```
postgres@postgreSQL:~$ ls -l
total 16
drwxr-xr-x 3 postgres postgres 4096 nov 15 20:49 15
drwxr-xr-x 4 postgres postgres 4096 nov 16 00:14 instantclient_21_1
drwxr-xr-x 6 postgres postgres 4096 nov 16 00:55 oracle_fdw
drwxr-xr-x 3 postgres postgres 4096 nov 16 00:50 oradiag_postgres

```

Efectivamente, el repositorio de nombre oracle_fdw ha sido correctamente clonado en nuestra máquina local y podremos empezar a hacer uso del mismo, de manera que nos moveremos dentro dicho directorio para visualizar su contenido, ejecutando para ello el comando:

```
postgres@postgreSQL:~$ cd oracle_fdw/
postgres@postgreSQL:~/oracle_fdw$ 


```

Una vez dentro listamos el contenido existente:

```
postgres@postgreSQL:~/oracle_fdw$ ls -l
total 500
-rw-r--r-- 1 postgres postgres  28436 nov 16 00:55 CHANGELOG
drwxr-xr-x 2 postgres postgres   4096 nov 16 00:55 expected
-rw-r--r-- 1 postgres postgres   1059 nov 16 00:55 LICENSE
-rw-r--r-- 1 postgres postgres   1475 nov 16 00:55 Makefile
drwxr-xr-x 2 postgres postgres   4096 nov 16 00:55 msvc
-rw-r--r-- 1 postgres postgres    231 nov 16 00:55 oracle_fdw--1.0--1.1.sql
-rw-r--r-- 1 postgres postgres    240 nov 16 00:55 oracle_fdw--1.1--1.2.sql
-rw-r--r-- 1 postgres postgres   1244 nov 16 00:55 oracle_fdw--1.2.sql
-rw-r--r-- 1 postgres postgres 229598 nov 16 00:55 oracle_fdw.c
-rw-r--r-- 1 postgres postgres    133 nov 16 00:55 oracle_fdw.control
-rw-r--r-- 1 postgres postgres   9156 nov 16 00:55 oracle_fdw.h
-rw-r--r-- 1 postgres postgres  44511 nov 16 00:55 oracle_gis.c
-rw-r--r-- 1 postgres postgres 104953 nov 16 00:55 oracle_utils.c
lrwxrwxrwx 1 postgres postgres     17 nov 16 00:55 README.md -> README.oracle_fdw
-rw-r--r-- 1 postgres postgres  44112 nov 16 00:55 README.oracle_fdw
drwxr-xr-x 2 postgres postgres   4096 nov 16 00:55 sql
-rw-r--r-- 1 postgres postgres    948 nov 16 00:55 TODO

```

Ahora procederemos a ha hacer la compilación e instalar el resultadoen los directorios correpsondientes, para ello lo primero que haremos sera hacer:

```
postgres@postgreSQL:~/oracle_fdw$ make
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wimplicit-fallthrough=3 -Wcast-function-type -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -I"/var/lib/postgresql/instantclient_21_1/sdk/include" -I"/var/lib/postgresql/instantclient_21_1/oci/include" -I"/var/lib/postgresql/instantclient_21_1/rdbms/public" -I"/var/lib/postgresql/instantclient_21_1/"  -I. -I./ -I/usr/include/postgresql/15/server -I/usr/include/postgresql/internal  -Wdate-time -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -I/usr/include/libxml2   -c -o oracle_fdw.o oracle_fdw.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wimplicit-fallthrough=3 -Wcast-function-type -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -I"/var/lib/postgresql/instantclient_21_1/sdk/include" -I"/var/lib/postgresql/instantclient_21_1/oci/include" -I"/var/lib/postgresql/instantclient_21_1/rdbms/public" -I"/var/lib/postgresql/instantclient_21_1/"  -I. -I./ -I/usr/include/postgresql/15/server -I/usr/include/postgresql/internal  -Wdate-time -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -I/usr/include/libxml2   -c -o oracle_utils.o oracle_utils.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wimplicit-fallthrough=3 -Wcast-function-type -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -I"/var/lib/postgresql/instantclient_21_1/sdk/include" -I"/var/lib/postgresql/instantclient_21_1/oci/include" -I"/var/lib/postgresql/instantclient_21_1/rdbms/public" -I"/var/lib/postgresql/instantclient_21_1/"  -I. -I./ -I/usr/include/postgresql/15/server -I/usr/include/postgresql/internal  -Wdate-time -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -I/usr/include/libxml2   -c -o oracle_gis.o oracle_gis.c
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wimplicit-fallthrough=3 -Wcast-function-type -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -shared -o oracle_fdw.so oracle_fdw.o oracle_utils.o oracle_gis.o -L/usr/lib/x86_64-linux-gnu  -Wl,-z,relro -Wl,-z,now -L/usr/lib/llvm-14/lib  -Wl,--as-needed  -L"/var/lib/postgresql/instantclient_21_1/" -L"/var/lib/postgresql/instantclient_21_1/bin" -L"/var/lib/postgresql/instantclient_21_1/lib" -L"/var/lib/postgresql/instantclient_21_1/lib/amd64"  -lclntsh 


postgres@postgreSQL:~/oracle_fdw$ sudo make install
[sudo] contraseña para postgres: 
/bin/mkdir -p '/usr/lib/postgresql/15/lib'
/bin/mkdir -p '/usr/share/postgresql/15/extension'
/bin/mkdir -p '/usr/share/postgresql/15/extension'
/bin/mkdir -p '/usr/share/doc/postgresql-doc-15/extension'
/usr/bin/install -c -m 755  oracle_fdw.so '/usr/lib/postgresql/15/lib/oracle_fdw.so'
/usr/bin/install -c -m 644 .//oracle_fdw.control '/usr/share/postgresql/15/extension/'
/usr/bin/install -c -m 644 .//oracle_fdw--1.2.sql .//oracle_fdw--1.0--1.1.sql .//oracle_fdw--1.1--1.2.sql  '/usr/share/postgresql/15/extension/'
/usr/bin/install -c -m 644 .//README.oracle_fdw '/usr/share/doc/postgresql-doc-15/extension/'


```


Después de que el resultado de la compilación se haya instalado correctamente en los directorios locales de PostgreSQL, podremos utilizar la extensión. No obstante, en mi caso, aunque las variables de entorno estaban configuradas correctamente, el gestor no podía localizar las bibliotecas compartidas de Oracle. Por lo tanto, fue necesario especificar explícitamente la ruta a estas bibliotecas en un archivo llamado oracle.conf dentro de /etc/ld.so.conf.d/, utilizando el siguiente comando:

```
postgres@postgreSQL:~/oracle_fdw$ echo '/var/lib/postgresql/instantclient_21_1' | sudo tee /etc/ld.so.conf.d/oracle.conf
/home/postgres/instantclient\_21\_1
```
Si vemos como ha quedado el fichero:

```
postgres@postgreSQL:~/oracle_fdw$ cat  /etc/ld.so.conf.d/oracle.conf
/var/lib/postgresql/instantclient_21_1

```

Por último, tendremos que generar los enlaces necesarios y cargar en memoria las nuevas librerías compartidas que hemos introducido, de manera que ejecutaremos el comando:

```
postgres@postgreSQL:~/oracle_fdw$ sudo ldconfig 

```

Toda la configuración necesaria ha finalizado, pues únicamente faltaría generar el correspondiente enlace y empezar a hacer uso del mismo. Para ello, abriremos una shell de psql haciendo uso de la base de datos testeo desde el usuario actual, pues es el que cuenta con los privilegios necesarios para crear dicho enlace, haciendo para ello uso del comando:

```
postgres@postgreSQL:~/oracle_fdw$ psql -d testeo
psql (15.9 (Debian 15.9-0+deb12u1))
Digite «help» para obtener ayuda.

testeo=# 

```

Es muy importante que la conexión se realice a la base de datos andy, ya que es donde el rol andy tiene privilegios, pues de lo contrario, no podría utilizar dicho enlace. La creación del mismo es muy sencilla, llevándose a cabo mediante la ejecución del comando:

```
postgres@postgreSQL:~/oracle_fdw$ psql -d testeo
psql (15.9 (Debian 15.9-0+deb12u1))
Digite «help» para obtener ayuda.

testeo=# CREATE EXTENSION oracle_fdw;
CREATE EXTENSION
testeo=# 

```
La extensión que hará la función de enlace ya ha sido creada, pero para verificarlo, vamos a listar todas las extensiones existentes, haciendo para ello uso de la instrucción:

```
testeo=# \dx
                     Listado de extensiones instaladas
   Nombre   | Versión |  Esquema   |              Descripción               
------------+---------+------------+----------------------------------------
 oracle_fdw | 1.2     | public     | foreign data wrapper for Oracle access
 plpgsql    | 1.0     | pg_catalog | PL/pgSQL procedural language
(2 filas)

testeo=# 

```

Efectivamente, la extensión *oracle_fdw* ha sido correctamente generada, por lo que el siguiente paso consistirá en crear un nuevo esquema (schema) al que posteriormente importaremos las tablas de la base de datos Oracle remota. Para ello, utilizaremos la instrucción:

```
testeo=# CREATE SCHEMA oracle_prueba2;
CREATE SCHEMA
```

Nuestro esquema de nombre oracle ya ha sido generado, sin embargo, se encuentra actualmente vacío. Para llevar a cabo la importación de dichas tablas, tendremos que definir un nuevo servidor remoto que utilice la extensión que acabamos de generar, especificando, como es lógico, la dirección IP y la base de datos a la que pretendemos acceder, de la siguiente forma:

```
testeo=# CREATE SERVER oracle_prueba2 FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver '//192.168.1.152/ORCLCDB');
CREATE SERVER
```

Sin embargo, definir un servidor remoto no es suficiente para acceder al mismo, ya que necesitamos “mapear” nuestro usuario local a un usuario existente en dicho gestor remoto que cuente con los privilegios necesarios para visualizar las tablas.

En este caso, vamos a “mapear” el usuario local andy(postgre) al usuario remoto c##and1, indicando a su vez las credenciales del mismo, ejecutando para ello la instrucción:

```
testeo=# CREATE USER MAPPING FOR andy SERVER oracle_prueba2 OPTIONS (user 'c##and1', password 'and1');
CREATE USER MAPPING
```

Dado que estas configuraciones las hemos llevado a cabo como un usuario administrador de la base de datos, tendremos que otorgar los privilegios necesarios al usuario andy para utilizar tanto el nuevo esquema generado como el servidor remoto definido, haciendo para ello uso de las instrucciones:

```
testeo=# GRANT ALL PRIVILEGES ON SCHEMA oracle_prueba2 TO andy;
GRANT
testeo=# GRANT ALL PRIVILEGES ON FOREIGN SERVER oracle_prueba2 TO andy;
GRANT


```
La configuración como administrador ha finalizado, de manera que podremos salir del cliente ejecutando la instrucción exit para así realizar una nueva conexión a la base de datos testeo pero haciendo uso esta vez del rol andy, y así verificar que puede utilizar dicho enlace, ejecutando para ello el comando:

```
postgres@postgreSQL:~$ psql -h localhost -U andy -d testeo
Contraseña para usuario andy: 
psql (15.9 (Debian 15.9-0+deb12u1))
Conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, compresión: desactivado)
Digite «help» para obtener ayuda.

testeo=> 

```

Para verificar que el enlace funciona correctamente, vamos a proceder a importar las tablas existentes en el esquema remoto c##and1 a nuestro nuevo esquema local de nombre oracle, haciendo para ello uso del comando:

```
testeo=> IMPORT FOREIGN SCHEMA "C##AND1" FROM SERVER oracle_prueba2 INTO oracle_prueba2;
IMPORT FOREIGN SCHEMA

```

Listo, según la salida que dicha instrucción nos ha devuelto, el esquema ha sido correctamente importado, de manera que ya podremos hacer uso de las tablas existentes en nuestro esquema public por defecto y del nuevo que hemos generado, de nombre oracle, que contiene las tablas del gestor remoto Oracle ubicado en el servidor oracle19.


Ahora si hacemos una consulta nos deberia de aparecer por pantalla:

```
testeo=> SELECT * FROM oracle_prueba2.Sectores;
 identificador |  nombre   | ubicacion 
---------------+-----------+-----------
            10 | Marketing | Madrid
            20 | Ventas    | Barcelona
            30 | Soporte   | Sevilla
(3 filas)

```

Como podemos apreciar el contenido es exactmante el mimso al que hicimos con anterioridad,por lo que esta perfectamente hecho.

