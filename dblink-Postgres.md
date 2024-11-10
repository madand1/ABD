# Introducción 

Este documento explica cómo establecer una conexión entre dos servidores de bases de datos PostgreSQL en un entorno Debian 12. Además, se detalla la configuración necesaria para aceptar solicitudes desde equipos remotos.

Para lograr esta interconexión, instalaremos un gestor en una segunda máquina, permitiendo así que un cliente pueda acceder a ambas bases de datos de manera simultánea, aunque de forma indirecta. Este proceso es similar a realizar un JOIN entre tablas ubicadas en diferentes servidores, donde los servidores están enlazados. En este esquema, uno de los servidores funcionará como cliente del otro, en una conexión unilateral.

En última instancia, el cliente solo establece una conexión inicial; luego, el primer servidor conectado abrirá una conexión hacia el segundo servidor.

A continuacón, lo que tenemos en nuestro escenario son dos máquinas virtuales con VM donde tenemos instalado PostgreSQL, en máquinas Debian 12, las cuales están virgenes totalmente.

El proceso de instalación esta a continuación:

[Instalación servidor PostgreSQL](Postgres.md)

Estás maquinas estan ahora mismo con la interfaz br0, por lo que adoptarán distintas direcciones depende de donde estemos trabajando:

- Servidor 1: 192.168.1.138/24
- Servidor 2: 192.168.1.137/24


Como tenemos ya instalado y tenemos la configuración para que pudamos entrar a nuestros servidores de bases de datos remotamente, lo que tenemos tenemos que tener en cuenta es lo sisguinete y es que el paquete de *postgresSQL* al estar instalado en la máquina, este habra apbierto un puerto TCP/IP en el puerto por defecto del servidor PostgreSQL, el cual es *5432* en donde estará escuchando peticiones provenientes tanto del localhost comno de otras redes.

Para ello vamos a meter el siguiente comando:

```netstat -tln```
El cual si hacemso un desglose del comando, podemos sacar en claro lo siguiente:

- -t: Filtramos únicamente para las conexiones que utilizan el protocolo TCP.
- -l: Filtramos únicamente para los sockets que están actualmente escuchando peticiones (State = LISTEN).
- -n: Indicamos que muestre las direcciones y puertos de forma numérica, en lugar de intentar traducirlos.


```
usuario@servidor1:~$ netstat -tln
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN     
tcp6       0      0 :::22                   :::*                    LISTEN     
tcp6       0      0 :::5432                 :::*                    LISTEN     
usuario@servidor1:~$ 
```

Y como podemos ver lo que nos da por pantalla, el proceso no está escuchando las peticiones, de manera que vamos a abir la consola de psql  para asi getsionar el motor, cambiandonos previamente al usuario postgres, ya que es el que cuenta con los privilegios para esto.

Para entrar a este tendremos que seguir estos pasos:

```
usuario@servidor1:~$ sudo su
[sudo] contraseña para usuario: 
root@servidor1:/home/usuario# su - postgres
postgres@servidor1:~$ 
```

Ahora que estamos dentro del usuario *postgres*, el cual entraremos siendo root, como hemos visto con anterioridad, ahora estaremos listo pata abrir la consola de psql, con el siguiente comando:

```psql```

Y nos aparecera por pantalla lo siguiente:

```
postgres@servidor1:~$ psql
psql (15.8 (Debian 15.8-0+deb12u1))
Digite «help» para obtener ayuda.

postgres=# 

```

Como podemos ver se ha abierto correctamente hasta ahora, y esta lista para que la usemos.

Ahora vamos a proceder a crear una bases de datos con sus permisos  para administrarla, por lo que voy a crear una base de datos con nombre *practica2* en la que existira *and1* que será el administrador de la misma. pero toatlmente aislado del resto de bases de datos que puedan ser creadas en el futuro.

1. Crear la base de datos cuyo nombre es *practica2*

```
postgres=# CREATE DATABASE practica2;
CREATE DATABASE

```
2. Verificar la lista de base de datos:

