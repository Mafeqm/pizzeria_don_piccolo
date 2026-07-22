-- 1. CREACIÓN
DROP DATABASE IF EXISTS pizzeria_don_piccolo;
CREATE DATABASE pizzeria_don_piccolo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pizzeria_don_piccolo;

-- Tabla Clientes
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Pizzas
CREATE TABLE pizzas (
    id_pizza INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tamano ENUM('Familiar', 'Mediana', 'Personal') NOT NULL,
    precio_base DECIMAL(10, 2) NOT NULL CHECK (precio_base > 0),
    tipo ENUM('Vegetariana', 'Especial', 'Clásica') NOT NULL
);

-- Tabla Ingredientes
CREATE TABLE ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    stock_actual DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    stock_minimo DECIMAL(10, 2) NOT NULL DEFAULT 5.00,
    costo_unidad DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (costo_unidad >= 0)
);

-- Tabla de Rompimiento Pizza_Ingredientes
CREATE TABLE pizza_ingredientes (
    id_pizza INT,
    id_ingrediente INT,
    cantidad_requerida DECIMAL(10, 2) NOT NULL CHECK (cantidad_requerida > 0),
    PRIMARY KEY (id_pizza, id_ingrediente),
    FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza) ON DELETE CASCADE,
    FOREIGN KEY (id_ingrediente) REFERENCES ingredientes(id_ingrediente) ON DELETE CASCADE
);

-- Tabla Repartidores
CREATE TABLE repartidores (
    id_repartidor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    zona_asignada VARCHAR(100) NOT NULL,
    estado ENUM('Disponible', 'No Disponible') NOT NULL DEFAULT 'Disponible'
);

-- Tabla Pedidos
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metodo_pago ENUM('Efectivo', 'Tarjeta', 'App') NOT NULL,
    estado ENUM('Pendiente', 'En Preparación', 'Entregado', 'Cancelado') NOT NULL DEFAULT 'Pendiente',
    costo_envio DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (costo_envio >= 0),
    total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE RESTRICT
);

-- Tabla de Rompimiento Detalles de Pedido (Pizzas solicitadas)
CREATE TABLE detalles_pedido (
    id_pedido INT,
    id_pizza INT,
    cantidad INT NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    PRIMARY KEY (id_pedido, id_pizza),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza) ON DELETE RESTRICT
);

-- Tabla Domicilios
CREATE TABLE domicilios (
    id_pedido INT PRIMARY KEY,
    id_repartidor INT NOT NULL,
    hora_salida DATETIME DEFAULT NULL,
    hora_entrega DATETIME DEFAULT NULL,
    distancia_km DECIMAL(5, 2) NOT NULL CHECK (distancia_km >= 0),
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_repartidor) REFERENCES repartidores(id_repartidor) ON DELETE RESTRICT
);

-- Tabla de Auditoría Historial de Precios de Pizzas
CREATE TABLE historial_precios (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_pizza INT NOT NULL,
    precio_anterior DECIMAL(10, 2) NOT NULL,
    precio_nuevo DECIMAL(10, 2) NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza) ON DELETE CASCADE
);

-- 2. DATOS DE PRUEBA
INSERT INTO clientes (nombre, telefono, direccion, correo) VALUES
('Juan Pérez', '555-0192', 'Calle 45 #12-34, Zona Norte', 'juan.perez@email.com'),
('María Gómez', '555-0143', 'Avenida 19 #88-12, Zona Centro', 'maria.gomez@email.com'),
('Carlos Ruiz', '555-0111', 'Diagonal 4 #5-90, Zona Sur', 'carlos.ruiz@email.com'),
('Ana López', '555-0177', 'Transversal 50 #120-10, Zona Norte', 'ana.lopez@email.com');

INSERT INTO pizzas (nombre, tamano, precio_base, tipo) VALUES
('Margarita', 'Personal', 12000.00, 'Vegetariana'),
('Margarita', 'Mediana', 18000.00, 'Vegetariana'),
('Pepperoni', 'Mediana', 22000.00, 'Clásica'),
('Pepperoni', 'Familiar', 32000.00, 'Clásica'),
('Don Piccolo Especial', 'Familiar', 38000.00, 'Especial');

INSERT INTO ingredientes (nombre, stock_actual, stock_minimo, costo_unidad) VALUES
('Masa de Pizza', 100.00, 10.00, 1500.00),
('Salsa de Tomate (porción)', 150.00, 15.00, 500.00),
('Queso Mozzarella (gr)', 5000.00, 500.00, 2.50),
('Pepperoni (gr)', 2000.00, 200.00, 5.00),
('Albahaca (gr)', 300.00, 50.00, 1.20);

INSERT INTO pizza_ingredientes VALUES 
(2, 1, 1.00), (2, 2, 1.00), (2, 3, 200.00), (2, 5, 10.00),
(3, 1, 1.00), (3, 2, 1.00), (3, 3, 180.00), (3, 4, 100.00);

INSERT INTO repartidores (nombre, zona_asignada, estado) VALUES
('Pedro Picapiedra', 'Zona Norte', 'Disponible'),
('Pablo Mármol', 'Zona Centro', 'Disponible'),
('Betty Mármol', 'Zona Sur', 'Disponible');

-- Inserciones explícitas con metodo_pago, estado y total
INSERT INTO pedidos (id_cliente, metodo_pago, estado, costo_envio, total) VALUES
(1, 'Efectivo', 'Entregado', 3000.00, 24420.00),
(2, 'Tarjeta', 'En Preparación', 2500.00, 28680.00),
(3, 'App', 'Pendiente', 3500.00, 41620.00);

INSERT INTO detalles_pedido (id_pedido, id_pizza, cantidad) VALUES
(1, 2, 1),
(2, 3, 1),
(3, 4, 1);

INSERT INTO domicilios (id_pedido, id_repartidor, hora_salida, hora_entrega, distancia_km) VALUES
(1, 1, '2026-03-01 19:10:00', '2026-03-01 19:35:00', 3.5),
(2, 2, '2026-03-01 20:00:00', NULL, 2.1);