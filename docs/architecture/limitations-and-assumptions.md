# Limitaciones y Supuestos - LvlUp WholeSale

## 1. Propósito del Documento

Este documento **consolida** las limitaciones, supuestos, restricciones, riesgos y
decisiones pendientes del proyecto `LvlUp-Wholesale-B2B`, recogidos de forma
transversal desde los documentos de negocio, UX y arquitectura.

Sirve como base para:

- Control de alcance.
- Prevención de la sobre-ingeniería.
- Decisiones de arquitectura.
- ADRs.
- Validación del MVP.
- Testing.
- Agentes de IA.
- Revisión futura del roadmap.

Este documento debe **actualizarse** cuando cambien supuestos importantes o se
resuelvan decisiones pendientes (ver sección 14). Aplica el principio rector del
proyecto: *Configuration first, customization only when justified*.

---

## 2. Clasificación de Elementos

- **Limitación.** Algo que restringe el proyecto por contexto, plataforma, alcance,
  tiempo, conocimiento o decisión explícita.
- **Supuesto.** Algo que se considera verdadero temporalmente, pero que debe
  validarse o puede cambiar.
- **Restricción.** Una condición que debe cumplirse obligatoriamente.
- **Decisión pendiente.** Algo que aún debe decidirse antes de la implementación
  final o de una fase posterior.
- **Riesgo.** Algo que puede afectar negativamente al alcance, la arquitectura, la
  UX, la seguridad, el testing o el mantenimiento.

---

## 3. Limitaciones Generales del Proyecto

| ID | Limitación | Impacto | Mitigación | Estado |
| --- | --- | --- | --- | --- |
| LIM-GEN-001 | Proyecto personal de aprendizaje | Alcance acotado y prioridades didácticas | Mantener foco en MVP y estándar | Vigente |
| LIM-GEN-002 | Se ejecuta en una Developer Org | Límites de edición y features | Validar capacidades antes de decidir | Vigente |
| LIM-GEN-003 | Site/storefront activo, pero capacidades reales por validar | Riesgo de asumir lo no confirmado | Validar en la org antes de comprometer | Vigente |
| LIM-GEN-004 | No se cubren todos los escenarios enterprise | Cobertura funcional parcial | Documentar lo no cubierto | Vigente |
| LIM-GEN-005 | El MVP debe mantenerse controlado | Tentación de scope creep | Aplicar `mvp-scope.md` | Vigente |
| LIM-GEN-006 | Prioridad de aprendizaje del estándar B2B Commerce | Menos customización temprana | Estándar primero | Vigente |
| LIM-GEN-007 | La documentación no reemplaza la validación real en la org | Riesgo de desviación doc/realidad | Revisar tras validar | Vigente |
| LIM-GEN-008 | Capacidades dependientes de licencias/configuración/features | Incertidumbre técnica | Confirmar en la org | Vigente |

---

## 4. Limitaciones del MVP

| ID | Limitación MVP | Motivo | Impacto | Fase futura posible |
| --- | --- | --- | --- | --- |
| LIM-MVP-001 | Sin pagos reales | Fuera del foco del MVP | No hay cobro real | Futuro posible |
| LIM-MVP-002 | Sin tax real | Complejidad fiscal | Importes sin impuestos reales | Futuro posible |
| LIM-MVP-003 | Sin shipping real | Complejidad logística | Sin cálculo de envío | Futuro posible |
| LIM-MVP-004 | Sin OMS avanzado | Historial básico suficiente | Gestión de pedidos limitada | Futuro posible |
| LIM-MVP-005 | Sin ERP real | Dependencia externa | Datos externos no reales | Simulación primero |
| LIM-MVP-006 | Sin promociones complejas | No aporta a la base B2B | Sin campañas avanzadas | Futuro posible |
| LIM-MVP-007 | Sin multi-idioma | Opera en España | Un solo idioma | Futuro (expansión) |
| LIM-MVP-008 | Sin multi-divisa | Un solo mercado | Una sola divisa | Futuro (expansión) |
| LIM-MVP-009 | Sin marketplace | Modelo distinto | Sin múltiples vendedores | No incluido |
| LIM-MVP-010 | Sin jerarquía completa de roles buyer (salvo necesidad estándar) | Un usuario operativo basta | Sin separación de roles | Futuro |
| LIM-MVP-011 | Sin motor externo real de pricing | No justificado | Pricing por estándar/datos | Futuro si se justifica |
| LIM-MVP-012 | Sin automatización completa de approval/quote/credit si excede el MVP | Control de alcance | Flujos documentados, no automatizados | Fase posterior |

