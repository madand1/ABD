# Movimiento de datos

## Introducción 

Los sistemas de gestión de bases de datos (SGBD) permiten almacenar y administrar grandes volúmenes de datos de manera eficiente. Es crucial que los administradores conozcan las herramientas para importar y exportar datos, así como sus distintas opciones. 

En esta práctica, vamos a enfocaremos en la transferencia de datos entre bases de datos relacionales y las herramientas disponibles para ello.

Para esta práctica, hay que usar el usuario scott, pero en mi caso scott ha muerto por lo que en su lugar voy a usar a **Byron**, el cual tiene las mismas cosas que Scott, por lo que usare a Byron para realizar las operaciones tantos de exportación com de importación.

Aquí dejo el como conectarnos:

```sql
oracle@madand1:~$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Tue Feb 25 17:14:42 2025
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> connect C###BYRON/BYRON
Conectado.

```

Y vemos sus tablas:

```sql
SQL> SELECT TABLE_NAME FROM ALL_TABLES WHERE OWNER = 'C###BYRON';

TABLE_NAME
--------------------------------------------------------------------------------
DEPT
EMP
SALGRADE
BONUS
DEPT_VIEW
EMP_VIEW

6 filas seleccionadas.
```
Una vez que tenemos esto, podemos seguir con la finalidad de dicha práctica.

---
## Ejercicio 1

Realiza una exportación del esquema de C###BYRON usando Oracle Data Pump con las siguientes condiciones:
• Exporta tanto la estructura de las tablas como los datos de las mismas.
• Excluye la tabla BONUS y los departamentos con menos de dos empleados.
• Realiza una estimación previa del tamaño necesario para el fichero de exportación.
• Programa la operación para dentro de 2 minutos.
• Genera un archivo de log en el directorio raíz.

Antes de poder realizar una exportación, lo que debemos de hacer es concederle al dueño de la bade de datos los permisos pertinentes para dicha exportación.

Por lo que para esta exportación, lo que debo de hacer es crear un directorio donde se almacenarán los archivos de exportación.

![1](1-1.png)

Ahora una vez creado lo que tenemos que hacer es ponerlo para que nuestro usuario `oracle` pueda acceder a este directorio que acabamos de crear.

` chown oracle:oinstall /opt/oracle/export`

![2](2.png)

AHora lo que tenemos que hacer e sconectarnos aa la base de datos y crerar lo que será el directorio en el que se van a almacenar todos los archivos de la exportación, a este le vamos a asiganr todo los permisos para que se puedan acceder a él.

Por lo que quedaría así:

```sql
CREATE DIRECTORY EXPORT_DB AS '/opt/oracle/export/';
GRANT READ, WRITE ON DIRECTORY EXPORT_DB TO C###BYRON;
```

![3](3-1.png)

AHora lo que haremos sera otorgarle permisos al usuario `C###BYRON` de que puedan exportar los datos.

```sql
GRANT DATAPUMP_EXP_FULL_DATABASE TO C###BYRON;
```

![4](4-1.png)

Ahora lo que deberia de pasar es esportar lo que es todo de `C###BYRON` usando lo que sería Oracle Data Pump con todo lo que ha dicho el en el enunciadO por lo que vamos a usar el siguiente comando, obviamente esto se hara desde la terminal de Oracle:


```bash 
    expdp C###BYRON/BYRON DIRECTORY=EXPORT_DB SCHEMAS=C###BYRON EXCLUDE=TABLE:\"=\'BONUS\'\"  QUERY=dept:'"WHERE deptno IN \(SELECT deptno FROM EMP GROUP BY deptno HAVING COUNT\(*\)>2\)"'
```

Donde:

- `C###BYRON/BYRON`: Son las credenciales
- `DIRECTORY=EXPORT_DB`: Directorio donde debe apuntar a la ubicación en el sistema de archivos donde el usuario pueda escribir los archivos exportados.
- `SCHEMAS=C###BYRON`: Especifivo que voy a aexportar.
- `EXCLUDE=TABLE:\"=\'BONUS\'\":`estp es que estoy exluyendo lo la tabla bonus de esta exportación, por la condición del enunciado.
- `QUERY`: Es la clausula para filtrar los datos de la tabla `DEPT`.

Si lo vemos por pantalla, veriamos lo siguiente:

![5](5-1.png)

