# Estrategia de Catálogo de Productos - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define **cómo se estructurará funcionalmente el catálogo de
productos** del storefront B2B de LvlUp WholeSale. Describe la organización, las
categorías y el comportamiento esperado del catálogo, no su configuración técnica.

Sirve como base para:

- Configuración del Product Catalog.
- Definición de categorías.
- Priorización de productos del MVP.
- Visibilidad por cliente o Buyer Group.
- PLP y PDP.
- Pricing.
- Testing funcional.
- Futuras decisiones técnicas.

Este documento **no define la configuración técnica detallada de Salesforce ni los
scripts de carga de datos**. Se alinea con los documentos de `docs/business/` y con
`docs/business/pricing-and-visibility-strategy.md`, y aplica el principio rector
del proyecto: *Configuration first, customization only when justified*.

---

## 2. Principios del Catálogo B2B

- El catálogo debe estar orientado a la **compra B2B, no B2C**.
- La navegación debe ser **clara, rápida y útil** para compradores recurrentes.
- Las categorías deben reflejar **intención de compra**, no solo clasificación
  interna.
- La **visibilidad** de productos puede variar por cuenta o Buyer Group.
- El **pricing aplicable** debe ser consistente en PLP, PDP, carrito y checkout.
- El catálogo del MVP debe ser **pequeño pero representativo**.
- Evitar la complejidad de **marketplace, multi-región o multi-divisa** en el MVP.
- Priorizar las **capacidades estándar** de Salesforce B2B Commerce.

---

## 3. Categorías Principales del MVP

### Consolas de gaming

- **Descripción funcional.** Consolas de videojuegos y packs asociados.
- **Tipo de comprador relevante.** Tienda gaming local; reseller; enterprise.
- **Ejemplos de productos.** Consola sobremesa, consola portátil, packs de consola.
- **Relevancia para el MVP.** Alta (producto ancla de gaming).
- **Consideraciones B2B.** Alta demanda y estacionalidad; sensible a stock en
  lanzamientos.

### Videojuegos

- **Descripción funcional.** Títulos físicos y digitales, preventas y bundles.
- **Tipo de comprador relevante.** Tienda gaming local; reseller.
- **Ejemplos de productos.** Juego físico, juego digital, bundle de títulos.
- **Relevancia para el MVP.** Alta (alta rotación).
- **Consideraciones B2B.** Catálogo amplio y de rotación rápida; pedidos
  recurrentes de bajo importe unitario.

### Portátiles

- **Descripción funcional.** Portátiles gaming, business y workstation.
- **Tipo de comprador relevante.** Reseller; empresa IT; enterprise.
- **Ejemplos de productos.** Gaming laptop, business laptop, workstation.
- **Relevancia para el MVP.** Alta (alto valor transversal).
- **Consideraciones B2B.** Importe elevado; sensible a pricing negociado y a stock.

### Monitores

- **Descripción funcional.** Monitores gaming y profesionales.
- **Tipo de comprador relevante.** Reseller; empresa IT; enterprise.
- **Ejemplos de productos.** Monitor gaming, monitor profesional, monitor curvo 4K.
- **Relevancia para el MVP.** Media-alta (complemento de portátiles).
- **Consideraciones B2B.** Buen candidato para venta cruzada y bundles.

### Periféricos

- **Descripción funcional.** Teclados, ratones, auriculares, mandos y webcams.
- **Tipo de comprador relevante.** Transversal a todos los segmentos.
- **Ejemplos de productos.** Teclado mecánico, ratón gaming, auriculares, mando.
- **Relevancia para el MVP.** Media-alta (alta recurrencia).
- **Consideraciones B2B.** Ticket bajo y reposición frecuente.

### Networking

- **Descripción funcional.** Routers, switches, access points y cableado.
- **Tipo de comprador relevante.** Reseller; empresa IT; enterprise.
- **Ejemplos de productos.** Router WiFi 6, switch, access point.
- **Relevancia para el MVP.** Media (orientado a reventa y oficina).
- **Consideraciones B2B.** Infraestructura; pedidos de empresa y reseller.

### Accesorios

