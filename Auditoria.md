# Auditoría de bases de datos

Lo primero antes de empezar esta práctica es saber que es una auditoria, obviamente en el ambito de bases de datos, por lo que voy a proceder a hacer una definición:

## Definición de auditoría:

- `Auditoría de bases de datos`: Es un proceso sistemático de monitoreo y registro de las actividades realizadas dentro de una base de datos. Su objetivo principal es asegurar la seguridad, conformidad e integridad de los datos almacenados, proporcionando un control eficaz sobre el acceso y uso de la información.

## Proposito de los auditores y administradores:

- Un `administrador` puede llevar a cabo auditorías registrando acciones específicas, como las consultas SQL ejecutadas, las aplicaciones utilizadas o la hora en la que se realiza cada acción.

- Los `auditores` deben asegurarse de registrar tanto las acciones exitosas como las fallidas, y tienen la opción de incluir o excluir a usuarios específicos en el proceso de auditoría.

Una vez dicho esto, voy a proceder a realizar la práctica de auditoría de bases de datos.

---

# Actividades.
## **1. Activa desde SQL*Plus la auditoría de los intentos de acceso no exitosos al sistema. Comprueba su funcionamiento.**

Para este ejercicio lo que voy a hacer es entrar en sqlplus, como hemos hecho hasta ahora, por lo que en mi caso dejo este [script](https://github.com/alejandrolf20/ABD_Usuarios/blob/main/Alumno4/oracle-pasos.md) para poder entrar.

Luego de haber entrado como **sysdba**, para una mejor visión de los resultados, tendremos que hacer lo siguiente:

```sql
COLUMN name FORMAT A30;
COLUMN value FORMAT A20;
```

Llegados a este momento, lo que vamos a hacer es una comprobación por si las auditorías está activadas en lo que es nuestra base de datos, por lo que vamos a ejecutar la siguiente consulta SQL,en ORACLE depende de un parámetro de sistema, `AUDIT_TRAIL`.

```sql
SQL> show parameter audit

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_file_dest 		     string	 /opt/oracle/admin/ORCLCDB/adum
						 p
audit_syslog_level		     string
audit_sys_operations		     boolean	 TRUE
audit_trail			     string	 DB
unified_audit_common_systemlog	     string
unified_audit_sga_queue_size	     integer	 1048576
unified_audit_systemlog 	     string
```

Como podemos observar `AUDIT_TRAIL`, nos sale con el valor `DB`, por lo que quiere decir que las auditorías estan activadas, esto puede tener tres valores distibto, aquí te los dejo, y lo que tendrias que hacer para poder activarlos:

```sql

`NONE`: No se realiza ninguna auditoría.

`DB`: Se realiza una auditoría en la base de datos.

`OS`: Se realiza una auditoría en el sistema operativo.
```

Para poder realizar dicha auditoría, la tendremos que activala, por lo que haremos uso del siguiente comando SQL:

```sql
ALTER SYSTEM SET audit_trail=db scope=spfile;
```
Luego de esto tendriamos que aplicar los cambios, por lo que tendríamos que reiniciar lo que es la instancia:

```sql
SQL> SHUTDOWN INMEDIATE;
SQL> STARTUP;
```
Y una vez hecho esto, volvemos a comprobar cn esta consulta SQL:

```sql
show parameter audit_trail
```
Y nos saldrá el valor, el cual seria `DB`:

```sql
SQL> show parameter audit_trail

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_trail			     string	 DB

```
- **Nota**: Dejo por aquí un [script](./Auditoria.md) en el cual tengo que hacerlo cuando deshabilito en mi Oracle.


Ahora que asumimos que la auditoría está activada, vamos a plantear un caso práctico basado en una situación real. En este caso, para registrar los intentos fallidos de acceso a la base de datos, será necesario tener habilitada la auditoría de inicio de sesión, específicamente la auditoría de intentos fallidos al sistema.

Por lo que vamos a hacer con los siguientes comandos:

```sql
AUDIT SESSION WHENEVER NOT SUCCESSFUL;


audit session by JABATO;
```

Por pantalla veremos lo siguiente:

```sql
SQL> AUDIT SESSION WHENEVER NOT SUCCESSFUL;

Auditoria terminada correctamente.

SQL> audit session by JABATO;

Auditoria terminada correctamente.
```
Ahora procederé a entrar en la base de datos, y fallaré un par de veces y entraré en alguna.

```sql
SQL> CONNECT JABATO/brasil@localhost:1521/ORCLPDB1;
ERROR:
ORA-01017: nombre de usuario/contrase?a no validos; conexion denegada


Advertencia: !Ya no esta conectado a ORACLE!
SQL> CONNECT JABATO/eurotruck@localhost:1521/ORCLPDB1;
ERROR:
ORA-01017: nombre de usuario/contrase?a no validos; conexion denegada


SQL> CONNECT JABATO/jabato@localhost:1521/ORCLPDB1;
ERROR:
ORA-28002: la contrase?a vencera en 7 dias


Conectado.
```

Y ahora lo que haremos será la comprobación del contenido de la tabla `dba_audit_session`, podremos observar el registro de intentos fallidos:

```sql
SQL> SELECT USERNAME, OS_USERNAME, TIMESTAMP, ACTION_NAME, RETURNCODE
FROM dba_audit_session
WHERE username = 'JABATO';
```

Y esto nos mostrará por pantalla lo siguiente:

![ENtrada-fallida](entrada-fallida.png)

Donde:

- El primer registro indica un inicio de sesión exitoso (código de retorno 0), lo que significa que el usuario JABATO accedió correctamente a la base de datos.
- En los segundo y tercer registros, se observan intentos de inicio de sesión fallidos (código de retorno 1017), lo que sugiere que hubo errores al intentar acceder con el usuario JABATO, obviamente por una contraseña incorrecta.
- El cuarto registro refleja un cierre de sesión exitoso (código de retorno 0), lo que confirma que JABATO cerró la sesión de manera adecuada.

Esto es lo que nos ha pedido el ejercicio, para acabar podriamos deshabilitar lo que es la auditoria con el siguiente comando:

```sql
ALTER SYSTEM SET AUDIT_TRAIL=NONE SCOPE=SPFILE;
```

Dejo los coamndos de como dehabilitar el proceso:

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

![Deshabiltación de auditoria.](Deshabilitar-auditoria.png)


Obviamente hay más codigos de errores, por lo que voy a dejar por aquí una lista de algunos, que pueden ser útiles, por si hayq ue usarlos tenerlos a mano:

| **Código de Error** | **Mensaje**                                                                                           | **Descripción**                                                                                           |
|---------------------|------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| 911                 | El dato ingresado contiene caracteres no válidos                                                      | Este error ocurre cuando los datos introducidos en un campo contienen caracteres no válidos para el sistema.|
| 1004                | Acceso denegado: no tienes permisos suficientes para realizar esta operación                          | El usuario no tiene los permisos necesarios para ejecutar la operación solicitada.                         |
| 1017                | Nombre de usuario o contraseña inválidos                                                              | Este error se produce cuando el usuario o la contraseña proporcionada no son correctos.                   |
| 1045                | Permiso denegado: no tienes el privilegio de crear una sesión                                        | El usuario intenta crear una sesión, pero no tiene el privilegio adecuado para hacerlo.                   |
| 28000               | La cuenta está bloqueada debido a intentos de inicio de sesión fallidos                               | La cuenta ha sido bloqueada temporalmente por varios intentos fallidos de inicio de sesión.               |
| 28001               | La contraseña ha caducado y debe ser cambiada                                                          | La contraseña del usuario ha expirado y necesita ser cambiada para continuar utilizando la cuenta.         |
| 28002               | La contraseña caducará pronto, por favor cámbiala                                                      | La contraseña está próxima a expirar, y se recomienda cambiarla antes de que caduque.                     |
| 28003               | La contraseña no cumple con los requisitos mínimos de complejidad                                      | La contraseña no cumple con las políticas de seguridad mínimas (como longitud, caracteres especiales, etc.).|
| 28007               | No puedes reutilizar una contraseña previamente utilizada                                             | El sistema no permite que el usuario vuelva a utilizar una contraseña que ya haya usado anteriormente.     |
| 28008               | Contraseña anterior no válida                                                                          | La contraseña proporcionada como "anterior" no es válida o no coincide con la registrada en el sistema.   |
| 28009               | La conexión a SYS debe realizarse a través de SYSDBA o SYSOPER                                        | El usuario intenta conectarse a la cuenta `SYS`, pero no lo hace con el privilegio adecuado (SYSDBA o SYSOPER).|
| 28011               | La contraseña caducará pronto, por favor cámbiala                                                      | Similar al error 28002, indica que la contraseña del usuario está cerca de expirar y debe ser cambiada.    |



---
## **2. Realiza un procedimiento en PL/SQL que te muestre los accesos fallidos junto con el motivo de los mismos, transformando el código de error almacenado en un mensaje de texto comprensible. Contempla todos los motivos posibles para que un acceso sea fallido.**

Para este ejercicio lo que voy a hacer es que nos traduzca lo que son los codigo que vimos antes por pantalla, es decir esto:

```sql
SQL> CONNECT JABATO/brasil@localhost:1521/ORCLPDB1;
ERROR:
ORA-01017: nombre de usuario/contrase?a no validos; conexion denegada


Advertencia: !Ya no esta conectado a ORACLE!
SQL> CONNECT JABATO/eurotruck@localhost:1521/ORCLPDB1;
ERROR:
ORA-01017: nombre de usuario/contrase?a no validos; conexion denegada


SQL> CONNECT JABATO/jabato@localhost:1521/ORCLPDB1;
ERROR:
ORA-28002: la contrase?a vencera en 7 dias
```

Y que nos aparezca por pantalla solo el error traducido al castellano, es decir, sin código. Por lo que haré una función que contenga dichos errores.

- Función 

```sql
CREATE OR REPLACE FUNCTION TraduccionCodigo(p_error NUMBER)
RETURN VARCHAR2
IS
    mensaje VARCHAR2(200);
BEGIN
    CASE p_error
        WHEN 911 THEN
            mensaje := 'El dato ingresado contiene caracteres no válidos';
        WHEN 1004 THEN
            mensaje := 'Acceso denegado: no tienes permisos suficientes para realizar esta operación';
        WHEN 1017 THEN
            mensaje := 'Nombre de usuario o contraseña inválidos';
        WHEN 1045 THEN
            mensaje := 'Permiso denegado: no tienes el privilegio de crear una sesión';
        WHEN 28000 THEN
            mensaje := 'La cuenta está bloqueada debido a intentos de inicio de sesión fallidos';
        WHEN 28001 THEN
            mensaje := 'La contraseña ha caducado y debe ser cambiada';
        WHEN 28002 THEN
            mensaje := 'La contraseña caducará pronto, por favor cámbiala';
        WHEN 28003 THEN
            mensaje := 'La contraseña no cumple con los requisitos mínimos de complejidad';
        WHEN 28007 THEN
            mensaje := 'No puedes reutilizar una contraseña previamente utilizada';
        WHEN 28008 THEN
            mensaje := 'Contraseña anterior no válida';
        WHEN 28009 THEN
            mensaje := 'La conexión a SYS debe realizarse a través de SYSDBA o SYSOPER';
        WHEN 28011 THEN
            mensaje := 'La contraseña caducará pronto, por favor cámbiala';
        
        ELSE
            mensaje := 'Contacta con el administrador para obtener más información sobre el error';
    END CASE;
    RETURN mensaje;
END TraduccionCodigo;
/
```
- Procedimiento principal:

```sql
CREATE OR REPLACE PROCEDURE AccesosFallidos
IS
    CURSOR c_accesos IS
        SELECT username, returncode, timestamp
        FROM dba_audit_session
        WHERE action_name='LOGON'
        AND returncode != 0
        ORDER BY timestamp;
    v_motivo VARCHAR2(200);
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(9)||CHR(9)||'-- ACCESOS FALLIDOS --');
    DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(9)||'USUARIO'||CHR(9)||CHR(9)||'FECHA'||CHR(9)||CHR(9)||CHR(9)||'DESCRIPCION');
    DBMS_OUTPUT.PUT_LINE(CHR(9)||'----------------------------------------------------------------');
    FOR acceso IN c_accesos LOOP
        v_motivo := TraduccionCodigo(acceso.returncode);
        DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(9)||acceso.username||CHR(9)||CHR(9)||TO_CHAR(acceso.timestamp,'YY/MM/DD DY HH24:MI')||CHR(9)||v_motivo);
    END LOOP;
END AccesosFallidos;
/
```
y para ejecutarlo lo que tendría que hacer es hacer lo siguiente:

```sql
SET SERVEROUTPUT ON;
```
Y ejecutar lo que sería la función principal

```sql
EXEC AccesosFallidos;
```

Por lo que voy a prbar cada uno, para ello lo que haré será fallar a proposito, y por ende tendremos todos los fallos, en pantalla:

```sql
		
		-- ACCESOS FALLIDOS --

	USUARIO		FECHA			DESCRIPCION
	----------------------------------------------------------------

	JABATO		25/02/17 LUN 17:29	Nombre de usuario o contrase??a inv??lidos

	JABATO		25/02/17 LUN 17:29	Nombre de usuario o contrase??a inv??lidos

	JABATO		25/02/17 LUN 17:45	El dato ingresado contiene caracteres no v??lidos

	JABATO		25/02/17 LUN 18:16	La cuenta est?? bloqueada debido a intentos de inicio de sesi??n fallidos

	JABATO		25/02/17 LUN 18:33	La contrase??a ha caducado y debe ser cambiada

	JABATO		25/02/17 LUN 19.41	La contrase??a caducar?? pronto, por favor c??mbiala

	JABATO		25/02/17 LUN 19.42	La contrase??a no cumple con los requisitos m??nimos de complejidad

	JABATO		25/02/17 LUN 19.42	No puedes reutilizar una contrase??a previamente utilizada

	JABATO		25/02/17 LUN 19.43	Contrase??a anterior no v??lida

	JABATO		26/02/17 LUN 10.12	La conexi??n a SYS debe realizarse a trav??s de SYSDBA o SYSOPER

	JABATO		26/02/17 LUN 13.14	La contrase??a caducar?? pronto, por favor c??mbiala

	JABATO		27/02/17 LUN 01.32	Acceso denegado: no tienes permisos suficientes para realizar esta operaci??n

	JABATO		27/02/17 LUN 11.53	Contacta con el administrador para obtener m??s informaci??n sobre el error

Procedimiento PL/SQL terminado correctamente.

```

---
## **3. Activa la auditoría de las operaciones DML realizadas por el usuario Prueba en tablas de su esquema. Comprueba su funcionamiento.**

Para este ejercicio, lo que tenemos que tener en cuenta es que en esta auditoría se incluirán cualquier sentencia que modifique cualqueir dato de la base de datos, por lo que tenemos que tener claras cuales son las sentencias:

- `Insert`
- `Delete`
- `Update`


Por lo que para empezar la **auditoría DML** lo que tendremos que hacer es meter el siguiente comando por consola:

```sql
SQL> AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE BY SCOTT BY ACCESS;  
```
Para no manchar lo que es las tablas del esquema SCOTT, lo que haré será crear lo que es una tabla y meterle registros:

```sql
SQL> CREATE TABLE PRACTICA(NOMBRE VARCHAR2(20),APELLIDO VARCHAR2(30));

Tabla creada.

SQL> INSERT INTO PRACTICA VALUES('Andrés','Rojas de las margaritas');

1 fila creada.

SQL> INSERT INTO PRACTICA VALUES('Concha','de la Rosa');

1 fila creada.

SQL> UPDATE PRACTICA SET APELLIDO = 'Morales' WHERE NOMBRE='Andrés';

1 fila actualizada.

SQL> DELETE FROM PRACTICA WHERE NOMBRE = 'Andrés';

1 fila suprimida.

```

Una vez hecho esto lo que haré sera conectarme de nuevo como sysdba, o como administrador en este caso, será para lo que es la auditoría, con el siguiente comando:

```sql
SQL> AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE BY SCOTT BY ACCESS;  

Auditoria terminada correctamente.
```

Una vez cerrada la auditoria, lo que tendremos que hacer es proceder a ver que ha pasado mientas nosotros nos hemos estado tomando un café y nuestro usuairo favorito Scott ha estado trasteando en la base de datos, por lo que usaremos lo siguiente:

```sql
SQL> SELECT obj_name, action_name, timestamp FROM dba_audit_object WHERE username='C##SCOTT';

```

Y esto nos mostrará por pantalla lo que nuestro querido usuario ha estado haciendo en las tablas, por lo que veremos por pantalla lo siguiente:

```sql
QL> SELECT OBJ_NAME, ACTION_NAME, TIMESTAMP
FROM DBA_AUDIT_TRAIL
WHERE USERNAME = 'SCOTT';   2    3  

OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------

LOGON			     17/02/25


LOGON			     20/02/25

PRACTICA
INSERT			     20/02/25


OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------
PRACTICA
INSERT			     20/02/25

PRACTICA
UPDATE			     20/02/25

PRACTICA
DELETE			     20/02/25


OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------

LOGON			     17/02/25


LOGON			     17/02/25


LOGOFF			     17/02/25


OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------

LOGOFF			     20/02/25


10 filas seleccionadas.
```

Por lo que de esta forma, va a quedar un registro de todas las operacines **DML** va a ejecutar el usuario **SCOTT**.

---

## 4. **Realiza una auditoría de grano fino para almacenar información sobre la inserción de empleados con comisión en la tabla emp de scott.**

Ahora lo que vamos a realizar es una auditoría de grano fino, pero te estará preguntado que est, lo que te acabo de comentar pues es ni más ni menos que un acaracteristica de Oracle Database en la cual nos va a permitir regustrar cambios que se producen en los datos de una base de datos.

Esta auditoria lo que hace es registrar los cambios que se estan produciendo en los mismos datos, por lo que es bastante interesante ya que nos va a permitir saber a ciencia cierta que datios y quien lo han cambiado.

Por lo que para ello vamos a hacer un experimento con nuetsro usuario Scott, en este caso se va a llamar Scotty, ya que nuestro anterior soldado, por desgracia perecio en la guerra llamada GBA del IES Gonzalo Nazareno.

Pero es su hijo así que no pasa nada, hará honor a su nombre.

Lo primero que vamos a hacer es crear un procedimiento para que, un objeto en concreto de una tabla, se audite cuando se realice una inserción en dicha tabla.

```sql
BEGIN
    DBMS_FGA.ADD_POLICY (
        object_schema => 'SCOTTY',
        object_name => 'EMP',
        policy_name => 'ejercicio4auditoria',
        audit_condition => 'SAL > 2000',
        statement_types => 'INSERT');
END;
/
```
Donde:

- `object_schema`: Es el esquema donde reside la tabla (en este caso, SCOTTY).
- `object_name`: El nombre de la tabla que estamos auditando (EMP).
- `policy_name`: Nombre de la política de auditoría (ejercicio4auditoria).
- `audit_condition`: Condición bajo la cual se auditan los registros. En este caso, se auditarán las inserciones donde el salario (SAL) sea mayor a 2000.
- `statement_types`: Tipos de sentencias SQL que activan la auditoría, en este caso, solo las INSERT.

Por pantalla nos mostrara lo siguiente:

```sql
SQL> BEGIN
    DBMS_FGA.ADD_POLICY (
        object_schema => 'SCOTTY',
        object_name => 'EMP',
        policy_name => 'ejercicio4auditoria',
        audit_condition => 'SAL > 2000',
        statement_types => 'INSERT');
END;
/  2    3    4    5    6    7    8    9  

Procedimiento PL/SQL terminado correctamente.
```
COmo estamos en dos terminales, y podemos hacer dos cosas a la vez lo que voamos a proceder es a coger y meter algunos datos:

```sql
INSERT INTO EMP VALUES(7958, 'GANSO', 'ARENOSO', 7698,TO_DATE('8-SEP-1981', 'DD-MON-YYYY'), 2001, 0, 30);
INSERT INTO EMP VALUES(7959, 'ROBY', 'RETOS', 7788,TO_DATE('12-ENE-1983', 'DD-MON-YYYY'), 1999, NULL, 20);
INSERT INTO EMP VALUES(7985, 'ANDRES', 'MORALES', 7698,TO_DATE('3-DIC-1981', 'DD-MON-YYYY'), 3395, NULL, 30);
INSERT INTO EMP VALUES(7999, 'DAVID', 'BATISTA', 7566,TO_DATE('3-DIC-1981', 'DD-MON-YYYY'), 3000, NULL, 20);
INSERT INTO EMP VALUES(8010, 'RANDY', 'ORTON', 7782,TO_DATE('23-ENE-1982', 'DD-MON-YYYY'), 2100, NULL, 10);
```

Una vez insertado a nuestros nuevos empleados con sus sueldos de **SCOTTY**, lo que vamos a comprobar desde **SYSDBA** es la auditoria de grano fino que pusimos antes, por lo que vamos a ejecutarla en este momento:

```sql

SELECT DB_USER, OBJECT_NAME, SQL_TEXT, CURRENT_USER, TIMESTAMP
FROM DBA_FGA_AUDIT_TRAIL
WHERE POLICY_NAME = 'EJERCICIO4AUDITORIA';
```
Lo he puesto de esta manera, pero se ve super mal por el formato, por lo que usare el siguiente comando, por lo menos para que se vea un poco mejor:

```sql
SELECT sql_text FROM dba_fga_audit_trail WHERE policy_name='EJERCICIO4AUDITORIA';
```

Ambas consultas nos van a mostrar exactamente lo mismo, pero la presentación por lo que es consola se ve horrible, y ahora lo que vemos es lo siguiente:

```sql
SQL> SELECT sql_text FROM dba_fga_audit_trail WHERE policy_name='EJERCICIO4AUDITORIA';

SQL_TEXT
--------------------------------------------------------------------------------
INSERT INTO EMP VALUES(7958, 'GANSO', 'ARENOSO', 7698,TO_DATE('8-SEP-1981', 'DD-
MON-YYYY'), 2001, 0, 30)

INSERT INTO EMP VALUES(7958, 'GANSO', 'ARENOSO', 7698,TO_DATE('8-SEP-1981', 'DD-
MON-YYYY'), 2001, 0, 30)

INSERT INTO EMP VALUES(7985, 'ANDRES', 'MORALES', 7698,TO_DATE('3-DIC-1981', 'DD
-MON-YYYY'), 3395, NULL, 30)

INSERT INTO EMP VALUES(7999, 'DAVID', 'BATISTA', 7566,TO_DATE('3-DIC-1981', 'DD-
MON-YYYY'), 3000, NULL, 20)

SQL_TEXT
--------------------------------------------------------------------------------

INSERT INTO SCOTTY.EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VAL
UES (7958, 'GANSO', 'ARENOSO', 7698, TO_DATE('8-SEP-1981', 'DD-MON-YYYY'), 2001,
 0, 30)

INSERT INTO SCOTTY.EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VAL
UES (7985, 'ANDRES', 'MORALES', 7698, TO_DATE('3-DIC-1981', 'DD-MON-YYYY'), 3395
, NULL, 30)

INSERT INTO SCOTTY.EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VAL
UES (7999, 'DAVID', 'BATISTA', 7566, TO_DATE('3-DIC-1981', 'DD-MON-YYYY'), 3000,

SQL_TEXT
--------------------------------------------------------------------------------
 NULL, 20)

INSERT INTO SCOTTY.EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VAL
UES (8010, 'RANDY', 'ORTON', 7782, TO_DATE('23-ENE-1982', 'DD-MON-YYYY'), 2100,
NULL, 10)

INSERT INTO EMP VALUES(8010, 'RANDY', 'ORTON', 7782,TO_DATE('23-ENE-1982', 'DD-M
ON-YYYY'), 2100, NULL, 10)


9 filas seleccionadas.
```

Y como podemos observar tenemos al sequito que acabamos de meter por inserciones para lo que sería etsa practica.


---
## 5. **Explica la diferencia entre auditar una operación by access o by session ilustrándolo con ejemplos.**

---
**## 6. Documenta las diferencias entre los valores db y db, extended del parámetro audit_trail de ORACLE. Demuéstralas poniendo un ejemplo de la información sobre una operación concreta recopilada con cada uno de ellos.**
**## 7. Averigua si en Postgres se pueden realizar los cuatro primeros apartados. Si es así, documenta el proceso adecuadamente.**
**## 8. Averigua si en MySQL se pueden realizar los apartados 1, 3 y 4. Si es así, documenta el proceso adecuadamente.**
**## 9. Averigua las posibilidades que ofrece MongoDB para auditar los cambios que va sufriendo un documento. Demuestra su funcionamiento.**
**## 10. Averigua si en MongoDB se pueden auditar los accesos a una colección concreta. Demuestra su funcionamiento.**
**## 11. Averigua si en Cassandra se pueden auditar las inserciones de datos.**


# Bibliografía 

- [COMO REALIZAR UNA TRAZA DE UN USUARIO EN ORACLE](https://orasite.com/tutoriales/auditoria-de-base-de-datos-oracle/traza-trc-oracle-usuario-activar)
- [Errores más comunes de Oracle](https://orasite.com/errores)
- 