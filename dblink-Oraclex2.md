# Introducción 

Este documento explica cómo establecer una conexión entre dos servidores de bases de datos Oracle en un entorno Debian 12. Además, se detalla la configuración necesaria para aceptar solicitudes desde equipos remotos.

Para lograr esta interconexión, instalaremos un gestor en una segunda máquina, permitiendo así que un cliente pueda acceder a ambas bases de datos de manera simultánea, aunque de forma indirecta. Este proceso es similar a realizar un JOIN entre tablas ubicadas en diferentes servidores, donde los servidores están enlazados. En este esquema, uno de los servidores funcionará como cliente del otro, en una conexión unilateral.

En última instancia, el cliente solo establece una conexión inicial; luego, el primer servidor conectado abrirá una conexión hacia el segundo servidor.

Lo primero que haremos será la instalación de [Oracle sobre nuestro sistema operativo Debian 12](./oracle-debian.md). 

Las máquinas que vamos a usar son las siguientes:

- *oracle-s1*: Conectado a mi red domesticaca en modo puente, con dirección IP *192.168.1.155*
- *oracle-server*: Conectado a mi red domesticaca en modo puente, con dirección IP *192.168.1.144*


Obviamente también se ha hecho las configuraciones pertinentes en ambas máquinas como son las siguientes:

- Permitir conexiones remotas.
- Levnatar el listener.

Todo esto esta detallado en el enlace anterior.

Ya con la configuración hecha correctamente en ambas máquinas, lo que haremo s será abrir uns _consola_ de *sqlplus* en la primera de ellas para así poder gestionar el moto, cambiando con anterioridad al usuario _oracle_,  pues es el único que tiene actualmente definida en sus variables de entorno la ruta a los binarios de Oracle, ejecutando por tanto el comando:

```
root@oracle-s1:/home/andy# su - oracle
oracle@oracle-s1:~$ 

```

Como en este preciso momento estamso haciendo uso del usuerio *oracle* (entrando desde _Root_), ahora si estamos listo para abrir la consola de sqlplus usando el usuario sysdba, ua que es el que cuenta con privilegios para llevar a cabo todas las acciones pertinentes, por lo que meteremos lo siguiente por consola:

```
oracle@oracle-s1:~$ sqlplus / as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Tue Nov 12 12:22:10 2024
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> 

```

PD: Para que nos salga hemos tenido que poner por consola el siguiente comando *STARTUP;*

Como apreciamos por pantalla, la consola sqlplus se ha abierto correctamente y está lista para su uso.

Lo primero que vamos a hacer es definir un nuevo usuario (schema) que pueda hacer uso tanto de la CDB actual como de futuras PDBs que se creen. En este caso, voy a crear un usuario común (common user) de nombre “*C##and1*” y cuya contraseña sea también “*and1*” (Si fuera un caso real se usarían credenciales más seguras, si no estaría en la calle). Para ello, haremos uso de la instrucción:

```
SQL> CREATE USER C##and1 IDENTIFIED BY and1;

Usuario creado.

```

Una vez que lo hayamos generado, le vamos a dar privilegios para poder rabajar sin ningún tipo de restricciones (en la fomra real, esto no pasaría, habria que ver quien es el usuario y donde va... esto lo veremos más adelante), por lo que será con el siguiente comando:

```
SQL> GRANT ALL PRIVILEGES TO c##and1;

Concesion terminada correctamente.

SQL> 

```

Como ya hemos finalizado con la creación y concesión de permisos para nuestro neuvo usuario, así que lo siguiente será conectarnos a través de el, para ello usaremos el siguiente comando:

```

SQL> DISCONNECT
Desconectado de Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0
SQL> 

```

Y nos conectaremos a nuestro nuevo usuario a través del siguiiente comando:

```
SQL> CONNECT c##and1/and1
Conectado.
SQL> 

```

