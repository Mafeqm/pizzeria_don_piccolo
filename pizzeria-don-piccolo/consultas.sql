USE pizzeria_don_piccolo;

-- 1. Vista de resumen de pedidos por cliente
CREATE OR REPLACE VIEW vista_resumen_clientes AS
SELECT 
    c.nombre AS cliente,
    COUNT(p.id_pedido) AS cantidad_pedidos,
    SUM(p.total) AS total_gastado
FROM clientes c
LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nombre;

-- 2. Vista de desempeño de repartidores
CREATE OR REPLACE VIEW vista_desempeno_repartidores AS
SELECT 
    r.nombre AS repartidor,
    r.zona_asignada AS zona,
    COUNT(d.id_pedido) AS total_entregas,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 1) AS tiempo_promedio_entrega_minutos
FROM repartidores r
LEFT JOIN domicilios d ON r.id_repartidor = d.id_repartidor
WHERE d.hora_entrega IS NOT NULL
GROUP BY r.id_repartidor, r.nombre, r.zona_asignada;

-- 3. Vista de stock de ingredientes por debajo del mínimo permitido (Alertas)
CREATE OR REPLACE VIEW vista_alerta_stock_ingredientes AS
SELECT 
    id_ingrediente,
    nombre AS ingrediente,
    stock_actual,
    stock_minimo,
    (stock_minimo - stock_actual) AS cantidad_a_comprar
FROM ingredientes
WHERE stock_actual < stock_minimo;