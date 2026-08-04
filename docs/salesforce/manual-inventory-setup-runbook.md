# Runbook de Configuración de Inventario - LvlUp WholeSale

> **Propósito:** explicar, paso a paso, cómo configurar y mantener el inventario y
> las reglas de compra B2B de los productos. Es un proceso **manual repetible**
> para el futuro (alta de productos, ajuste de stock, etc.).
>
> **Relacionado:** [`manual-add-product-runbook.md`](manual-add-product-runbook.md),
> [`contextual-quick-buy-design.md`](../ux/contextual-quick-buy-design.md),
> [`business-rules.md`](../business/business-rules.md),
> [`data-model.md`](data-model.md).

---

> **Actualización 2026-07-22 (ADR-0009):** las **reglas de compra** (MOQ /
> múltiplo / máximo) migraron del campo custom al objeto **estándar
> `PurchaseQuantityRule`** (asociado por el junction `ProductQuantityRule`). El
> storefront (Quick Buy + Description de la PDP) las lee de ahí; los campos
> `Min_Order_Quantity__c` / `Order_Increment__c` / `Max_Order_Quantity__c` quedan
> **deprecados** (ver §2). El **stock** sigue en el campo custom
> `Inventory_Quantity__c` (este runbook sigue vigente para el stock).

## 1. Contexto y decisión

La org `commerce-b2b-dev` (Developer Edition) está sobre el **modelo de inventario
moderno** de Commerce (`Location`, `LocationGroup`, `InventoryReservation`,
`OrderSummary`). En ese modelo, las **cantidades reales viven en Omnichannel
Inventory (OCI)**, un servicio externo de pago que **no es viable** en una DE de
portfolio. El modelo antiguo y simple (`ProductItem` con `QuantityOnHand`) **no
está provisionado** en esta org.

**Decisión (customización justificada — ADR 0002):** gestionar el **stock**
mediante un **campo custom en `Product2`** (`Inventory_Quantity__c`). Es
inventario **simulado** mantenido en Salesforce, leído directamente por el
componente _Contextual Quick Buy_ (no por el storefront estándar, que requeriría
OCI). Las **reglas de compra** ya **no** son campos custom: viven en el objeto
estándar `PurchaseQuantityRule` (ADR-0009, ver §2 y §9).

---

## 2. Modelo de datos

**Stock (campo custom vigente en `Product2`):**

| Campo              | API Name                | Tipo         | Significado                         |
| ------------------ | ----------------------- | ------------ | ----------------------------------- |
| Inventory Quantity | `Inventory_Quantity__c` | Number(18,0) | Unidades en stock (disponibilidad). |

**Reglas de compra (objeto estándar `PurchaseQuantityRule`, ADR-0009):**

| Campo       | Significado                          |
| ----------- | ------------------------------------ |
| `Minimum`   | Cantidad mínima de pedido (MOQ).     |
| `Increment` | Múltiplo / case pack.                |
| `Maximum`   | Máximo por pedido. Vacío = sin tope. |

La regla se asocia a un producto con un registro **`ProductQuantityRule`**
(`ProductId` + `PurchaseQuantityRuleId`). Ver §9 para el mantenimiento.

**Campos custom DEPRECADOS (ADR-0009, no leídos por el storefront):**
`Min_Order_Quantity__c`, `Order_Increment__c`, `Max_Order_Quantity__c`. Se
conservan read-only por reversibilidad; **no** editarlos para cambiar una regla
(no tienen efecto en el storefront). El publisher de externos aún los escribe
como input recuperable del seed de reglas (limpieza diferida, ADR-0009).

Acceso (FLS) del stock gobernado por el permission set
**`LvlUp_Inventory_Management`**.

---

## 3. Configuración inicial (one-time)

Solo se hace una vez por org/usuario.

1. **Desplegar la metadata** (campos + permission set):
   - `sf project deploy start --source-dir force-app/main/default/objects/Product2`
   - `sf project deploy start --source-dir force-app/main/default/permissionsets/LvlUp_Inventory_Management.permissionset-meta.xml`
2. **Asignar el permission set** al usuario que vaya a editar inventario:
   - `sf org assign permset --name LvlUp_Inventory_Management`
   - (o en UI: **Setup → Permission Sets → LvlUp Inventory Management → Manage Assignments → Add Assignments**).
3. **Añadir los campos al Page Layout de Producto** (para editarlos en la ficha):
   - **Setup → Object Manager → Product → Page Layouts → Product Layout**.
   - Arrastrar `Inventory Quantity`, `Min Order Quantity`, `Order Increment`,
     `Max Order Quantity` a una sección (p. ej. "Inventario y reglas de compra").
   - **Save**.

> Nota: con el approach de campos custom **no hace falta reindexar el catálogo**;
> el componente lee los valores en vivo. La reindexación solo aplica a cambios de
> catálogo estándar (ver [`manual-add-product-runbook.md`](manual-add-product-runbook.md)).

---

