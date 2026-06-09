# Buyer Personas - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define las **buyer personas** principales del proyecto
`LvlUp-Wholesale-B2B`: los perfiles de comprador B2B que representan a los
clientes de LvlUp WholeSale y que guiarán las decisiones **funcionales, de UX,
comerciales y técnicas** del portal.

Las personas se alinean con la estrategia descrita en
`docs/business/ecommerce-strategy.md` y con el contexto de
`PROJECT_CONTEXT.md`. Su objetivo es dar un marco humano y realista a las
funcionalidades del MVP (catálogo, PLP, PDP, carrito, checkout básico, historial,
reorder, aprobación por importe, pricing personalizado, catálogo restringido y la
futura integración simulada de stock), de modo que cada decisión pueda validarse
contra una necesidad concreta de un comprador.

Es documentación funcional y de negocio estable. No define configuración técnica
de Salesforce; esa responsabilidad recae en `docs/architecture/`.

---

## 2. Resumen de Buyer Personas

| Persona | Tipo de cliente | Necesidad principal | Frecuencia de compra | Relevancia para el MVP |
| --- | --- | --- | --- | --- |
| Responsable de compras de tienda gaming local | Tienda gaming local | Reponer rápido productos populares con stock visible | Alta | Alta — perfil canónico del MVP |
| Reseller tecnológico | Reseller tecnológico | Precios negociados y catálogo amplio fiable | Media-alta | Alta — valida pricing y visibilidad |
| Responsable IT de empresa | Empresa con compra interna | Compra controlada con aprobación por importe | Baja-media | Media-alta — valida aprobación y crédito |
| Cliente enterprise con compras recurrentes | Enterprise recurrente | Pricing personalizado y reorder eficiente de alto volumen | Alta | Media — valida casos límite |

---

## 3. Persona 1: Responsable de compras de tienda gaming local

- **Descripción**: persona responsable de las compras (a menudo el propio
  propietario) de una pequeña tienda física de gaming.
- **Contexto de negocio**: comercio local que revende consolas, videojuegos,
  periféricos y accesorios a consumidores finales; márgenes ajustados y fuerte
  dependencia de la disponibilidad en lanzamientos y campañas.
- **Objetivos**: mantener surtido de los productos más demandados, reponer con
  agilidad y no perder ventas por roturas de stock.
- **Necesidades principales**: precios claros por su cuenta, visibilidad de stock,
  proceso de reorder rápido para referencias habituales.
- **Pain points**: hoy compra por email o teléfono, sin ver stock ni precios al
  instante; los pedidos repetidos son trabajo manual y propensos a error.
- **Comportamiento de compra**: pedidos frecuentes de importe medio-bajo, muy
  recurrentes sobre un conjunto acotado de referencias.
- **Productos más relevantes**: consolas de gaming, videojuegos, periféricos y
  accesorios.
- **Funcionalidades clave del portal**: catálogo, búsqueda, PLP, PDP, carrito,
  checkout básico, historial de pedidos y reorder.
- **Consideraciones UX**: mobile-first, navegación simple y rápida, reorder
  accesible en pocos pasos; claridad de precio y disponibilidad en PLP/PDP.
- **Relevancia para el MVP**: alta. Es el perfil canónico para validar el journey
  completo de compra estándar y el reorder.

---

## 4. Persona 2: Reseller tecnológico

- **Descripción**: responsable de compras de un revendedor especializado en
  tecnología que abastece a otras empresas o tiendas.
- **Contexto de negocio**: opera con catálogo amplio (portátiles, monitores,
  networking, periféricos) y compite por precio y disponibilidad; el margen
  depende de comprar bien y en volumen.
- **Objetivos**: obtener precios negociados competitivos, asegurar fiabilidad de
  stock y trazabilidad de sus pedidos.
- **Necesidades principales**: pricing por cuenta o Buyer Group, catálogo amplio y
  diferenciado, información de stock fiable, historial y reorder.
- **Pain points**: poca transparencia de precios negociados, dependencia del
  representante y riesgo de errores en pedidos de volumen.
- **Comportamiento de compra**: pedidos de importe medio-alto, combinando
  recurrencia con compras puntuales de mayor volumen.
- **Productos más relevantes**: portátiles, monitores, networking y periféricos.
- **Funcionalidades clave del portal**: pricing por cuenta/Buyer Group, catálogo
  con visibilidad diferenciada, PLP, PDP, carrito, checkout, historial, reorder y,
  potencialmente, aprobación por importe.
- **Consideraciones UX**: visibilidad inmediata del precio negociado, eficiencia
  para pedidos de varias líneas y comparación ágil dentro de una categoría.
- **Relevancia para el MVP**: alta. Valida pricing por cuenta/Buyer Group y la
  visibilidad de catálogo diferenciada.

---

## 5. Persona 3: Responsable IT de empresa

