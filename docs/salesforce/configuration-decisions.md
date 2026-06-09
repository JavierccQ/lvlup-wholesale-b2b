# Decisiones de Configuración Salesforce - LvlUp WholeSale

## 1. Propósito del Documento

Este documento registra de forma **estructurada** las decisiones de configuración
Salesforce relevantes para el proyecto `LvlUp-Wholesale-B2B`, diferenciando
decisiones confirmadas, pendientes, supuestos, gaps, validaciones necesarias en la
org y decisiones que deban escalarse a ADR.

Sirve para:

- Mantener la trazabilidad de la configuración.
- Diferenciar decisiones confirmadas, pendientes y futuras.
- Evitar la customización prematura.
- Documentar las validaciones realizadas en la org.
- Identificar gaps.
- Conectar la configuración con arquitectura, negocio, UX y testing.
- Determinar cuándo una decisión debe escalarse a ADR.

Este documento **no reemplaza los ADRs ni la documentación oficial de Salesforce**.
Aplica el principio rector: *Configuration first, customization only when
justified*.

> **Nota de honestidad:** las decisiones de **gobernanza y alcance** pueden estar
> *Confirmadas* (son decisiones de proyecto). Las decisiones de **configuración
> técnica** que dependen de la org se marcan como *Pendiente de validación* o
> *Supuesto*; no se inventa configuración concreta.

---

## 2. Principios de Decisión de Configuración

- **Configuración antes que customización**.
- **Validar en la org** antes de asumir.
- **Documentar cada decisión** relevante.
- **No usar Apex/LWC/Flow** si la configuración estándar resuelve la necesidad.
- **No crear datos o metadata** sin propósito funcional claro.
- **Separar** configuración, metadata y datos.
- Mantener el **MVP controlado**.
- **Escalar a ADR** si hay customización, integración o excepción relevante.

---

## 3. Estados de Decisión

| Estado | Significado | Cuándo usarlo | Ejemplo |
| --- | --- | --- | --- |
| Confirmada | Decisión tomada y estable | Decisión de proyecto/alcance ya establecida | Priorizar el estándar |
| Pendiente de validación | Depende de comprobar en la org | Capacidad/configuración no validada | Componentes de PLP |
| Supuesto | Se asume temporalmente | Aún sin confirmar, pero se trabaja con ello | Buyer Groups por segmento |
| Rechazada | Descartada | No se hará | Customizar por estética |
| Diferida | Pospuesta a fase futura | Útil pero no ahora | Pricing por volumen |
| Fuera del MVP | Excluida del MVP | Explícitamente no incluida | Pagos reales |
| Requiere ADR | Implica customización/excepción | Antes de implementar | Apex de integración |

---

## 4. Plantilla de Decisión de Configuración

Cada decisión relevante puede documentarse con esta plantilla:

- **ID** (p. ej. `CFG-CAT-001`)
- **Área**
- **Decisión**
- **Estado**
- **Justificación**
- **Alternativas evaluadas**
- **Impacto funcional**
- **Impacto técnico**
- **Impacto UX**
- **Impacto en seguridad**
- **Impacto en testing**
- **Documento relacionado**
- **¿Requiere ADR?**
- **Próximo paso**

Prefijos de ID por área: `CFG-GEN` (general), `CFG-STO` (storefront), `CFG-CAT`
(catálogo), `CFG-PRD` (productos), `CFG-ACC` (cuentas/usuarios), `CFG-BG` (Buyer
Groups), `CFG-PRI` (pricing), `CFG-VIS` (visibilidad), `CFG-PLP` (PLP/PDP),
`CFG-CRT` (carrito), `CFG-CHK` (checkout), `CFG-ORD` (orders/historial/reorder),
`CFG-APP` (approval/credit/quote), `CFG-INT` (integración), `CFG-SEC` (seguridad),
`CFG-TST` (testing).

---

## 5. Decisiones Generales del Proyecto