```
postgres=# \l
                                                     Listado de base de datos
  Nombre   |  Dueño   | Codificación |   Collate   |    Ctype    | configuración ICU | Proveedor de locale |      Privilegios      
-----------+----------+--------------+-------------+-------------+-------------------+---------------------+-----------------------
 postgres  | postgres | UTF8         | es_ES.UTF-8 | es_ES.UTF-8 |                   | libc                | 
 practica2 | postgres | UTF8         | es_ES.UTF-8 | es_ES.UTF-8 |                   | libc                | 
 template0 | postgres | UTF8         | es_ES.UTF-8 | es_ES.UTF-8 |                   | libc                | =c/postgres          +
           |          |              |             |             |                   |                     | postgres=CTc/postgres
 template1 | postgres | UTF8         | es_ES.UTF-8 | es_ES.UTF-8 |                   | libc                | =c/postgres          +
           |          |              |             |             |                   |                     | postgres=CTc/postgres
(4 filas)

postgres=# 

```
Como podemos ver en la segunda línea tenemos la base de datos *practica2* generada correctamente, por lo que una vez comprobado esto vamos a crear el rol de *and1* y la contraseña que sera *and1*, por lo que este será el tercer paso.

3. Creación del rol:

```
postgres=# CREATE USER and1 WITH PASSWORD 'and1';
CREATE ROLE
postgres=# 
```

4. Permisos al rol *and1*, es decir dar privilegios:

```
postgres=# GRANT ALL PRIVILEGES ON DATABASE practica2 TO and1;
GRANT
```

```
practica2=# GRANT CREATE ON SCHEMA public TO and1;
GRANT

```

Una vez realizado esto lo que haremos será salir de la terminal de _psql_, para poder comprobar si esta todo perfectamente en la conexión a la base de datos, con el usuario, por lo que haremos esto:

```
postgres=# exit
postgres@servidor1:~$ 

```


Y ahora procederemos a la comprobación de su funcionamiento correcto,por lo que meteremos por consola lo siguiente:

```
postgres@servidor1:~$ psql -h localhost -U and1 -d practica2
Contraseña para usuario and1: 
psql (15.8 (Debian 15.8-0+deb12u1))
Conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, compresión: desactivado)
Digite «help» para obtener ayuda.

practica2=> 

```

Desglose del comando:

- -h: Especificamos el nombre de la máquina a la que nos queremos conectar, en este caso, localhost.
- -U: Especificamos el rol con el que nos queremos conectar, en este caso, alvaro1.
- -d: Especificamos la base de datos a la que nos queremos conectar, en este caso, prueba1.

Como podems ver, la autentificación ha salido bien, y ahroa que estamso conectado a temrinal psql haciendo uso del user and1, el cual acabmos de crear. El gestor de bases de datos se encuentra totalmente funcional.

Ahora voy a meter una tabla con sus insersiones, esta la podemo ver en el siguiente enlace:

[Pulsa aquí](Insersion-Postgres.md)


Una vez insertado las tablas e insersiones, nos  saldremos del cliente ejecuntado ```exit``` para asi continuar con la parte referente al uso de dicha base remota.

Como esto lo hemos hecho en el servidor 1 tendremos que hacer el mismo procedimeinto pero esta vez habrá una diferencia y es que el rol o usuario que vamso a generar el *and2* cuya contraseña sera *and2* y el nombre de la base de datos será *practica3*, para poder diferenciarlo.

Para esto he metido la siguiente tabla e insersiones:

[Pulsa aquí](Insersion-Postgres.md)

Hasta aqui podemos decir lo siguiente:

Ambas máquinas servidoras se encuentran ya configuradas y listas para recibir conexiones remotas, de manera que todo está listo para interconectarlas. Para ello, realizaremos el procedimiento de forma ordenada, configurando primero el enlace de la máquina servidor1 a la máquina servidor2 y posteriormente, a la inversa, ya que dichas conexiones son unidireccionales.

Para ello nececistamos un requisito el cual es que para poder crear dicho enlace tendremo sque tener instalado en la maquina origen el paquete *postgresql-contrib*, de manera que lo instalaremos ejecuntado el siguiente comando:

```
root@servidor1:/home/usuario# apt install postgresql-contrib

```
Una vez instalado, tendremos que cambiarnos una vez más al usuario postgres, pues es el que cuenta con los privilegios necesarios para crear dicho enlace, haciendo para ello uso del comando:

```
root@servidor1:/home/usuario# su - postgres
postgres@servidor1:~$ 

```