- **Descripción**: responsable de IT o de compras internas de una empresa que
  **no** se dedica a la reventa y adquiere tecnología para uso propio.
- **Contexto de negocio**: compra equipamiento para empleados y oficina
  (renovaciones, nuevas incorporaciones), con control presupuestario y, a menudo,
  necesidad de aprobación interna.
- **Objetivos**: equipar a la organización cumpliendo presupuesto, con precios
  claros y trazabilidad administrativa de cada pedido.
- **Necesidades principales**: proceso de compra simple, precios claros, historial
  para control y un flujo de aprobación por importe.
- **Pain points**: aprobaciones manuales lentas, falta de trazabilidad y
  dependencia de un comercial para confirmar disponibilidad y precio.
- **Comportamiento de compra**: compras menos frecuentes pero a menudo de importe
  elevado y concentradas en momentos puntuales.
- **Productos más relevantes**: portátiles, monitores, networking y accesorios.
- **Funcionalidades clave del portal**: aprobación por importe, validación de
  límite de crédito, historial de pedidos, checkout básico y PDP con información
  clara.
- **Consideraciones UX**: flujo de aprobación comprensible y transparente, estados
  de pedido claros y resumen de importe antes de confirmar.
- **Relevancia para el MVP**: media-alta. Es el perfil idóneo para ejercitar la
  aprobación por importe y la validación de límite de crédito.

---

## 6. Persona 4: Cliente enterprise con compras recurrentes

- **Descripción**: responsable de compras de un cliente de gran tamaño con
  relación comercial consolidada y acuerdos específicos.
- **Contexto de negocio**: realiza compras periódicas de alto volumen bajo
  condiciones negociadas; valora la previsibilidad y la eficiencia operativa.
- **Objetivos**: garantizar recurrencia sin fricción, cumplir su acuerdo comercial
  y minimizar el esfuerzo manual en pedidos grandes.
- **Necesidades principales**: pricing personalizado, catálogo ajustado a su
  acuerdo (restringido o ampliado), límites de crédito amplios, reorder eficiente
  y trazabilidad completa.
- **Pain points**: gestión manual de pedidos grandes, dependencia del comercial y
  riesgo de error en compras de alto importe.
- **Comportamiento de compra**: pedidos recurrentes y de gran volumen, con fuerte
  apoyo en el reorder.
- **Productos más relevantes**: bundles enterprise, portátiles, monitores y
  networking en volumen.
- **Funcionalidades clave del portal**: pricing personalizado, catálogo
  restringido o personalizado, reorder, historial y validación de crédito.
- **Consideraciones UX**: reorder destacado, eficiencia en pedidos de muchas
  líneas y visibilidad clara del estado de crédito y de los pedidos.
- **Relevancia para el MVP**: media. Valida los casos límite de pricing
  personalizado, catálogo restringido y crédito; los matices de jerarquía de
  usuarios y acuerdos complejos quedan como consideración futura.

---

## 7. Roles B2B Actuales y Futuros

### Situación en el MVP

Para el MVP, **cada cuenta buyer tendrá un único usuario operativo**. Ese usuario
concentra todas las acciones del comprador: navegar el catálogo, gestionar el
carrito, completar el checkout, consultar el historial y lanzar reorders. Cuando
un pedido requiere aprobación por importe, el flujo de aprobación existe como
funcionalidad, pero no implica todavía una separación de roles entre quien compra
y quien aprueba.

### Jerarquía futura prevista

El modelo funcional debe quedar preparado para una futura jerarquía de roles, sin
sobre-ingeniería en el MVP más allá de lo que requiera la configuración estándar
de Salesforce B2B Commerce.

#### Buyer User

- **Responsabilidad**: operar la compra del día a día en nombre de la cuenta.
- **Acciones posibles**: buscar y navegar el catálogo, añadir al carrito, hacer
  checkout, reordenar y consultar el historial.
- **Relevancia futura**: rol base sobre el que se construyen los demás.
- **Dentro/fuera del MVP**: la **función** está en el MVP (la cubre el usuario
  único); la **separación formal del rol** queda fuera del MVP.

#### Buyer Approver

- **Responsabilidad**: revisar y aprobar o rechazar pedidos que superan el umbral
  de importe.
- **Acciones posibles**: consultar pedidos pendientes, aprobar o rechazar y, en su
  caso, añadir comentarios.
- **Relevancia futura**: necesario cuando se separe la función de compra de la de
  aprobación dentro de una misma cuenta.
- **Dentro/fuera del MVP**: el **flujo de aprobación por importe** está en el MVP;
  el **rol diferenciado de aprobador** queda fuera (lo asume el usuario único).

#### Buyer Admin

- **Responsabilidad**: administrar la cuenta buyer y sus usuarios.
- **Acciones posibles**: alta y baja de usuarios, gestión de su acceso y de la
  configuración de la cuenta.
