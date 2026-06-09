# Estrategia E-Commerce B2B - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define la **estrategia funcional de e-commerce B2B** del proyecto
`LvlUp-Wholesale-B2B`. Describe cómo el negocio de LvlUp WholeSale se traduce en
un storefront de Salesforce B2B Commerce: modelo comercial, tipos de cliente,
catálogo, pricing, visibilidad, stock, journey del comprador, flujos de negocio,
reglas iniciales y KPIs.

Es documentación de negocio estable, no técnica. Las decisiones de configuración
e implementación de Salesforce se documentan aparte en `docs/architecture/`. Las
reglas de negocio detalladas evolucionarán en `docs/business/business-rules.md`.

El documento asume el principio rector del proyecto:
*Configuration first, customization only when justified*. La estrategia prioriza
las capacidades estándar de Salesforce B2B Commerce y solo contempla
personalización cuando aporta valor de negocio claro.

---

## 2. Resumen del Negocio

**LvlUp WholeSale** es una distribuidora mayorista B2B ficticia, de estilo
startup, especializada en productos de **tecnología y gaming**. Opera
inicialmente en **España**, con la intención de habilitar una futura expansión a
otras regiones.

La empresa vende a **empresas, tiendas y resellers**, nunca a consumidores
finales. Su propuesta de valor es ofrecer un catálogo amplio de tecnología y
gaming con **precios negociados por cliente**, disponibilidad de stock y un canal
de compra recurrente fiable.

El objetivo del portal es trasladar a un storefront self-service un proceso de
compra que hoy ocurre mayoritariamente por email y teléfono, reduciendo carga
operativa, errores y dependencia del representante de ventas, y mejorando la
trazabilidad y la recurrencia de las compras.

---

## 3. Modelo Comercial B2B

LvlUp WholeSale opera un modelo **distribuidor a reseller**. El comportamiento de
compra es distinto al de un e-commerce B2C y la estrategia debe reflejar los
siguientes patrones:

- **Venta a empresas**: cada comprador actúa en nombre de una cuenta de negocio,
  no como particular. El acceso al catálogo y a los precios requiere sesión
  iniciada.
- **Compra recurrente**: gran parte del valor proviene de pedidos repetidos de
  los mismos productos; el reorder es un patrón central, no accesorio.
- **Precios por cuenta o Buyer Group**: los precios son negociados y específicos
  por cliente o por grupo de clientes; no existe un precio público único.
- **Volúmenes altos**: los pedidos tienden a ser de cantidades elevadas, lo que
  refuerza la importancia de la disponibilidad de stock y del control de crédito.
- **Catálogo restringido**: no todos los clientes ven el mismo catálogo; la
  oferta puede limitarse según el tipo de cliente o el Buyer Group.
- **Aprobación por importe**: pedidos por encima de cierto umbral pueden requerir
  una aprobación antes de confirmarse.
- **Stock visible**: el comprador necesita ver disponibilidad para decidir, sin
  depender de un representante.

Estos patrones guían el diseño del catálogo, el pricing, la visibilidad y los
flujos descritos en las secciones siguientes.

---

## 4. Tipos de Clientes

Para orientar el MVP se definen cuatro tipos de cliente representativos. Estos
perfiles son un modelo funcional de partida; la segmentación real en Buyer Groups
es una decisión pendiente (ver sección 13).

### 4.1. Tienda Gaming Local

- **Descripción**: pequeño comercio físico de gaming que revende consolas,
  videojuegos, accesorios y periféricos a consumidores finales.
- **Necesidades**: precios competitivos, reposición ágil de productos populares,
  visibilidad de stock para no quedarse sin existencias en lanzamientos.
- **Comportamiento de compra**: pedidos frecuentes de importe medio-bajo,
  fuertemente recurrentes sobre un conjunto acotado de referencias.
- **Relevancia para el MVP**: alta. Es el perfil canónico para validar catálogo,
  PLP/PDP, carrito, checkout básico y reorder.

### 4.2. Reseller Tecnológico

- **Descripción**: revendedor especializado en tecnología (portátiles, monitores,
  networking, periféricos) que abastece a otras empresas o a tiendas.