Como se puede apreciar, la conexión al nuevo usuario se ha realizado exitosamente, por lo que he procedido a crear algunas tablas e insertar una serie de registros, aquí tenemos la [tabla](tabla-oracle.sql) que hemos metido.

Una vez hecho esto procederemos a hacer lo mismo en el servidor oracle, el cual se llama *oracle-server*, el cual van a ser los mismos pasos que en el anterior, pero etsa vez nuestro usuario se llamara "c##and2" con contraseña "and2", para ver el procedimeinto de creación de este usuario pinche [aqui](creacionand2.sql) y la tabla esta pinchado [aquí](tabla-oracle.sql)

Ambas máquinas servidoras se encuentran ya totalmente configuradas, de manera que todo está listo para interconectarlas. Para ello, realizaremos el procedimiento de forma ordenada, configurando primero el enlace de la máquina oracle1 a la máquina oracle2 y posteriormente, a la inversa, ya que dichas conexiones son unidireccionales.

Comprobación de archivo, para que escuchen todas, esto debería de estar en todas las máquinas, que quereamos linkear:

```
oracle@oracle-server:~$ cat /opt/oracle/homes/OraDBHome21cEE/network/admin/listener.ora
# listener.ora Network Configuration File: /opt/oracle/homes/OraDBHome21cEE/network/admin/listener.ora
# Generated by Oracle configuration tools.

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

```

Lo primero que haremos será comprobar la conectividad a la máquina *oracle-s1*, pero no una conectividad normal y corriente como la que nos podría ofrecer el comando *ping*, sino conectividad con el listener de Oracle, para así confirmar que tenemos acceso al puerto 1521. Para ello, haremos uso de tnsping, indicando a su vez la dirección IP de la máquina a la que nos queremos conectar (en este caso, 192.168.1.144):

```
oracle@oracle-s1:~$ tnsping 192.168.1.144

TNS Ping Utility for Linux: Version 21.0.0.0.0 - Production on 12-NOV-2024 13:00:28

Copyright (c) 1997, 2021, Oracle.  All rights reserved.

Used parameter files:
/opt/oracle/homes/OraDBHome21cEE/network/admin/sqlnet.ora

Used HOSTNAME adapter to resolve the alias
Attempting to contact (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=))(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.1.144)(PORT=1521)))
OK (20 msec)

```

Como apreciamos en la última línea de la salida del comando esta *OK* lo cual nos dice que el intento ha sido exitoso en un tiempo de 20ms, ya que ambas máquians estan en mi host físico, por lo que el tiempo de transferencia es muy corto.

# Creación de dblink

Ahora lo que haremos será conectarnos a las bases de datos con nuestros usuario que nos acabamos de crear, tanto "c##and1" , como "c##and2" y haremos lo siguiente.

Ahora tendremos que irnos a este fichero */opt/oracle/homes/OraDBHome21cEE/network/admin/tnsnames.ora*, poner abajo del todo lo que hacia donde queremos sacar la informacion, a continuación pondré el fichero entero modificado:

```
oracle@oracle-s1:~$ cat /opt/oracle/homes/OraDBHome21cEE/network/admin/tnsnames.ora


# tnsnames.ora Network Configuration File: /opt/oracle/homes/OraDBHome21cEE/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

ORCLCDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = oracle-s1)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )

LISTENER_ORCLCDB =
  (ADDRESS = (PROTOCOL = TCP)(HOST = loaclhost)(PORT = 1521))

ORACLE-SERVER =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.1.144)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )
```

Desglose de la parte que se añadio:

```
ORACLE-SERVER =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.1.144)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )
```

- ORACLE-SERVER: Es el alias de la conexión que utilizarás para referenciar esta configuración. Es decir, cada vez que uses este alias, Oracle utilizará la configuración especificada.

- ADDRESS: Define la dirección del servidor al que deseas conectarte:

- PROTOCOL = TCP: Establece que se usará el protocolo TCP.
- HOST = 192.168.1.144: Especifica la dirección IP del servidor al que deseas conectarte (en este caso, 192.168.1.144).
- PORT = 1521: Especifica el puerto en el que Oracle está escuchando (por defecto es el puerto 1521).
- CONNECT_DATA: Define los parámetros de conexión específicos de la base de datos.