---

## 5. Supuestos de Negocio

| ID | Supuesto | Impacto si cambia | Validación requerida | Estado |
| --- | --- | --- | --- | --- |
| ASM-BIZ-001 | Opera inicialmente en España | Revisar multi-región | Confirmar mercado | Vigente |
| ASM-BIZ-002 | Modelo distribuidor a reseller | Cambia el modelo comercial | Confirmar modelo | Vigente |
| ASM-BIZ-003 | Comprador principal: responsable de compras | Revisar personas | Validar con personas | Vigente |
| ASM-BIZ-004 | Los buyers compran de forma recurrente | Cambia el foco en reorder | Validar con negocio | Vigente |
| ASM-BIZ-005 | Los buyers necesitan pricing claro | Cambia prioridad UX | Validar con buyers | Vigente |
| ASM-BIZ-006 | Los buyers necesitan stock visible | Cambia prioridad de stock | Validar con buyers | Vigente |
| ASM-BIZ-007 | Catálogo inicial pequeño y representativo | Escala de datos | Confirmar surtido MVP | Vigente |
| ASM-BIZ-008 | Un único usuario operativo por buyer account en el MVP | Activa roles antes | Confirmar con negocio | Vigente |
| ASM-BIZ-009 | Buyer Groups o cuenta influyen en catálogo y pricing | Cambia segmentación | Validar en la org | Por validar |

---

## 6. Supuestos Funcionales

| ID | Supuesto funcional | Relación con MVP | Validación requerida | Estado |
| --- | --- | --- | --- | --- |
| ASM-FUN-001 | Autenticado para ver pricing aplicable | Acceso (`BR-ACCESS-002`) | Validar en storefront | Vigente |
| ASM-FUN-002 | Autenticado para comprar | Acceso (`BR-ACCESS-003`) | Validar en storefront | Vigente |
| ASM-FUN-003 | Pricing/visibilidad consistentes en PLP, PDP, carrito y checkout | Pricing/visibilidad (`PR-003`) | Validar consistencia | Vigente |
| ASM-FUN-004 | Reorder revalida pricing, visibilidad y stock | Reorder (`BR-REORDER-003`) | Validar comportamiento | Vigente |
| ASM-FUN-005 | Aprobación por importe puede documentarse antes de automatizarse | Aprobación (`BR-APPROVAL-*`) | Definir automatización | Por validar |
| ASM-FUN-006 | Validación de crédito puede documentarse antes de automatizarse | Crédito (`BR-CREDIT-*`) | Definir reglas | Por validar |
| ASM-FUN-007 | Stock funcional puede documentarse antes de la simulación | Stock (`BR-STOCK-*`) | Definir fuente | Por validar |
| ASM-FUN-008 | Quote request parcialmente documentado o futuro | Cotización (`BR-QUOTE-*`) | Definir alcance | Por validar |

---

## 7. Supuestos UX