- **Necesidades**: precios negociados por volumen, catálogo amplio, información
  fiable de stock y trazabilidad de pedidos.
- **Comportamiento de compra**: pedidos de importe medio-alto, combinando
  recurrencia con compras puntuales de mayor volumen.
- **Relevancia para el MVP**: alta. Valida pricing por cuenta/Buyer Group,
  visibilidad de catálogo diferenciada y, potencialmente, aprobación por importe.

### 4.3. Empresa que Compra Equipamiento Tecnológico Interno

- **Descripción**: empresa no dedicada a la reventa que adquiere tecnología para
  uso interno (equipos para empleados, monitores, networking de oficina).
- **Necesidades**: proceso de compra simple, precios claros, historial de pedidos
  para control administrativo y, en su caso, flujo de aprobación interno por
  importe.
- **Comportamiento de compra**: compras menos frecuentes pero a menudo de importe
  elevado (renovaciones, equipamiento de nuevas incorporaciones).
- **Relevancia para el MVP**: media-alta. Es el perfil idóneo para ejercitar la
  aprobación por importe y la validación de límite de crédito.

### 4.4. Cliente Enterprise con Compras Recurrentes

- **Descripción**: cliente de gran tamaño con relación comercial consolidada y
  acuerdos específicos, que realiza compras periódicas y de alto volumen.
- **Necesidades**: pricing personalizado, catálogo potencialmente restringido o
  ampliado a su acuerdo, límites de crédito amplios, reorder eficiente y
  trazabilidad completa.
- **Comportamiento de compra**: pedidos recurrentes y de gran volumen, con fuerte
  dependencia del reorder y de la previsibilidad del stock.
- **Relevancia para el MVP**: media. Valida los casos límite de pricing
  personalizado, catálogo restringido y crédito; algunos matices (jerarquía de
  usuarios, acuerdos complejos) quedan como consideración futura.

---

## 5. Catálogo Inicial

El catálogo inicial se organiza en categorías principales alineadas con el
negocio de tecnología y gaming. La estructura técnica del Product Catalog y de
las ProductCategory es una decisión de modelado de datos posterior; aquí solo se
define el rol de negocio de cada categoría.

- **Consolas de gaming**: producto ancla de alta rotación y demanda estacional;
  motor de tráfico y de pedidos recurrentes para tiendas gaming.
- **Videojuegos**: catálogo amplio y de rotación rápida; complementa a consolas y
  favorece pedidos frecuentes de bajo importe unitario.
- **Portátiles**: referencia de alto valor para resellers y empresas; pedidos de
  importe elevado y sensibles a stock y pricing negociado.
- **Monitores**: complemento habitual de portátiles y equipamiento interno; buen
  candidato para venta cruzada y bundles.
- **Periféricos**: teclados, ratones, auriculares, controladores; alta recurrencia
  y ticket bajo, relevantes tanto para gaming como para empresa.
- **Networking**: routers, switches y equipamiento de red; orientado a resellers y
  a equipamiento interno empresarial.
- **Accesorios**: cables, soportes, almacenamiento y consumibles; refuerzan el
  ticket medio y la recurrencia.
- **Bundles enterprise**: paquetes preconfigurados para clientes empresariales y
  enterprise; simplifican la compra recurrente de alto volumen y son palanca de
  upselling. El alcance exacto de los bundles es una consideración futura.

---

## 6. Estrategia de Pricing

El pricing es un diferenciador central del modelo B2B. Los supuestos de partida
son:

- **Pricing específico por cuenta o Buyer Group**: cada cliente o grupo de
  clientes ve precios asignados a su relación comercial, no un precio público
  único.
- **Precios negociados**: los precios reflejan acuerdos comerciales previos; el
  comprador debe iniciar sesión para verlos.
- **Pricing por volumen** *(consideración futura)*: descuentos por cantidad o
  escalados por volumen se contemplan como evolución posterior, no como parte del
  MVP.
- **Sin promociones complejas en el MVP**: campañas, cupones, promociones
  combinadas o reglas promocionales avanzadas quedan fuera del alcance inicial.

