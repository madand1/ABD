#### Fallo de permisos. 

Para llegar a esto nos dío el siguiente fallo, y es un fallo de permisos, por lo que dejo por aquí el fallo que dío:

```sql
byron=# SELECT export_csv('byron', '/home/andy/' );
ERROR:  no se pudo abrir el archivo «/home/andy/emp.csv» para escritura: Permiso denegado
SUGERENCIA:  COPY TO indica al proceso servidor PostgreSQL escribir a un archivo. Puede desear usar facilidades del lado del cliente, como \copy de psql.
CONTEXTO:  sentencia SQL: «COPY emp TO '/home/andy/emp.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER TRUE)»
función PL/pgSQL export_csv(text,text) en la línea 11 en EXECUTE
byron=# 
\q

```
Para arreglarlo hice lo siguiente:

```bash
andy@postgreSQL:~$ sudo chmod 777 /home/andy/
```