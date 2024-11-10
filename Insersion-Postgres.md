practica2=> CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    stock INTEGER NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE
practica2=> INSERT INTO productos (nombre, descripcion, precio, stock)
VALUES 
    ('Laptop HP Pavilion', 'Laptop HP de 15.6 pulgadas con procesador Intel Core i5 y 8GB de RAM.', 799.99, 10),
    ('Smartphone Samsung Galaxy S21', 'Smartphone Samsung con pantalla AMOLED de 6.2 pulgadas y 128GB de almacenamiento.', 999.00, 15),
    ('Auriculares Sony WH-1000XM4', 'Auriculares inalámbricos con cancelación de ruido y hasta 30 horas de batería.', 349.99, 25),
    ('Monitor Dell UltraSharp', 'Monitor Dell de 27 pulgadas con resolución QHD y tecnología IPS.', 449.50, 8),
    ('Mouse Logitech MX Master 3', 'Mouse inalámbrico ergonómico con múltiples botones programables.', 99.99, 50),
    ('Teclado Mecánico Corsair K95', 'Teclado mecánico RGB con switches Cherry MX y retroiluminación.', 189.00, 20),
    ('Tablet Apple iPad Air', 'iPad Air de 10.9 pulgadas con chip A14 Bionic y 64GB de almacenamiento.', 599.99, 30),
    ('Disco Duro Externo WD 1TB', 'Disco duro externo portátil de 1TB y USB 3.0.', 54.99, 100),
    ('Cámara Canon EOS Rebel T7', 'Cámara DSLR con sensor de 24.1 MP y grabación de video Full HD.', 549.99, 5),
    ('Smartwatch Garmin Forerunner 245', 'Reloj deportivo con GPS y monitor de frecuencia cardíaca.', 299.99, 12);
INSERT 0 10


-------------------------------------------------------

postgres@servidor2:~$ psql -h localhost -U and2 -d practica3
Contraseña para usuario and2: 
psql (15.8 (Debian 15.8-0+deb12u1))
Conexión SSL (protocolo: TLSv1.3, cifrado: TLS_AES_256_GCM_SHA384, compresión: desactivado)
Digite «help» para obtener ayuda.

practica3=> CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    producto_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    total DECIMAL(10, 2) NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_producto
        FOREIGN KEY (producto_id) 
        REFERENCES productos (id)
);
ERROR:  no existe la relación «productos»
practica3=> CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    producto_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    total DECIMAL(10, 2) NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE
practica3=> INSERT INTO ventas (producto_id, cantidad, total)
VALUES 
    (1, 2, 1599.98), -- Ejemplo de venta de un producto con id 1
    (3, 1, 349.99), 
    (5, 3, 299.97),
    (7, 1, 599.99),
    (9, 2, 1099.98);
INSERT 0 5
practica3=> 
