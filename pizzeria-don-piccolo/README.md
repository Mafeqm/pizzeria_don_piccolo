# 🍕 Pizzería Don Piccolo - Sistema de Gestión de Pedidos (Examen Práctico)

Este repositorio contiene la solución técnica para el examen del módulo de gestión de pedidos, domicilios, inventario y logística de la **Pizzería Don Piccolo**, implementado sobre **MySQL**.

---

## 🚀 Guía de Ejecución Secuencial

Para mantener la integridad referencial de las llaves foráneas y objetos de la base de datos, debes ejecutar los archivos en el siguiente orden:

1. **`database.sql`**: Crea el esquema `pizzeria_don_piccolo`, las tablas principales con sus restricciones DDL y los datos iniciales de prueba (DML).
2. **`funciones.sql`**: Compila las funciones determinísticas y procedimientos almacenados (cálculo de totales con IVA, ganancias netas y registro de entregas).
3. **`triggers.sql`**: Compila los disparadores para el descuento automático de stock de ingredientes, auditoría de precios y liberación automática de repartidores.
4. **`vistas.sql`**: Genera vistas reusables para auditoría y métricas operativas (promedios de entrega por zona, ranking de pizzas).
5. **`consultas.sql`**: Ejecuta las vistas administrativas y las consultas DML para la validación y actualización en tiempo real de los pedidos.

---

## 🗺️ Estructura del Esquema Relacional

- **`clientes`**: Información del cliente (teléfono, dirección, correo).
- **`pizzas`**: Catálogo de productos clasificados por nombre, tamaño (`Personal`, `Mediana`, `Familiar`), tipo y precio base.
- **`ingredientes`**: Inventario de materia prima con métricas de `stock_actual` y `stock_minimo`.
- **`pizza_ingredientes`** *(N:M)*: Receta que conecta las pizzas con la cantidad exacta requerida de cada ingrediente.
- **`pedidos`**: Entidad central del módulo de compras que gestiona `metodo_pago`, `estado`, `costo_envio` y el `total` calculated.
- **`detalles_pedido`** *(N:M)*: Asociación entre pedidos y pizzas solicitadas con sus respectivas cantidades.
- **`repartidores`**: Gestión de repartidores, asignación de zona y control de disponibilidad (`Disponible` / `No Disponible`).
- **`domicilios`** *(1:1)*: Logística de tiempos de salida, entrega y distancia en kilómetros.
- **`historial_precios`**: Tabla de auditoría para registro histórico ante variaciones en precios base de las pizzas.

---

## 🛠️ Demostración Operativa (Flujo Completo)

Puedes probar el funcionamiento integrado del sistema ejecutando el siguiente flujo SQL en tu cliente de MySQL:

```sql
USE pizzeria_don_piccolo;

-- 1. Insertar un nuevo pedido con método de pago 'App' y estado 'Pendiente'
INSERT INTO pedidos (id_cliente, metodo_pago, estado, costo_envio) 
VALUES (1, 'App', 'Pendiente', 4000.00); 

-- 2. Asignar 2 Pizzas Pepperoni Familiar al pedido generado (ID: 4 por ejemplo)
INSERT INTO detalles_pedido (id_pedido, id_pizza, cantidad) 
VALUES (4, 4, 2); 

-- 3. Calcular y actualizar el valor total (Pizzas + IVA 19% + Envío)
SELECT calcular_total_pedido(4);

-- 4. Validar el estado del pedido y total en el módulo de compras
SELECT id_pedido, metodo_pago, estado, total 
FROM pedidos 
WHERE id_pedido = 4;

-- 5. Pasar el pedido a 'En Preparación' (Simulación de acción del Gerente)
UPDATE pedidos 
SET estado = 'En Preparación' 
WHERE id_pedido = 4;

-- 6. Registrar salida a domicilio y entrega mediante el procedimiento almacenado
INSERT INTO domicilios (id_pedido, id_repartidor, hora_salida, distancia_km) 
VALUES (4, 1, NOW(), 4.2);

CALL registrar_entrega_pedido(4, NOW());

-- 7. Verificar cambio automático de estado a 'Entregado'
SELECT id_pedido, estado FROM pedidos WHERE id_pedido = 4;
```