# Índice de Documentación - LvlUp-Wholesale-B2B

## 1. Propósito del Documento

Este archivo funciona como **mapa maestro de documentación** del proyecto
`LvlUp-Wholesale-B2B`. Describe qué documentos existen, cuál es su propósito,
cuándo deben consultarse y cómo se relacionan entre sí.

Debe ayudar a:

- Ubicar rápidamente cada documento.
- Entender el propósito de cada archivo.
- Evitar la duplicidad de contenido.
- Saber qué documento consultar según el tipo de decisión.
- Mantener ordenada la evolución del proyecto.
- Servir como guía tanto para personas como para agentes de IA.

---

## 2. Principios de Organización Documental

- Cada documento debe tener una **responsabilidad clara**.
- **No duplicar** contenido entre documentos; enlazar en lugar de repetir.
- `PROJECT_CONTEXT.md` es la **fuente de verdad** del contexto general.
- `CLAUDE.md` contiene **instrucciones operativas**, no contexto funcional
  profundo.
- Los documentos de **negocio** describen el *qué* y el *por qué*.
- Los documentos de **arquitectura** describen decisiones técnicas y trade-offs.
- Los documentos de **Salesforce** describen configuración, capacidades estándar y
  modelo de plataforma.
- Los documentos de **UX** describen experiencia, journeys y comportamiento visual.
- Los documentos de **testing/evals** validan calidad y robustez.
- Los **ADRs** registran decisiones importantes.

---

## 3. Documentos Raíz

| Archivo | Propósito | Cuándo consultarlo | Responsable conceptual |
| --- | --- | --- | --- |
| `PROJECT_CONTEXT.md` | Fuente de verdad del contexto de negocio y proyecto: qué es, qué simula, alcance del MVP, principios y restricciones | Para entender el proyecto en su conjunto o al iniciar cualquier trabajo | Contexto de proyecto |
| `CLAUDE.md` | Instrucciones operativas para Claude Code: idioma, comandos, workflow, arquitectura del repo y convenciones | Al operar sobre el repositorio o definir comportamiento del asistente | Operación del repositorio |
| `MEMORY.md` | Memoria operativa **ligera**: reglas, preferencias e instrucciones recurrentes del usuario que aún no están en la documentación formal | Antes de ejecutar cualquier tarea, junto a `PROJECT_CONTEXT.md` y `CLAUDE.md` | Memoria operativa del repositorio |
| `README.md` | Actualmente es el README genérico de Salesforce DX ("Next Steps"); pendiente de personalizar como presentación del proyecto | Como punto de entrada del repositorio | Onboarding del repositorio |

> Nota: `MEMORY.md` es una memoria operativa ligera. **No** reemplaza ADRs,
> documentación de negocio/funcional, arquitectura ni guías técnicas: solo captura
> reglas recurrentes del usuario que aún no tienen lugar en la documentación
> formal, y siempre tras confirmación explícita. Si una regla ya vive en otro
> `.md`, esa es la fuente de verdad y no se duplica aquí.

> Nota: `README.md` existe pero conserva el contenido boilerplate de Salesforce DX.
> Su personalización para LvlUp WholeSale queda como tarea futura.

---

## 4. Documentación de Negocio

Vive bajo `docs/business/` y describe el *qué* y el *por qué* del proyecto.

| Archivo | Propósito | Pregunta que responde | Estado |
| --- | --- | --- | --- |
| `docs/business/ecommerce-strategy.md` | Estrategia funcional de e-commerce B2B: modelo comercial, catálogo, pricing, stock, journey y flujos | ¿Qué tipo de e-commerce B2B estamos simulando? | Creado |
| `docs/business/buyer-personas.md` | Perfiles de comprador B2B y roles actuales/futuros | ¿Quién compra y qué necesita? | Creado |
| `docs/business/business-rules.md` | Reglas de negocio iniciales identificadas (`BR-*`) | ¿Qué reglas de negocio aplican? | Creado |
| `docs/business/b2b-commerce-flows.md` | Flujos funcionales del portal y sus dependencias | ¿Cómo fluyen las operaciones del comprador? | Creado |
| `docs/business/mvp-scope.md` | Alcance del MVP: incluido, fuera de alcance, MoSCoW y criterios de éxito | ¿Qué entra y qué queda fuera del MVP? | Creado |
| `docs/business/product-catalog-strategy.md` | Estrategia de estructura del catálogo de producto | ¿Cómo se estructura el catálogo? | Creado |
| `docs/business/pricing-and-visibility-strategy.md` | Estrategia funcional de pricing y visibilidad por segmento/Buyer Group | ¿Quién ve qué productos y a qué precio? | Creado |