Este documento **no define configuración técnica de pricing** (estructura de
Price Books, PricebookEntry, asignación a Buyer Groups, etc.). Esas decisiones se
documentarán en `docs/architecture/` y en `docs/business/business-rules.md`
cuando se confirmen. Hasta entonces, las reglas concretas de pricing se tratan
como supuestos.

---

## 7. Estrategia de Visibilidad de Catálogo

La visibilidad de catálogo determina qué productos puede ver y comprar cada
cliente:

- **Visibilidad por cuenta o Buyer Group**: el catálogo mostrado depende de la
  cuenta del comprador o del Buyer Group al que pertenece.
- **Catálogo restringido**: algunos clientes pueden tener acceso limitado a un
  subconjunto de productos o categorías, según su acuerdo comercial.
- **Diferenciación por tipo de cliente**: se prevén, al menos, tres niveles
  funcionales de visibilidad —clientes básicos (p. ej. tienda gaming local),
  resellers y enterprise— con alcances de catálogo potencialmente distintos.
- **Relación con capacidades estándar**: la visibilidad se apoyará en las
  capacidades estándar de Salesforce B2B Commerce para entitlements y asignación
  de catálogo a Buyer Groups, sin entrar en este documento en detalle de
  configuración.

Los criterios exactos de qué cliente ve qué catálogo son un supuesto a confirmar
(ver sección 13).

---

## 8. Estrategia de Stock

La visibilidad de stock es clave para la autonomía del comprador:

- **Stock visible para el comprador**: el portal muestra disponibilidad para que
  el cliente decida sin contactar a un representante.
- **Escenario de stock suficiente**: si hay existencias, el comprador puede añadir
  al carrito y completar el checkout con normalidad.
- **Escenario de stock insuficiente**: si no hay existencias suficientes, el
  portal debe informar de disponibilidad insuficiente y condicionar o impedir la
  compra de la cantidad solicitada. El comportamiento exacto (bloqueo, ajuste de
  cantidad, aviso) es un supuesto a definir.
- **Futura integración simulada con ERP**: la fuente de verdad del stock será, en
  una fase posterior, una integración **simulada por REST mediante Postman Mock
  Server**, con contratos de request/response documentados.
- **Sin integración real con ERP en el MVP**: el MVP no incluye integración real;
  el dato de stock inicial se gestionará con las capacidades estándar disponibles
  hasta habilitar la simulación.

---

## 9. Journey Principal del Comprador

El journey principal del comprador en el storefront sigue este flujo:

1. **Login**: el comprador inicia sesión; sin sesión no ve precios negociados ni
   catálogo restringido.
2. **Home**: punto de entrada con accesos a catálogo, búsqueda y pedidos previos.
3. **Búsqueda o navegación de catálogo**: el comprador localiza productos por
   búsqueda o navegando categorías.
4. **PLP (Product Listing Page)**: listado de productos de una categoría o
   búsqueda, con precios y disponibilidad según su cuenta.
5. **PDP (Product Detail Page)**: detalle del producto, precio negociado y stock.
6. **Agregar al carrito**: el comprador añade productos con la cantidad deseada.
7. **Revisar carrito**: validación de líneas, cantidades, precios y
   disponibilidad.
8. **Checkout**: checkout básico con los datos necesarios para registrar el
   pedido (sin pago real).
9. **Confirmación o solicitud de aprobación**: si el pedido no requiere
   aprobación, se confirma; si supera el umbral o lo requiere una regla, entra en
   flujo de aprobación.
10. **Historial de pedidos**: el comprador consulta sus pedidos anteriores y su
    estado.
11. **Reorder**: el comprador repite un pedido anterior para agilizar compras
    recurrentes.

---

## 10. Flujos de Negocio del MVP

### 10.1. Compra Estándar

- **Descripción**: compra completa sin aprobación ni restricciones especiales.
- **Actor principal**: comprador (Buyer User).
- **Resultado esperado**: pedido confirmado y registrado, visible en el historial.
- **Consideraciones funcionales**: requiere sesión iniciada, precios por cuenta y
  stock suficiente.