| ID | Decisión | Estado | Justificación | Documento relacionado | ¿Requiere ADR? |
| --- | --- | --- | --- | --- | --- |
| CFG-GEN-001 | Priorizar Salesforce B2B Commerce estándar | Confirmada | Mantenibilidad y upgradeability | `standard-vs-custom-framework.md` | No |
| CFG-GEN-002 | Mantener *Configuration first, customization only when justified* | Confirmada | Principio rector | `PROJECT_CONTEXT.md` | No |
| CFG-GEN-003 | Mantener el MVP controlado | Confirmada | Evitar scope creep | `mvp-scope.md` | No |
| CFG-GEN-004 | Español para documentación y contexto | Confirmada | Política de idioma | `CLAUDE.md` | No |
| CFG-GEN-005 | Inglés para código, contratos API y commits | Confirmada | Política de idioma | `CLAUDE.md` | No |
| CFG-GEN-006 | ERP real fuera del MVP | Confirmada (Fuera del MVP) | Control de alcance | `integration-architecture.md` | No |
| CFG-GEN-007 | No customizar sin gap validado | Confirmada | Disciplina arquitectónica | `standard-vs-custom-framework.md` | Sí, al proponer custom |
| CFG-GEN-008 | Registrar decisiones relevantes en ADR | Confirmada | Trazabilidad | `standard-vs-custom-framework.md` | No |

---

## 6. Decisiones sobre Storefront / Webstore

| ID | Decisión | Estado | Justificación | Validación requerida | Riesgo | Próximo paso |
| --- | --- | --- | --- | --- | --- | --- |
| CFG-STO-001 | Usar el Site/storefront existente | Supuesto | Site activo por contexto | Confirmar configuración del WebStore | Asumir lo no validado | Validar en la org |
| CFG-STO-002 | Experience Builder como primera opción | Confirmada | Estándar primero | Componentes disponibles | Customizar antes de tiempo | Inventariar componentes |
| CFG-STO-003 | Home como pantalla inicial B2B | Confirmada | Journey definido | Configuración de Home | Home demasiado B2C | Diseñar en Builder |
| CFG-STO-004 | Navegación simple por categorías | Confirmada | UX clara | Navegación estándar | Menús profundos | Configurar navegación |
| CFG-STO-005 | Mobile-first | Confirmada | Principio UX | Responsive estándar | Mala UX mobile | Validar en dispositivos |
| CFG-STO-006 | Componentes estándar antes que LWC custom | Confirmada | Estándar primero | Cobertura del estándar | Custom innecesario | Validar gaps |

---

## 7. Decisiones sobre Catálogo

| ID | Decisión | Estado | Justificación | Documento relacionado | Validación requerida | Próximo paso |
| --- | --- | --- | --- | --- | --- | --- |
| CFG-CAT-001 | Categorías principales del catálogo | Confirmada (negocio) | Estrategia de catálogo | `product-catalog-strategy.md` | Estructura en la org | Configurar categorías |
| CFG-CAT-002 | Catálogo tecnológico/gaming | Confirmada (negocio) | Modelo de negocio | `ecommerce-strategy.md` | — | — |
| CFG-CAT-003 | Productos representativos para el MVP | Confirmada (negocio) | Set acotado | `product-catalog-strategy.md` | Carga de datos | Definir carga |
| CFG-CAT-004 | Product Catalog / Categories como capacidades a validar | Pendiente de validación | Estándar a confirmar | `b2b-commerce-standard-capabilities.md` | Capacidad en la org | Validar |
| CFG-CAT-005 | Separar estrategia de catálogo de la carga de datos | Confirmada | Data ≠ metadata | `data-model.md` | — | Definir carga |
| CFG-CAT-006 | No crear modelo custom de catálogo salvo gap validado | Confirmada | Estándar primero | `standard-vs-custom-framework.md` | Gap | ADR si aplica |

---

## 8. Decisiones sobre Productos

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-PRD-001 | Usar productos estándar (Product2) cuando aplique | Pendiente de validación | Confirmar en la org | No |
| CFG-PRD-002 | Información funcional esperada en PLP/PDP | Confirmada (funcional) | SKU, nombre, descripción, categoría, imagen, estado | No |
| CFG-PRD-003 | No crear campos custom hasta validar necesidad | Confirmada | Estándar primero | Sí, si se crean |
| CFG-PRD-004 | MVP con 15–25 productos representativos | Confirmada | Set acotado (`LVL-*`) | No |
| CFG-PRD-005 | Productos de prueba para stock/visibilidad/pricing | Confirmada | Cobertura de casos | No |

---