> `product-catalog-strategy.md` y `pricing-and-visibility-strategy.md` deben
> mantenerse coherentes: el primero define la estructura del catálogo y el segundo
> el pricing y la visibilidad por segmento.

---

## 5. Documentación UX Prevista

Vivirá bajo `docs/ux/`. Describe experiencia, journeys y comportamiento visual.

| Archivo | Propósito esperado | Estado |
| --- | --- | --- |
| `docs/ux/ux-principles.md` | Principios de UX (mobile-first, claridad, enfoque B2B) | Creado |
| `docs/ux/storefront-journey.md` | Journey completo del comprador en el storefront | Creado |
| `docs/ux/plp-pdp-guidelines.md` | Directrices de diseño y comportamiento de PLP y PDP | Creado |
| `docs/ux/cart-checkout-experience.md` | Experiencia de carrito y checkout | Creado |
| `docs/ux/empty-error-loading-states.md` | Comportamiento de estados empty, error y loading | Creado |
| `docs/ux/wireframes.md` | Wireframes (texto, Mermaid o assets visuales) | Creado |

---

## 6. Documentación de Arquitectura Prevista

Vivirá bajo `docs/architecture/`. Describe decisiones técnicas y trade-offs.

| Archivo | Propósito esperado | Estado |
| --- | --- | --- |
| `docs/architecture/standard-vs-custom-framework.md` | Marco de decisión estándar vs custom | Creado |
| `docs/architecture/solution-architecture.md` | Arquitectura global de la solución | Creado |
| `docs/architecture/integration-architecture.md` | Arquitectura de integraciones (REST, simulación ERP) | Creado |
| `docs/architecture/security-architecture.md` | Arquitectura de seguridad y control de accesos | Creado |
| `docs/architecture/limitations-and-assumptions.md` | Limitaciones y supuestos técnicos | Creado |

---

## 7. Documentación Salesforce Prevista

Vivirá bajo `docs/salesforce/`. Describe configuración, capacidades estándar y
modelo de plataforma.

| Archivo | Propósito esperado | Estado |
| --- | --- | --- |
| `docs/salesforce/b2b-commerce-standard-capabilities.md` | Capacidades estándar de Salesforce B2B Commerce | Creado |
| `docs/salesforce/data-model.md` | Modelo de datos (WebStore, Product2, Buyer Group, Price Book, etc.) | Creado |
| `docs/salesforce/security-model.md` | Modelo de seguridad (perfiles, permission sets, sharing) | Creado |
| `docs/salesforce/configuration-decisions.md` | Decisiones de configuración de la plataforma | Creado |
| `docs/salesforce/data-loading-strategy.md` | Estrategia de carga de datos (set MVP, orden, dependencias) | Creado |
| `docs/salesforce/org-validation-checklist.md` | Checklist de validación de capacidades en la Developer Org | Creado |
| `docs/salesforce/commerce-cloud-glossary.md` | Glosario de términos de Commerce Cloud | Creado |

---

## 8. Documentación de Desarrollo Prevista

Vivirá bajo `docs/development/`. Describe guías y convenciones de desarrollo.

| Archivo | Propósito esperado | Estado |
| --- | --- | --- |
| `docs/development/apex-guidelines.md` | Guías de desarrollo Apex | Creado |
| `docs/development/lwc-guidelines.md` | Guías de desarrollo LWC | Creado |
| `docs/development/flow-guidelines.md` | Guías de diseño de Flows | Creado |
| `docs/development/integration-guidelines.md` | Guías de desarrollo de integraciones (REST, mocks, callouts) | Creado |
| `docs/development/code-review-checklist.md` | Checklist transversal de code review | Creado |
| `docs/development/naming-conventions.md` | Convenciones de nombres | Creado |
| `docs/development/error-handling-guidelines.md` | Guías de manejo de errores | Creado |
| `docs/development/logging-guidelines.md` | Guías de logging | Creado |
| `docs/development/deployment-guidelines.md` | Guías de despliegue | Creado |