Cuando ya estamos usando el usuario postgres, todo estará lsito para abrir la terminal psql, haciendo uso de la base de datos practica1, con el siguiente comando:

```
postgres@servidor1:~$ psql -d practica2
psql (15.8 (Debian 15.8-0+deb12u1))
Digite «help» para obtener ayuda.

practica2=# 
```

Es muy importante que la conexión se realice a la base de datos practica2, ya que es donde el rol and1 tiene privilegios, pues de lo contrario, no podría utilizar dicho enlace. La creación del mismo es muy sencilla, llevándose a cabo mediante la ejecución del comando:

```
practica2=# CREATE EXTENSION dblink;
CREATE EXTENSION
practica2=# 

```
La extensión que hará la función de enlace ya ha sido creada, pero para verificarlo, vamos a listar todas las extensiones existentes, haciendo para ello uso de la instrucción:

```
practica2=# \dx

                              Listado de extensiones instaladas
 Nombre  | Versión |  Esquema   |                         Descripción                          
---------+---------+------------+--------------------------------------------------------------
 dblink  | 1.2     | public     | connect to other PostgreSQL databases from within a database
 plpgsql | 1.0     | pg_catalog | PL/pgSQL procedural language
(2 filas)

(END)

```

Efectivamente, la extensión dblink ha sido correctamente generada, de manera que podremos salir del cliente ejecutando la instrucción ```exit``` para así realizar una nueva conexión a la base de datos practica2 pero haciendo uso esta vez del rol and1, y así verificar que puede utilizar dicho enlace, ejecutando para ello el comando visto con anterioridad:

```
postgres@servidor1:~$ psql -h localhost -U and1 -d practica2
Contraseña para usuario and1: 
psql (15.8 (Debian 15.8-0+deb12u1))
Conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, compresión: desactivado)
Digite «help» para obtener ayuda.

practica2=> 

```

Una vez más, la autenticación ha funcionado como debería, de manera que vamos a proceder a llevar a cabo una consulta cuya información mostrada provenga de ambas bases de datos, ubicadas como ya hemos visto, en servidores distintos.

Ahora lo que quiero mostrar son los datos de los *Productos* (servidor 1) junto con todo lo que tiene la tabla, la información que nos muestra la tabla *Ventas* (servidor 2), y como vemos a continuación nos lo muestra:

```
practica2=> SELECT 
    ventas.id AS id_venta,
    ventas.producto_id AS producto_id,
    ventas.cantidad AS cantidad_vendida,
    ventas.total AS total_venta,
    ventas.fecha_venta AS fecha_venta,
    productos.nombre AS nombre_producto,
    productos.precio AS precio_producto
FROM 
    dblink('dbname=practica3 host=192.168.1.137 user=and2 password=and2', 
           'SELECT id, producto_id, cantidad, total, fecha_venta FROM ventas') 
    AS ventas (id INTEGER, producto_id INTEGER, cantidad INTEGER, total DECIMAL(10, 2), fecha_venta TIMESTAMP),
    dblink('dbname=practica2 host=192.168.1.138 user=and1 password=and1', 
           'SELECT id, nombre, precio FROM productos') 
    AS productos (id INTEGER, nombre VARCHAR(100), precio DECIMAL(10, 2))
WHERE 
    ventas.producto_id = productos.id;
 id_venta | producto_id | cantidad_vendida | total_venta |        fecha_venta         |       nombre_producto       | precio_producto 
----------+-------------+------------------+-------------+----------------------------+-----------------------------+-----------------
        1 |           1 |                2 |     1599.98 | 2024-11-04 13:03:45.348567 | Laptop HP Pavilion          |          799.99
        2 |           3 |                1 |      349.99 | 2024-11-04 13:03:45.348567 | Auriculares Sony WH-1000XM4 |          349.99
        3 |           5 |                3 |      299.97 | 2024-11-04 13:03:45.348567 | Mouse Logitech MX Master 3  |           99.99
        4 |           7 |                1 |      599.99 | 2024-11-04 13:03:45.348567 | Tablet Apple iPad Air       |          599.99
        5 |           9 |                2 |     1099.98 | 2024-11-04 13:03:45.348567 | Cámara Canon EOS Rebel T7   |          549.99
(5 filas)

practica2=> 

```