## 9. Decisiones sobre Buyer Accounts y Buyer Users

| ID | Decisión | Estado | Justificación | Validación requerida | Riesgo | Próximo paso |
| --- | --- | --- | --- | --- | --- | --- |
| CFG-ACC-001 | Un único usuario operativo por buyer account en el MVP | Confirmada | Alcance MVP (`BR-ACCESS-005`) | Modelo usuario-cuenta | Sobre-ingeniería de roles | Validar relación |
| CFG-ACC-002 | Roles buyer avanzados para futuro | Confirmada (Diferida) | No necesarios en MVP | — | Adelantarse | Documentar futuro |
| CFG-ACC-003 | Buyer User/Approver/Admin no completos en MVP salvo necesidad estándar | Confirmada | Control de alcance | Necesidad estándar | Complejidad | Revisar estándar |
| CFG-ACC-004 | Relación usuario-cuenta pendiente de validación | Pendiente de validación | Depende de la org | Configuración real | Asumir lo no validado | Validar |
| CFG-ACC-005 | No definir licencia/permisos definitivos hasta validar | Pendiente de validación | Estándar a confirmar | Licencias/permisos | Permisos erróneos | Validar |

---

## 10. Decisiones sobre Buyer Groups

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-BG-001 | Buyer Groups como mecanismo de segmentación esperado | Supuesto | Pendiente de validación en la org | No |
| CFG-BG-002 | Segmentos funcionales (gaming local, reseller, empresa IT, enterprise) | Confirmada (negocio) | `pricing-and-visibility-strategy.md` | No |
| CFG-BG-003 | Uso potencial para catálogo, pricing y visibilidad | Supuesto | Confirmar capacidad | No |
| CFG-BG-004 | Estructura final pendiente de validación | Pendiente de validación | Depende de la org (`DEC-005`) | No |
| CFG-BG-005 | No cerrar nombres definitivos sin validar | Confirmada | Honestidad de configuración | No |

---

## 11. Decisiones sobre Pricing

| ID | Decisión | Estado | Justificación | Validación requerida | Riesgo | Documento relacionado |
| --- | --- | --- | --- | --- | --- | --- |
| CFG-PRI-001 | Pricing personalizado por cuenta/Buyer Group | Supuesto | Objetivo funcional (`PR-001`) | Capacidad estándar | Pricing inconsistente | `pricing-and-visibility-strategy.md` |
| CFG-PRI-002 | Consistencia en PLP, PDP, carrito y checkout | Confirmada (funcional) | `PR-003` | Resolución de precio | Sorpresa de precio | `pricing-and-visibility-strategy.md` |
| CFG-PRI-003 | Promociones complejas fuera del MVP | Confirmada (Fuera del MVP) | Control de alcance | — | Complejidad | `mvp-scope.md` |
| CFG-PRI-004 | Multi-divisa fuera del MVP | Confirmada (Fuera del MVP) | Un solo mercado | — | Complejidad | `mvp-scope.md` |
| CFG-PRI-005 | Motor externo real de pricing fuera del MVP | Confirmada (Fuera del MVP) | No justificado | — | Acoplamiento | `mvp-scope.md` |
| CFG-PRI-006 | Validar capacidades estándar antes de customizar | Confirmada | Estándar primero | Price Books/Buyer Groups | Custom prematuro | `standard-vs-custom-framework.md` |

---

## 12. Decisiones sobre Visibilidad / Entitlements

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-VIS-001 | Catálogo restringido por cuenta o Buyer Group | Supuesto | `PV-001`, `PV-006`; validar entitlements | No |
| CFG-VIS-002 | Productos no visibles fuera de PLP/search | Confirmada (funcional) | Seguridad de visibilidad | No |
| CFG-VIS-003 | PDP directa manejada de forma segura | Pendiente de validación | Control de acceso por URL | No |
| CFG-VIS-004 | Carrito/checkout/reorder revalidan visibilidad | Confirmada (funcional) | No confiar solo en UI | No |
| CFG-VIS-005 | Validar capacidades estándar antes de customizar | Confirmada | Estándar primero | No |
| CFG-VIS-006 | Lógica custom de visibilidad requiere ADR | Confirmada | Excepción relevante | Sí |

---

