# Arquitectura de Integración - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define la **estrategia conceptual de integración** del proyecto
`LvlUp-Wholesale-B2B`: cómo se abordarán las futuras integraciones **REST
simuladas**, especialmente con un **ERP ficticio** mediante **Postman Mock
Server**. Describe criterios y arquitectura conceptual, no implementación final.

Sirve como base para:

- Diseñar futuras integraciones simuladas.
- Evitar integrar sistemas externos antes de tiempo.
- Definir criterios para REST, mocks y contratos.
- Preparar la futura arquitectura con Postman Mock Server.
- Guiar decisiones sobre Apex callouts, Named Credentials y contratos de API.
- Servir como base para ADRs y testing de integración.

Este documento **no define la implementación final ni endpoints definitivos**, y
**no propone integración real todavía**. Se apoya en
`docs/architecture/standard-vs-custom-framework.md` y
`docs/architecture/solution-architecture.md`, y aplica el principio rector:
*Configuration first, customization only when justified*.

---

## 2. Principios de Integración

- **No implementar ERP real** dentro del MVP.
- **Documentar primero el contrato funcional**.
- **Simular antes de integrar**.
- **REST** como enfoque inicial.
- **Postman Mock Server** como opción simple de simulación.
- **Named Credentials** cuando se implementen callouts (reales o simulados) desde
  Salesforce.
- **Apex** solo si la integración requiere callout o lógica no soportada por
  configuración/Flow.
- Diseñar integraciones **idempotentes** cuando aplique.
- **Manejar errores** de forma clara para el buyer y trazable para administración.
- **No exponer errores técnicos** al usuario final.

---

## 3. Alcance de Integración del MVP

### Incluido en el MVP

- Documentación conceptual de integración.
- Identificación de los datos externos futuros.
- Diseño funcional de los escenarios de stock, crédito, precio final, ETA, estado
  de pedido y facturas.
- Preparación documental para la futura simulación REST.

### Fuera del MVP

- ERP real.
- Sincronización real de datos.
- Middleware real.
- Callouts productivos.
- Integración SOAP.
- Procesamiento real de facturas.
- Motor externo real de pricing.
- Sistema real de crédito.

---

## 4. Sistemas Involucrados

| Sistema | Tipo | Rol funcional | Estado MVP | Observaciones |
| --- | --- | --- | --- | --- |
| Salesforce B2B Commerce | Plataforma | Catálogo, carrito, checkout, pedidos | Activo | Núcleo del MVP |
| Experience Cloud storefront | Capa de experiencia | UI del portal B2B | Activo | Storefront LWR |
| Salesforce data layer | Datos | Cuentas, productos, pricing, pedidos | Activo | Fuente de verdad interna |
| Postman Mock Server | Simulación (futuro) | Simular respuestas del ERP | Futuro | Enfoque inicial de simulación |
| ERP ficticio/simulado | Externo (simulado) | Stock, precio final, crédito, ETA, estado, facturas | Futuro | No real; representado por el mock |
| Buyer B2B | Actor | Consume la experiencia | Activo | Usuario autenticado |
| Agentes IA / documentación | Soporte | Contexto y guía | Soporte | No forman parte del runtime del storefront |

---

## 5. Vista Conceptual de Integración

```text
[Buyer B2B]
    ↓
[Storefront B2B Commerce]
    ↓
[Salesforce Commerce / Data Layer]
    ↓
[Apex Service / Integration Layer - futuro si se justifica]
    ↓
[Named Credential - futuro]
    ↓
[Postman Mock Server - ERP simulado]
```

**Nota.** La vista es **conceptual** y de responsabilidades. Las capas marcadas
como "futuro" solo se materializan cuando se justifique y se llegue a la fase de
integración; en el MVP no existen callouts.

---

## 6. Datos Externos a Simular

| Dato externo | Descripción | Flujo de negocio relacionado | Estado MVP | Prioridad futura |
| --- | --- | --- | --- | --- |
| Stock disponible | Disponibilidad por producto/SKU | PLP, PDP, carrito, checkout, stock insuficiente | Funcional/documentado | Alta |
| Precio final | Precio confirmado por el ERP | Pricing, checkout | Documentado | Media |
| Estado de crédito | Crédito disponible / bloqueado / excedido | Checkout, validación de crédito | Documentado | Media |
| Fecha estimada de entrega (ETA) | Fecha prevista de entrega | PDP, checkout, pedido | Futuro | Baja |
| Estado de pedido | Estado del pedido en el ERP | Historial, detalle de pedido | Futuro | Media |
| Facturas | Facturas del cliente | Mi Cuenta, historial | Futuro | Baja |

En el MVP, estos datos se tratan de forma **funcional/documentada**; su origen real
o simulado se incorpora en una fase posterior.

