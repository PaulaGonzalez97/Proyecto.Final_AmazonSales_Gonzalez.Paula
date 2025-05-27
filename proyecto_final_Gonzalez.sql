CREATE DATABASE amazon_sales_2025;

USE amazon_sales_2025;

-- Crear la tabla Categorias
CREATE TABLE Categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(255),
    descripcion_categoria TEXT
);

-- Crear la tabla Metodos_Pago
CREATE TABLE Metodos_Pago (
    id_metodo_pago INT AUTO_INCREMENT PRIMARY KEY,
    nombre_metodo VARCHAR(255)
);

-- Crear la tabla Clientes
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_cliente VARCHAR(255),
    correo_cliente VARCHAR(255),
    telefono_cliente VARCHAR(20),
    direccion_cliente VARCHAR(255),
    pais_cliente VARCHAR(100)
);

-- Crear la tabla Productos
CREATE TABLE Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(255),
    precio_producto FLOAT,
    descripcion_producto TEXT,
    id_categoria INT,
    stock_producto INT,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

-- Crear la tabla Ventas
CREATE TABLE Ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_producto INT,
    cantidad_venta INT,
    fecha_venta DATE,
    monto_venta FLOAT,
    id_metodo_pago INT,
	id_estado INT,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
	FOREIGN KEY (id_metodo_pago) REFERENCES Metodos_Pago(id_metodo_pago),
    FOREIGN KEY (id_estado) REFERENCES Estados_Pedido(id_estado)
);
ALTER TABLE Ventas
ADD COLUMN id_estado INT,
ADD FOREIGN KEY (id_estado) REFERENCES Estados_Pedido(id_estado);


-- Crear la tabla Ubicacion_Envio
CREATE TABLE Ubicacion_Envio (
    id_envio INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    direccion_envio VARCHAR(255),
    ciudad_envio VARCHAR(100),
    pais_envio VARCHAR(100),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- Crear tabla adicional Estados pedido
CREATE TABLE ESTADOS_PEDIDO (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    descripcion_estado VARCHAR(100)
);


-- VISTAS:
-- Esta vista indica el resumen de ventas

CREATE VIEW vista_resumen_ventas AS
SELECT 
    v.id_venta,
    c.nombre_cliente,
    p.nombre_producto,
    v.cantidad_venta,
    v.monto_venta,
    v.fecha_venta
FROM VENTAS v
JOIN CLIENTES c ON v.id_cliente = c.id_cliente
JOIN PRODUCTOS p ON v.id_producto = p.id_producto;

SELECT * FROM vista_resumen_ventas;

-- Esta vista lista clientes frecuentes

CREATE VIEW vista_clientes_frecuentes AS
SELECT 
    c.id_cliente,
    c.nombre_cliente,
    COUNT(v.id_venta) AS total_compras
FROM VENTAS v
JOIN CLIENTES c ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_cliente
HAVING COUNT(v.id_venta) > 5;

SELECT * FROM vista_clientes_frecuentes;

-- Vista adicional sobre el estado de los pedidos
CREATE VIEW vista_ventas_por_estado AS
SELECT 
    ep.descripcion_estado AS estado,
    COUNT(v.id_venta) AS total_ventas,
    SUM(v.monto_venta) AS monto_total
FROM Ventas v
JOIN Estados_Pedido ep ON v.id_estado = ep.id_estado
GROUP BY ep.descripcion_estado;

-- Vista adicional sobre ventas por cliente
CREATE VIEW vista_ventas_por_cliente AS
SELECT 
    c.nombre_cliente,
    COUNT(v.id_venta) AS total_compras,
    SUM(v.monto_venta) AS monto_total
FROM Ventas v
JOIN Clientes c ON v.id_cliente = c.id_cliente
GROUP BY c.nombre_cliente;

-- Vista adicional sobre productos mas vendidos
CREATE VIEW vista_productos_mas_vendidos AS
SELECT 
    p.nombre_producto,
    SUM(v.cantidad_venta) AS cantidad_total,
    SUM(v.monto_venta) AS ingreso_total
FROM Ventas v
JOIN Productos p ON v.id_producto = p.id_producto
GROUP BY p.nombre_producto
ORDER BY cantidad_total DESC;



-- FUNCIONES:
-- Esta funcion calcula el total vendido por producto

DELIMITER //

CREATE FUNCTION fn_calcular_total_por_producto(p_id_producto INT)
RETURNS FLOAT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total FLOAT;

    SELECT SUM(monto_venta)
    INTO total
    FROM VENTAS
    WHERE id_producto = p_id_producto;

    RETURN IFNULL(total, 0);
END //

DELIMITER ;

-- Esta funcion obtiene el nombre de categoria por ID de producto

DELIMITER //

CREATE FUNCTION fn_obtener_categoria_producto(p_id_producto INT)
RETURNS VARCHAR(255)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE categoria_nombre VARCHAR(255);

    SELECT c.nombre_categoria
    INTO categoria_nombre
    FROM PRODUCTOS p
    JOIN CATEGORIAS c ON p.id_categoria = c.id_categoria
    WHERE p.id_producto = p_id_producto;

    RETURN categoria_nombre;
END //

DELIMITER ;

-- STORED PROCEDURES:
-- Este procedimiento almacenado permite insertar una nueva venta en la base de datos

DELIMITER //

CREATE PROCEDURE sp_insertar_nueva_venta(
    IN p_id_cliente INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_monto FLOAT,
    IN p_fecha DATE,
    IN p_id_metodo_pago INT
)
BEGIN
    INSERT INTO VENTAS (
        id_cliente, 
        id_producto, 
        cantidad_venta, 
        monto_venta, 
        fecha_venta, 
        id_metodo_pago
    )
    VALUES (
        p_id_cliente, 
        p_id_producto, 
        p_cantidad, 
        p_monto, 
        p_fecha, 
        p_id_metodo_pago
    );
END //

DELIMITER ;

-- Este procedimiento almacenado recibe el ID de un producto y una cantidad, y actualiza el stock restando esa cantidad al inventario actual.

DELIMITER //

CREATE PROCEDURE sp_actualizar_stock_producto(
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    UPDATE PRODUCTOS
    SET stock_producto = stock_producto - p_cantidad
    WHERE id_producto = p_id_producto;
END //

DELIMITER ;

-- Creacion de tabla Log_Ventas que sirve para registrar automaticamente cada nueva venta insertada en la tabla Ventas.

CREATE TABLE LOG_VENTAS (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    id_cliente INT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- TRIGGER
-- Este trigger se ejecuta automáticamente después de que se registra una nueva venta en la tabla VENTAS. Inserta un nuevo registro en la tabla LOG_VENTAS.
DELIMITER //

CREATE TRIGGER trg_log_venta_insert
AFTER INSERT ON VENTAS
FOR EACH ROW
BEGIN
    INSERT INTO LOG_VENTAS (id_venta, id_cliente)
    VALUES (NEW.id_venta, NEW.id_cliente);
END //

DELIMITER ;

-- Trigger adicional: Cada vez que se inserta una venta, este trigger descuenta automáticamente la cantidad vendida del stock disponible en la tabla PRODUCTOS

DELIMITER //

CREATE TRIGGER trg_actualizar_stock_venta
AFTER INSERT ON Ventas
FOR EACH ROW
BEGIN
    UPDATE Productos
    SET stock_producto = stock_producto - NEW.cantidad_venta
    WHERE id_producto = NEW.id_producto;
END //

DELIMITER ;