- **Descripción funcional.** Cables, soportes, cargadores y adaptadores.
- **Tipo de comprador relevante.** Transversal a todos los segmentos.
- **Ejemplos de productos.** Cable USB-C, soporte de monitor, cargador.
- **Relevancia para el MVP.** Media-baja (complementan el ticket).
- **Consideraciones B2B.** Consumibles y reemplazos; refuerzan el ticket medio.

### Bundles enterprise

- **Descripción funcional.** Kits preconfigurados para tiendas, oficinas, eventos y
  renovación tecnológica.
- **Tipo de comprador relevante.** Reseller; empresa IT; enterprise.
- **Ejemplos de productos.** Kit tienda gaming, kit oficina, kit eventos.
- **Relevancia para el MVP.** Media (palanca de upselling; visibilidad por
  segmento).
- **Consideraciones B2B.** Simplifican la compra recurrente de alto volumen.

---

## 4. Taxonomía Inicial del Catálogo

Estructura de categorías y subcategorías inicial. Es una propuesta funcional, no
una configuración técnica; se mantiene deliberadamente acotada para no
sobredimensionar el catálogo del MVP.

### Consolas de gaming
- Consolas PlayStation
- Consolas Xbox
- Consolas Nintendo
- Packs de consola

### Videojuegos
- Juegos físicos
- Juegos digitales
- Preventas
- Bundles de juegos

### Portátiles
- Gaming laptops
- Business laptops
- Workstation laptops

### Monitores
- Monitores gaming
- Monitores profesionales
- Monitores curvos
- Monitores 4K

### Periféricos
- Teclados
- Ratones
- Auriculares
- Mandos
- Webcams

### Networking
- Routers
- Switches
- Access points
- Cableado

### Accesorios
- Cables
- Soportes
- Cargadores
- Adaptadores

### Bundles enterprise
- Kits para tiendas gaming
- Kits para oficinas
- Kits para eventos
- Packs de renovación tecnológica

---

## 5. Catálogo MVP vs Catálogo Futuro

| Categoría | Incluida en MVP | Nivel de prioridad | Posible expansión futura | Comentario |
| --- | --- | --- | --- | --- |
| Consolas de gaming | Sí | Alta | Más modelos y ediciones limitadas | Producto ancla de gaming |
| Videojuegos | Sí | Alta | Catálogo digital ampliado, preventas | Alta rotación |
| Portátiles | Sí | Alta | Más gamas y configuraciones | Alto valor transversal |
| Monitores | Sí | Media | Gamas profesionales y 4K | Complemento de portátiles |
| Periféricos | Sí | Media | Líneas pro y accesorios gaming | Alta recurrencia |
| Networking | Sí | Media | Equipamiento avanzado de red | Reseller y empresa |
| Accesorios | Sí | Baja | Consumibles y almacenamiento | Refuerzan ticket |
| Bundles enterprise | Sí (acotado) | Media | Bundles configurables por acuerdo | Visibilidad por segmento |

> Todas las categorías se incluyen en el MVP de forma **representativa y acotada**;
> la prioridad indica el foco de surtido y profundidad, no la exclusión.

---

## 6. Productos Ejemplo para el MVP

Set pequeño y representativo de productos de ejemplo con nombres ficticios. Los
SKU son **funcionales** (no técnicos) y sirven solo para ilustrar el catálogo;
este documento **no es una carga de datos definitiva**.