| ID | Supuesto UX | Impacto si cambia | Validación requerida | Estado |
| --- | --- | --- | --- | --- |
| ASM-UX-001 | Mobile-first y responsive | Rediseño de experiencia | Validar en dispositivos | Vigente |
| ASM-UX-002 | El buyer prioriza rapidez y claridad | Cambia prioridad UX | Validar con personas | Vigente |
| ASM-UX-003 | Evitar enfoque excesivamente B2C | Cambia el tono | Revisar diseño | Vigente |
| ASM-UX-004 | Navegación por categorías simple | Revisar IA | Validar navegación | Vigente |
| ASM-UX-005 | Contemplar estados empty/error/loading/pending | Huecos de experiencia | Validar estados | Vigente |
| ASM-UX-006 | Mensajes claros y no técnicos | Confusión del buyer | Revisar microcopy | Vigente |
| ASM-UX-007 | Experience Builder y componentes estándar primero | Más custom del previsto | Validar en la org | Por validar |
| ASM-UX-008 | Wireframes actuales conceptuales, no diseño final | Expectativas de diseño | Evolucionar wireframes | Vigente |

---

## 8. Supuestos Salesforce / Plataforma

| ID | Supuesto plataforma | Impacto si cambia | Validación requerida | Estado |
| --- | --- | --- | --- | --- |
| ASM-SF-001 | La org tiene B2B Commerce y Site activo | Bloquea el MVP | Confirmar en la org | Vigente |
| ASM-SF-002 | Las capacidades estándar deben validarse en la org | Decisiones sobre supuestos | Validar capacidades | Por validar |
| ASM-SF-003 | Catálogo/productos/precios/Buyer Groups/entitlements pueden requerir carga de datos | Estrategia de datos | Definir carga | Por validar |
| ASM-SF-004 | Metadata y datos se gestionan por separado | Despliegues frágiles si se mezcla | Aplicar separación | Vigente |
| ASM-SF-005 | Experience Builder como primera opción de layout | Más LWC del previsto | Validar componentes | Por validar |
| ASM-SF-006 | LWC custom solo si el estándar no cubre necesidad crítica | Sobre-ingeniería de UI | Justificar y ADR | Vigente |
| ASM-SF-007 | Flow antes que Apex cuando sea mantenible | Apex prematuro | Evaluar caso a caso | Vigente |
| ASM-SF-008 | Apex solo para lógica compleja, integraciones o transaccionalidad | Complejidad innecesaria | Justificar y ADR | Vigente |
| ASM-SF-009 | Algunas decisiones dependen de lo que permita la Developer Org | Incertidumbre técnica | Validar en la org | Por validar |

---

## 9. Supuestos de Integración

| ID | Supuesto integración | Impacto si cambia | Validación requerida | Estado |
| --- | --- | --- | --- | --- |
| ASM-INT-001 | ERP real fuera del MVP | Cambia el alcance | Confirmar fase | Vigente |
| ASM-INT-002 | REST como enfoque inicial | Cambia el patrón | Confirmar enfoque | Vigente |
| ASM-INT-003 | Postman Mock Server suficiente para simulación inicial | Cambia herramienta | Validar en fase 1 | Por validar |
| ASM-INT-004 | JSON como formato esperado | Cambia el contrato | Confirmar formato | Vigente |
| ASM-INT-005 | Datos futuros: stock, precio final, crédito, ETA, estado, facturas | Cambia el alcance de datos | Priorizar datos | Vigente |
| ASM-INT-006 | Named Credentials necesarios si hay callouts | Configuración de seguridad | Definir en fase | Por validar |
| ASM-INT-007 | Apex puede ser necesario para callouts | Introduce código | Justificar y ADR | Por validar |
| ASM-INT-008 | La integración se implementa solo cuando una fase lo requiera | Riesgo de adelantarse | Controlar fases | Vigente |

---

## 10. Restricciones Arquitectónicas

