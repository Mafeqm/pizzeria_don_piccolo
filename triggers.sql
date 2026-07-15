USE pizzeria_don_piccolo;

DELIMITER $$

-- 1. Trigger para descontar stock de ingredientes cuando se inserta un detalle de pedido
DROP TRIGGER IF EXISTS tg_descontar_stock_pedido$$
CREATE TRIGGER tg_descontar_stock_pedido
AFTER INSERT ON detalles_pedido
FOR EACH ROW
BEGIN
    -- Actualizar stock restando (cantidad de pizzas * cantidad de ingrediente por pizza)
    UPDATE ingredientes i
    JOIN pizza_ingredientes pi ON i.id_ingrediente = pi.id_ingrediente
    SET i.stock_actual = i.stock_actual - (NEW.cantidad * pi.cantidad_requerida)
    WHERE pi.id_pizza = NEW.id_pizza;
END$$

-- 2. Trigger de auditoría histórica de precios de pizzas
DROP TRIGGER IF EXISTS tg_auditoria_precio_pizza$$
CREATE TRIGGER tg_auditoria_precio_pizza
AFTER UPDATE ON pizzas
FOR EACH ROW
BEGIN
    -- Si el precio cambió, registrar en el historial
    IF OLD.precio_base <> NEW.precio_base THEN
        INSERT INTO historial_precios (id_pizza, precio_anterior, precio_nuevo)
        VALUES (OLD.id_pizza, OLD.precio_base, NEW.precio_base);
    END IF;
END$$

-- 3. Trigger para marcar repartidor como "Disponible" al finalizar el domicilio
DROP TRIGGER IF EXISTS tg_liberar_repartidor_entrega$$
CREATE TRIGGER tg_liberar_repartidor_entrega
AFTER UPDATE ON domicilios
FOR EACH ROW
BEGIN
    -- Si se registra una hora de entrega válida (el domicilio terminó)
    IF OLD.hora_entrega IS NULL AND NEW.hora_entrega IS NOT NULL THEN
        UPDATE repartidores
        SET estado = 'Disponible'
        WHERE id_repartidor = NEW.id_repartidor;
    END IF;
END$$

DELIMITER ;