- **Relevancia futura**: necesario al existir varios usuarios por cuenta.
- **Dentro/fuera del MVP**: fuera del MVP.

---

## 8. Necesidades Comunes de los Compradores

Necesidades compartidas por todas las personas, con independencia de su tipo de
cliente:

- **Login seguro**: acceso autenticado a la cuenta antes de ver precios y catálogo
  restringido.
- **Catálogo claro**: organización comprensible por categorías de tecnología y
  gaming.
- **Búsqueda rápida**: localización ágil de productos por nombre o categoría.
- **Precios negociados visibles**: ver el precio específico de su cuenta o Buyer
  Group.
- **Stock visible**: conocer la disponibilidad antes de comprar.
- **Carrito simple**: gestión clara de líneas y cantidades.
- **Checkout claro**: proceso de confirmación sencillo (sin pago real en el MVP).
- **Historial de pedidos**: consulta de pedidos anteriores y su estado.
- **Reorder**: repetición ágil de compras recurrentes.
- **Solicitud de aprobación**: posibilidad de que un pedido entre en flujo de
  aprobación por importe.
- **Solicitud de cotización**: posibilidad de pedir un presupuesto en lugar de
  comprar directamente *(alcance en el MVP por confirmar)*.

---

## 9. Diferencias Funcionales por Tipo de Cliente

| Tipo de cliente | Catálogo esperado | Pricing esperado | Frecuencia de compra | Necesidad de aprobación | Necesidad de reorder | Sensibilidad al stock |
| --- | --- | --- | --- | --- | --- | --- |
| Tienda gaming local | Estándar orientado a gaming | Por cuenta | Alta | Baja | Alta | Alta |
| Reseller tecnológico | Amplio y diferenciado | Negociado, con volumen futuro | Media-alta | Media | Alta | Alta |
| Empresa con compra interna | Estándar tecnológico | Por cuenta | Baja-media | Alta | Media | Media |
| Enterprise recurrente | Personalizado o restringido | Personalizado | Alta | Media-alta | Alta | Alta |

> Los valores de esta tabla son un modelo funcional de partida; la segmentación
> real en Buyer Groups y las reglas concretas de pricing, aprobación y stock son
> decisiones pendientes (ver sección 11).

---

## 10. Implicaciones para B2B Commerce

Estas personas condicionan futuras decisiones funcionales sobre el storefront de
Salesforce B2B Commerce. Se documentan solo las **implicaciones funcionales**, no
la configuración técnica:

- **Buyer Groups**: la diversidad de perfiles sugiere agrupar clientes para
  diferenciar catálogo y pricing; la cantidad y los criterios de los grupos están
  por definir.
- **Catálogo restringido**: clientes enterprise y ciertos resellers pueden requerir
  un catálogo acotado o ampliado respecto al estándar.
- **Pricing por cuenta o segmento**: todas las personas esperan precios negociados;
  el modelo debe soportar precios por cuenta y, potencialmente, por segmento.
- **Product visibility**: la visibilidad de producto debe poder variar por cuenta o
  Buyer Group, apoyándose en capacidades estándar de B2B Commerce.
- **Reorder**: es una necesidad transversal y especialmente crítica para tienda
  local y enterprise; debe ser eficiente y revalidar precio y stock actuales.
- **Approval flows**: los perfiles de empresa y enterprise justifican la aprobación
  por importe; el umbral y el alcance se definirán más adelante.
- **UX del storefront**: la diversidad de frecuencia y volumen exige una UX
  mobile-first, clara y orientada a la repetición de compra.
- **Testing funcional**: las personas sirven de base para diseñar casos de prueba
  funcionales representativos de cada tipo de cliente y flujo.

---

## 11. Supuestos y Decisiones Pendientes

Supuestos actuales y decisiones que deberán definirse más adelante:

- **Segmentación exacta de Buyer Groups**: número, criterios y correspondencia con
  los tipos de cliente.
- **Reglas exactas de pricing**: precios negociados, asignación a cuentas o
  segmentos y eventual pricing por volumen.
- **Umbral de aprobación por importe**: valor que dispara el flujo de aprobación.
- **Reglas de crédito**: cálculo del crédito disponible y acción ante superación
  del límite.
- **Diferencias reales entre clientes reseller y enterprise**: alcance de catálogo,
  pricing y crédito que los distingue.
- **Productos específicos por categoría**: surtido concreto y composición de los
  bundles enterprise.

---

## 12. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto y del negocio.
- `docs/business/ecommerce-strategy.md` define la **estrategia de e-commerce B2B**,
  incluidos los tipos de cliente que aquí se desarrollan como personas.
- Este documento define los **perfiles de comprador** que guían las decisiones
  funcionales, de UX y comerciales.
- Las **reglas de negocio detalladas** deberán evolucionar luego en
  `docs/business/business-rules.md`.
- Las **implicaciones técnicas** deberán documentarse después en
  `docs/architecture/`.