- SERVER = DEDICATED: Utiliza una conexión dedicada para el cliente.
- SERVICE_NAME = ORCLCDB: Especifica el nombre del servicio al que te estás conectando, que en este caso es ORCLCDB. Es el servicio de base de datos principal en una configuración de base de datos multitenant.

Una vez hecho esto lo que tenemos que hacer es conectarnos a través de nuestro usuario *oracle* y como *sysdba* y desconectarnos para poder conectarnos con el usuario '*c##and1*':

```
oracle@oracle-s1:~$ sqlplus / as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Tue Nov 12 13:36:52 2024
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> STARTUP;
ORACLE instance started.

Total System Global Area 2499803024 bytes
Fixed Size		    9688976 bytes
Variable Size		  536870912 bytes
Database Buffers	 1946157056 bytes
Redo Buffers		    7086080 bytes
Base de datos montada.
Base de datos abierta.
SQL> DISCONNECT
Desconectado de Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0

SQL> CONNECT c##and1/and1
Conectado.
```
Una vez conectado lo que tendremos que hacer es crear el enlace donde antes lo hemos definido en el fichero *tsname.ora*, y tendremos que hacer mediante la ejecución del siguiente comando:

```
SQL> CREATE DATABASE LINK oracleserverlink
  2  CONNECT TO c##and2 IDENTIFIED BY and2
  3  USING 'oracle-server';

Enlace con la base de datos creado.
```
Donde :

- CREATE DATABASE LINK: Especificamos un nombre identificativo para el enlace.
- CONNECT TO: Indicamos las credenciales de acceso a la base de datos remota.
- USING: Indicamos el nombre del alias de la conexión que previamente hemos definido en el fichero tnsnames.ora.

Mi intencion es mostrar desde este servidor en el que estamos es *oracle-s1* la tabla de *Sectores*, con lo cual veremos si se hizo bien:

```
SQL> SELECT * FROM Sectores@oracleserverlink
  2  ;

IDENTIFICADOR NOMBRE		   UBICACION
------------- -------------------- ---------------
	   10 Marketing 	   Madrid
	   20 Ventas		   Barcelona
	   30 Soporte		   Sevilla
```

Y ahora vamos a proceder a mostarr la tabla *clientes* junto con *Sectores* en una misma consulta, para ello haremos el siguiente comando:

```
SQL> SELECT 
    c.ID, 
    c.Nombre, 
    c.Direccion, 
    c.Telefono, 
    c.FechaRegistro, 
    c.Credito, 
    c.Sector, 
    s.Nombre AS SectorNombre, 
    s.Ubicacion
FROM 
    Clientes c
JOIN 
    Sectores@oracleserverlink s
ON 
    c.Sector = s.Identificador;
  2    3    4    5    6    7    8    9   10   11   12   13   14   15   16  
ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR SECTORNOMBRE 	UBICACION
---------- -------------------- ---------------
C001	  Carlos Benitez Ruiz
Av. de la Paz, 112			 625493014 15/01/22	  1500
	10 Marketing		Madrid

C003	  Juan Pedro Marquez
Paseo del Prado, 77			 644902357 11/03/23	  2200
	10 Marketing		Madrid

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR SECTORNOMBRE 	UBICACION
---------- -------------------- ---------------

C008	  Susana Navas Rubio
Paseo de la Castellana, 5		 679451230 10/09/20	  3900
	10 Marketing		Madrid

C002	  Ana Gomez Pardo
C/ Mayor, 45				 631824589 23/05/21	  5000

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR SECTORNOMBRE 	UBICACION
---------- -------------------- ---------------
	20 Ventas		Barcelona

C006	  Maria Fernanda Perez
C/ Serrano, 19				 655983021 08/07/22	  2800
	20 Ventas		Barcelona

C004	  Lorena Vargas Diaz

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR SECTORNOMBRE 	UBICACION
---------- -------------------- ---------------
C/ Alcala, 9				 617293874 02/12/20	  3500
	30 Soporte		Sevilla

C007	  Alberto Ruiz Calderon
Av. Reina Sofia, 22			 612937546 29/11/21	  1300
	30 Soporte		Sevilla


7 filas seleccionadas.

SQL> 

```

