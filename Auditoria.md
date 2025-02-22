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
SQL> SELECT obj_name, action_name, timestamp FROM dba_audit_object WHERE username='SCOTT';

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

En las auditorías de un SGBD, podemos diferenciar dos tipos principales de auditoría:

- `Auditoría by access`: Registra cada vez que ocurre una acción específica, sin importar quién la realice o cuándo suceda. Es más detallada que la auditoría By Session, ya que permite un seguimiento preciso de eventos individuales.


- `Auditoría by session`: Registra toda la actividad realizada por un usuario durante su sesión. En lugar de auditar acciones individuales, se monitorea todo lo que sucede desde que el usuario inicia sesión hasta que la finaliza.


#### Comprobaciones

Ahora lo que haremos será algunas comprobaciones para ambas auditorias con nuestro super agente **SCOTTY**, por lo que vamos a proceder a realizarlas:

- ```By Session```

Para este caso, ejecutaremos el siguiente comando en SQL como usuario SYSDBA:

```sql
SQL> AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE BY SCOTTY BY SESSION;      

Auditoria terminada correctamente.

```
Ahora, en otra terminal, nos conectaremos como el usuario SCOTTY y realizaremos algunas operaciones sobre la tabla DEPT.

- Lo primero que hacemos es realizar alguna incersiones een la tabla DEPT:

```
SQL> INSERT INTO DEPT VALUES (70, 'ORCOS', 'ESPACIALES');

1 fila creada.

SQL> INSERT INTO DEPT VALUES (90, 'ANGELES', 'GUERRERAS');

1 fila creada.

```
- Segundo hacemos una acutualización de la localización de la inserción con valor 90:

```sql
SQL> UPDATE DEPT SET loc='TERRA' WHERE deptno=90;

1 fila actualizada.
```

- Tercero borramos la fila que hemos metido referentes a los ángeles, ya que en esta casa somos equipo Orcos:

```sql

SQL> DELETE FROM dept WHERE deptno=90;

1 fila suprimida.

```

Para verificar los eventos registrados, volvemos a conectarnos como SYSDBA y ejecutamos la siguiente consulta:

```sql
SQL> SELECT obj_name, action_name, timestamp FROM dba_audit_object WHERE username='SCOTTY';
```
Y el resultado que nos dará será el siguiente:

```sql
SQL> SELECT obj_name, action_name, timestamp FROM dba_audit_object WHERE username='SCOTTY';

OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------
DEPT
SESSION REC		     22/02/25

DEPT
SESSION REC		     22/02/25

DEPT
SESSION REC		     22/02/25


OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------
DEPT
SESSION REC		     22/02/25


SQL> 
```

- Auditoría by access

ara este caso, ejecutaremos el siguiente comando en SQL como usuario SYSDBA:

```sql
SQL> AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE BY SCOTTY BY ACCESS;

Auditoria terminada correctamente.

```

Ahora, en otra terminal, nos conectaremos como el usuario SCOTTY y realizaremos algunas operaciones sobre la tabla DEPT.

- Lo primero que hacemos es realizar alguna incersiones een la tabla DEPT:

```sql
SQL> INSERT INTO DEPT VALUES (70, 'ORCOS', 'ESPACIALES');

1 fila creada.

SQL> INSERT INTO DEPT VALUES (90, 'ANGELES', 'GUERRERAS');

1 fila creada.

```
- Segundo hacemos una acutualización de la localización de la inserción con valor 90:

```sql
SQL> UPDATE DEPT SET loc='TERRA' WHERE deptno=90;

1 fila actualizada.
```

- Tercero borramos la fila que hemos metido referentes a los ángeles, ya que en esta casa somos equipo Orcos:

```sql

SQL> DELETE FROM dept WHERE deptno=90;

1 fila suprimida.

```

Luegod de esto lo que tendremos que hacer es volver a la terminal de SYSDBA, y ejecutar lo siguiente por línea de comando:

```sql
SELECT obj_name, action_name, timestamp FROM dba_audit_object WHERE username='SCOTTY';
```

y esto es lo que nos muestra por pantalla:

```sql
SQL> SELECT obj_name, action_name, timestamp FROM dba_audit_object WHERE username='SCOTTY';

OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------
DEPT
INSERT			     22/02/25

DEPT
INSERT			     22/02/25

DEPT
UPDATE			     22/02/25


OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------
DEPT
DELETE			     22/02/25

DEPT
SESSION REC		     22/02/25

DEPT
SESSION REC		     22/02/25


OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------
DEPT
SESSION REC		     22/02/25

DEPT
SESSION REC		     22/02/25

DEPT
SESSION REC		     22/02/25


OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAM
---------------------------- --------
DEPT
SESSION REC		     22/02/25


10 filas seleccionadas.
```