## 13. Decisiones sobre PLP y PDP

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-PLP-001 | Usar componentes estándar si cubren la necesidad | Pendiente de validación | Confirmar componentes | No |
| CFG-PLP-002 | Mostrar información B2B relevante | Confirmada (funcional) | `plp-pdp-guidelines.md` | No |
| CFG-PLP-003 | Priorizar claridad sobre diseño B2C | Confirmada | Principio UX | No |
| CFG-PLP-004 | No crear LWC custom por estética | Confirmada (Rechazada como práctica) | Evitar sobre-ingeniería | Sí, si se justifica |
| CFG-PLP-005 | PLP/PDP respetan pricing y visibilidad | Confirmada (funcional) | Consistencia/seguridad | No |
| CFG-PLP-006 | Estados de stock/pricing/visibilidad claros | Confirmada | `empty-error-loading-states.md` | No |

---

## 14. Decisiones sobre Cart

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-CRT-001 | Usar carrito estándar primero | Pendiente de validación | Confirmar capacidad | No |
| CFG-CRT-002 | Validar productos, pricing y visibilidad | Confirmada (funcional) | `BR-CART-005` | No |
| CFG-CRT-003 | Modificar cantidades y eliminar productos si el estándar lo permite | Pendiente de validación | Confirmar capacidad | No |
| CFG-CRT-004 | Mensajes claros ante restricciones | Confirmada | UX | No |
| CFG-CRT-005 | No customizar carrito salvo gap validado | Confirmada | Estándar primero | Sí, si es relevante |

---

## 15. Decisiones sobre Checkout

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-CHK-001 | Checkout básico en MVP | Confirmada | Alcance | No |
| CFG-CHK-002 | Pagos reales fuera del MVP | Confirmada (Fuera del MVP) | Alcance | No |
| CFG-CHK-003 | Tax real fuera del MVP | Confirmada (Fuera del MVP) | Alcance | No |
| CFG-CHK-004 | Shipping real fuera del MVP | Confirmada (Fuera del MVP) | Alcance | No |
| CFG-CHK-005 | Confirmación vs solicitud pendiente clara | Confirmada (funcional) | `BR-CHECKOUT-003` | No |
| CFG-CHK-006 | Approval/credit/stock documentados antes de automatizar | Confirmada | Documentar primero | No |
| CFG-CHK-007 | Validar checkout estándar antes de Flow/LWC/Apex | Confirmada | Estándar primero | Sí, si se customiza |

---

## 16. Decisiones sobre Orders, Historial y Reorder

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-ORD-001 | Historial como capacidad clave para recurrencia | Confirmada (funcional) | `BR-HISTORY-*` | No |
| CFG-ORD-002 | Reorder revalida pricing, visibilidad y stock | Confirmada (funcional) | `BR-REORDER-003` | No |
| CFG-ORD-003 | Validar capacidades estándar de historial/reorder | Pendiente de validación | Confirmar en la org | No |
| CFG-ORD-004 | Si el estándar no cubre, documentar gap antes de customizar | Confirmada | Disciplina | No |
| CFG-ORD-005 | Reorder custom relevante requiere ADR | Confirmada | Excepción relevante | Sí |

---

## 17. Decisiones sobre Approval, Credit y Quote Request

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-APP-001 | Approval por importe documentado funcionalmente | Confirmada (funcional) | `BR-APPROVAL-*` | No |
| CFG-APP-002 | Umbral pendiente de definición | Pendiente de validación | `DEC-008` | No |
| CFG-APP-003 | Credit validation documentada funcionalmente | Confirmada (funcional) | `BR-CREDIT-*` | No |
| CFG-APP-004 | Fuente futura posible: ERP simulado | Diferida | Integración futura | Sí, al integrar |
| CFG-APP-005 | Quote request documentada funcionalmente | Confirmada (funcional) | `BR-QUOTE-*` | No |
| CFG-APP-006 | Automatización pendiente | Pendiente de validación | Definir nivel | No |
| CFG-APP-007 | Validar estándar/configuración/Flow antes de Apex | Confirmada | Estándar primero | Sí, si Apex |
| CFG-APP-008 | No crear objetos custom por defecto | Confirmada | Estándar primero | Sí, si se crean |

---

