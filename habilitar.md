- Deshabilitar una auditoria:

```sql
SQL> CONN / AS SYSDBA
Conectado.
SQL> ALTER SYSTEM SET AUDIT_TRAIL=NONE SCOPE=SPFILE;

Sistema modificado.

SQL> show parameter audit_trail

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_trail			     string	 DB
SQL> SHUTDOWN INMEDIATE
SP2-0717: opcion SHUTDOWN no valida
SQL> SHUTDOWN IMMEDIATE;

Base de datos cerrada.
Base de datos desmontada.
Instancia ORACLE cerrada.
SQL> SQL> STARTUP;
Instancia ORACLE iniciada.

Total System Global Area 1644164936 bytes
Fixed Size		    9135944 bytes
Variable Size		 1107296256 bytes
Database Buffers	  520093696 bytes
Redo Buffers		    7639040 bytes
Base de datos montada.
Base de datos abierta.
SQL> show parameter audit_trail

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_trail			     string	 NONE
SQL> ALTER SESSION SET CONTAINER = ORCLPDB1;

Sesion modificada.

SQL> show parameter audit

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_file_dest 		     string	 /opt/oracle/admin/ORCLCDB/adum
						 p
audit_syslog_level		     string
audit_sys_operations		     boolean	 TRUE
audit_trail			     string	 NONE
unified_audit_common_systemlog	     string
unified_audit_sga_queue_size	     integer	 1048576
unified_audit_systemlog 	     string
SQL> ALTER SYSTEM SET audit_trail=db scope=spfile;
ALTER SYSTEM SET audit_trail=db scope=spfile
*
ERROR en linea 1:
ORA-65040: operacion no permitida desde una base de datos de conexion
```
- Habilitar uan auditoria

```sql
SQL> ALTER SESSION SET CONTAINER = CDB$ROOT;

Sesion modificada.

SQL> ALTER SYSTEM SET AUDIT_TRAIL=db SCOPE=SPFILE;

Sistema modificado.

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
SQL> ALTER SESSION SET CONTAINER = ORCLPDB1;

Sesion modificada.

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