| SKU funcional | Nombre de producto | Categoría | Tipo de producto | Cliente objetivo | Relevancia MVP | Notas funcionales |
| --- | --- | --- | --- | --- | --- | --- |
| LVL-CON-001 | LvlUp Console Pro X | Consolas de gaming | Consola sobremesa | Tienda gaming local | Alta | Producto ancla; sensible a stock |
| LVL-CON-002 | LvlUp Console Go | Consolas de gaming | Consola portátil | Tienda gaming local | Media | Variante portátil |
| LVL-CON-003 | LvlUp Console Pro X Starter Pack | Consolas de gaming | Pack de consola | Tienda gaming local | Media | Consola + mando + juego |
| LVL-VGM-001 | Galaxy Raiders (Físico) | Videojuegos | Juego físico | Tienda gaming local | Alta | Lanzamiento popular |
| LVL-VGM-002 | Galaxy Raiders (Digital) | Videojuegos | Juego digital | Tienda gaming local | Media | Versión digital |
| LVL-VGM-003 | Speed Legends Bundle | Videojuegos | Bundle de juegos | Tienda gaming local | Baja | Pack de varios títulos |
| LVL-LAP-001 | LvlUp Gaming Laptop 15 | Portátiles | Gaming laptop | Reseller tecnológico | Alta | Alto valor; margen de reventa |
| LVL-LAP-002 | LvlUp Business Laptop 14 | Portátiles | Business laptop | Empresa IT | Alta | Equipamiento corporativo |
| LVL-LAP-003 | LvlUp Workstation 17 | Portátiles | Workstation laptop | Cliente enterprise | Media | Alto rendimiento |
| LVL-MON-001 | LvlUp 27'' Gaming Monitor | Monitores | Monitor gaming | Tienda gaming local | Alta | Complemento gaming |
| LVL-MON-002 | LvlUp 24'' Pro Monitor | Monitores | Monitor profesional | Empresa IT | Media | Equipamiento de oficina |
| LVL-MON-003 | LvlUp 34'' Curved 4K | Monitores | Monitor curvo 4K | Cliente enterprise | Baja | Gama alta |
| LVL-PER-001 | LvlUp Mechanical Keyboard | Periféricos | Teclado | Tienda gaming local | Alta | Alta recurrencia |
| LVL-PER-002 | LvlUp Pro Gaming Mouse | Periféricos | Ratón | Tienda gaming local | Media | Recurrente |
| LVL-PER-003 | LvlUp Wireless Headset | Periféricos | Auriculares | Reseller tecnológico | Media | Transversal |
| LVL-PER-004 | LvlUp Wireless Controller | Periféricos | Mando | Tienda gaming local | Media | Accesorio de consola |
| LVL-NET-001 | LvlUp WiFi 6 Router | Networking | Router | Empresa IT | Media | Reseller y oficina |
| LVL-NET-002 | LvlUp 8-Port Switch | Networking | Switch | Cliente enterprise | Media | Infraestructura de red |
| LVL-ACC-001 | LvlUp USB-C Cable 2m | Accesorios | Cable | Todos los segmentos | Baja | Consumible |
| LVL-ACC-002 | LvlUp Monitor Stand | Accesorios | Soporte | Empresa IT | Baja | Complemento de oficina |
| LVL-ACC-003 | LvlUp 65W USB-C Charger | Accesorios | Cargador | Todos los segmentos | Baja | Reemplazo |
| LVL-BND-001 | LvlUp Reseller Starter Bundle | Bundles enterprise | Kit tienda gaming | Reseller tecnológico | Media | Pack orientado a reventa |
| LVL-BND-002 | LvlUp Office Setup Kit | Bundles enterprise | Kit oficina | Empresa IT | Media | Renovación tecnológica |
| LVL-BND-003 | LvlUp Event Gaming Kit | Bundles enterprise | Kit eventos | Cliente enterprise | Baja | Eventos y activaciones |

---

## 7. Estrategia de Visibilidad de Catálogo

Comportamiento funcional esperado de la visibilidad (sin configuración técnica
concreta):

- Algunos productos pueden estar **visibles para todos** los buyers autenticados.
- Algunos productos pueden estar **restringidos** por Buyer Group o cuenta.
- Los clientes **enterprise** pueden tener acceso a **bundles específicos**.
- Los **resellers** pueden tener acceso a productos o packs orientados a reventa.
- Los productos **no visibles no deben aparecer** en PLP, búsqueda ni PDP.
- La visibilidad debe mantenerse **consistente** durante PLP, PDP, carrito y
  reorder.

Esta estrategia es coherente con las reglas `PV-*` de
`docs/business/pricing-and-visibility-strategy.md`.

---

## 8. Estrategia de Pricing Relacionada con Catálogo

Relación funcional entre catálogo y pricing:

- El comprador debe ver el **precio aplicable** a su cuenta o Buyer Group.
- El **mismo producto** puede tener un **precio distinto según el segmento**.
- El pricing debe ser **consistente** en PLP, PDP, carrito y checkout.
- El **pricing avanzado por volumen** queda como consideración futura.
- Las **promociones complejas** quedan fuera del MVP.

