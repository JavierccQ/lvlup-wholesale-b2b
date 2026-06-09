# Estrategia de Pricing y Visibilidad - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define cómo debe comportarse **funcionalmente** el pricing y la
visibilidad de productos para los compradores B2B de LvlUp WholeSale. Describe el
comportamiento esperado, no la configuración técnica.

Sirve como base para:

- Configuración funcional del catálogo.
- Buyer Groups.
- Segmentación de clientes.
- PLP.
- PDP.
- Carrito.
- Checkout.
- Reorder.
- Testing funcional.
- Futuras decisiones técnicas.

Este documento **no define configuración técnica detallada de Salesforce** ni
reglas definitivas de implementación. Se alinea con `docs/business/ecommerce-strategy.md`,
`docs/business/buyer-personas.md`, `docs/business/business-rules.md`,
`docs/business/b2b-commerce-flows.md` y `docs/business/mvp-scope.md`, y aplica el
principio rector del proyecto: *Configuration first, customization only when
justified*.

---

## 2. Principios de Pricing y Visibilidad B2B

- El comprador debe ver **solo los productos permitidos** para su cuenta o
  segmento.
- El comprador debe ver el **precio aplicable** a su cuenta, Buyer Group o
  segmento.
- La experiencia debe ser **consistente** en PLP, PDP, carrito y checkout.
- Un producto no visible **no debe aparecer** en PLP, búsqueda, PDP ni reorder.
- El pricing y la visibilidad deben **priorizar las capacidades estándar** de
  Salesforce B2B Commerce.
- La **customización** solo debe considerarse si el estándar no cubre una necesidad
  funcional justificada.
- El MVP debe **evitar el pricing excesivamente complejo**.

---

## 3. Segmentación Funcional de Clientes

Segmentación funcional inicial para el MVP. Es un modelo de negocio, no una
configuración técnica definitiva; los segmentos se materializarán como cuentas o
Buyer Groups en la fase de configuración.

### 3.1. Tienda gaming local

- **Descripción**: comercio físico local de gaming que revende a consumidor final.
- **Necesidad principal**: reponer rápido productos populares con stock visible.
- **Tipo de catálogo esperado**: catálogo estándar orientado a gaming.
- **Tipo de pricing esperado**: precio básico negociado por su cuenta.
- **Relevancia para el MVP**: alta (perfil canónico).
- **Consideraciones de visibilidad**: ve el núcleo de gaming y accesorios; puede no
  necesitar bundles enterprise ni networking avanzado.

### 3.2. Reseller tecnológico

- **Descripción**: revendedor especializado en tecnología que abastece a empresas o
  tiendas.
- **Necesidad principal**: precios negociados competitivos y catálogo amplio y
  fiable.
- **Tipo de catálogo esperado**: catálogo amplio y diferenciado.
- **Tipo de pricing esperado**: pricing orientado a margen de reventa, con volumen
  como evolución futura.
- **Relevancia para el MVP**: alta.
- **Consideraciones de visibilidad**: acceso a un catálogo más amplio que la tienda
  local; potencial acceso futuro a bundles.

### 3.3. Empresa compradora de equipamiento interno

- **Descripción**: empresa no revendedora que adquiere tecnología para uso interno.
- **Necesidad principal**: compra controlada con precios claros y trazabilidad.
- **Tipo de catálogo esperado**: catálogo tecnológico (sin foco en gaming).
- **Tipo de pricing esperado**: pricing por equipamiento corporativo, por su cuenta.
- **Relevancia para el MVP**: media-alta (ejercita aprobación y crédito).
- **Consideraciones de visibilidad**: foco en portátiles, monitores, networking y
  accesorios; gaming puro puede no aplicar.

### 3.4. Cliente enterprise recurrente

- **Descripción**: cliente de gran tamaño con acuerdos específicos y compras
  periódicas de alto volumen.
- **Necesidad principal**: pricing personalizado y estable, y reorder eficiente.
- **Tipo de catálogo esperado**: catálogo personalizado o restringido a su acuerdo.
- **Tipo de pricing esperado**: pricing más personalizado y estable.
- **Relevancia para el MVP**: media (casos límite).
- **Consideraciones de visibilidad**: acceso prioritario a bundles enterprise y a
  un catálogo potencialmente ajustado a su acuerdo.

