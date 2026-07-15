USE pizzeria_don_piccolo;

-- Cambio al delimitador para poder compilar funciones con bloques BEGIN/END
DELIMITER $$

-- 1. Función para calcular el total de un pedido
DROP FUNCTION IF EXISTS calcular_total_pedido$$
CREATE FUNCTION calcular_total_pedido(p_id_pedido INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_subtotal DECIMAL(10, 2) DEFAULT 0.00;
    DECLARE v_envio DECIMAL(10, 2) DEFAULT 0.00;
    DECLARE v_iva_factor DECIMAL(5, 2) DEFAULT 0.19; -- Ejemplo: IVA del 19%
    DECLARE v_total DECIMAL(10, 2) DEFAULT 0.00;

    -- Sumar precios de las pizzas * cantidad en el detalle
    SELECT SUM(p.precio_base * dp.cantidad)
    INTO v_subtotal
    FROM detalles_pedido dp
    JOIN pizzas p ON dp.id_pizza = p.id_pizza
    WHERE dp.id_pedido = p_id_pedido;

    -- Obtener costo de envío
    SELECT costo_envio INTO v_envio
    FROM pedidos
    WHERE id_pedido = p_id_pedido;

    -- Fallback por si la suma o envío son nulos
    IF v_subtotal IS NULL THEN SET v_subtotal = 0.00; END IF;
    IF v_envio IS NULL THEN SET v_envio = 0.00; END IF;

    -- Cálculo: (Subtotal + IVA de las pizzas) + Envío (el envío no suele llevar el mismo IVA de alimentos o varía según país)
    SET v_total = (v_subtotal * (1 + v_iva_factor)) + v_envio;

    RETURN v_total;
END$$

-- 2. Función para calcular la ganancia neta diaria
DROP FUNCTION IF EXISTS calcular_ganancia_neta_diaria$$
CREATE FUNCTION calcular_ganancia_neta_diaria(p_fecha DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_ingresos_ventas DECIMAL(10, 2) DEFAULT 0.00;
    DECLARE v_costo_ingredientes DECIMAL(10, 2) DEFAULT 0.00;
    DECLARE v_ganancia_neta DECIMAL(10, 2) DEFAULT 0.00;

    -- Sumar los totales facturados del día (sin contar el envío que va al repartidor)
    SELECT SUM(total - costo_envio)
    INTO v_ingresos_ventas
    FROM pedidos
    WHERE DATE(fecha_hora) = p_fecha AND estado != 'Cancelado';

    -- Calcular el costo de los ingredientes consumidos en los pedidos de ese día
    SELECT SUM(dp.cantidad * pi.cantidad_requerida * i.costo_unidad)
    INTO v_costo_ingredientes
    FROM pedidos ped
    JOIN detalles_pedido dp ON ped.id_pedido = dp.id_pedido
    JOIN pizza_ingredientes pi ON dp.id_pizza = pi.id_pizza
    JOIN ingredientes i ON pi.id_ingrediente = i.id_ingrediente
    WHERE DATE(ped.fecha_hora) = p_fecha AND ped.estado != 'Cancelado';

    IF v_ingresos_ventas IS NULL THEN SET v_ingresos_ventas = 0.00; END IF;
    IF v_costo_ingredientes IS NULL THEN SET v_costo_ingredientes = 0.00; END IF;

    SET v_ganancia_neta = v_ingresos_ventas - v_costo_ingredientes;
    RETURN v_ganancia_neta;
END$$

-- 3. Procedimiento para actualizar el estado del pedido al registrar la entrega
DROP PROCEDURE IF EXISTS registrar_entrega_pedido$$
CREATE PROCEDURE registrar_entrega_pedido(
    IN p_id_pedido INT,
    IN p_hora_entrega DATETIME
)
BEGIN
    -- Actualizar la hora de entrega en la tabla domicilios
    UPDATE domicilios 
    SET hora_entrega = p_hora_entrega
    WHERE id_pedido = p_id_pedido;

    -- Cambiar automáticamente el estado del pedido
    UPDATE pedidos
    SET estado = 'Entregado'
    WHERE id_pedido = p_id_pedido;
END$$

DELIMITER ;