## 4. Mantenimiento manual: ajustar el inventario de UN producto

Flujo habitual al dar de alta un producto o reponer stock.

1. **App Launcher → Products** (o desde la ficha del producto en la app Commerce).
2. Abrir el producto y pulsar **Edit**.
3. Rellenar **Inventory Quantity**: unidades disponibles (p. ej. `120`).
4. **Save**.

> Las reglas de compra (MOQ / múltiplo / máximo) **ya no se editan aquí**: se
> gestionan en la `PurchaseQuantityRule` estándar (ver §9).

Reglas de coherencia recomendadas:

- `Inventory Quantity = 0` ⇒ el producto se muestra **sin stock** en el componente.
- La coherencia de la regla de compra (`Increment` divide a `Minimum`,
  `Maximum ≥ Minimum`) se cuida al definir la `PurchaseQuantityRule` (§9).

---

## 5. Mantenimiento por lote (varios productos)

Tres alternativas según el caso:

**A) Script Apex (rápido, reproducible)**

- Editar `scripts/apex/seed-inventory.apex` con la lógica deseada.
- `sf apex run --file scripts/apex/seed-inventory.apex`
- Útil para sembrar/resetear todo el catálogo de golpe (es idempotente).

**B) `sf data` con CSV**

- Preparar un CSV con `Id` + columnas de los campos.
- `sf data update bulk --sobject Product2 --file scripts/data/inventory.csv`

**C) Data Loader (UI)**

- **Update** sobre `Product2`, mapeando las columnas a los 4 campos.
- Recomendado si se prefiere interfaz gráfica sobre CLI.

---

## 6. Verificación

Consultar una muestra para confirmar los valores:

- `sf data query --query "SELECT StockKeepingUnit, Inventory_Quantity__c, Min_Order_Quantity__c, Order_Increment__c, Max_Order_Quantity__c FROM Product2 WHERE IsActive = true ORDER BY StockKeepingUnit LIMIT 20"`

> Los campos numéricos con esta precisión **no se pueden agrupar** (`GROUP BY`) en
> SOQL; para distribuciones, exportar y agregar fuera de la query.

---

## 7. Estado actual (sembrado inicial, 2026-06-22)

52 productos activos sembrados con valores variados para ejercitar el componente:

| Inventory Quantity | Productos | Estado que demuestra |
| -----------------: | --------: | -------------------- |
|                  0 |         6 | Sin stock            |
|                  8 |         6 | Stock bajo           |
|                 75 |        15 | Stock medio          |
|                300 |        25 | Stock saludable      |

- **13** productos con `Min Order Quantity = 5` y `Order Increment = 5`; el resto unitarios.
- **Max Order Quantity = 500** en todos.

---

## 8. Limitaciones y notas

- Es **inventario simulado**: no descuenta stock automáticamente al comprar (no hay
  reservas/OCI). Para descuento real haría falta lógica adicional o OCI.
- El **storefront estándar no lee el stock** de forma nativa; lo consume el
  componente custom _Contextual Quick Buy_. En cambio, las **reglas de compra** sí
  las lee el componente estándar de la PDP (`purchaseQuantityRule`), además del
  Quick Buy (ADR-0009).
- Si en el futuro se habilita **Omnichannel Inventory**, la estrategia de stock
  debería revisarse y, probablemente, migrarse al modelo estándar (registrar un ADR).

---

## 9. Mantenimiento de las reglas de compra (`PurchaseQuantityRule`, ADR-0009)

Las reglas MOQ / múltiplo / máximo viven en el objeto estándar
`PurchaseQuantityRule` y se asocian a un producto con un registro
`ProductQuantityRule`.

**A) Seed reproducible (recomendado).** El script idempotente
`scripts/apex/seed-purchase-quantity-rules.apex` crea **una regla por combinación
distinta** de min/inc/máx presente en los productos activos y asocia a cada
producto la regla de su combo. Se casa por valores (no por Id) → re-ejecutarlo no
duplica.

- `sf apex run --file scripts/apex/seed-purchase-quantity-rules.apex --target-org commerce-b2b-dev`
- Ejecutarlo **después de cada importación Platzi** (el publisher de externos aún
  escribe los campos deprecados, de los que el seed deriva la regla del producto
  nuevo). No requiere reindexar la búsqueda (la regla alimenta el data provider de
  producto, no el índice).

**B) Cambio puntual de una regla (UI).** Editar la `PurchaseQuantityRule` (App
Launcher → _Quantity Rules_ / Setup) y ajustar `Minimum` / `Increment` /
`Maximum`. Afecta a **todos** los productos asociados a esa regla (la regla es
global por producto, sin dimensión de Buyer Group). Para reglas distintas, crear
una nueva `PurchaseQuantityRule` y re-apuntar el `ProductQuantityRule` del
producto.

Coherencia recomendada: `Increment` divide a `Minimum`; `Maximum ≥ Minimum`;
vacío en `Maximum` = sin tope.