---

## 7. Patrón de Integración REST

- **Estilo**: REST sobre HTTPS, con payloads JSON.
- **Dirección**: Salesforce como **consumidor** (outbound) de los servicios del ERP
  simulado.
- **Sincronía**: llamadas síncronas para consultas puntuales (p. ej. stock o
  crédito en checkout); patrones asíncronos quedan como consideración futura.
- **Idempotencia**: las operaciones de consulta son idempotentes; cualquier
  operación de escritura futura debe diseñarse para serlo cuando aplique.
- **Versionado**: los contratos deben preverse versionables (consideración futura),
  sin fijar aquí un esquema concreto.
- **Aislamiento**: la lógica de integración se encapsula en una capa de servicio
  (Apex) separada de la UI.

---

## 8. Contratos Funcionales (Request/Response Conceptual)

Los contratos se definen primero a nivel **funcional**. Los ejemplos siguientes son
**ilustrativos y no definitivos** (no son endpoints ni esquemas finales).

| Operación conceptual | Entrada (conceptual) | Salida (conceptual) | Flujo relacionado | Estado |
| --- | --- | --- | --- | --- |
| Consultar stock | SKU(s) | Disponibilidad por SKU | Stock insuficiente | Documentado |
| Consultar precio final | SKU + cuenta/Buyer Group | Precio final aplicable | Pricing/checkout | Documentado |
| Consultar crédito | Cuenta | Estado y crédito disponible | Validación de crédito | Documentado |
| Consultar ETA | SKU + cantidad | Fecha estimada | PDP/checkout | Futuro |
| Consultar estado de pedido | Referencia de pedido | Estado del pedido | Historial | Futuro |
| Listar facturas | Cuenta | Listado de facturas | Mi Cuenta | Futuro |

**Ejemplo ilustrativo (no definitivo) de una consulta de stock:**

```text
Request (conceptual):
{
  "skus": ["LVL-CON-001", "LVL-LAP-001"]
}

Response (conceptual):
{
  "items": [
    { "sku": "LVL-CON-001", "available": true,  "quantity": 25 },
    { "sku": "LVL-LAP-001", "available": false, "quantity": 0 }
  ]
}
```

> Este ejemplo solo ilustra la **forma** de un contrato; los nombres de campos,
> rutas y esquemas reales se definirán cuando el proyecto llegue a la fase de
> simulación.

---

## 9. Postman Mock Server como Simulación

- **Rol**: representar al ERP ficticio devolviendo respuestas predefinidas a los
  contratos conceptuales.
- **Beneficios**: simple de montar, sin dependencias reales, permite probar
  escenarios (stock suficiente/insuficiente, crédito bloqueado, etc.).
- **Uso**: validar el comportamiento funcional del storefront frente a respuestas
  controladas antes de cualquier integración real.
- **Limitaciones**: no replica la lógica ni el rendimiento de un ERP real; es solo
  un doble de pruebas.
- **Escenarios a cubrir**: respuestas de éxito, casos límite (sin stock, crédito
  excedido) y errores, para validar los estados de `empty-error-loading-states.md`.

---

## 10. Named Credentials y Configuración de Callout (Futuro)

- Los **callouts** desde Salesforce (reales o hacia el mock) usarán **Named
  Credentials** para gestionar endpoint y autenticación.
- Los **Remote Site Settings** o la configuración equivalente se añadirán solo
  cuando se habiliten los callouts.
- En el **MVP no existen callouts**; esta sección fija el criterio para la fase
  futura.
- No se fijan aquí URLs, credenciales ni configuración concreta.

---

## 11. Apex como Capa de Integración (Cuándo)

- Apex se usará como **capa de integración** solo cuando exista un callout o lógica
  no soportada por configuración/Flow (coherente con
  `standard-vs-custom-framework.md` §9 y §10).
- Responsabilidades de la capa Apex de integración:
  - Construir y enviar el request.
  - Interpretar el response.
  - Mapear el resultado al modelo interno.
  - Manejar errores y traza.
- Debe contar con **test classes** y **mocks** de los callouts.
- La decisión de introducir Apex de integración debe registrarse en un **ADR**.

---

## 12. Manejo de Errores y Resiliencia