---

## 9. Testing y Evaluaciones Previstas

Dos ámbitos distintos y complementarios:

- **`docs/testing/`**: documentación de **testing funcional y técnico** del portal
  (estrategia de pruebas, escenarios de QA).
- **`evals/`**: **evaluación de la calidad de las respuestas de los agentes de
  IA** (no pruebas funcionales del software, sino calidad de los agentes).

| Archivo | Propósito esperado | Estado |
| --- | --- | --- |
| `docs/testing/test-strategy.md` | Estrategia general de testing del MVP | Creado |
| `docs/testing/functional-test-cases.md` | Catálogo de casos de prueba funcionales (FTC-*) | Creado |
| `docs/testing/security-test-cases.md` | Catálogo de casos de prueba de seguridad (STC-*) | Creado |
| `docs/testing/integration-test-cases.md` | Catálogo de casos de prueba de integración futura | Creado |
| `docs/testing/regression-checklist.md` | Checklist de regresión (smoke/core/extended/targeted) | Creado |
| `evals/agent-evaluation-framework.md` | Framework base de evaluación de agentes | Creado |
| `evals/orchestrator-agent-evals.md` | Casos de evaluación del Orchestrator Agent | Creado |
| `evals/business-analyst-agent-evals.md` | Casos de evaluación del Business Analyst Agent | Creado |
| `evals/b2b-commerce-specialist-agent-evals.md` | Casos de evaluación del B2B Commerce Specialist Agent | Creado |
| `evals/salesforce-architect-agent-evals.md` | Casos de evaluación del Salesforce Architect Agent | Creado |
| `evals/ux-specialist-agent-evals.md` | Casos de evaluación del UX Specialist Agent | Creado |
| `evals/salesforce-developer-agent-evals.md` | Casos de evaluación del Salesforce Developer Agent | Creado |
| `evals/qa-specialist-agent-evals.md` | Casos de evaluación del QA Specialist Agent | Creado |
| `evals/documentation-agent-evals.md` | Casos de evaluación del Documentation Agent | Creado |

---

## 10. Agentes IA Previstos

Vivirán bajo `agents/`. Cada documento contendrá la **definición de rol** del
agente: misión, límites, responsabilidades, criterios de calidad y formatos de
salida. **No contienen prompts completos en este índice**; solo se listan y se
explica su propósito.

| Archivo | Propósito esperado | Estado |
| --- | --- | --- |
| `agents/orchestrator-agent.md` | Agente orquestador / coordinación entre agentes | Creado |
| `agents/business-analyst-agent.md` | Análisis de negocio, reglas y alcance funcional | Creado |
| `agents/b2b-commerce-specialist-agent.md` | B2B Commerce estándar: catálogo, pricing, Buyer Groups, storefront | Creado |
| `agents/salesforce-architect-agent.md` | Arquitectura, seguridad, estándar vs custom, integración | Creado |
| `agents/ux-specialist-agent.md` | UX, storefront journey y estados | Creado |
| `agents/salesforce-developer-agent.md` | Apex, LWC, Flow, integración técnica, error handling, logging | Creado |
| `agents/qa-specialist-agent.md` | Testing y regresión | Creado |
| `agents/documentation-agent.md` | Documentación, índice, consistencia y trazabilidad | Creado |

---

## 11. ADRs Previstos

Vivirán bajo `adr/`. Cada ADR registra una **decisión arquitectónica relevante**:
contexto, decisión tomada, consecuencias y alternativas consideradas.

