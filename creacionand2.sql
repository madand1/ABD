andy@oracle-server:~$ sudo su
[sudo] contraseña para andy: 
root@oracle-server:/home/andy# su - oracle
oracle@oracle-server:~$ sqlplus / as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Tue Nov 12 12:45:33 2024
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
SQL> CREATE USER c##and2 IDENTIFIED BY and2;

Usuario creado.

SQL> GRANT ALL PRIVILEGES TO c##and2;

Concesion terminada correctamente.

SQL> DISCONNECT
Desconectado de Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0
SQL> CONNECT c##and2/and2
Conectado.
SQL> 