Como conclusión:

📌 **Auditoría By Access**

- Registra cada vez que ocurre una acción específica, sin importar quién la realice o cuándo suceda.

- Es más detallada que la auditoría By Session, ya que permite un seguimiento preciso de eventos individuales.

📌 **Auditoría By Session**

- Registra toda la actividad realizada por un usuario durante su sesión.

- En lugar de auditar acciones individuales, monitorea todo lo que sucede desde que el usuario inicia sesión hasta que la finaliza.
---

## **6. Documenta las diferencias entre los valores db y db_extended del parámetro audit_trail de ORACLE. Demuéstralas poniendo un ejemplo de la información sobre una operación concreta recopilada con cada uno de ellos.**

Lo primero que haremos mención sera al parametro `AUDIT_TRAIL` en Oracle, es el que permite **controlar cómo se almacenan los registros de auditoria** en la base de datos.

Ahora vamos a explicar dos valores bastante importantes de este parametro que acabamos de hacer mención:

- `AUDIT_TRAIL = DB`

📌 ¿Qué hace?

- Guarda los registros de auditoría en la base de datos, dentro de la tabla SYS.AUD$.
- No almacena información sobre los comandos SQL completos, solo los eventos auditados.
- Se usa cuando queremos gestionar la auditoría desde la propia base de datos.

📌 Importante:

- Si la base de datos se inicia en modo solo lectura, este parámetro cambia automáticamente a OS (almacenando la auditoría en el sistema operativo).


- `AUDIT_TRAIL = DB_EXTENDED`

📌 ¿Qué hace?

- Hace lo mismo que DB, pero con más detalles.
- Además de los registros básicos, guarda el texto completo de las sentencias SQL ejecutadas.
- También almacena información adicional, como valores de enlaces SQL y políticas de seguridad de Oracle Virtual Private Database (VPD).

📌 Importante:

- Si la base de datos está en modo solo lectura, este parámetro también cambia automáticamente a OS.


Dejaré por aquí un cuadro para saber cual elegir dependiendo de las necesidades:

| Valor            | ¿Dónde se almacenan los registros? | ¿Qué información guarda?                        |
|-----------------|----------------------------------|------------------------------------------------|
| `DB`            | Tabla `SYS.AUD$` en la base de datos | Eventos auditados (básico)                     |
| `DB_EXTENDED`   | Tabla `SYS.AUD$` en la base de datos | Eventos auditados + Texto SQL completo + Valores de enlaces SQL |

En conclusión si necesItamoS un registro super detallado, de las consultas SQL, usaremos `DB_EXTENDED`.

Si solo necesitamos un regustro básico, usaremos `DB`.


Ahora vamos a hacer unas cuantas de comprobaciones, por lo que primero que vamos a hacer es ver en que valor tenemos `AUDIT_TRAIL`, como ya hicimos mención al comando lo vuelvo a dejar por aqui:

```sql
SHOW PARAMETER AUDIT_TRAIL;
```
Y esto nos mostrará por pantalla lo siguiente:

```sql

SQL> SHOW PARAMETER AUDIT_TRAIL;

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_trail			     string	 DB
SQL> 
```

COmo podemos observar el `audit_trail` ya se encuentra con el valor `DB`, por lo que voy a ejecutar sentencias en nuestro conejillo de indias llamado **SCOTTY** para poder regustarrlo y hacer una comprobación de datos, por lo que dejo por aquí laas sentencias que hare:
```sql
SQL> INSERT INTO DEPT VALUES (90, 'ANGELES', 'GUERRERAS');

1 fila creada.

SQL> UPDATE DEPT SET loc='TERRA' WHERE deptno=90;

1 fila actualizada.

SQL> DELETE FROM dept WHERE deptno=90;

1 fila suprimida.
```

Luego de hacer las inserciones, lo que tendremos que hacer es desde SYSDBA es realizar la siguiente consulta:

```sql
SQL> SELECT OS_USERNAME, USERNAME, USERHOST, TERMINAL, ACTION_NAME, SESSIONID, EXTENDED_TIMESTAMP, SQL_TEXT
FROM DBA_AUDIT_TRAIL
WHERE USERNAME = 'SCOTTY'
ORDER BY EXTENDED_TIMESTAMP DESC;
```