Si nos posemos a desglosar el comando este que vemos a continuacion:

```
SELECT 
    ventas.id AS id_venta,
    ventas.producto_id AS producto_id,
    ventas.cantidad AS cantidad_vendida,
    ventas.total AS total_venta,
    ventas.fecha_venta AS fecha_venta,
    productos.nombre AS nombre_producto,
    productos.precio AS precio_producto
FROM 
    dblink('dbname=practica3 host=192.168.1.137 user=and2 password=and2', 
           'SELECT id, producto_id, cantidad, total, fecha_venta FROM ventas') 
    AS ventas (id INTEGER, producto_id INTEGER, cantidad INTEGER, total DECIMAL(10, 2), fecha_venta TIMESTAMP),
    dblink('dbname=practica2 host=192.168.1.138 user=and1 password=and1', 
           'SELECT id, nombre, precio FROM productos') 
    AS productos (id INTEGER, nombre VARCHAR(100), precio DECIMAL(10, 2))
WHERE 
    ventas.producto_id = productos.id;
```

Desglose de consulta con dblink:

1. **Conexión a la base de datos**: 
   - Se utiliza `dblink` para conectarse a la base de datos `practica3`, que está ubicada en `192.168.1.137`.
  
2. **Extracción de columnas**: 
   - Se extraen las siguientes columnas de la tabla `ventas`:
     - `id`: Identificador de la venta.
     - `producto_id`: Identificador del producto vendido.
     - `cantidad`: Número de unidades vendidas.
     - `total`: Monto total de la venta.
     - `fecha_venta`: Fecha y hora en que se realizó la venta.

3. **Definición de alias**:
   - Se define un alias llamado `ventas` para referirse a estos datos.
   - Se especifica el tipo de cada columna (por ejemplo, qué tipo de datos es `id`, `cantidad`, etc.).

## Segunda llamada a dblink (tabla productos):
1. **Conexión a la base de datos**: 
   - Se utiliza `dblink` nuevamente para conectarse a la base de datos `practica2`, que está ubicada en `192.168.1.138`.

2. **Extracción de columnas**: 
   - Se extraen las siguientes columnas de la tabla `productos`:
     - `id`: Identificador del producto.
     - `nombre`: Nombre del producto.
     - `precio`: Precio del producto.

3. **Definición de alias**:
   - Se define un alias llamado `productos` para referirse a estos datos.
   - Se especifica el tipo de cada columna (por ejemplo, qué tipo de datos es `id`, `nombre`, etc.).

## Cláusula WHERE para el JOIN:
1. **Realización del JOIN**:
   - Se usa una cláusula `WHERE` para unir ambas tablas.
   - La condición para la unión es que `ventas.producto_id` debe ser igual a `productos.id`.
   - Esto asegura que solo se muestren las ventas para las que existe un producto correspondiente en la tabla de productos.


Como vemos se ha hecho la consulta sin ningún tipo de problemas, ya que nos ha devuelto la información que deberia, pues tal y como he mencionado con anterioridad, ambas máquinas servidoras cuentan con un direccionamiento dentro de la red local, siendo ambas totalmente alcanzables entre sí, además de estar correctamente configuradas para aceptar dichas conexiones.

Lo siguiente que veremos a continuación sera que con estos tipos de enlaces tenemos la capacidad de copiar las tablas de un gestor a otro, usando el resultado de una consulta simple para crear una tabla a partir de la misma .

Por ejemplo copiar la tabla ventas en el servidor 1;

```
practica2=> CREATE TABLE ventas AS 
SELECT *
FROM dblink('dbname=practica3 host=192.168.1.137 user=and2 password=and2',
            'SELECT producto_id, cantidad, total, fecha_venta FROM ventas')
AS t (producto_id INTEGER, cantidad INTEGER, total DECIMAL(10, 2), fecha_venta TIMESTAMP);
SELECT 5

```

Desglose del comando:


- **`CREATE TABLE ventas AS`**: Esto crea una nueva tabla llamada `ventas` en el servidor 1.

- **`SELECT * FROM dblink(...)`**: Se conecta al servidor 2 y selecciona los datos de la tabla `ventas`.

