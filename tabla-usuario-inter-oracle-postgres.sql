andy@servidores:~$ sudo -u postgres psql
[sudo] contraseña para andy: 
could not change directory to "/home/andy": Permiso denegado
psql (15.8 (Debian 15.8-0+deb12u1))
Type "help" for help.

postgres=# CREATE USER and2 WITH PASSWORD 'and2';
CREATE ROLE
postgres=# CREATE DATABASE prueba-inter;
ERROR:  error de sintaxis en o cerca de «-»
LÍNEA 1: CREATE DATABASE prueba-inter;
                               ^
postgres=# CREATE DATABASE prueba_inter;
CREATE DATABASE
postgres=# GRANT ALL PRIVILEGES ON DATABASE prueba_inter TO and2;
GRANT
postgres=# \c prueba_inter and2
falló la conexión al servidor en el socket «/var/run/postgresql/.s.PGSQL.5432»: FATAL:  la autentificación Peer falló para el usuario «and2»
Previous connection kept
postgres=# \c prueba_inter and2
falló la conexión al servidor en el socket «/var/run/postgresql/.s.PGSQL.5432»: FATAL:  la autentificación Peer falló para el usuario «and2»
Previous connection kept
postgres=# \q
andy@servidores:~$ psql -U and2 -d prueba_inter
psql: error: falló la conexión al servidor en el socket «/var/run/postgresql/.s.PGSQL.5432»: FATAL:  la autentificación Peer falló para el usuario «and2»
andy@servidores:~$ sudo nano /etc/postgresql/15/main/pg_hba.conf
andy@servidores:~$ sudo systemctl restart postgresql
andy@servidores:~$ psql -U and2 -d prueba_inter
psql: error: falló la conexión al servidor en el socket «/var/run/postgresql/.s.PGSQL.5432»: No existe el fichero o el directorio
	¿Está el servidor en ejecución localmente y aceptando conexiones en ese socket?
andy@servidores:~$ psql -U and2 -d prueba_inter
psql: error: falló la conexión al servidor en el socket «/var/run/postgresql/.s.PGSQL.5432»: No existe el fichero o el directorio
	¿Está el servidor en ejecución localmente y aceptando conexiones en ese socket?
andy@servidores:~$ sudo nano /etc/postgresql/15/main/pg_hba.conf
andy@servidores:~$ sudo systemctl restart postgresql
andy@servidores:~$ psql -U and2 -d prueba_inter
psql: error: falló la conexión al servidor en el socket «/var/run/postgresql/.s.PGSQL.5432»: FATAL:  la autentificación Peer falló para el usuario «and2»
andy@servidores:~$ sudo nano /etc/postgresql/15/main/pg_hba.conf

# Aqui puse la linea esta:
## local   all             all                                    md5

andy@servidores:~$ sudo systemctl restart postgresql


andy@servidores:~$ psql -U and2 -d prueba_inter
Contraseña para usuario and2: 
psql (15.8 (Debian 15.8-0+deb12u1))
Digite «help» para obtener ayuda.


prueba_inter=> CREATE TABLE Sectores (
    Identificador   INTEGER,
    Nombre          VARCHAR(20),
    Ubicacion       VARCHAR(15),
    CONSTRAINT pk_sectores PRIMARY KEY (Identificador),
    CONSTRAINT ubicacion_no_vacia CHECK (Ubicacion IS NOT NULL)
);
ERROR:  permiso denegado al esquema public
LÍNEA 1: CREATE TABLE Sectores (
                     ^
prueba_inter=> \q



andy@servidores:~$ psql -U and2 -d prueba_inter
Contraseña para usuario and2: 
psql (15.8 (Debian 15.8-0+deb12u1))
Digite «help» para obtener ayuda.

prueba_inter=> CREATE TABLE Sectores (
    Identificador   INTEGER,
    Nombre          VARCHAR(20),
    Ubicacion       VARCHAR(15),
    CONSTRAINT pk_sectores PRIMARY KEY (Identificador),
    CONSTRAINT ubicacion_no_vacia CHECK (Ubicacion IS NOT NULL)
);
CREATE TABLE
prueba_inter=> INSERT INTO Sectores VALUES (10, 'Marketing', 'Madrid');
INSERT INTO Sectores VALUES (20, 'Ventas', 'Barcelona');
INSERT INTO Sectores VALUES (30, 'Soporte', 'Sevilla');
INSERT INTO Sectores VALUES (40, 'Desarrollo', 'Valencia');
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
prueba_inter=> 