Esta estrategia es coherente con las reglas `PR-*` de
`docs/business/pricing-and-visibility-strategy.md`. No se entra en implementación
técnica concreta.

---

## 9. Estrategia de Stock Relacionada con Catálogo

- Los productos deben mostrar **disponibilidad funcional** cuando aplique.
- El comprador debe entender si puede **comprar, ajustar la cantidad o esperar
  reposición**.
- El **stock real vía ERP** está fuera del MVP.
- El **stock simulado vía REST / Postman Mock Server** queda como fase futura.
- El catálogo debe estar **preparado conceptualmente** para soportar el escenario
  de stock insuficiente.

---

## 10. Datos Funcionales Recomendados por Producto

Información funcional que un producto debería tener para soportar PLP/PDP y la
compra B2B. Es una **guía funcional**, no una definición técnica del data model:

- SKU.
- Nombre.
- Categoría.
- Descripción corta.
- Descripción larga.
- Imagen o placeholder visual.
- Precio aplicable.
- Disponibilidad / stock funcional.
- Unidad de venta.
- Cantidad mínima si aplica.
- Atributos relevantes.
- Segmento o visibilidad funcional.
- Estado activo / inactivo.

---

## 11. Consideraciones para PLP

- Mostrar los productos **visibles** para el buyer.
- Mostrar **nombre, imagen, precio aplicable y disponibilidad funcional** cuando
  aplique.
- Permitir la **navegación por categorías**.
- Soportar **búsqueda y filtros básicos** si el estándar lo permite.
- Evitar la **saturación visual**.
- Priorizar la **claridad y la velocidad**.
- Considerar el enfoque **mobile-first**.

---

## 12. Consideraciones para PDP

- Mostrar **información clara** del producto.
- Mostrar el **precio aplicable**.
- Mostrar la **disponibilidad funcional**.
- Permitir **agregar al carrito** si el producto es comprable.
- Mostrar información **relevante para la compra B2B** (SKU, categoría, unidad de
  venta, cantidad).
- Evitar contenido **excesivamente B2C**.
- Considerar **productos relacionados o alternativas** como consideración futura.

---

## 13. Consideraciones para Reorder

- Un producto de un pedido anterior puede **ya no estar visible**.
- Un producto puede tener un **precio actualizado**.
- Un producto puede **no tener stock suficiente**.
- El reorder debe **validar visibilidad, pricing y disponibilidad actuales**.
- Los **cambios deben informarse claramente** al buyer.

Coherente con `BR-REORDER-003` y `PV-007`.

---

## 14. Supuestos Actuales

- El catálogo inicial será **pequeño y representativo**.
- El MVP **no requiere catálogo multi-región**.
- El MVP **no requiere marketplace**.
- La **visibilidad** puede depender de la cuenta o del Buyer Group.
- El **pricing** puede depender de la cuenta o del Buyer Group.
- El **stock real** queda fuera del MVP.
- Se priorizarán las **capacidades estándar** de B2B Commerce.

---

## 15. Decisiones Pendientes

- Productos definitivos del MVP.
- Categorías definitivas en Salesforce.
- Segmentos o Buyer Groups concretos.
- Reglas exactas de visibilidad.
- Reglas exactas de pricing.
- Nivel de detalle requerido en la PDP.
- Si habrá cantidades mínimas de compra.
- Si se mostrarán productos alternativos ante stock insuficiente.
- Si habrá productos destacados en la Home.

---

## 16. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto.
- `docs/business/ecommerce-strategy.md` define la **estrategia de e-commerce**.
- `docs/business/buyer-personas.md` define los **compradores**.
- `docs/business/business-rules.md` define las **reglas de negocio**.
- `docs/business/b2b-commerce-flows.md` define los **flujos funcionales**.
- `docs/business/mvp-scope.md` delimita el **MVP**.
- `docs/business/pricing-and-visibility-strategy.md` define el **pricing y la
  visibilidad funcional**, con los que este catálogo debe mantenerse coherente.
- Este documento define la **estrategia funcional de catálogo**.
- Las **decisiones técnicas** deberán documentarse en `docs/architecture/`.
- La **configuración real** de Salesforce B2B Commerce deberá documentarse después
  en `docs/salesforce/`.
- Los **casos de prueba** deberán derivarse en `docs/testing/` o `evals/`.