Esto nos va a mostrar por pantalla lo siguiente:


| OS_USERNAME | USERNAME | USERHOST | TERMINAL | ACTION_NAME  | SESSIONID | EXTENDED_TIMESTAMP              | SQL_TEXT |
|------------|----------|----------|----------|-------------|----------|------------------------------|----------|
| oracle     | SCOTTY   | madand1  | pts/3    | DELETE      | 590023   | 22/02/25 10:41:33,291820 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | UPDATE      | 590023   | 22/02/25 10:41:25,561355 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | INSERT      | 590023   | 22/02/25 10:41:15,729080 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | INSERT      | 590023   | 22/02/25 10:41:01,764152 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | INSERT      | 590023   | 22/02/25 10:40:39,956359 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | INSERT      | 590023   | 22/02/25 10:39:51,851913 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | INSERT      | 590023   | 22/02/25 10:39:15,693490 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | DELETE      | 580021   | 22/02/25 10:13:44,488291 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | UPDATE      | 580021   | 22/02/25 10:13:38,933027 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | INSERT      | 580021   | 22/02/25 10:13:33,291861 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | INSERT      | 580021   | 22/02/25 10:13:27,923023 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | SESSION REC | 580020   | 22/02/25 10:11:39,112146 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | SESSION REC | 580020   | 22/02/25 10:11:31,145096 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | SESSION REC | 570020   | 22/02/25 10:02:59,026681 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | SESSION REC | 570020   | 22/02/25 10:01:33,904076 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | SESSION REC | 570020   | 22/02/25 09:59:17,185163 +01:00 | 0        |
| oracle     | SCOTTY   | madand1  | pts/3    | SESSION REC | 570020   | 22/02/25 09:57:32,441784 +01:00 | 0        |

**17 filas seleccionadas.**


Como podemos observar tenemos el campo vacio, o mejor dicho con valor 0 en la columna ``SQL_TEXT``, una vez hecho esto lo que vamos a proceder es a hacerlo con el parametro `DB_EXTENDED`, por lo que para ello vamos a proceder a meter el siguiente comando SQL:

```sql
ALTER SYSTEM SET audit_trail = db,extended SCOPE=SPFILE;
```

Y veremos por pantalla lo siguiente:

```sql
SQL> ALTER SYSTEM SET audit_trail = db,extended SCOPE=SPFILE;

Sistema modificado.
```
A continuación hacemos un reinicio de la base de datos, con los siguienets comandos:

```sql
SQL> SHUTDOWN IMMEDIATE;
Base de datos cerrada.
Base de datos desmontada.
Instancia ORACLE cerrada.
SQL> STARTUP;
Instancia ORACLE iniciada.

Total System Global Area 1644164936 bytes
Fixed Size		    9135944 bytes
Variable Size		 1107296256 bytes
Database Buffers	  520093696 bytes
Redo Buffers		    7639040 bytes
Base de datos montada.
Base de datos abierta.
```

Y a continuación hacemos una comprobación del cambio:

```sql
SQL>  SHOW PARAMETER audit_trail;

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_trail			     string	 DB, EXTENDED
SQL> 

```

Una vez hecho esto, pues vamos a hacer como anteriormente meter algunos registros, metere los mismos por comodidad y procedere a comprobar las diferencias:

Desde el usuario **SCOTTY**:

```sql
SQL> CONNECT SCOTTY/tiger@localhost:1521/ORCLPDB1;
ERROR:
ORA-28002: la contrase?a vencera en 7 dias


Conectado.
SQL> INSERT INTO DEPT VALUES (90, 'ANGELES', 'GUERRERAS');

1 fila creada.

SQL> UPDATE DEPT SET loc='TERRA' WHERE deptno=90;

1 fila actualizada.

SQL> DELETE FROM dept WHERE deptno=90;

1 fila suprimida.
```

Y luego nos vamos al usuario SYSDBA, y ejecutamos lo siguiente:

```sql
SQL> SELECT OS_USERNAME, USERNAME, USERHOST, TERMINAL, SES_ACTIONS, ACTION_NAME, SESSIONID, EXTENDED_TIMESTAMP, INSTANCE_NUMBER, OS_PROCESS, RETURNCODE, SQL_BIND, SQL_TEXT
FROM DBA_AUDIT_TRAIL
WHERE USERNAME = 'SCOTTY'
ORDER BY EXTENDED_TIMESTAMP DESC;  2    3    4  
```