- **Para el buyer**: mensajes claros y no técnicos (p. ej. "No pudimos comprobar la
  disponibilidad. Inténtalo de nuevo."), alineados con
  `empty-error-loading-states.md`.
- **Para administración**: traza suficiente para diagnosticar (sin exponerla al
  usuario).
- **Timeouts y fallos**: definir comportamiento ante no disponibilidad del servicio
  (degradación o reintento) como decisión futura.
- **No bloquear** al comprador con detalles técnicos; ofrecer siempre una acción
  siguiente.

---

## 13. Mapeo de Datos Simulados a Flujos de Negocio

| Dato simulado | Flujo de negocio | Regla relacionada | Comportamiento esperado |
| --- | --- | --- | --- |
| Stock disponible | Stock insuficiente / checkout | `BR-STOCK-001`, `BR-STOCK-003` | Informar disponibilidad y bloquear cantidad no satisfacible |
| Precio final | Pricing / checkout | `PR-002`, `PR-003` | Mantener consistencia de precio antes de confirmar |
| Estado de crédito | Validación de crédito | `BR-CREDIT-001…005` | Impedir o condicionar el pedido según el crédito |
| ETA | PDP / checkout (futuro) | — | Mostrar fecha estimada cuando esté disponible |
| Estado de pedido | Historial / detalle (futuro) | `BR-HISTORY-002` | Reflejar el estado del pedido |
| Facturas | Mi Cuenta (futuro) | — | Listar facturas del cliente |

---

## 14. Seguridad de Integración

- **Autenticación de callouts** mediante Named Credentials (futuro).
- **No almacenar secretos** en código ni en metadata desplegable.
- **Mínimo privilegio** en los datos expuestos a la integración.
- **No exponer** datos sensibles del ERP al frontend más allá de lo necesario.
- El modelo de seguridad general se documentará en
  `docs/architecture/security-architecture.md` y `docs/salesforce/security-model.md`.

---

## 15. Testing de Integración

- **Mocks obligatorios** para aislar los callouts en los tests de Apex.
- **Escenarios de prueba**: éxito, casos límite (sin stock, crédito excedido) y
  errores/timeout.
- **Postman Mock Server** como entorno de validación funcional antes de cualquier
  integración real.
- Los casos se derivarán a `docs/testing/` y podrán evaluarse en `evals/`.

---

## 16. Fases de Evolución de la Integración

1. **Fase 0 — Documental (MVP).** Contratos funcionales y escenarios documentados;
   sin callouts.
2. **Fase 1 — Simulación.** Postman Mock Server respondiendo a los contratos;
   primeros callouts desde Salesforce con Named Credentials y mocks en tests.
3. **Fase 2 — Integración real (fuera del alcance actual).** Conexión a un ERP real;
   requiere ADRs, seguridad y testing ampliados.

Cada avance de fase es una **decisión explícita** y, cuando aplique, un ADR.

---

## 17. Riesgos de Integración

- Implementar **integración real antes de necesitarla**.
- **Acoplar** el storefront a un sistema externo no disponible.
- **Exponer errores técnicos** al buyer.
- **Inventar contratos definitivos** prematuramente.
- No aislar la integración con **mocks** en testing.
- **Almacenar secretos** indebidamente.
- No definir el comportamiento ante **fallos/timeouts**.

---

## 18. Criterios para Crear un ADR

- Decidir introducir **callouts** desde Salesforce.
- Adoptar el **patrón de integración** y sus contratos.
- Pasar de **documentación a simulación** (Postman Mock Server).
- Introducir **Apex de integración**.
- Cualquier avance hacia **integración real**.

---

## 19. Supuestos Actuales

- El **ERP real está fuera** del MVP.
- La simulación inicial será **REST con Postman Mock Server**.
- En el MVP **no hay callouts**.
- Los **contratos se documentan** antes de simularse.
- Los datos externos (stock, crédito, precio final, ETA, estado, facturas) son
  **candidatos a simular**, no a integrar en el MVP.
- Se priorizan **capacidades estándar** antes que customización.

---

## 20. Decisiones Pendientes

- Contratos concretos (campos, operaciones, esquemas).
- Momento de introducir el Postman Mock Server.
- Qué datos se simulan primero (probablemente stock y crédito).
- Estrategia de errores, timeouts y reintentos.
- Sincronía vs asincronía por caso.
- Estrategia de versionado de contratos.
- Qué avances requerirán ADR.

---

## 21. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto.
- `docs/business/` define **negocio, reglas, flujos y alcance**.
- `docs/architecture/standard-vs-custom-framework.md` define el **framework de
  decisión** (incluido cuándo integrar).
- `docs/architecture/solution-architecture.md` define la **arquitectura de
  solución** que enmarca esta integración.
- Este documento define la **arquitectura conceptual de integración**.
- `docs/architecture/security-architecture.md` deberá definir la **seguridad**.
- `docs/salesforce/` deberá documentar la **configuración** (Named Credentials,
  Remote Site Settings) cuando aplique.
- `adr/` registrará las **decisiones de integración**.
- `docs/testing/` y `evals/` cubrirán el **testing y la evaluación** de la
  integración simulada.
