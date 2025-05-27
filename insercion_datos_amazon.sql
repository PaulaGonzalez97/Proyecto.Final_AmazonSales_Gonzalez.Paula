-- insercion de datos amazon sales 2025

INSERT INTO CLIENTES (id_cliente, nombre_cliente, correo_cliente, telefono_cliente, direccion_cliente, pais_cliente)
VALUES 
(1, 'Paula Gonzalez', 'paula.gonzalez@gmail.com', '123456789', 'Calle Falsa 123', 'Argentina'),
(2, 'Juan Alcaraz', 'juanalcaraz10@gmail.com', '987654321', 'Av. Mitre 456', 'Chile');

INSERT INTO CATEGORIAS (id_categoria, nombre_categoria, descripcion_categoria)
VALUES 
(1, 'Electrónica', 'Dispositivos electrónicos y gadgets'),
(2, 'Ropa', 'Indumentaria y accesorios');

INSERT INTO PRODUCTOS (id_producto, nombre_producto, precio_producto, descripcion_producto, id_categoria, stock_producto)
VALUES 
(1, 'Smartphone X', 250.00, 'Teléfono inteligente gama media', 1, 50),
(2, 'Camiseta básica', 15.00, 'Camiseta de algodón blanca', 2, 200);

INSERT INTO METODOS_PAGO (id_metodo_pago, nombre_metodo)
VALUES 
(1, 'Tarjeta de crédito'),
(2, 'Transferencia bancaria');

INSERT INTO ESTADOS_PEDIDO (id_estado, descripcion_estado)
VALUES 
(1, 'Pendiente'),
(2, 'Enviado'),
(3, 'Entregado'),
(4, 'Cancelado');


INSERT INTO VENTAS (id_venta, id_cliente, id_producto, cantidad_venta, fecha_venta, monto_venta, id_metodo_pago, id_estado)
VALUES 
(1, 1, 1, 1, '2025-05-01', 250.00, 1, 2),  -- Enviado
(2, 2, 2, 3, '2025-05-03', 45.00, 2, 1);  -- Pendiente


INSERT INTO UBICACION_ENVIO (id_envio, id_cliente, direccion_envio, ciudad_envio, pais_envio)
VALUES 
(1, 1, 'Calle Falsa 123', 'Mendoza', 'Argentina'),
(2, 2, 'Av. Mitre 456', 'Valparaiso', 'Chile');





