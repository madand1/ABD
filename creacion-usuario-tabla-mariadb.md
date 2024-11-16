andy@mariadb:~$ sudo mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 31
Server version: 10.11.6-MariaDB-0+deb12u1 Debian 12

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'andy'@'%' IDENTIFIED BY 'andy';
Query OK, 0 rows affected (0,026 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'andy'@'%';
Query OK, 0 rows affected (0,003 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0,001 sec)

MariaDB [(none)]> ^DBye
andy@mariadb:~$ mysql -u andy -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 32
Server version: 10.11.6-MariaDB-0+deb12u1 Debian 12

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE alegria;
Query OK, 1 row affected (0,001 sec)

MariaDB [(none)]> USE alegria;
Database changed
MariaDB [alegria]> CREATE TABLE usuarios (
    ->     id INT AUTO_INCREMENT PRIMARY KEY,
    ->     nombre VARCHAR(100),
    ->     correo VARCHAR(100),
    ->     fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    -> );
Query OK, 0 rows affected (0,061 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('Juan Pérez', 'juan.perez@email.com');
Query OK, 1 row affected (0,005 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('María Gómez', 'maria.gomez@email.com');
Query OK, 1 row affected (0,003 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('Carlos Ruiz', 'carlos.ruiz@email.com');
Query OK, 1 row affected (0,005 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('Laura Martínez', 'laura.martinez@email.com');
Query OK, 1 row affected (0,004 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('Pedro López', 'pedro.lopez@email.com');
Query OK, 1 row affected (0,004 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('Ana Fernández', 'ana.fernandez@email.com');
Query OK, 1 row affected (0,004 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('Luis García', 'luis.garcia@email.com');
Query OK, 1 row affected (0,004 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('Sofía Sánchez', 'sofia.sanchez@email.com');
Query OK, 1 row affected (0,004 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('David Pérez', 'david.perez@email.com');
Query OK, 1 row affected (0,004 sec)

MariaDB [alegria]> INSERT INTO usuarios (nombre, correo) VALUES ('Carmen Rodríguez', 'carmen.rodriguez@email.com');
Query OK, 1 row affected (0,009 sec)

MariaDB [alegria]> 


MariaDB [alegria]> SELECT * FROM usuarios;
+----+-------------------+----------------------------+---------------------+
| id | nombre            | correo                     | fecha_creacion      |
+----+-------------------+----------------------------+---------------------+
|  1 | Juan Pérez        | juan.perez@email.com       | 2024-11-16 12:43:19 |
|  2 | María Gómez       | maria.gomez@email.com      | 2024-11-16 12:43:19 |
|  3 | Carlos Ruiz       | carlos.ruiz@email.com      | 2024-11-16 12:43:19 |
|  4 | Laura Martínez    | laura.martinez@email.com   | 2024-11-16 12:43:19 |
|  5 | Pedro López       | pedro.lopez@email.com      | 2024-11-16 12:43:19 |
|  6 | Ana Fernández     | ana.fernandez@email.com    | 2024-11-16 12:43:19 |
|  7 | Luis García       | luis.garcia@email.com      | 2024-11-16 12:43:19 |
|  8 | Sofía Sánchez     | sofia.sanchez@email.com    | 2024-11-16 12:43:19 |
|  9 | David Pérez       | david.perez@email.com      | 2024-11-16 12:43:19 |
| 10 | Carmen Rodríguez  | carmen.rodriguez@email.com | 2024-11-16 12:43:19 |
+----+-------------------+----------------------------+---------------------+
10 rows in set (0,000 sec)

MariaDB [alegria]> 
