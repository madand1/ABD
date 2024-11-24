# Tipos de bloques

vamos a usar siempre bloques definidos, pero tambien tenemos bloques anonimos por lo que empiezan asi:

BEGIN 
    DBMS_OUTPUT.PUT_LINE ('hOLA QUE TAL ESTAS');
END;

Ahora iremos con los subprogramas que se encuentran dentro de los bloques definidos:

- Procedimientos

```
CREATE PROCEDURE pr_nombre IS 

    --Sección declarativa

BEGIN
    --Sección ejecutiva

EXCEPTION
    --Control de excepciones

END;
```

- Funciones 

```
CREATE FUNCTION fn_nombre
RETURN varchar2 IS
    -Seccion declarativ

BEGIN 
    --sECCIÓN EJECUTIVA
    RETURN valor;


EXCEPTION
    --control de excepciones
    RETURN valor;

END;
```

# Variables

### Variables

💬 ¿Qué son las variables?
Es como cuando pillas un colega pa’ que te guarde algo mientras tú haces otras movidas. Ese "colega" guarda datos que tú puedes usar y cambiar más tarde.

👉 Cómo declararlas
Tú dices: "Quiero guardar esto aquí" y le das un nombre, le dices qué tipo de cosa va a guardar y listo.


### Constantes

💬 ¿Qué son las constantes?
Son como un tatuaje: una vez que lo pones, ya no cambia. Es un valor fijo, que declaras al principio y te lo llevas pa’ siempre en tu programa.

👉 Cómo declararlas
Aquí va la misma vaina que las variables, pero le pones CONSTANT pa' que quede claro que no va a cambiar.

Aquí un ejemplo:

```
DECLARE
    -- Variables
    mi_nombre VARCHAR2(50);        -- Tu nombre pa’ empezar.
    edad NUMBER;                   -- Tu edad.
    dinero_en_banco NUMBER(10, 2); -- Tu pasta en el banco.

    -- Constantes
    pi CONSTANT NUMBER := 3.1416;         -- Pa’ mover círculos o lo que sea.
    dia_de_pago CONSTANT NUMBER := 15;    -- El día en que toca soltar la guita.

BEGIN
    -- Inicializamos variables
    mi_nombre := 'Juan Cani';
    edad := 22;
    dinero_en_banco := 1234.56;

    -- Usamos las variables y constantes
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || mi_nombre);
    DBMS_OUTPUT.PUT_LINE('Edad: ' || edad || ' años');
    DBMS_OUTPUT.PUT_LINE('Dinero en el banco: $' || dinero_en_banco);
    DBMS_OUTPUT.PUT_LINE('El valor de Pi es: ' || pi);
    DBMS_OUTPUT.PUT_LINE('El día de pago es el ' || dia_de_pago);

END;
/


```

Desglose:

¿Qué pasa aquí?

    - DECLARE: Aquí definimos las variables y las constantes, diciendo qué tipo de datos van a guardar.
    
    - BEGIN: Aquí empieza la acción. Le damos valores a las variables y usamos las constantes.
    
    - DBMS_OUTPUT.PUT_LINE: Esto es pa’ imprimir cosas en la consola, como si fuera tu micrófono pa’ hablarle al mundo.
  

# Funciones SQL en pl/sql

Vamos a dividirlas en:

- De control
- Numéricas
- Cadena 
- Conversion 
- Fecha

## Contorl 

- NVL 

- LENGTH 