| ID | Restricción | Justificación | Documento relacionado | Estado |
| --- | --- | --- | --- | --- |
| CON-ARCH-001 | Respetar *Configuration first, customization only when justified* | Mantenibilidad y upgradeability | `standard-vs-custom-framework.md` | Activa |
| CON-ARCH-002 | Priorizar estándar Salesforce B2B Commerce | Menor coste y riesgo | `solution-architecture.md` | Activa |
| CON-ARCH-003 | No crear LWC custom sin justificación | Evitar sobre-ingeniería | `standard-vs-custom-framework.md` | Activa |
| CON-ARCH-004 | No crear Apex si Flow/configuración resuelve el caso | Mantenibilidad | `standard-vs-custom-framework.md` | Activa |
| CON-ARCH-005 | No implementar ERP real dentro del MVP | Control de alcance | `integration-architecture.md` | Activa |
| CON-ARCH-006 | No mezclar documentación de contexto con instrucciones operativas de Claude | Separación de responsabilidades | `PROJECT_CONTEXT.md` / `CLAUDE.md` | Activa |
| CON-ARCH-007 | Español en documentación de contexto/negocio/UX/arquitectura/agentes/ADRs/evaluaciones | Política de idioma | `CLAUDE.md` | Activa |
| CON-ARCH-008 | Inglés para código, nombres técnicos, contratos API y commits | Política de idioma | `CLAUDE.md` | Activa |
| CON-ARCH-009 | Registrar decisiones relevantes en ADRs | Trazabilidad | `standard-vs-custom-framework.md` | Activa |

---

## 11. Decisiones Pendientes Consolidadas

| ID | Decisión pendiente | Área | Impacto | Prioridad | Documento relacionado | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| DEC-001 | Capacidades estándar reales disponibles en la org | Plataforma | Alto | Alta | `solution-architecture.md` | Abierta |
| DEC-002 | Componentes estándar para PLP/PDP/carrito/checkout | Plataforma/UX | Alto | Alta | `plp-pdp-guidelines.md` | Abierta |
| DEC-003 | Layout final de Home | UX | Medio | Media | `wireframes.md` | Abierta |
| DEC-004 | Nivel de filtros en PLP | UX | Medio | Media | `plp-pdp-guidelines.md` | Abierta |
| DEC-005 | Buyer Groups definitivos | Negocio/Datos | Alto | Alta | `pricing-and-visibility-strategy.md` | Abierta |
| DEC-006 | Reglas exactas de pricing | Negocio/Datos | Alto | Alta | `pricing-and-visibility-strategy.md` | Abierta |
| DEC-007 | Reglas exactas de visibilidad | Negocio/Datos | Alto | Alta | `pricing-and-visibility-strategy.md` | Abierta |
| DEC-008 | Umbral de aprobación por importe | Negocio | Alto | Alta | `business-rules.md` | Abierta |
| DEC-009 | Reglas exactas de crédito | Negocio | Alto | Media | `business-rules.md` | Abierta |
| DEC-010 | Comportamiento ante stock insuficiente | Funcional | Alto | Alta | `b2b-commerce-flows.md` | Abierta |
| DEC-011 | Si habrá backorder | Funcional | Medio | Baja | `cart-checkout-experience.md` | Abierta |
| DEC-012 | Si se mostrará ETA | Funcional | Bajo | Baja | `integration-architecture.md` | Abierta |
| DEC-013 | Nivel de automatización del quote request | Funcional | Medio | Media | `b2b-commerce-flows.md` | Abierta |
| DEC-014 | Nivel de automatización del approval flow | Funcional | Alto | Media | `b2b-commerce-flows.md` | Abierta |
| DEC-015 | Estrategia de carga de datos | Plataforma | Alto | Media | `solution-architecture.md` | Abierta |
| DEC-016 | Cuándo crear el Postman Mock Server | Integración | Medio | Baja | `integration-architecture.md` | Abierta |
| DEC-017 | Endpoints/contratos REST futuros | Integración | Medio | Baja | `integration-architecture.md` | Abierta |
| DEC-018 | Permission Sets / Permission Set Groups definitivos | Seguridad | Alto | Media | `security-architecture.md` | Abierta |
| DEC-019 | Necesidad real de LWC custom | Arquitectura | Medio | Media | `standard-vs-custom-framework.md` | Abierta |
| DEC-020 | Necesidad real de Apex | Arquitectura | Medio | Media | `standard-vs-custom-framework.md` | Abierta |
| DEC-021 | ADRs requeridos | Arquitectura | Medio | Media | `standard-vs-custom-framework.md` | Abierta |

