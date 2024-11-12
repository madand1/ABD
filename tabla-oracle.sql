
# Para and1

CREATE TABLE Clientes
(
    ID              VARCHAR2(9),
    Nombre          VARCHAR2(30),
    Direccion       VARCHAR2(40),
    Telefono        VARCHAR2(9),
    FechaRegistro   DATE,
    Credito         NUMBER(6),
    Sector          NUMBER(2),
    CONSTRAINT pk_clientes PRIMARY KEY (ID),
    CONSTRAINT nombre_no_vacio CHECK (Nombre IS NOT NULL)
);

INSERT INTO Clientes VALUES ('C001', 'Carlos Benitez Ruiz', 'Av. de la Paz, 112', '625493014', TO_DATE('2022-01-15', 'YYYY-MM-DD'), 1500, 10);
INSERT INTO Clientes VALUES ('C002', 'Ana Gomez Pardo', 'C/ Mayor, 45', '631824589', TO_DATE('2021-05-23', 'YYYY-MM-DD'), 5000, 20);
INSERT INTO Clientes VALUES ('C003', 'Juan Pedro Marquez', 'Paseo del Prado, 77', '644902357', TO_DATE('2023-03-11', 'YYYY-MM-DD'), 2200, 10);
INSERT INTO Clientes VALUES ('C004', 'Lorena Vargas Diaz', 'C/ Alcala, 9', '617293874', TO_DATE('2020-12-02', 'YYYY-MM-DD'), 3500, 30);
INSERT INTO Clientes VALUES ('C005', 'Miguel Torres Gomez', 'Av. Libertad, 85', '650281972', TO_DATE('2019-08-14', 'YYYY-MM-DD'), 4700, 40);
INSERT INTO Clientes VALUES ('C006', 'Maria Fernanda Perez', 'C/ Serrano, 19', '655983021', TO_DATE('2022-07-08', 'YYYY-MM-DD'), 2800, 20);
INSERT INTO Clientes VALUES ('C007', 'Alberto Ruiz Calderon', 'Av. Reina Sofia, 22', '612937546', TO_DATE('2021-11-29', 'YYYY-MM-DD'), 1300, 30);
INSERT INTO Clientes VALUES ('C008', 'Susana Navas Rubio', 'Paseo de la Castellana, 5', '679451230', TO_DATE('2020-09-10', 'YYYY-MM-DD'), 3900, 10);
INSERT INTO Clientes VALUES ('C009', 'Jose Luis Torres', 'C/ Gran Via, 65', '615289430', TO_DATE('2018-04-27', 'YYYY-MM-DD'), 5600, 40);
INSERT INTO Clientes VALUES ('C010', 'Daniela Lopez Paredes', 'C/ Alcobendas, 43', '602198723', TO_DATE('2021-06-05', 'YYYY-MM-DD'), 4400, 20);


******************************************************************************************

# Para and2

CREATE TABLE Sectores
(
    Identificador   NUMBER(2),
    Nombre          VARCHAR2(20),
    Ubicacion       VARCHAR2(15),
    CONSTRAINT pk_sectores PRIMARY KEY (Identificador),
    CONSTRAINT ubicacion_no_vacia CHECK (Ubicacion IS NOT NULL)
);

INSERT INTO Sectores VALUES (10, 'Marketing', 'Madrid');
INSERT INTO Sectores VALUES (20, 'Ventas', 'Barcelona');
INSERT INTO Sectores VALUES (30, 'Soporte', 'Sevilla');
INSERT INTO Sectores VALUES (40, 'Desarrollo', 'Valencia');
