# PROJECT_CONTEXT.md

Este documento es la fuente de verdad a largo plazo del **contexto de negocio y
de proyecto** de `LvlUp-Wholesale-B2B`. Describe qué es el proyecto, el negocio
que simula, el alcance del MVP, los principios que guían la solución y las
restricciones que aplican.

Es intencionadamente descriptivo y estable. Las instrucciones operativas
específicas de Claude, los comandos, el flujo de trabajo del repositorio y el
comportamiento del asistente viven en `CLAUDE.md` (ver
[Relación con CLAUDE.md](#relación-con-claudemd)).

---

## 1. Qué Es Este Proyecto

`LvlUp-Wholesale-B2B` es un proyecto personal de Salesforce **B2B Commerce
Cloud** que se ejecuta en una Salesforce Developer Org. La org ya tiene acceso a
B2B Commerce y un Site/storefront activo listo para trabajar.

El proyecto simula una implementación enterprise real de e-commerce B2B y se
utiliza como entorno práctico para practicar arquitectura de Salesforce y la
construcción de agentes de IA dentro de un contexto realista de Salesforce.

Es principalmente un **proyecto de aprendizaje**. Más adelante puede servir como
proyecto de portfolio/demo, pero el objetivo inicial es la práctica, el
aprendizaje y la profundidad técnica.

---

## 2. El Negocio Ficticio: LvlUp WholeSale

**LvlUp WholeSale** es un distribuidor mayorista B2B ficticio, de estilo
startup, enfocado en productos de tecnología y gaming.

- Modelo de negocio: **distribuidor a reseller (B2B)**.
- Vende a empresas, tiendas y resellers — no a consumidores finales.
- Opera inicialmente **de forma local en España**, con la arquitectura diseñada
  para permitir una **futura expansión a otras regiones**.

### Categorías de Producto

- Consolas de gaming
- Videojuegos
- Portátiles
- Monitores
- Periféricos
- Productos de networking
- Accesorios
- Bundles enterprise

El proyecto debe reflejar **patrones de comercio B2B**, no B2C. Diferenciadores
B2B clave a modelar:

- Pricing específico por cuenta
- Visibilidad de producto basada en Buyer Group o cuenta
- Compras recurrentes y flujos de reorder
- Pedidos de alto volumen
- Historial de pedidos y trazabilidad
- Flujos de aprobación para pedidos de alto valor
- Visibilidad de stock
- Futura integración simulada con ERP

---

## 3. Propósito del Proyecto

1. Practicar arquitectura de Salesforce aplicada a B2B Commerce Cloud.
2. Practicar la construcción de agentes de IA en un contexto realista de
   proyecto Salesforce.
3. Simular una implementación enterprise real de e-commerce B2B.
4. Construir un storefront funcional de Salesforce B2B Commerce.
5. Entregar un MVP técnico con catálogo, navegación de productos, carrito,
   checkout y una futura integración simulada con ERP.

---

## 4. Compradores y Sus Necesidades

### Persona Principal

Un **purchasing manager / responsable de compras** que trabaja para un reseller,
tienda o cliente empresarial.

Para el MVP, se asume que cada cuenta de buyer tiene un **único usuario
operativo**. El modelo funcional debe dejar margen para una futura jerarquía de
roles, sin sobre-ingeniería en el MVP más allá de lo que requiera la
configuración estándar de Salesforce B2B Commerce:

- Buyer User
- Buyer Approver
- Buyer Admin

### Qué Necesita Hacer el Comprador

- Iniciar sesión en el storefront B2B.
- Navegar y buscar en el catálogo.
- Ver páginas de detalle de producto.
- Ver precios negociados / específicos por cuenta.
- Ver solo los productos disponibles para su cuenta o Buyer Group.
- Comprobar disponibilidad de stock.
- Añadir productos al carrito y completar un checkout básico.
- Reordenar compras frecuentes.
- Solicitar aprobación cuando sea necesario.
- Ver historial de pedidos y detalles de pedido.

### Pain Points Actuales (sin el portal)

- Las compras se hacen por email o teléfono.
- Sin visibilidad self-service del stock.
- Sin visibilidad inmediata del pricing negociado.
- Los pedidos repetidos requieren trabajo manual.
- Mala trazabilidad de pedidos.
- Dependencia de un representante de ventas.
- Mayor riesgo de errores de pricing o de pedido.

---

## 5. Problemas de Negocio Resueltos y Beneficios

### Problemas Resueltos

- Reducir los pedidos manuales por email o teléfono.
- Centralizar las compras B2B.
- Mejorar el self-service del cliente.
- Reducir errores de pricing.
- Automatizar escenarios de aprobación.
- Preparar la arquitectura para una futura integración de stock/pricing con ERP.
- Mejorar la experiencia de compra recurrente.
- Mejorar la trazabilidad de pedidos.
- Reducir la carga operativa del seller.

### Beneficios para LvlUp WholeSale

- Menor carga operativa.
- Más ventas recurrentes.
- Mejor control del catálogo y trazabilidad.
- Mejor conversión.
- Menos errores de pedido y de pricing.

### Beneficios para los Compradores

- Compras más rápidas.
- Precios claros y específicos por cuenta.
- Información de stock visible.
- Menor dependencia de los representantes de ventas.
- Historial de pedidos y reorders más sencillos.

---

## 6. Alcance del MVP

El MVP debe incluir:

- Login de buyer B2B.
- Product Catalog y categorías.
- Búsqueda de productos.
- Product Listing Page (PLP).
- Product Detail Page (PDP).
- Pricing específico por cuenta o basado en Buyer Group.
- Visibilidad de producto por Buyer Group o cuenta.
- Carrito.
- Checkout básico.
- Historial de pedidos y detalle de pedido.
- Reorder.
- Flujo de solicitud de aprobación (aprobación por importe del pedido).
- Validación de límite de crédito.
- Manejo de escenarios de stock insuficiente.
- Comportamiento de catálogo restringido.
- Comportamiento de pricing personalizado.

### Pantallas del MVP

Home · Login · Catálogo / PLP · PDP · Carrito · Checkout · Historial de Pedidos ·
Detalle de Pedido · Reorder · Solicitud de Aprobación · Mi Cuenta.

### Flujos de Negocio a Considerar

- Compra estándar.
- Compra que requiere aprobación por importe.
- Compra con stock insuficiente.
- Reorder.
- Solicitud de presupuesto (quote request).
- Validación de límite de crédito.
- Cliente con catálogo restringido.
- Cliente con pricing personalizado.

---

## 7. Fuera del Alcance del MVP

Explícitamente **fuera** del MVP inicial:

- Pagos reales.
- Cálculo real de impuestos.
- Cálculo real de envíos.
- Implementación avanzada de un Order Management System.
- Integración real con ERP.
- Promociones complejas.
- Multi-idioma.
- Multi-divisa.
- Modelo de marketplace.

---

## 8. Principios Guía

**Principio de arquitectura principal:** *Configuration first, customization
only when justified* (configuración primero, personalización solo cuando se
justifique).

La solución prioriza las capacidades en este orden:

1. Capacidades estándar de Salesforce B2B Commerce.
2. Configuración con Experience Builder.
3. Automatización declarativa con Flow cuando sea mantenible.
4. LWC custom solo cuando los componentes estándar sean insuficientes.
5. Apex solo para lógica compleja, integraciones, consistencia transaccional o
   lógica no adecuada para Flow.
6. Patrones de integración externa solo cuando el caso de uso lo requiera.

El proyecto usa un **enfoque mixto**: configuración y storefront reales de
Salesforce B2B Commerce, con integraciones simuladas donde se necesite, y
prefiriendo las capacidades estándar de Salesforce antes que el desarrollo
custom.

---

## 9. Building Blocks Técnicos

El proyecto puede involucrar estas áreas técnicas (usadas solo cuando lo
justifiquen los principios anteriores):

- Storefront de Experience Cloud.
- Setup de Salesforce B2B Commerce.
- Product Catalog y categorías.
- Buyer Groups y acceso basado en cuenta.
- Price Books / configuración de pricing.
- LWC custom (solo cuando se necesite).
- Servicios Apex (solo cuando se justifique).
- Flows.
- Integraciones REST y Named Credentials.
- Permission Sets.
- Test classes.
- Estrategia de despliegue.
- Documentación y ADRs.

No se requiere ninguna convención de nombres custom en esta etapa más allá de
nombres claros, descriptivos y mantenibles.

---

## 10. Estrategia de Integración

Una integración real con ERP está **fuera del alcance** del MVP, pero el
proyecto debe diseñarse de forma que se pueda añadir una futura integración
**simulada y basada en REST** con un ERP.

Enfoque inicial de simulación (consideración futura):

- Postman Mock Server.
- Contratos de request/response documentados.
- Callouts de Salesforce solo cuando el proyecto llegue a esa fase.

Datos tipo ERP que se podrían simular más adelante:

- Stock disponible.
- Precio final.
- Estado de crédito del cliente.
- Fecha estimada de entrega.
- Estado del pedido.
- Facturas.

---

## 11. Enfoque de UX

La UX se considera desde el principio, apoyándose en las capacidades estándar de
Salesforce B2B Commerce y Experience Builder tanto como sea posible.

Enfoque de diseño:

- Mobile-first y responsive.
- Limpio y práctico para compradores B2B.
- Enfocado en velocidad, claridad y compras repetidas.
- Configuración estándar de Salesforce antes que UI custom.

Los wireframes pueden documentarse como texto, diagramas Mermaid o, más
adelante, assets visuales, según lo que resulte más útil.

---

## 12. Infraestructura de Agentes de IA (Solo Contexto)

Este proyecto también se utiliza para construir y probar una infraestructura de
agentes de IA en torno a Salesforce B2B Commerce. El objetivo a largo plazo son
agentes de IA especializados en áreas como: estrategia de B2B Commerce, análisis
de negocio de e-commerce, UX/customer journey, arquitectura de Salesforce, LWC,
Apex, Flow, integraciones REST/SOAP, QA/testing y documentación técnica.

Este archivo documenta solo el **contexto** de ese objetivo. Las definiciones de
los agentes, las reglas de colaboración y los prompts deben vivir por separado
en ubicaciones apropiadas como `agents/`, `docs/`, `evals/` y `CLAUDE.md`. Este
archivo no debe contener prompts completos de agentes ni reglas operativas.

---

## 13. Principios de Documentación

El proyecto debe documentarse como si fuera una implementación enterprise
seria, aunque sea personal. La documentación debe ayudar a explicar: contexto de
negocio, alcance funcional, arquitectura de Salesforce, decisiones de estándar
vs custom, supuestos de UX, supuestos de integración, estrategia de testing y
decisiones arquitectónicas.

Documentos futuros importantes (consideración):

- `docs/business/ecommerce-strategy.md`
- `docs/business/business-rules.md`
- `docs/ux/ux-principles.md`
- `docs/salesforce/b2b-commerce-standard-capabilities.md`
- `docs/architecture/standard-vs-custom-framework.md`
- `docs/architecture/solution-architecture.md`
- `docs/development/apex-guidelines.md`
- `docs/development/lwc-guidelines.md`
- `docs/development/flow-guidelines.md`
- `docs/testing/testing-strategy.md`
- `adr/`

---

## Relación con CLAUDE.md

`PROJECT_CONTEXT.md` describe el contexto del proyecto, el escenario de negocio,
el alcance del MVP, los principios técnicos y la dirección a largo plazo.

No debe contener instrucciones operativas específicas de Claude, referencias de
comandos, reglas de comportamiento de agentes ni instrucciones de flujo de
trabajo del repositorio.

El comportamiento específico de Claude, los comandos, el flujo de trabajo, el
enrutamiento de agentes y las reglas del repositorio deben definirse por
separado en `CLAUDE.md`.

`CLAUDE.md` debe permanecer conciso y operativo. Debe referenciar
`PROJECT_CONTEXT.md` como la fuente de verdad del contexto de negocio y de
proyecto, pero no debe duplicar este archivo.