- **`AS t (...)`**: Aquí defines un alias `t` y especificas los tipos de las columnas. Esto es necesario porque `dblink` no conoce la estructura de la tabla a la que te estás conectando, por lo que necesitas definir explícitamente los tipos de datos.


Y hacemos la comprobacion:

```
practica2=> SELECT * FROM ventas;
 producto_id | cantidad |  total  |        fecha_venta         
-------------+----------+---------+----------------------------
           1 |        2 | 1599.98 | 2024-11-04 13:03:45.348567
           3 |        1 |  349.99 | 2024-11-04 13:03:45.348567
           5 |        3 |  299.97 | 2024-11-04 13:03:45.348567
           7 |        1 |  599.99 | 2024-11-04 13:03:45.348567
           9 |        2 | 1099.98 | 2024-11-04 13:03:45.348567
(5 filas)

practica2=> 
```

y como podemos ver esta de locos

El enlace ha funcionado del extremo servidor1 al extremo servidor2, pero como ya sabemos, dichos enlaces son unidireccionales, de manera que si quisiésemos realizar la conexión a la inversa, tendríamos que repetir el mismo procedimiento en la segunda máquina, así que vamos a proceder a ello.

lo primero que haremos sera entrar en el servidor 2 como el usuario postrges:

```
root@servidor2:~# su - postgres
postgres@servidor2:~$ 


```

Cuando nos encontremos utilizando el usuario postgres, todo estará listo para abrir la shell de psql haciendo uso de la base de datos practica3, ejecutando para ello el comando:

```
postgres@servidor2:~$ psql -d practica3 
psql (15.8 (Debian 15.8-0+deb12u1))
Digite «help» para obtener ayuda.

practica3=# 


```

Es muy importante que la conexión se realice a la base de datos practica3, ya que es donde el rol and2 tiene privilegios, pues de lo contrario, no podría utilizar dicho enlace. La creación del mismo es muy sencilla, llevándose a cabo mediante la ejecución del comando:

```
practica3=# CREATE EXTENSION dblink;
CREATE EXTENSION
practica3=# 

```
La extensión que hará la función de enlace ya ha sido creada, pero para verificarlo, vamos a listar todas las extensiones existentes, haciendo para ello uso de la instrucción:

```
practica3=# \dx
                               Listado de extensiones instaladas
 Nombre  | Versión |  Esquema   |                         Descripción                          
---------+---------+------------+--------------------------------------------------------------
 dblink  | 1.2     | public     | connect to other PostgreSQL databases from within a database
 plpgsql | 1.0     | pg_catalog | PL/pgSQL procedural language
(2 filas)

practica3=# 


```


Efectivamente, la extensión dblink ha sido correctamente generada, de manera que podremos salir del cliente ejecutando la instrucción exit para así realizar una nueva conexión a la base de datos practica3 pero haciendo uso esta vez del rol and2, y así verificar que puede utilizar dicho enlace, ejecutando para ello el comando visto con anterioridad:

```
postgres@servidor2:~$ psql -h localhost -U and2 -d practica3
Contraseña para usuario and2: 
psql (15.8 (Debian 15.8-0+deb12u1))
Conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, compresión: desactivado)
Digite «help» para obtener ayuda.

practica3=> 

```


Una vez más, la autenticación ha funcionado como debería, de manera que vamos a proceder a llevar a cabo una consulta cuya información mostrada provenga de ambas bases de datos, ubicadas como ya hemos visto, en servidores distintos.

```
practica3=> SELECT 
    ventas.id AS id_venta,
    ventas.producto_id AS producto_id,
    ventas.cantidad AS cantidad_vendida,
    ventas.total AS total_venta,
    ventas.fecha_venta AS fecha_venta,
    productos.nombre AS nombre_producto,
    productos.precio AS precio_producto
FROM 
    dblink('dbname=practica3 host=192.168.1.137 user=and2 password=and2', 
           'SELECT id, producto_id, cantidad, total, fecha_venta FROM ventas') 
    AS ventas (id INTEGER, producto_id INTEGER, cantidad INTEGER, total DECIMAL(10, 2), fecha_venta TIMESTAMP),
    dblink('dbname=practica2 host=192.168.1.138 user=and1 password=and1', 
           'SELECT id, nombre, precio FROM productos WHERE precio < 200') 
    AS productos (id INTEGER, nombre VARCHAR(100), precio DECIMAL(10, 2))
WHERE 
    ventas.producto_id = productos.id;
 id_venta | producto_id | cantidad_vendida | total_venta |        fecha_venta         |      nombre_producto       | precio_producto 
----------+-------------+------------------+-------------+----------------------------+----------------------------+-----------------
        3 |           5 |                3 |      299.97 | 2024-11-04 13:03:45.348567 | Mouse Logitech MX Master 3 |           99.99
(1 fila)

practica3=> 


```