Lo que no hice fue la condicion de que la exportación sea tra cierto tiempo en este caso 2 minutos, pero eso tiene cierto arreglo, ya que se podríamos hacerlo modificando lo que pusimos, o bien a través de un script, pero yo os voy a dejar lo que es el comando:

```bash

sleep 120 && rm -f /opt/oracle/export/expdat.dmp && expdp C###BYRON/BYRON DIRECTORY=EXPORT_DB SCHEMAS=C###BYRON EXCLUDE=TABLE:\"=\'BONUS\'\"  QUERY=dept:'"WHERE deptno IN \(SELECT deptno FROM EMP GROUP BY deptno HAVING COUNT\(*\)>2\)"'
```

Donde:

- `sleep 120`: Es la suma de todos los segundos de dos minutos, si quisieramos tardar 5 min seria sleep 300.


![6](6-1.png)

POr lo que voy a demostarr que se puede por timepo, ya que si hacemos de nuevo la exportación esta se va a sobreescribir, por lo que os dejo por aqui la demostración, pero tenemos uno que es el mismo nomre, podriamos borrarlo antes:

![7](7.png)

---
## Ejercicio 2

### Importa el fichero obtenido anteriormente usando Oracle Data Pump pero en un usuario distinto de la misma base de datos.

Para hacer realidad la importación, lo que debemos de hacer es darle permisos de lectura y escritura al usuario al que vamos a improatr la base de datos, al directorio donde se almacenán los archivos de importación.

Nuestro conejillo de indias será `C###ZEUS`, este tiene esta contraseña:

```sql
CREATE USER C###ZEUS IDENTIFIED BY ZEUS;

```

Por lo que lo acabamos de crear, y este esta vacío, por lo que muestro por pantalla que no tiene nada:

![alt text](8.png)

Ahora como estamos como `SYSDBA` vamos como dije antes a darle permisos de lectura y escritura a `C###ZEUS`, y permisos para la importación.

```sql
GRANT READ, WRITE ON DIRECTORY EXPORT_DB TO C###ZEUS;
GRANT IMP_FULL_DATABASE TO C###ZEUS;
```

![9](9.png)

Y ahoa lo qu ehacenos es importar la base de datos, que anteriormente exportamos, al igual que antes lo debemos de hacer en el usuario oracle.


```bash
impdp C###ZEUS/ZEUS schemas=C###BYRONdirectory=EXPORT_DB dumpfile=expdat.dmp logfile=impdat.log table_exists_action=replace
```

Antes de ejecutar esto, lo que he tenido que hacer es otorgar permisos correctos a lo que es el fichero `expdat.dmp`, por lo que ejecute esto:

```bash
chmod 644 /opt/oracle/export/expdat.dmp
```
Y luego ejecute esto, para verificar los permisos:

```bash
ls -l /opt/oracle/export/expdat.dmp
```
Y ahora si a ejecutar:

![11](11.png)

COmo podemos ver ha ido de locos, y se realizo correctamente, pero ahora vamos una vez hecho esto, lo que voy a hacer es entrar como `C###ZEUS`, y hacer unas consultas.

![12](12.png)

Para comprobar que se hizo todo correcto podemos ver los logs que se han hecho, que son los de exportación como los de importación:

- Logs de importación:

```bash
oracle@madand1:/opt/oracle/export$ cat impdat.log 
;;; 
Import: Release 19.0.0.0.0 - Production on Tue Feb 25 18:34:53 2025
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
;;; 
Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
La tabla maestra "C###ZEUS"."SYS_IMPORT_SCHEMA_01" se ha cargado/descargado correctamente
Iniciando "C###ZEUS"."SYS_IMPORT_SCHEMA_01":  C###ZEUS/******** schemas=C###BYRON directory=EXPORT_DB dumpfile=expdat.dmp logfile=impdat.log table_exists_action=replace 
Procesando el tipo de objeto SCHEMA_EXPORT/SYSTEM_GRANT
Procesando el tipo de objeto SCHEMA_EXPORT/ROLE_GRANT
Procesando el tipo de objeto SCHEMA_EXPORT/DEFAULT_ROLE
Procesando el tipo de objeto SCHEMA_EXPORT/TABLESPACE_QUOTA
Procesando el tipo de objeto SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/TABLE
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/TABLE_DATA
. . "C###BYRON"."DEPT"                          6.007 KB       3 filas importadas
. . "C###BYRON"."DEPT_VIEW"                         0 KB       0 filas importadas
. . "C###BYRON"."EMP"                           8.781 KB      14 filas importadas
. . "C###BYRON"."EMP_VIEW"                          0 KB       0 filas importadas
. . "C###BYRON"."SALGRADE"                      6.101 KB       5 filas importadas
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/CONSTRAINT/REF_CONSTRAINT
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Procesando el tipo de objeto SCHEMA_EXPORT/STATISTICS/MARKER
El trabajo "C###ZEUS"."SYS_IMPORT_SCHEMA_01" ha terminado correctamente en Mar Feb 25 18:35:03 2025 elapsed 0 00:00:09
```