Donde:

- SELECT: Indicamos las columnas que queremos mostrar de la información obtenida, de la forma [tabla].[columna].
- FROM: Hacemos un JOIN de la tabla Clientes que se encuentra en la base de datos local junto a la consulta remota, haciendo uso del enlace que acabamos de generar, para así poder mostrar información de ambas tablas en la misma consulta.
- WHERE: Establecemos la condición del JOIN, que deberá ser aquella columna mediante la cual vamos a unir los registros devueltos. Como es lógico, será el código del departamento, pues es la columna que se repite en ambas tablas.


Parece que la consulta se ha efectuado correctamente y ha proporcionado la información esperada, ya que, como mencioné previamente, ambas máquinas servidoras tienen direcciones dentro de la red local, siendo completamente accesibles entre sí y estando adecuadamente configuradas para permitir esas conexiones.

Otra utilidad que estos enlaces nos aportan es la capacidad de copiar las tablas de un gestor a otro, utilizando el resultado de una consulta simple para crear una tabla a partir de la misma. Por ejemplo, podríamos copiar la tabla Sectores haciendo uso de la siguiente instrucción:

```
SQL> CREATE TABLE Sectores 
  2  AS (SELECT *
  3  FROM Sectores@oracleserverlink);

Tabla creada.

SQL> 

```

En dicha instrucción, hemos realizado una consulta a la tabla Sectores ubicada en la base de datos del servidor *oracle-server*, utilizando la respuesta obtenida para crear una nueva tabla con el mismo nombre, que se almacenará ahora de forma local en el servidor *oracle-s1*, y que podremos empezar a utilizar sin necesidad de recurrir al enlace con el segundo servidor. Si consultamos la nueva tabla generada, obtendremos el siguiente resultado:

```
SQL> SELECT * FROM Sectores;

IDENTIFICADOR NOMBRE		   UBICACION
------------- -------------------- ---------------
	   10 Marketing 	   Madrid
	   20 Ventas		   Barcelona
	   30 Soporte		   Sevilla

SQL> 

```

Como se puede apreciar, el contenido es exactamente el mismo que el existente en la tabla ubicada en el gestor remoto, por lo que podemos concluir que su clonación ha sido efectiva.

El enlace ha funcionado del extremo oracle-s1 al extremo oracle-server, pero como ya sabemos, dichos enlaces son unidireccionales, de manera que si quisiésemos realizar la conexión a la inversa, tendríamos que repetir el mismo procedimiento en la segunda máquina, así que vamos a proceder a ello.

Por lo que ahora voy a hacer un *tnsping* a la dirección de oracl-s1 (192.168.1.155):


```
oracle@oracle-server:~$ tnsping 192.168.1.155

TNS Ping Utility for Linux: Version 21.0.0.0.0 - Production on 12-NOV-2024 14:08:10

Copyright (c) 1997, 2021, Oracle.  All rights reserved.

Used parameter files:
/opt/oracle/homes/OraDBHome21cEE/network/admin/sqlnet.ora

Used HOSTNAME adapter to resolve the alias
Attempting to contact (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=))(ADDRESS=(PROTOCOL=tcp)(HOST=192.168.1.155)(PORT=1521)))
OK (0 msec)

```

Como era de esperar, el intento de conexión con el listener ha sido exitoso una vez más en un tiempo total de 0 ms.