Y esto nos muestra por pantall lo siguiente:

| OS_USERNAME | USERNAME | USERHOST | TERMINAL | ACTION_NAME | SESSIONID | EXTENDED_TIMESTAMP           | INSTANCE_NUMBER | OS_PROCESS | RETURNCODE | SQL_TEXT                                      |
|------------|---------|---------|---------|-------------|-----------|-----------------------------|----------------|------------|-----------|-----------------------------------------------|
| oracle     | SCOTTY  | madand1 | pts/3   | DELETE      | 600020    | 22/02/25 11:01:43,382140 +01:00 | 0              | 1678       | 0         | DELETE FROM dept WHERE deptno=90              |
| oracle     | SCOTTY  | madand1 | pts/3   | UPDATE      | 600020    | 22/02/25 11:01:37,887797 +01:00 | 0              | 1678       | 0         | UPDATE DEPT SET loc='TERRA' WHERE deptno=90  |
| oracle     | SCOTTY  | madand1 | pts/3   | INSERT      | 600020    | 22/02/25 11:01:27,576251 +01:00 | 0              | 1678       | 0         | INSERT INTO DEPT VALUES (90, 'ANGELES', 'GUERRERAS') |
| oracle     | SCOTTY  | madand1 | pts/3   | DELETE      | 590023    | 22/02/25 10:41:33,291820 +01:00 | 0              | 1281       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | UPDATE      | 590023    | 22/02/25 10:41:25,561355 +01:00 | 0              | 1281       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | INSERT      | 590023    | 22/02/25 10:41:15,729080 +01:00 | 0              | 1281       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | INSERT      | 590023    | 22/02/25 10:41:01,764152 +01:00 | 0              | 1281       | 1         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | INSERT      | 590023    | 22/02/25 10:40:39,956359 +01:00 | 0              | 1281       | 2291      |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | INSERT      | 590023    | 22/02/25 10:39:51,851913 +01:00 | 0              | 1281       | 2291      |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | INSERT      | 590023    | 22/02/25 10:39:15,693490 +01:00 | 0              | 1281       | 1438      |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | DELETE      | 580021    | 22/02/25 10:13:44,488291 +01:00 | 0              | 1148       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | UPDATE      | 580021    | 22/02/25 10:13:38,933027 +01:00 | 0              | 1148       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | INSERT      | 580021    | 22/02/25 10:13:33,291861 +01:00 | 0              | 1148       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | INSERT      | 580021    | 22/02/25 10:13:27,923023 +01:00 | 0              | 1148       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | SESSION REC | 580020    | 22/02/25 10:11:39,112146 +01:00 | 0              | 1141       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | SESSION REC | 580020    | 22/02/25 10:11:31,145096 +01:00 | 0              | 1141       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | SESSION REC | 570020    | 22/02/25 10:02:59,026681 +01:00 | 0              | 1117       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | SESSION REC | 570020    | 22/02/25 10:01:33,904076 +01:00 | 0              | 1117       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | SESSION REC | 570020    | 22/02/25 09:59:17,185163 +01:00 | 0              | 1117       | 0         |                                               |
| oracle     | SCOTTY  | madand1 | pts/3   | SESSION REC | 570020    | 22/02/25 09:57:32,441784 +01:00 | 0              | 1117       | 0         |                                               |


Y como podemos apreciar la columna `SQL_TEXT` se ha rellenado con lo que hicimos, es decir nos ha mostrado las sentencias que se han llevado a cabo.


**## 7. Averigua si en Postgres se pueden realizar los cuatro primeros apartados. Si es así, documenta el proceso adecuadamente.**
**## 8. Averigua si en MySQL se pueden realizar los apartados 1, 3 y 4. Si es así, documenta el proceso adecuadamente.**
**## 9. Averigua las posibilidades que ofrece MongoDB para auditar los cambios que va sufriendo un documento. Demuestra su funcionamiento.**
**## 10. Averigua si en MongoDB se pueden auditar los accesos a una colección concreta. Demuestra su funcionamiento.**
**## 11. Averigua si en Cassandra se pueden auditar las inserciones de datos.**


# Bibliografía 

- [COMO REALIZAR UNA TRAZA DE UN USUARIO EN ORACLE](https://orasite.com/tutoriales/auditoria-de-base-de-datos-oracle/traza-trc-oracle-usuario-activar)
- [Errores más comunes de Oracle](https://orasite.com/errores)
- 