# Runbook: Alta Manual de Producto - LvlUp WholeSale

## 1. Propósito del Documento

Este documento describe el **paso a paso manual** para dar de alta un producto de
punta a punta en el storefront B2B de LvlUp WholeSale: crear categoría, crear
producto, asignarlo a la categoría, ponerle precio, asociarle imagen y publicarlo.

Sirve para:

- Tener un procedimiento repetible para altas puntuales en la UI.
- Onboarding de quien gestione el catálogo sin depender de scripts.
- Documentar el orden correcto de pasos y los puntos que suelen olvidarse
  (precio base, publicación de contenido CMS, reindexado).
- Reflejar la configuración **real** validada en la Developer Org.

Este runbook cubre el flujo **manual y unitario**. Para carga **masiva** de
catálogo (datos), ver `docs/salesforce/data-loading-strategy.md` y los scripts de
`scripts/apex/` (`seed-product-categories.apex`, `seed-products.apex`,
`assign-product-media.apex`). Aplica el principio rector: *Configuration first,
customization only when justified*.

---

## 2. Datos de Referencia de la Org

Los pasos referencian estas piezas por **nombre** (los Ids pueden variar entre
orgs):

| Pieza | Nombre | Rol |
| --- | --- | --- |
| WebStore | LevelUp Wholesale | Tienda |
| ProductCatalog | LevelUp Wholesale Catalog | Catálogo donde viven las categorías |
| Categoría raíz | Categorías | Las subcategorías navegables cuelgan de aquí |
| Pricebook estándar | Standard Price Book | Precio base obligatorio |
| Pricebook de venta | LevelUp Wholesale Price Book | Precio que paga el Buyer Group |
| Pricebook strikethrough | LevelUp Wholesale Strikethrough Price Book | Precio tachado (opcional) |
| Buyer Group | LevelUp Wholesale Buyer Group | Segmento comprador |
| Entitlement Policy | All Access for LevelUp Wholesale | Da visibilidad a todos los productos |
| CMS workspace | LevelUp Wholesale Managed Content Space | Donde se crea la imagen |
| Grupo media (PLP) | Product List Image (Listing) | Imagen de tarjeta en PLP |
| Grupo media (PDP) | Product Detail Images (Standard) | Imágenes de detalle en PDP |

> La **visibilidad** ya está resuelta por la política *All Access*: un producto
> nuevo es visible para el Buyer Group sin configurar entitlements por producto.
> No hay que tocar entitlements en el alta.

---

## 3. Secuencia del Flujo

El orden importa para evitar errores (p. ej. no se puede poner precio de venta sin
precio estándar previo):

1. Crear la categoría.
2. Crear el producto.
3. Asignar el producto a la categoría.
4. Asignar precios.
5. Asociar la imagen.
6. Publicar y reindexar.
7. Verificar en el storefront.

Todo se realiza en la app **Commerce** (App Launcher → *Commerce*) sobre el store
**LevelUp Wholesale**, salvo la imagen (CMS) y, si aplica, el Trusted URL (Setup).

---

## 4. Paso 1 - Crear la Categoría

1. App Launcher → **Commerce** → abre el store **LevelUp Wholesale**.
2. Entra a la gestión del **Catálogo / Categories**.
3. Sobre la categoría raíz **"Categorías"**, crea una **subcategoría**
   (*Add Category / New*).
4. Asigna el **Name** y **márcala como navegable** (*Show in Menu* /
   `IsNavigational = true`) para que aparezca en el menú "Categorías" del header
   (el menú es *data-source-driven* y se llena con las categorías navegables).
5. Guarda.

> El menú puede no reflejar la categoría hasta el reindexado/refresh del Paso 6.

---

## 5. Paso 2 - Crear el Producto

1. En Commerce → store → workspace **Products** → **Add Product / New**.
2. Campos mínimos:
   - **Product Name**.
   - **SKU** (`StockKeepingUnit`), p. ej. `LVL-XXX-051`.
   - **Product Code** (puede coincidir con el SKU).
   - **Active = true**.
3. Guarda.

---

## 6. Paso 3 - Asignar el Producto a la Categoría

1. Abre el producto → pestaña **Categories**.
2. **Add** → busca la categoría creada en el Paso 1 → asígnala.

> Equivale al registro `ProductCategoryProduct` (junction producto↔categoría).

---

## 7. Paso 4 - Asignar Precios

En la ficha del producto → pestaña **Prices** (o desde cada Price Book):