- **Fuera de alcance**: pago real, cálculo real de impuestos y de envío.

### 10.2. Compra con Aprobación por Importe

- **Descripción**: pedido cuyo importe supera un umbral y requiere aprobación
  antes de confirmarse.
- **Actor principal**: comprador; aprobador como rol futuro (Buyer Approver).
- **Resultado esperado**: el pedido queda en estado pendiente de aprobación y solo
  se confirma tras aprobarse.
- **Consideraciones funcionales**: el umbral de importe es un supuesto a definir;
  en el MVP cada cuenta tiene un único usuario operativo, por lo que la jerarquía
  de aprobación se mantiene simple.
- **Fuera de alcance**: jerarquías de aprobación multinivel complejas.

### 10.3. Compra con Stock Insuficiente

- **Descripción**: el comprador intenta adquirir una cantidad superior al stock
  disponible.
- **Actor principal**: comprador.
- **Resultado esperado**: el portal informa de disponibilidad insuficiente y evita
  confirmar un pedido no satisfacible.
- **Consideraciones funcionales**: el comportamiento exacto (bloqueo total, ajuste
  de cantidad o aviso) es un supuesto; el dato de stock proviene de capacidades
  estándar hasta la simulación ERP.
- **Fuera de alcance**: backorder, reservas y promesas de entrega reales.

### 10.4. Reorder

- **Descripción**: el comprador repite un pedido anterior para acelerar una compra
  recurrente.
- **Actor principal**: comprador.
- **Resultado esperado**: se genera un nuevo carrito/pedido a partir de uno
  previo, revalidando precios y stock actuales.
- **Consideraciones funcionales**: los precios y la disponibilidad se recalculan
  en el momento del reorder, no se heredan del pedido original.
- **Fuera de alcance**: programación de pedidos recurrentes automáticos.

### 10.5. Solicitud de Cotización

- **Descripción**: el comprador solicita un presupuesto en lugar de comprar
  directamente.
- **Actor principal**: comprador; seller como rol que responde.
- **Resultado esperado**: se registra una solicitud de cotización para su
  tratamiento posterior.
- **Consideraciones funcionales**: alcance y automatización de la cotización son un
  supuesto; puede apoyarse en capacidades estándar de Salesforce. Su inclusión
  plena en el MVP está por confirmar (ver sección 13).
- **Fuera de alcance**: negociación avanzada y workflows complejos de quoting.

### 10.6. Validación de Límite de Crédito

- **Descripción**: el sistema valida que el pedido no supere el crédito disponible
  del cliente.
- **Actor principal**: comprador; regla de negocio del seller.
- **Resultado esperado**: si se supera el límite, el pedido se bloquea o deriva a
  revisión; si no, continúa.
- **Consideraciones funcionales**: las reglas y los valores de crédito son un
  supuesto a definir; en el MVP el estado de crédito real provendría, en el
  futuro, de la simulación ERP.
- **Fuera de alcance**: gestión financiera real y scoring de crédito.

### 10.7. Cliente con Catálogo Restringido

- **Descripción**: cliente cuyo catálogo visible está limitado a un subconjunto de
  productos o categorías.
- **Actor principal**: comprador de una cuenta con catálogo restringido.
- **Resultado esperado**: el comprador solo ve y compra los productos permitidos
  para su cuenta o Buyer Group.
- **Consideraciones funcionales**: se apoya en la visibilidad por Buyer Group y en
  las capacidades estándar de entitlements de B2B Commerce.
- **Fuera de alcance**: reglas de visibilidad dinámicas complejas no soportadas por
  configuración estándar.

### 10.8. Cliente con Pricing Personalizado

- **Descripción**: cliente con precios negociados específicos distintos a los de
  otros clientes.
- **Actor principal**: comprador de una cuenta con pricing personalizado.
- **Resultado esperado**: el comprador ve y compra a sus precios negociados.
- **Consideraciones funcionales**: se apoya en pricing por cuenta o Buyer Group;
  la configuración concreta se define en documentación técnica posterior.