- Logs de exportación:

```bash
oracle@madand1:/opt/oracle/export$ cat export.log 
;;; 
Export: Release 19.0.0.0.0 - Production on Tue Feb 25 18:05:32 2025
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
;;; 
Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Iniciando "C###BYRON"."SYS_EXPORT_SCHEMA_01":  C###BYRON/******** DIRECTORY=EXPORT_DB SCHEMAS=C###BYRON EXCLUDE=TABLE:"='BONUS'" QUERY=dept:"WHERE deptno IN \(SELECT deptno FROM EMP GROUP BY deptno HAVING COUNT\(*\)>2\)" 
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/TABLE_DATA
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Procesando el tipo de objeto SCHEMA_EXPORT/STATISTICS/MARKER
Procesando el tipo de objeto SCHEMA_EXPORT/SYSTEM_GRANT
Procesando el tipo de objeto SCHEMA_EXPORT/ROLE_GRANT
Procesando el tipo de objeto SCHEMA_EXPORT/DEFAULT_ROLE
Procesando el tipo de objeto SCHEMA_EXPORT/TABLESPACE_QUOTA
Procesando el tipo de objeto SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/TABLE
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/COMMENT
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/INDEX/INDEX
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
Procesando el tipo de objeto SCHEMA_EXPORT/TABLE/CONSTRAINT/REF_CONSTRAINT
. . "C###BYRON"."DEPT"                          6.007 KB       3 filas exportadas
. . "C###BYRON"."DEPT_VIEW"                         0 KB       0 filas exportadas
. . "C###BYRON"."EMP"                           8.781 KB      14 filas exportadas
. . "C###BYRON"."EMP_VIEW"                          0 KB       0 filas exportadas
. . "C###BYRON"."SALGRADE"                      6.101 KB       5 filas exportadas
La tabla maestra "C###BYRON"."SYS_EXPORT_SCHEMA_01" se ha cargado/descargado correctamente
******************************************************************************
El juego de archivos de volcado para C###BYRON.SYS_EXPORT_SCHEMA_01 es:
  /opt/oracle/export/expdat.dmp
El trabajo "C###BYRON"."SYS_EXPORT_SCHEMA_01" ha terminado correctamente en Mar Feb 25 18:05:53 2025 elapsed 0 00:00:20
```
Como no quiero tener que poner `C###BYRON` delante de los objetos loq ue he hecho ha sido lo siguinete:

```bash 
impdp C###ZEUS/ZEUS schemas=C###BYRON directory=EXPORT_DB dumpfile=expdat.dmp logfile=impdat.log table_exists_action=replace remap_schema=C###BYRON:C###ZEUS
```

Que lo que hace es sustituir el esquema `C###BYRON` por `C###ZEUS`, aqui lo demuestro:

![14](14.png)

Y si hacemos la consulta, y comporbamos esto que estoy diciendo:

![15](15.png)

---

## Ejercicio 3
###  Realiza una exportación de la estructura de todas las tablas de la base de datos usando el comando expdp de Oracle Data Pump probando al menos cinco de las posibles opciones que ofrece dicho comando y documentándolas adecuadamente.

En este ejercicio lo que nos pide es una exportación completa, por lo que voy a proceder a realizarlo hacinedolo de la sigueinte manera:

```bash 
expdp C###BYRON/BYRON schemas=De-donde-sale dumpfile=nombre.dmp logfile=nombre.log directory=variable-entorno CONTENT=contenido-espectacular
```

Donde:

- `C###BYRON/BYRON`: Especifica las credenciales para la conexión (usuario/contraseña) de la base de datos a la que se va a acceder.
- `schemas=De-donde-sale`: Especifica el esquema de la base de datos que se va a exportar.
- `dumpfile=nombre.dmp`: Especifica el nombre del fichero de exportación.
- `logfile=nombre.log`: Especifica el nombre del fichero de log.
- `directory=variable-entorno`: Especifica el directorio donde se almacenarán los archivos de exportación.
- `content=ALL`: Especifica el contenido que se va a exportar.
  - Hay opciones, las cuales las voy a exponer y explicar.
    - `ALL`: Exporta todo el contenido (tablas, vistas, índices, etc.) del esquema.
    - `DATA_ONLY`: Exporta solo los datos de las tablas.
    - `METADATA_ONLY`: Exporta solo la estructura (definición de tablas, vistas, índices, etc.), sin los datos.
    - `NONE`: No exporta nada.


```bash
expdp C###BYRON/BYRON schemas=C###BYRON dumpfile=byronfullequip.dmp logfile=byronfullequip.log directory=EXPORT_DB CONTENT=METADATA_ONLY
```

![12+1](13+1.png)

## Ejercicio 4

### Intenta realizar operaciones similares de importación y exportación con las herramientas proporcionadas con MySQL desde línea de comandos, documentando el proceso.

En esta ocasión lo que voy a hacer es crear una base de datos con los datos anteriores, esta pase de datos se va a llamar byron, y voy a meter las tablas y datos que necesitamos, por lo que dejo por aquí dichos datos 

- Creación de base de datos que vamos a exportar:

![16](16.png)

- Inserción de tablas y datos.

![alt text](17.png) 

![alt text](18.png) 

![alt text](20.png) 

![alt text](21.png)

Una vez hecho esto, lo que tenemos que hacer es lo siguiente, que será hacer una exportación de la base de datos, por lo que vamos a usar el siguiente comando, desde la terminal fuera de la consola de MariaDB, y es el siguiente comando:

`sudo mysqldump -u root byron > byronexport.sql`

Donde: 

- `mysqldump` → Es la herramienta que se usa para hacer copias de seguridad (exportaciones) de bases de datos en MySQL.
- `-u root` → Indica que el usuario que ejecuta el comando es root (el administrador de MySQL).
- `byron` → Es el nombre de la base de datos que quieres exportar.
- `> byronexport.sql` → Guarda el contenido exportado en un archivo llamado byronexport.sql.

Esto es para este caso en concreto, pero dejo por aqui el caso generico por si nos hiciera falta:

`mysqldump -u [usuario] -p [nombre_base_datos] > [archivo_salida.sql]`

Una vez dicho esto, lo que tendremos que hacer es ejecutarlo y ver si se hizo lo que es el fichero:

![OK](22.png)


Y como podemos observar esta todo listo y perfecto, ya tenemos la exportación realizada, ahora procederemos con la importación, por lo que voy a hacer una base de datos virgen, en este caso se va a llamar zeus, dejo por aquí su creación:

![23](23.png)

Y ahora procedemos a la importación por lo que esta vez, usaremos lo que es el comando para la exportación pero con unos pequeños ajustes, el cual lo dejare por aquí:

`sudo mysql -u root zeus < byronexport.sql`

Donde:

- `mysql` → Se usa para importar datos.
- `-u root` → Se ejecuta como el usuario root.
- `zeus` → Es la base de datos donde se restaurarán los datos.
- `< byronexport.sql` → Importa el contenido del archivo SQL a la base de datos zeus.

Esto es para este caso en concreto, pero dejo por aqui el caso generico por si nos hiciera falta:

`sudo mysql -u [usuario] -p [nombre_base_datos_que_queremos_importar] < [archivo_a_importar.sql]`

Y ahora comprobamos por pantalla lo siguiente que nos ha dado y nos metemos dentro y hacemos ciertas comprobaciones:

![OKIDOY](24.png)

![De locos mi rey](25.png)

---

## Ejercicio 5

### Intenta realizar operaciones similares de importación y exportación con las herramientas proporcionadas con Postgres desde línea de comandos, documentando el proceso.

Para este ejercicio vamos a volver a usar lo que la base de datos de Scott, pero al igual que antes usaremos una base de datos llamada byron y otra llamazada zeus, por lo que vamos a crear primero las bases de datos:

![creación de bases de datos](26.png)

Y como podemos ver ya tenemos todo listo en lo que será nuestra base de datos byron, para poder exportarla:

![Okaaaaaaaay](27.png)

Ahora procedemos a exportar lo que es la base de datos, por lo que vamos a usar el siguinete comando:

`sudo -u postgres pg_dump byron > byronexportado.sql`

Donde:

- `sudo -u postgres` → Ejecuta el comando como el usuario postgres, que es el usuario administrador por defecto en PostgreSQL.
- `pg_dump byron` → Exporta la base de datos byron.
- `> byronexportado.sql` → Guarda la exportación en el archivo byronexportado.sql.

Y en terminos generales, el comando quedaria de la siguiente manera:


`sudo -u [nombre_del_usuario] pg_dump [base_de_datos_a_exportar] > [archivo_salida] `

![OKAAAAAAAAAAAA](28.png)

Y como ya creamos con anterioridad la base de datos de zeus, la muestro para que se vea que esta vacía:

![hellouda](29.png)

Ahora lo que vamos a proceder es a importar dicha base de datos, anteriormente la cual era `byronexportado.sql`, con el siguiente comando:

`sudo -u postgres psql -d zeus -f byronexportado.sql`

Donde:

- `sudo -u postgres` → Ejecuta el comando como el usuario postgres (usuario administrador de PostgreSQL).
- `psql` → Es la herramienta de línea de comandos para interactuar con PostgreSQL.
- `-d zeus` → Indica que la base de datos a la que se conectará es zeus.
- `-f byronexportado.sql` → Especifica el archivo SQL que se importará.

Y veremos lo siguiente por pantalla:

![De locos](30.png)

Y ahora nos metemos dentro y hacemos las comprobaciones para ver si se han hecho perfectamente:

![Volaaaaaaaaaaaaaandddddo](31.png)

---

## Ejercicio 6

### Exporta los documentos de una colección de MongoDB que cumplan una determinada condición e impórtalos en otra base de datos.

Para este ejercicio voy a crear en mi SGBD no relacional, una base de datos llamada `aprobare` y donde tendre una colección llaamda `articulos`, de los cuales solo vamos a exportar los documentos donde sean de tipo `Libros`.

Por lo que para exportar en mongo tendremos que usar el siguiente comando:

`mongoexport -u andy -p andy --authenticationDatabase admin --db aprobare --collection articulos --query "{\"tipo\":\"Libros\"}" --out exportacion-accesorios.json`

Donde: 

- `mongoexport`: Herramienta de línea de comandos utilizada para exportar datos desde MongoDB hacia un archivo (puede ser JSON o CSV)
- `-u andy`: Nombre de usuario que se usará para la autenticación en MongoDB
- `-p andy`: Contraseña del usuario andy.
- `--authenticationDatabase admin`: Define la base de datos que se utiliza para autenticar al usuario.
- `--db aprobare`: La base de datos en la que se encuentra la colección de la cual se exportarán los datos
- `--collection articulos`: Es el nombre de la colección de la cual se exportarán los datos.
- `--query "{\"tipo\":\"Libros\"}"`: Es el filtro en formato JSON
- `--out exportacion-accesorios.json`: Es el archivo donde se guardarán los datos exportados.

Por pantalla nos aparece lo siguiente:

![EEEEEEEEEEEEEEEEEESpartaco](32.png)

Lo que acabamos de ver en la captura de arriba, es como ha codigo con el filtro que le pusimos el cual es Librosm y este lo qu eha hecho es pasarlo al fichero con extension .json, y en el cual como se puede ver, estan almacenados, por lo que ahora con la exportación realizada, vamos a proceder a hacer la importación.

Como tengo de anteriores pruebas varias bases de datos, voy a meterlo en `pratcicamotos`, muestro en pantalla las colecciones que tengo:

![Collections](33.png)

Por lo que procedere a importar lo que es el json que hicimos con anterioridad.

`mongoimport -u andy -p andy --authenticationDatabase admin --db pratcicamotos --collection articulos --file exportacion-accesorios.json`

Donde:

- `mongoimport`: Es la herramienta utilizada para importar datos en MongoDB desde un archivo (JSON, CSV, TSV).
- `-u andy`: Identidad de nuetsro usuario.
- `-p andy`: Contraseña de nuetsro usuario.
- `--authenticationDatabase admin`: Especifica la base de datos para la autenticación. 
- `--db pratcicamotos`: Especifica la base de datos de destino donde se importarán los datos.
- `--collection articulos`: Especifica la colección en la que se van a importar los datos. 
- `--file exportacion-accesorios.json`: Define el archivo que se va a importar.
Como podemos ver por pantalla se han importado:

![alt text](34.png)

Pero para asegurarnos lo que vamos a hacer es entrar en la base de datos de `pratcicamotos` y ver las colecciones y ver que hay dentro:

![Espectaculo](35.png)


