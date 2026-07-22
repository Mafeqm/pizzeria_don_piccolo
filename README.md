# 🍕 Pizzería Don Piccolo - DB System

Este proyecto contiene el diseño e implementación de la base de datos relacional para el sistema de gestión de pedidos, domicilios, inventarios y repartidores de **Pizzería Don Piccolo** utilizando **MySQL**.

## 🚀 Cómo empezar / Ejecución de scripts

Para levantar el sistema de base de datos de manera correcta y evitar problemas de dependencias de objetos, ejecuta los scripts en el siguiente orden secuencial:

1. **`database.sql`**: Crea el esquema físico, define las relaciones y precarga catálogos básicos de clientes, pizzas, ingredientes y repartidores.
2. **`funciones.sql`**: Define la lógica matemática y de cálculo requerida por el negocio (totales, IVA, ganancias netas).
3. **`triggers.sql`**: Instala los disparadores de automatización (descuentos automáticos de stock, registros de logs, liberación de repartidores).
4. **`vistas.sql`**: Genera los paneles virtuales de consulta rápida para administración y despacho.
5. **`consultas.sql`**: Script opcional con plantillas de consultas avanzadas de control de calidad.

---

## 🗺️ Estructura del Modelo y Relaciones

El diseño cuenta con las siguientes entidades estructuradas:

- **clientes**: Almacena los perfiles que realizan los pedidos.
- **pizzas**: Catálogo de productos con diferenciación por tamaño y tipo.
- **ingredientes**: Controla el almacén actual y las alertas mínimas de stock.
- **pizza_ingredientes**: Tabla puente de relación muchos-a-muchos ($N:M$) que especifica la "receta" y la cantidad exacta que requiere cada pizza.
- **pedidos**: Cabecera principal de la compra que vincula al cliente, tipo de pago e importes finales.
- **detalles_pedido**: Detalle de cuántas pizzas de qué tipo contiene un pedido ($N:M$ entre pedidos y pizzas).
- **repartidores**: Listado del personal de entrega, su estado actual de disponibilidad y zonas asignadas.
- **domicilios**: Relación $1:1$ con pedidos que controla las métricas de logística del despacho a domicilio.
- **historial_precios**: Historial de auditoría para monitorizar cambios de precios de productos en el tiempo.

---

## 🧪 Pruebas Rápidas de Funcionamiento (Ejemplo)

Puedes ejecutar el siguiente bloque SQL en tu consola una vez cargados todos los scripts para comprobar el funcionamiento de los **Triggers** y **Funciones**:

```sql
-- 1. Crear un pedido para Juan Pérez (ID: 1)
INSERT INTO pedidos (id_cliente, metodo_pago, costo_envio) 
VALUES (1, 'Efectivo', 5000.00); -- Retorna Pedido ID: 1

-- 2. Añadir una Pizza Pepperoni Mediana (ID: 3) al pedido
INSERT INTO detalles_pedido (id_pedido, id_pizza, cantidad) 
VALUES (1, 3, 2); 

-- 3. Actualizar el total del pedido usando la función calculada
UPDATE pedidos 
SET total = calcular_total_pedido(1) 
WHERE id_pedido = 1;

-- 4. Consultar que el stock de 'Queso Mozzarella' y 'Pepperoni' haya bajado automáticamente
SELECT * FROM ingredientes;

-- 5. Asignar un repartidor y mandarlo a reparto
INSERT INTO domicilios (id_pedido, id_repartidor, hora_salida, distancia_km) 
VALUES (1, 1, NOW(), 3.5);

-- Ocupar al repartidor
UPDATE repartidores SET estado = 'No Disponible' WHERE id_repartidor = 1;

-- 6. Entregar el pedido usando el procedimiento almacenado
CALL registrar_entrega_pedido(1, DATE_ADD(NOW(), INTERVAL 25 MINUTE));

-- 7. Verificar que el repartidor vuelve a estar "Disponible" automáticamente
SELECT * FROM repartidores WHERE id_repartidor = 1;