---

## 12. Riesgos Consolidados

| ID | Riesgo | Área | Probabilidad | Impacto | Mitigación | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| RISK-001 | Customizar demasiado pronto | Arquitectura | Media | Alto | Estándar primero; checklist custom | Abierto |
| RISK-002 | Sobredimensionar el MVP | Alcance | Media | Alto | Aplicar `mvp-scope.md` | Abierto |
| RISK-003 | Usar Apex para evitar configuración | Arquitectura | Media | Medio | Criterios Flow/Apex | Abierto |
| RISK-004 | Usar Flow para lógica demasiado compleja | Arquitectura | Media | Medio | Límites de Flow; ADR | Abierto |
| RISK-005 | Crear LWC por estética | UX/Arquitectura | Media | Medio | Justificación + ADR | Abierto |
| RISK-006 | Exponer productos restringidos | Seguridad | Media | Alto | Visibilidad estándar; testing | Abierto |
| RISK-007 | Exponer pricing incorrecto | Seguridad | Media | Alto | Consistencia y testing | Abierto |
| RISK-008 | Mezclar metadata con datos | Plataforma | Media | Alto | Separar deploy y carga | Abierto |
| RISK-009 | No validar capacidades reales de la org | Plataforma | Alta | Alto | Validar antes de decidir | Abierto |
| RISK-010 | Implementar integración real demasiado pronto | Integración | Baja | Alto | Simular primero; fases | Abierto |
| RISK-011 | No documentar decisiones | Gobernanza | Media | Medio | ADRs | Abierto |
| RISK-012 | No probar mobile | UX | Media | Medio | Testing mobile-first | Abierto |
| RISK-013 | No contemplar estados empty/error/loading | UX | Media | Medio | `empty-error-loading-states.md` | Abierto |
| RISK-014 | No probar permisos | Seguridad | Media | Alto | Testing de seguridad | Abierto |
| RISK-015 | Documentación como burocracia no accionable | Gobernanza | Media | Medio | Mantener docs útiles y enlazadas | Abierto |

---

## 13. Impacto en el Roadmap

Estas limitaciones y supuestos sugieren la siguiente secuencia:

1. **Validar el estándar** disponible en la org.
2. **Configurar** catálogo, pricing y visibilidad (datos + Buyer Groups).
3. **Probar la UX base** (Home, PLP, PDP, carrito, checkout, historial, reorder).
4. **Decidir** si hace falta Flow/LWC/Apex, caso a caso y con justificación.
5. **Documentar ADRs** de las decisiones relevantes.
6. **Crear los agentes especializados** sobre una base estable.
7. **Integración futura** solo después de tener una base de Commerce estable
   (simulación REST antes que ERP real).

---

## 14. Criterios para Revisar este Documento

Revisar este archivo cuando:

- Se valide una capacidad estándar en la org.
- Se tome una decisión de arquitectura.
- Se cree un ADR.
- Cambie el alcance del MVP.
- Se implemente una integración.
- Se agregue LWC custom.
- Se agregue Apex.
- Se definan los Buyer Groups.
- Se definan las reglas de pricing o crédito.
- Se cierre una decisión pendiente.

---

## 15. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto.
- `docs/business/` define **negocio, reglas, flujos, catálogo, pricing y MVP**.
- `docs/ux/` define la **experiencia esperada**.
- `docs/architecture/standard-vs-custom-framework.md` define el **criterio estándar
  vs custom**.
- `docs/architecture/solution-architecture.md` define la **arquitectura general**.
- `docs/architecture/integration-architecture.md` define la **integración futura**.
- `docs/architecture/security-architecture.md` define la **seguridad conceptual**.
- Este documento **consolida** limitaciones, supuestos, restricciones, riesgos y
  decisiones pendientes.
- `adr/` deberá registrar las **decisiones relevantes**.
- `docs/salesforce/` deberá **validar la configuración real** en Salesforce.
- `agents/` y `evals/` deberán **respetar estas limitaciones**.