- **Fuera de alcance**: promociones complejas y reglas de pricing dinámicas
  avanzadas.

---

## 11. Reglas de Negocio Iniciales

Lista de reglas funcionales de partida. Las que no tienen aún valores concretos se
marcan como supuesto y deberán confirmarse en `docs/business/business-rules.md`.

- El comprador **debe iniciar sesión** para ver precios negociados y catálogo
  restringido.
- La **visibilidad de productos** puede depender de la cuenta o del Buyer Group del
  comprador.
- Los **pedidos por encima de cierto importe** pueden requerir aprobación.
  *(Supuesto: umbral de importe por definir.)*
- Los **productos sin stock suficiente** deben informar disponibilidad insuficiente
  y no permitir confirmar una cantidad no satisfacible. *(Supuesto: comportamiento
  exacto por definir.)*
- El comprador **debe poder consultar sus pedidos anteriores** y su estado.
- El **reorder** debe facilitar las compras recurrentes recalculando precio y stock
  actuales.
- Los **precios** son específicos por cuenta o Buyer Group; no existe precio público
  único. *(Supuesto: reglas exactas de asignación por definir.)*
- La **validación de límite de crédito** puede bloquear o derivar a revisión los
  pedidos que superen el crédito disponible. *(Supuesto: reglas y valores por
  definir.)*

---

## 12. KPIs Funcionales

KPIs de negocio propuestos para medir el éxito del portal. Los valores objetivo y
la instrumentación de medición son una decisión posterior.

- **Reducción de pedidos manuales**: porcentaje de pedidos realizados por el portal
  frente a email/teléfono.
- **Aumento del self-service**: proporción de compradores que operan de forma
  autónoma sin intervención del representante.
- **Tasa de conversión**: pedidos completados respecto a sesiones o carritos
  iniciados.
- **Frecuencia de reorder**: porcentaje de pedidos generados vía reorder y su
  cadencia.
- **Abandono de carrito**: carritos iniciados que no terminan en pedido.
- **Tiempo medio de compra**: duración desde el login hasta la confirmación del
  pedido.
- **Reducción de errores de pedido**: disminución de incidencias de pricing,
  cantidades o referencias respecto al proceso manual.

---

## 13. Supuestos y Decisiones Pendientes

Supuestos actuales y decisiones que deberán definirse más adelante:

- **Importe exacto para aprobación**: umbral que dispara el flujo de aprobación por
  importe.
- **Tipos de Buyer Groups**: número y criterios de los Buyer Groups y su relación
  con los tipos de cliente de la sección 4.
- **Reglas exactas de pricing**: estructura de precios negociados, asignación a
  cuentas/Buyer Groups y eventual pricing por volumen.
- **Reglas exactas de stock**: comportamiento ante stock insuficiente y fuente del
  dato hasta la simulación ERP.
- **Reglas de crédito**: cálculo del crédito disponible, valores y acción ante
  superación del límite.
- **Estructura real de datos de catálogo**: modelado de Product Catalog, categorías
  y bundles.
- **Alcance de la solicitud de cotización**: si se incluye plenamente en el MVP y
  con qué nivel de automatización.

---

## 14. Fuera de Alcance

Se reafirma que quedan fuera del MVP:

- Pagos reales.
- Cálculo real de impuestos (tax).
- Cálculo real de envíos (shipping).
- Order Management System (OMS) avanzado.
- Integración real con ERP.
- Promociones complejas.
- Multi-idioma.
- Multi-divisa.
- Modelo de marketplace.

---

## 15. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` es la **fuente de verdad del contexto general** del
  proyecto y del negocio.
- Este documento profundiza únicamente en la **estrategia de negocio de e-commerce
  B2B**; no define arquitectura ni configuración técnica.
- Las **decisiones técnicas específicas** (modelado de datos, configuración de
  Salesforce B2B Commerce, integraciones) deben documentarse en
  `docs/architecture/`.
- Las **reglas de negocio detalladas** deben evolucionar posteriormente en
  `docs/business/business-rules.md`, donde se concretarán los supuestos marcados
  en este documento.
