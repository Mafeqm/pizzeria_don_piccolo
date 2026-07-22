USE pizzeria_don_piccolo;

-- 1. Clientes con pedidos entre dos fechas (BETWEEN)
SELECT DISTINCT c.nombre, c.correo, p.fecha_hora 
FROM clientes c
JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE p.fecha_hora BETWEEN '2026-01-01 00:00:00' AND '2026-12-31 23:59:59';

-- 2. Pizzas más vendidas (GROUP BY y COUNT / SUM)
SELECT pi.nombre, pi.tamano, SUM(dp.cantidad) AS total_unidades_vendidas
FROM detalles_pedido dp
JOIN pizzas pi ON dp.id_pizza = pi.id_pizza
GROUP BY pi.id_pizza, pi.nombre, pi.tamano
ORDER BY total_unidades_vendidas DESC;

-- 3. Pedidos por repartidor (JOIN)
SELECT r.nombre AS repartidor, p.id_pedido, p.fecha_hora, p.estado
FROM repartidores r
JOIN domicilios d ON r.id_repartidor = d.id_repartidor
JOIN pedidos p ON d.id_pedido = p.id_pedido;

-- 4. Promedio de entrega por zona (AVG y JOIN)
CREATE OR REPLACE VIEW vista_promedio_entrega_zona AS
SELECT r.zona_asignada AS zona, 
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 2) AS promedio_minutos_entrega
FROM domicilios d
JOIN repartidores r ON d.id_repartidor = r.id_repartidor
WHERE d.hora_entrega IS NOT NULL
GROUP BY r.zona_asignada;

-- 5. Clientes que gastaron más de un monto específico (HAVING)
SELECT c.nombre, SUM(p.total) AS total_gastado
FROM clientes c
JOIN pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nombre
HAVING total_gastado > 50000.00;

-- 6. Búsqueda por coincidencia parcial de nombre de pizza (LIKE)
SELECT * FROM pizzas 
WHERE nombre LIKE '%Piccolo%';

-- 7. Subconsulta para obtener los clientes frecuentes (más de 5 pedidos en el mes actual)
SELECT id_cliente, nombre, correo
FROM clientes
WHERE id_cliente IN (
    SELECT id_cliente 
    FROM pedidos 
    WHERE fecha_hora >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
    GROUP BY id_cliente
    HAVING COUNT(id_pedido) > 5
);