El siguiente paso será modificar el fichero de nombre *tnsnames.ora*, ubicado en *$ORACLE_HOME/network/admin/*, indicando en el mismo una entrada para el nuevo servidor al que se pretende acceder, ejecutando para ello el comando:

```nano /opt/oracle/homes/OraDBHome21cEE/network/admin/tnsnames.ora```

Dentro del mismo, tendremos que definir un nuevo alias para la máquina a la que pretendemos conectarnos, en este caso, para *oracle-s1*. El nombre del mismo no influye, de manera que en mi caso lo llamaré *ORACLE-S1*. El protocolo de conexión será TCP a la dirección *192.168.1.155*, utilizando el puerto por defecto, 1521. Por último, tendremos que indicar el nombre del servicio/base de datos al que queremos conectarnos, que por defecto será ORCLCDB. El resultado final sería:

```
oracle@oracle-server:~$ cat /opt/oracle/homes/OraDBHome21cEE/network/admin/tnsnames.ora
# tnsnames.ora Network Configuration File: /opt/oracle/homes/OraDBHome21cEE/network/admin/tnsnames.ora
# Generated by Oracle configuration tools.

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
```

Una vez hecha la modificación del fichero anteriormente nombrado, nos conectaremos a nuestro usuario '*c##and2*':

```
oracle@oracle-server:~$ sqlplus c##and2/and2

SQL*Plus: Release 21.0.0.0.0 - Production on Tue Nov 12 14:12:41 2024
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Hora de Ultima Conexion Correcta: Mar Nov 12 2024 13:57:25 +01:00

Conectado a:
Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0

SQL> 

```

Crearemos el enlace de la forma como lo hicimos anteriormente:

```
SQL> CREATE DATABASE LINK oracles1link
  2  CONNECT TO c##and1 IDENTIFIED BY and1
  3  USING 'oracle-s1';

Enlace con la base de datos creado.

SQL> 

```

COmo vemos se ha creado el enlace oracles1link ha sido correctamente generado, por lo que vamos a verificar su funcionamiento de dicho enlace, ejecutando para ell una consulta que provenga solo de la base de datos que no contenga este servidor:

```
SELECT * FROM clientes@oracles1link;
```
>[!Warning]
>Si nos da un error es porque clonamso las máquinas, por lo que el lsnrctl status nos fallara.


Y cuyos resultados tenemos en pantalla:

```

SQL> SELECT * FROM clientes@oracle_s1_link;

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------
C001	  Carlos Benitez Ruiz
Av. de la Paz, 112			 625493014 15/01/22	  1500
	10

C002	  Ana Gomez Pardo
C/ Mayor, 45				 631824589 23/05/21	  5000
	20

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------

C003	  Juan Pedro Marquez
Paseo del Prado, 77			 644902357 11/03/23	  2200
	10

C004	  Lorena Vargas Diaz
C/ Alcala, 9				 617293874 02/12/20	  3500

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------
	30

C005	  Miguel Torres Gomez
Av. Libertad, 85			 650281972 14/08/19	  4700
	40

C006	  Maria Fernanda Perez

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------
C/ Serrano, 19				 655983021 08/07/22	  2800
	20

C007	  Alberto Ruiz Calderon
Av. Reina Sofia, 22			 612937546 29/11/21	  1300
	30


ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------
C008	  Susana Navas Rubio
Paseo de la Castellana, 5		 679451230 10/09/20	  3900
	10

C009	  Jose Luis Torres
C/ Gran Via, 65 			 615289430 27/04/18	  5600
	40

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------


9 filas seleccionadas.

SQL> 

```

Ahora haremos la comprobación de que podemos unir las tablas de clienets como la de sectores:

```
SQL> SELECT 
    c.ID AS identificador_cliente,
    c.Nombre AS nombre_cliente,
    c.Direccion AS ubicacion_cliente,
    s.Nombre AS nombre_sector,
    s.Ubicacion AS ubicacion_sector
FROM 
    clientes@oracle_s1_link c
JOIN 
    sectores s
ON 
    c.Sector = s.Identificador;
  2    3    4    5    6    7    8    9   10   11   12  
IDENTIFIC NOMBRE_CLIENTE
--------- ------------------------------
UBICACION_CLIENTE			 NOMBRE_SECTOR	      UBICACION_SECTO
---------------------------------------- -------------------- ---------------
C001	  Carlos Benitez Ruiz
Av. de la Paz, 112			 Marketing	      Madrid

C002	  Ana Gomez Pardo
C/ Mayor, 45				 Ventas 	      Barcelona

C003	  Juan Pedro Marquez
Paseo del Prado, 77			 Marketing	      Madrid


IDENTIFIC NOMBRE_CLIENTE
--------- ------------------------------
UBICACION_CLIENTE			 NOMBRE_SECTOR	      UBICACION_SECTO
---------------------------------------- -------------------- ---------------
C004	  Lorena Vargas Diaz
C/ Alcala, 9				 Soporte	      Sevilla

C006	  Maria Fernanda Perez
C/ Serrano, 19				 Ventas 	      Barcelona

C007	  Alberto Ruiz Calderon
Av. Reina Sofia, 22			 Soporte	      Sevilla


IDENTIFIC NOMBRE_CLIENTE
--------- ------------------------------
UBICACION_CLIENTE			 NOMBRE_SECTOR	      UBICACION_SECTO
---------------------------------------- -------------------- ---------------
C008	  Susana Navas Rubio
Paseo de la Castellana, 5		 Marketing	      Madrid


7 filas seleccionadas.


```

Como era de esperar, la consulta ha vuelto a realizarse sin ningún problema y ha devuelto la información que debería, de manera que vamos a hacer una última prueba, llevando a cabo una copia de la tabla Empleados ubicada en el primero de los servidores, haciendo uso de la siguiente instrucción:


```
SQL> CREATE TABLE Clientes
  2  AS (SELECT * FROM Clientes@oracle_s1_link);

Tabla creada.

```

En dicha instrucción, hemos realizado una consulta a la tabla *Clientes* ubicada en la base de datos del servidor oracle-s1, utilizando la respuesta obtenida para crear una nueva tabla con el mismo nombre, que se almacenará ahora de forma local en el servidor oracle-server, y que podremos empezar a utilizar sin necesidad de recurrir al enlace con el primer servidor. Si consultamos la nueva tabla generada, obtendremos el siguiente resultado:

```
SQL> SELECT * FROM Clientes;

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------
C001	  Carlos Benitez Ruiz
Av. de la Paz, 112			 625493014 15/01/22	  1500
	10

C002	  Ana Gomez Pardo
C/ Mayor, 45				 631824589 23/05/21	  5000
	20

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------

C003	  Juan Pedro Marquez
Paseo del Prado, 77			 644902357 11/03/23	  2200
	10

C004	  Lorena Vargas Diaz
C/ Alcala, 9				 617293874 02/12/20	  3500

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------
	30

C005	  Miguel Torres Gomez
Av. Libertad, 85			 650281972 14/08/19	  4700
	40

C006	  Maria Fernanda Perez

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------
C/ Serrano, 19				 655983021 08/07/22	  2800
	20

C007	  Alberto Ruiz Calderon
Av. Reina Sofia, 22			 612937546 29/11/21	  1300
	30


ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------
C008	  Susana Navas Rubio
Paseo de la Castellana, 5		 679451230 10/09/20	  3900
	10

C009	  Jose Luis Torres
C/ Gran Via, 65 			 615289430 27/04/18	  5600
	40

ID	  NOMBRE
--------- ------------------------------
DIRECCION				 TELEFONO  FECHAREG    CREDITO
---------------------------------------- --------- -------- ----------
    SECTOR
----------


9 filas seleccionadas.

```

Como se puede apreciar, el contenido es exactamente el mismo que el existente en la tabla ubicada en el gestor remoto, por lo que podemos concluir que su clonación ha sido efectiva y que los servidores tienen conectividad entre sí mediante los enlaces creados, sea cual sea el sentido utilizado.