## 18. Decisiones sobre Integración

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-INT-001 | ERP real fuera del MVP | Confirmada (Fuera del MVP) | Alcance | No |
| CFG-INT-002 | REST como enfoque futuro | Confirmada | `integration-architecture.md` | Sí, al implementar |
| CFG-INT-003 | Postman Mock Server como simulación futura | Diferida | Simulación primero | Sí, al implementar |
| CFG-INT-004 | JSON como formato esperado | Confirmada | Enfoque REST | No |
| CFG-INT-005 | Named Credentials si hay callouts | Pendiente de validación | Seguridad de callout | Sí, al implementar |
| CFG-INT-006 | Apex solo si se implementan callouts | Diferida | Estándar primero | Sí |
| CFG-INT-007 | Contratos definitivos pendientes | Pendiente de validación | `DEC-017` | No |
| CFG-INT-008 | Integración real requiere ADR | Confirmada | Excepción relevante | Sí |

---

## 19. Decisiones sobre Seguridad

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-SEC-001 | Mínimo privilegio | Confirmada | Principio de seguridad | No |
| CFG-SEC-002 | Buyer solo ve datos de su cuenta | Confirmada (funcional) | `security-model.md` | No |
| CFG-SEC-003 | Buyer solo ve catálogo/pricing permitido | Confirmada (funcional) | `PV-*`, `PR-*` | No |
| CFG-SEC-004 | No confiar solo en la UI | Confirmada | Seguridad | No |
| CFG-SEC-005 | Permission Sets definitivos pendientes | Pendiente de validación | `DEC-018` | No |
| CFG-SEC-006 | Permission Set Groups definitivos pendientes | Pendiente de validación | `DEC-018` | No |
| CFG-SEC-007 | No crear permisos excesivos | Confirmada | Mínimo privilegio | No |
| CFG-SEC-008 | Gaps de seguridad relevantes requieren ADR | Confirmada | Excepción relevante | Sí |

---

## 20. Decisiones sobre Testing

| ID | Decisión | Estado | Validación/Justificación | ¿Requiere ADR? |
| --- | --- | --- | --- | --- |
| CFG-TST-001 | Testing funcional basado en flujos B2B | Confirmada | `b2b-commerce-flows.md` | No |
| CFG-TST-002 | Testing de permisos y visibilidad | Confirmada | `security-model.md` | No |
| CFG-TST-003 | Testing de pricing consistente | Confirmada | `PR-003` | No |
| CFG-TST-004 | Testing de carrito/checkout | Confirmada | Flujos | No |
| CFG-TST-005 | Testing de reorder | Confirmada | `BR-REORDER-003` | No |
| CFG-TST-006 | Testing mobile/UX | Confirmada | Mobile-first | No |
| CFG-TST-007 | Testing técnico solo si hay Flow/Apex/LWC | Confirmada | Proporcionalidad | No |
| CFG-TST-008 | Testing de integración futuro con mocks | Diferida | Integración futura | No |

---

## 21. Decisiones Rechazadas o Diferidas

| ID | Decisión rechazada/diferida | Motivo | Riesgo si se adelanta | Fase futura posible |
| --- | --- | --- | --- | --- |
| CFG-OOS-001 | Pagos reales | Fuera del foco del MVP | Complejidad/cumplimiento | Futuro posible |
| CFG-OOS-002 | Tax real | Complejidad fiscal | Esfuerzo desviado | Futuro posible |
| CFG-OOS-003 | Shipping real | Complejidad logística | Esfuerzo desviado | Futuro posible |
| CFG-OOS-004 | OMS avanzado | Historial básico suficiente | Sobre-ingeniería | Futuro posible |
| CFG-OOS-005 | ERP real | Dependencia externa | Acoplamiento prematuro | Tras simulación |
| CFG-OOS-006 | Promociones complejas | No aporta a la base B2B | Complejidad de pricing | Futuro posible |
| CFG-OOS-007 | Multi-idioma | Opera en España | Esfuerzo desviado | Futuro (expansión) |
| CFG-OOS-008 | Multi-divisa | Un solo mercado | Complejidad | Futuro (expansión) |
| CFG-OOS-009 | Marketplace | Modelo distinto | Cambio de modelo | No incluido |
| CFG-OOS-010 | LWC custom por estética | Sin valor funcional | Deuda técnica | Rechazada |
| CFG-OOS-011 | Apex sin gap validado | Evita configuración | Complejidad innecesaria | Rechazada |
| CFG-OOS-012 | Objetos custom por defecto (approval/quote/credit/stock) | Estándar primero | Sobre-ingeniería | Solo con ADR |