---

## 4. Estrategia de Buyer Groups

Los Buyer Groups pueden usarse como **mecanismo funcional** para agrupar
compradores con necesidades de catálogo y pricing similares. Los nombres y la
configuración final deberán validarse en la fase de Salesforce/configuración; aquí
se proponen grupos funcionales de partida.

### 4.1. Gaming Local Buyers

- **Propósito**: agrupar tiendas gaming locales con necesidades similares.
- **Tipo de cliente incluido**: tienda gaming local.
- **Productos relevantes**: consolas, videojuegos, periféricos, accesorios.
- **Consideraciones de pricing**: pricing básico negociado.
- **Consideraciones de visibilidad**: catálogo gaming estándar; sin bundles
  enterprise.
- **Estado MVP**: Supuesto.

### 4.2. Tech Resellers

- **Propósito**: agrupar resellers tecnológicos.
- **Tipo de cliente incluido**: reseller tecnológico.
- **Productos relevantes**: portátiles, monitores, networking, periféricos.
- **Consideraciones de pricing**: pricing orientado a margen; volumen futuro.
- **Consideraciones de visibilidad**: catálogo amplio; bundles como futuro.
- **Estado MVP**: Supuesto.

### 4.3. Corporate IT Buyers

- **Propósito**: agrupar empresas que compran equipamiento interno.
- **Tipo de cliente incluido**: empresa compradora de equipamiento interno.
- **Productos relevantes**: portátiles, monitores, networking, accesorios.
- **Consideraciones de pricing**: pricing por equipamiento corporativo.
- **Consideraciones de visibilidad**: foco tecnológico; gaming puro puede
  restringirse.
- **Estado MVP**: Supuesto.

### 4.4. Enterprise Buyers

- **Propósito**: agrupar clientes enterprise con acuerdos específicos.
- **Tipo de cliente incluido**: cliente enterprise recurrente.
- **Productos relevantes**: bundles enterprise, portátiles, monitores, networking en
  volumen.
- **Consideraciones de pricing**: pricing personalizado y estable.
- **Consideraciones de visibilidad**: catálogo personalizado o restringido; acceso
  prioritario a bundles.
- **Estado MVP**: Supuesto.

> Los nombres exactos y la configuración final de los Buyer Groups deberán
> validarse posteriormente en la fase Salesforce/configuración.

---

## 5. Visibilidad de Productos

Reglas funcionales de visibilidad. Prioridad MVP: Alta / Media / Baja. Estado:
Definido / Supuesto / Pendiente / Futuro.

- **PV-001** — Productos del catálogo base visibles para todos los compradores
  autenticados.
- **PV-002** — Productos visibles solo para resellers (Tech Resellers).
- **PV-003** — Productos visibles solo para enterprise (Enterprise Buyers).
- **PV-004** — Bundles visibles solo para ciertos segmentos.
- **PV-005** — Productos no disponibles comercialmente no deben mostrarse.
- **PV-006** — Productos restringidos no deben aparecer en PLP, búsqueda ni PDP.
- **PV-007** — El reorder debe validar si los productos siguen siendo visibles.

| ID | Regla de visibilidad | Segmento afectado | Prioridad MVP | Estado |
| --- | --- | --- | --- | --- |
| PV-001 | Catálogo base visible para todo comprador autenticado | Todos | Alta | Definido |
| PV-002 | Productos visibles solo para resellers | Tech Resellers | Media | Supuesto |
| PV-003 | Productos visibles solo para enterprise | Enterprise Buyers | Media | Supuesto |
| PV-004 | Bundles visibles solo para ciertos segmentos | Enterprise (y reseller futuro) | Media | Supuesto |
| PV-005 | Ocultar productos no disponibles comercialmente | Todos | Alta | Definido |
| PV-006 | Productos restringidos fuera de PLP, búsqueda y PDP | Segmentos restringidos | Alta | Definido |
| PV-007 | Revalidar visibilidad en el reorder | Todos | Alta | Definido |

---