Como era de esperar, la consulta ha vuelto a realizarse sin ningún problema y ha devuelto la información que debería, de manera que vamos a hacer una última prueba, llevando a cabo una copia de la tabla Empleados ubicada en el primero de los servidores, haciendo uso de la siguiente instrucción:

```
practica3=> CREATE TABLE productos AS 
SELECT * 
FROM dblink('dbname=practica2 host=192.168.1.138 user=and1 password=and1',
            'SELECT id, nombre, descripcion, precio, stock, fecha_creacion FROM productos')
AS t (id INTEGER, nombre VARCHAR(100), descripcion TEXT, precio DECIMAL(10, 2), stock INTEGER, fecha_creacion TIMESTAMP);
SELECT 10
practica3=> 

```

En dicha instrucción, hemos realizado una consulta a la tabla Productos ubicada en la base de datos del servidor1, utilizando la respuesta obtenida para crear una nueva tabla con el mismo nombre, que se almacenará ahora de forma local en el servidor servidor2, y que podremos empezar a utilizar sin necesidad de recurrir al enlace con el primer servidor. Si consultamos la nueva tabla generada, obtendremos el siguiente resultado:

```
practica3=> SELECT * FROM productos;
 id |              nombre              |                                    descripcion                                    | precio | stock |       fecha_creacion       
----+----------------------------------+-----------------------------------------------------------------------------------+--------+-------+----------------------------
  1 | Laptop HP Pavilion               | Laptop HP de 15.6 pulgadas con procesador Intel Core i5 y 8GB de RAM.             | 799.99 |    10 | 2024-11-04 12:44:21.847856
  2 | Smartphone Samsung Galaxy S21    | Smartphone Samsung con pantalla AMOLED de 6.2 pulgadas y 128GB de almacenamiento. | 999.00 |    15 | 2024-11-04 12:44:21.847856
  3 | Auriculares Sony WH-1000XM4      | Auriculares inalámbricos con cancelación de ruido y hasta 30 horas de batería.    | 349.99 |    25 | 2024-11-04 12:44:21.847856
  4 | Monitor Dell UltraSharp          | Monitor Dell de 27 pulgadas con resolución QHD y tecnología IPS.                  | 449.50 |     8 | 2024-11-04 12:44:21.847856
  5 | Mouse Logitech MX Master 3       | Mouse inalámbrico ergonómico con múltiples botones programables.                  |  99.99 |    50 | 2024-11-04 12:44:21.847856
  6 | Teclado Mecánico Corsair K95     | Teclado mecánico RGB con switches Cherry MX y retroiluminación.                   | 189.00 |    20 | 2024-11-04 12:44:21.847856
  7 | Tablet Apple iPad Air            | iPad Air de 10.9 pulgadas con chip A14 Bionic y 64GB de almacenamiento.           | 599.99 |    30 | 2024-11-04 12:44:21.847856
  8 | Disco Duro Externo WD 1TB        | Disco duro externo portátil de 1TB y USB 3.0.                                     |  54.99 |   100 | 2024-11-04 12:44:21.847856
  9 | Cámara Canon EOS Rebel T7        | Cámara DSLR con sensor de 24.1 MP y grabación de video Full HD.                   | 549.99 |     5 | 2024-11-04 12:44:21.847856
 10 | Smartwatch Garmin Forerunner 245 | Reloj deportivo con GPS y monitor de frecuencia cardíaca.                         | 299.99 |    12 | 2024-11-04 12:44:21.847856
(10 filas)

practica3=> 

```

Como se puede apreciar, el contenido es exactamente el mismo que el existente en la tabla ubicada en el gestor remoto, por lo que podemos concluir que su clonación ha sido efectiva y que los servidores tienen conectividad entre sí mediante los enlaces creados, sea cual sea el sentido utilizado.