---

## 22. Decisiones que Requieren ADR

| ID | Decisión potencial | Motivo ADR | Área | Prioridad | Estado |
| --- | --- | --- | --- | --- | --- |
| CFG-ADR-001 | LWC custom para PLP/PDP | UI custom relevante | UX/Arquitectura | Media | Potencial |
| CFG-ADR-002 | LWC custom para carrito/checkout | UI custom relevante | UX/Arquitectura | Media | Potencial |
| CFG-ADR-003 | Apex para approval/credit/stock | Lógica central | Arquitectura | Media | Potencial |
| CFG-ADR-004 | Apex para integración REST | Callouts | Integración | Media | Potencial |
| CFG-ADR-005 | Objeto custom para quote/approval/credit | Modelo de datos | Datos | Media | Potencial |
| CFG-ADR-006 | Implementar Postman Mock Server | Inicio de simulación | Integración | Baja | Potencial |
| CFG-ADR-007 | Definir contrato REST relevante | Contrato de integración | Integración | Baja | Potencial |
| CFG-ADR-008 | Cambiar el modelo de seguridad | Acceso/visibilidad | Seguridad | Alta | Potencial |
| CFG-ADR-009 | Excepción al estándar Salesforce | Desviación del principio | Arquitectura | Alta | Potencial |

---

## 23. Gaps Pendientes de Validación

| ID | Gap o pregunta | Área | Impacto | Cómo validar | Estado |
| --- | --- | --- | --- | --- | --- |
| CFG-GAP-001 | Capacidades reales disponibles en la Developer Org | Plataforma | Alto | Revisar la org | Abierto |
| CFG-GAP-002 | Componentes estándar de PLP/PDP | UX | Alto | Probar en Builder | Abierto |
| CFG-GAP-003 | Configuración real del carrito | Comercio | Alto | Probar el carrito | Abierto |
| CFG-GAP-004 | Configuración real del checkout | Comercio | Alto | Probar el checkout | Abierto |
| CFG-GAP-005 | Historial y reorder estándar | Comercio | Alto | Probar historial/reorder | Abierto |
| CFG-GAP-006 | Buyer Groups y visibilidad | Datos/Seguridad | Alto | Configurar y probar | Abierto |
| CFG-GAP-007 | Pricing por cuenta/Buyer Group | Datos | Alto | Configurar y probar | Abierto |
| CFG-GAP-008 | PDP restringido por URL directa | Seguridad | Alto | Prueba de acceso | Abierto |
| CFG-GAP-009 | Permission Sets requeridos | Seguridad | Medio | Definir y probar | Abierto |
| CFG-GAP-010 | Data loading de catálogo y pricing | Datos | Alto | Definir estrategia | Abierto |

---

## 24. Criterios para Actualizar este Documento

Actualizar este archivo cuando:

- Se valide una capacidad en la org.
- Se tome una decisión de configuración.
- Se descarte una alternativa.
- Se cree un ADR.
- Se detecte un gap.
- Se cree metadata o datos relevantes.
- Se implemente Flow, LWC, Apex o integración.
- Cambie el alcance del MVP.

---

## 25. Relación con Otros Documentos

- `docs/architecture/standard-vs-custom-framework.md` define el **criterio estándar
  vs custom**.
- `docs/architecture/solution-architecture.md` define la **arquitectura general**.
- `docs/architecture/limitations-and-assumptions.md` consolida **límites y riesgos**.
- `docs/salesforce/b2b-commerce-standard-capabilities.md` define las **capacidades
  estándar**.
- `docs/salesforce/data-model.md` define las **entidades y datos**.
- `docs/salesforce/security-model.md` define la **seguridad Salesforce-relevante**.
- Este documento registra las **decisiones de configuración**.
- `adr/` registrará las **decisiones arquitectónicas relevantes**.
- `docs/testing/` deberá derivar **pruebas** desde estas decisiones.
- `agents/` deberá usar estas decisiones como **restricciones**.