## 6. Estrategia de Pricing

Reglas funcionales de pricing. Prioridad MVP: Alta / Media / Baja. Estado:
Definido / Supuesto / Pendiente / Futuro.

- **PR-001** — El pricing puede depender de la cuenta o del Buyer Group.
- **PR-002** — El comprador autenticado debe ver el precio aplicable a su segmento.
- **PR-003** — El precio debe ser consistente en PLP, PDP, carrito y checkout.
- **PR-004** — Si existe pricing específico, no debe mostrarse un pricing genérico
  contradictorio.
- **PR-005** — El pricing por volumen queda como consideración futura.
- **PR-006** — Las promociones complejas quedan fuera del MVP.
- **PR-007** — La multi-divisa queda fuera del MVP.

| ID | Regla de pricing | Segmento afectado | Prioridad MVP | Estado |
| --- | --- | --- | --- | --- |
| PR-001 | Pricing por cuenta o Buyer Group | Todos | Alta | Definido (reglas exactas pendientes) |
| PR-002 | Precio aplicable al segmento del comprador | Todos | Alta | Definido |
| PR-003 | Consistencia de precio en PLP/PDP/carrito/checkout | Todos | Alta | Definido |
| PR-004 | Prevalece el precio específico sobre el genérico | Todos | Alta | Definido |
| PR-005 | Pricing por volumen | Resellers/Enterprise | Baja | Futuro |
| PR-006 | Promociones complejas | Todos | — | Futuro (fuera del MVP) |
| PR-007 | Multi-divisa | Todos | — | Futuro (fuera del MVP) |

---

## 7. Matriz Segmento vs Categoría

Matriz funcional de visibilidad por categoría. Valores: Visible / Restringido /
Prioritario / Futuro / No aplica.

| Categoría | Tienda gaming local | Reseller tecnológico | Empresa IT | Cliente enterprise | Comentario |
| --- | --- | --- | --- | --- | --- |
| Consolas de gaming | Prioritario | Visible | No aplica | Visible | Ancla de gaming; sin foco para empresa interna |
| Videojuegos | Prioritario | Visible | No aplica | Visible | Alta rotación gaming |
| Portátiles | Visible | Prioritario | Prioritario | Prioritario | Alto valor transversal |
| Monitores | Visible | Visible | Prioritario | Prioritario | Complemento de portátiles |
| Periféricos | Visible | Visible | Visible | Visible | Recurrencia transversal |
| Networking | Visible | Prioritario | Visible | Prioritario | Foco reseller y enterprise |
| Accesorios | Visible | Visible | Visible | Visible | Refuerzan ticket; transversal |
| Bundles enterprise | No aplica | Futuro | Restringido | Prioritario | Orientado a enterprise; visibilidad por segmento |

---

## 8. Matriz Segmento vs Pricing

Matriz funcional de la estrategia de pricing por segmento.

| Segmento | Tipo de pricing esperado | Nivel de personalización | Sensibilidad al precio | Consideraciones MVP | Futuro |
| --- | --- | --- | --- | --- | --- |
| Tienda gaming local | Básico negociado | Bajo | Alta | Pricing por cuenta; sin volumen | Posible escalado por recurrencia |
| Reseller tecnológico | Orientado a margen de reventa | Medio | Alta | Pricing por cuenta/Buyer Group | Pricing por volumen |
| Empresa IT | Por equipamiento corporativo | Medio | Media | Pricing por cuenta; foco en aprobación | Catálogos corporativos |
| Enterprise recurrente | Personalizado y estable | Alto | Media-baja | Pricing personalizado por cuenta | Acuerdos y volumen avanzados |

---

## 9. Comportamiento en PLP

- Mostrar **solo productos visibles** para el buyer.
- Mostrar el **precio aplicable** cuando corresponda.
- **No mostrar** productos restringidos.
- Evitar **mensajes técnicos** dirigidos al comprador.
- Considerar un **estado vacío** claro cuando no hay productos visibles.
- Mantener un diseño **claro y mobile-first**.

---

## 10. Comportamiento en PDP