| Archivo | Propósito esperado | Estado |
| --- | --- | --- |
| `adr/README.md` | Índice y guía base de la carpeta `adr/` (qué es un ADR, cuándo crearlo, naming, estructura) | Creado |
| `adr/0001-project-scope-and-mvp-boundaries.md` | Alcance del proyecto y límites del MVP | Creado |
| `adr/0002-standard-first-b2b-commerce-approach.md` | Enfoque estándar primero en B2B Commerce | Creado |
| `adr/0003-commerce-data-vs-metadata-strategy.md` | Estrategia de data vs metadata en Commerce | Creado |
| `adr/0004-pricing-and-visibility-strategy.md` | Estrategia de pricing y visibility | Creado |
| `adr/0005-checkout-approval-credit-and-stock-strategy.md` | Estrategia de checkout: approval, credit y stock | Creado |
| `adr/0006-future-rest-mock-integration-strategy.md` | Estrategia futura de integración REST/mock | Creado |

---

## 12. Mapa de Consulta Rápida

| Si necesitas responder... | Consulta primero... | Luego consulta... |
| --- | --- | --- |
| ¿Cuál es el objetivo del proyecto? | `PROJECT_CONTEXT.md` | `docs/business/ecommerce-strategy.md` |
| ¿Qué entra en el MVP? | `docs/business/mvp-scope.md` | `docs/business/b2b-commerce-flows.md` |
| ¿Quién es el comprador? | `docs/business/buyer-personas.md` | `docs/business/pricing-and-visibility-strategy.md` |
| ¿Qué reglas aplican? | `docs/business/business-rules.md` | `docs/business/b2b-commerce-flows.md` |
| ¿Cómo fluye la compra? | `docs/business/b2b-commerce-flows.md` | `docs/business/business-rules.md` |
| ¿Cómo se estructura el catálogo? | `docs/business/product-catalog-strategy.md` | `docs/business/pricing-and-visibility-strategy.md` |
| ¿Quién ve qué producto y a qué precio? | `docs/business/pricing-and-visibility-strategy.md` | `docs/business/buyer-personas.md` |
| ¿Qué estándar vs custom aplica? | `docs/architecture/standard-vs-custom-framework.md` *(cuando exista)* | `PROJECT_CONTEXT.md` |
| ¿Cómo debe comportarse Claude? | `CLAUDE.md` + `MEMORY.md` | `PROJECT_CONTEXT.md` |

---

## 13. Estados Documentales

| Estado | Cuándo usarlo |
| --- | --- |
| **Creado** | El documento existe y tiene contenido utilizable. |
| **Pendiente** | El documento está previsto pero aún no se ha creado. |
| **En revisión** | El documento existe pero está siendo revisado o completado. |
| **Aprobado** | El documento ha sido validado y se considera estable. |
| **Obsoleto** | El documento ya no refleja la realidad y no debe usarse como referencia. |
| **Reemplazado** | El documento fue sustituido por otro; debe apuntar a su reemplazo. |

---

## 14. Reglas para Crear Nuevos Documentos

- Crear un documento **solo si tiene una responsabilidad clara**.
- **No duplicar** contenido existente; enlazar a la fuente.
- **Referenciar** los documentos relacionados.
- **Marcar** los supuestos y las decisiones pendientes.
- Usar **español** para documentación de contexto, negocio, arquitectura, UX,
  agentes, ADRs y evaluaciones.
- Usar **inglés** para código, nombres técnicos, contratos de API y mensajes de
  commit (según la política de idioma de `CLAUDE.md`).
- No mezclar idiomas dentro de un mismo archivo, salvo términos técnicos propios
  del ecosistema Salesforce.
- Si un tema implica una **decisión arquitectónica relevante**, crear o actualizar
  un **ADR**.
- Registrar el nuevo documento en este índice con su estado.

---

## 15. Relación con PROJECT_CONTEXT.md y CLAUDE.md

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto (negocio,
  alcance, principios).
- `CLAUDE.md` define **cómo debe trabajar Claude** dentro del repositorio
  (operación, comandos, workflow, convenciones).
- Este índice ayuda a **navegar** la documentación, pero **no reemplaza** a ninguno
  de los dos: ante una duda de contexto, manda `PROJECT_CONTEXT.md`; ante una duda
  de operación del repositorio, manda `CLAUDE.md`.
