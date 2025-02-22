-- Crear la base de datos:
CREATE DATABASE scott;

-- 1) Crear el usuario 'scott' con la contraseña 'tiger'
CREATE USER 'scott'@'localhost' IDENTIFIED BY 'tiger';

-- 2) Otorgar permisos adecuados
GRANT CONNECT ON scott.* TO 'scott'@'localhost';
GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE ON scott.* TO 'scott'@'localhost';

-- 3) Crear las tablas en el esquema público
-- Iniciar sesión como scott antes de ejecutar estas sentencias

-- Tabla DEPT
CREATE TABLE scott.dept (
    deptno INT PRIMARY KEY,
    dname VARCHAR(14),
    loc VARCHAR(13)
);

-- Tabla EMP
CREATE TABLE scott.emp (
    empno INT PRIMARY KEY,
    ename VARCHAR(10),
    job VARCHAR(9),
    mgr INT,
    hiredate DATE,
    sal DECIMAL(7,2),
    comm DECIMAL(7,2),
    deptno INT,
    CONSTRAINT fk_deptno FOREIGN KEY (deptno) REFERENCES scott.dept (deptno)
);

-- Insertar registros en DEPT
INSERT INTO scott.dept VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO scott.dept VALUES (20, 'RESEARCH', 'DALLAS');
INSERT INTO scott.dept VALUES (30, 'SALES', 'CHICAGO');
INSERT INTO scott.dept VALUES (40, 'OPERATIONS', 'BOSTON');

-- Insertar registros en EMP
INSERT INTO scott.emp VALUES(7369, 'SMITH', 'CLERK', 7902, '1980-12-17', 800, NULL, 20);
INSERT INTO scott.emp VALUES(7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20', 1600, 300, 30);
INSERT INTO scott.emp VALUES(7521, 'WARD', 'SALESMAN', 7698, '1981-02-22', 1250, 500, 30);
INSERT INTO scott.emp VALUES(7566, 'JONES', 'MANAGER', 7839, '1981-04-02', 2975, NULL, 20);
INSERT INTO scott.emp VALUES(7654, 'MARTIN', 'SALESMAN', 7698, '1981-09-28', 1250, 1400, 30);
INSERT INTO scott.emp VALUES(7698, 'BLAKE', 'MANAGER', 7839, '1981-05-01', 2850, NULL, 30);
INSERT INTO scott.emp VALUES(7782, 'CLARK', 'MANAGER', 7839, '1981-06-09', 2450, NULL, 10);
INSERT INTO scott.emp VALUES(7788, 'SCOTT', 'ANALYST', 7566, '1982-12-09', 3000, NULL, 20);
INSERT INTO scott.emp VALUES(7839, 'KING', 'PRESIDENT', NULL, '1981-11-17', 5000, NULL, 10);
INSERT INTO scott.emp VALUES(7844, 'TURNER', 'SALESMAN', 7698, '1981-09-08', 1500, 0, 30);
INSERT INTO scott.emp VALUES(7876, 'ADAMS', 'CLERK', 7788, '1983-01-12', 1100, NULL, 20);
INSERT INTO scott.emp VALUES(7900, 'JAMES', 'CLERK', 7698, '1981-12-03', 950, NULL, 30);
INSERT INTO scott.emp VALUES(7902, 'FORD', 'ANALYST', 7566, '1981-12-03', 3000, NULL, 20);
INSERT INTO scott.emp VALUES(7934, 'MILLER', 'CLERK', 7782, '1982-01-23', 1300, NULL, 10);

-- Confirmar los cambios
COMMIT;