1. **Standard Price Book**: añade el precio base. **Es obligatorio y primero**; sin
   él no se puede añadir el producto a otros price books.
2. **LevelUp Wholesale Price Book**: el precio que paga el buyer (descuento
   mayorista). Es el price book asociado al Buyer Group.
3. *(Opcional)* **LevelUp Wholesale Strikethrough Price Book**: el PVP "tachado"
   (más alto que el de venta) para mostrar el descuento.
4. Verifica que cada **PricebookEntry** quede **Active**.

> Coherente con `docs/business/pricing-and-visibility-strategy.md`.

---

## 8. Paso 5 - Asociar la Imagen (vía URL externa)

El proyecto sirve las imágenes desde un **host externo** (GitHub raw) referenciadas
por URL, para **no consumir File Storage** de la org (Developer Edition, límite
reducido). Subir un archivo al CMS también funciona, pero **cada archivo consume
File Storage**.

1. Sube la imagen al repo (`data/product-images/<SKU>.png`) y haz push; obtén su
   raw URL:
   `https://raw.githubusercontent.com/JavierccQ/lvlup-wholesale-b2b/main/data/product-images/<SKU>.png`
2. App Launcher → **CMS** → workspace **LevelUp Wholesale Managed Content Space** →
   **Add Content → Image → "Insert by link" (from URL)** → pega la raw URL →
   **Title = el SKU** → **Publish**.
3. Vuelve al producto → pestaña **Media / Images** → **Add** → selecciona ese
   contenido del CMS → asígnalo a **Product List Image** (PLP) y
   **Product Detail Images** (PDP).

> Equivale a 2 registros `ProductMedia` (uno por grupo). El host
> `raw.githubusercontent.com` ya está autorizado en **Setup → Trusted URLs** con la
> directiva `img-src`; si la imagen viene de otro host, hay que añadirlo ahí o el
> CSP la bloqueará.

---

## 9. Paso 6 - Publicar y Reindexar

1. Confirma que el **contenido CMS** está *Published* y el **producto** está
   *Active*.
2. Commerce → store → **Settings | Search → Update → Full Update**.

> **Sin reindexar, el producto no aparece** en PLP ni en la búsqueda. Es el paso
> que más se olvida. Límite: máx. 60 reindexados/hora por org y esperar ≥5 min
> entre *full updates*.

---

## 10. Paso 7 - Verificar en el Storefront

1. Recarga el storefront (**Ctrl+Shift+R** para evitar caché).
2. Comprueba:
   - La **categoría** aparece en el menú "Categorías".
   - El **producto** se ve dentro de la categoría y en la búsqueda.
   - El **precio** se muestra correctamente (`~~PVP~~ venta` si hay strikethrough).
   - La **imagen** aparece en la tarjeta (PLP) y en el detalle (PDP).

---

## 11. Notas Clave y Errores Comunes

- **Orden de precios**: Standard primero, siempre.
- **Visibilidad**: no se tocan entitlements; la política *All Access* ya cubre el
  Buyer Group.
- **Imágenes**: URL externa = 0 File Storage; archivo subido = consume el límite
  (~20 MB en esta org).
- **Reindexado**: imprescindible tras cualquier alta o cambio para que sea visible.
- **Gestión de contenido CMS**: el contenido publicado **no** se puede borrar de
  forma masiva ni por API en esta org; el unpublish + delete es manual y 1 a 1.
  Conviene evitar crear contenido CMS innecesario.

---

## 12. Relación con Otros Documentos

- `docs/business/product-catalog-strategy.md` define la **estructura** de catálogo y
  categorías.
- `docs/business/pricing-and-visibility-strategy.md` define el **pricing y la
  visibilidad** por segmento/Buyer Group.
- `docs/salesforce/data-model.md` describe los **objetos** implicados (Product2,
  ProductCategory, PricebookEntry, ProductMedia, ManagedContent, etc.).
- `docs/salesforce/data-loading-strategy.md` cubre la **carga masiva** (alternativa
  a este flujo manual unitario).
- `adr/0003-commerce-data-vs-metadata-strategy.md` justifica tratar catálogo,
  precios e imágenes como **datos**, no metadata.
- Scripts reproducibles del alta masiva: `scripts/apex/seed-product-categories.apex`,
  `scripts/apex/seed-products.apex`, `scripts/apex/assign-product-media.apex`,
  `scripts/build-cms-image-import.py`.