- La PDP solo debe ser **accesible** si el producto es visible para el buyer.
- Debe mostrar el **precio aplicable**.
- Debe mostrar la **disponibilidad funcional** si aplica.
- Debe **evitar inconsistencias** entre el precio de PLP y el de PDP.
- Si un producto deja de estar disponible o visible, el buyer debe recibir
  **feedback claro**.

---

## 11. Comportamiento en Carrito

- El carrito debe mantener un **pricing consistente**.
- Si cambia la **visibilidad** de un producto, debe informarse.
- Si un producto **ya no está disponible**, debe informarse.
- Si el **pricing cambia**, debe mostrarse de forma clara.
- El carrito debe **validar las restricciones** antes del checkout.

---

## 12. Comportamiento en Checkout

- El checkout debe usar el **pricing vigente** aplicable.
- No debe permitir **confirmar productos** que ya no sean visibles o válidos.
- Debe mostrar **importes claros**.
- Pagos, tax y shipping reales quedan **fuera del MVP**.
- Si el importe **activa aprobación**, debe indicarse claramente.

---

## 13. Comportamiento en Reorder

- El reorder **no debe asumir** que todos los productos anteriores siguen
  disponibles.
- Debe validar la **visibilidad actual**.
- Debe validar el **pricing actual**.
- Debe validar la **disponibilidad funcional**.
- Los productos no válidos deben **informarse claramente**.
- El buyer debe poder **continuar con los productos válidos**.

---

## 14. Casos Funcionales Clave

Casos funcionales que deberán probarse más adelante (base para `docs/testing/` o
`evals/`):

- El buyer ve solo los productos permitidos para su segmento.
- El buyer no ve productos restringidos.
- El buyer ve el precio específico de su segmento.
- El precio es consistente en PLP, PDP, carrito y checkout.
- Un producto visible para enterprise no aparece para una tienda gaming local.
- Un producto de un pedido anterior ya no es visible durante el reorder.
- Un producto con pricing actualizado durante el reorder.
- El carrito detecta un producto no válido antes del checkout.

---

## 15. Supuestos Actuales

- La segmentación inicial se basará en la cuenta o el Buyer Group.
- Los **Buyer Groups definitivos** están pendientes.
- El **pricing exacto** está pendiente.
- La **visibilidad exacta** está pendiente.
- El MVP **no incluye promociones complejas**.
- El MVP **no incluye multi-divisa**.
- El **pricing por volumen no es obligatorio** para el MVP.
- Se priorizará la **configuración estándar** de Salesforce B2B Commerce.

---

## 16. Decisiones Pendientes

- Nombres definitivos de los Buyer Groups.
- Segmentos definitivos del MVP.
- Productos visibles por segmento.
- Reglas exactas de pricing.
- Si habrá pricing por volumen en fases futuras.
- Cómo se representará el stock en PLP/PDP.
- Qué mensajes UX se mostrarán cuando un producto no esté disponible o visible.
- Qué validaciones exactas ocurrirán en carrito y checkout.

---

## 17. Fuera de Alcance

- Promociones complejas.
- Multi-divisa.
- Marketplace.
- Pricing dinámico avanzado.
- Motor externo de pricing.
- ERP real.
- Reglas fiscales.
- Descuentos comerciales complejos no justificados por el MVP.

---

## 18. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto y del negocio.
- `docs/business/ecommerce-strategy.md` define la **estrategia de e-commerce B2B**.
- `docs/business/buyer-personas.md` define los **perfiles de comprador**.
- `docs/business/business-rules.md` define las **reglas de negocio**.
- `docs/business/b2b-commerce-flows.md` define los **flujos funcionales**.
- `docs/business/mvp-scope.md` delimita el **alcance del MVP**.
- `docs/business/product-catalog-strategy.md` *(documento previsto)* recogerá la
  **estrategia de catálogo de producto**; este documento deberá alinearse con él
  cuando exista.
- Este documento define el **pricing y la visibilidad funcional**.
- La **configuración técnica** deberá documentarse luego en `docs/salesforce/`.
- Las **decisiones arquitectónicas** deberán documentarse en `docs/architecture/`.
- Los **casos de prueba** deberán derivarse en `docs/testing/` o `evals/`.
