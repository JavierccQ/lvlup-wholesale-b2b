# Guidelines Flow - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define los **criterios y buenas prácticas** para usar Salesforce
Flow en el proyecto `LvlUp-Wholesale-B2B`: cuándo está justificado, cuándo
evitarlo, cómo compararlo con Apex y LWC, y cómo mantener automatizaciones simples,
testeables y alineadas con el MVP.

Sirve como base para:

- Decidir **cuándo Flow está justificado**.
- Evitar automatizaciones innecesarias.
- Mantener **lógica declarativa simple**.
- Comparar **Flow vs Apex**.
- Diseñar automatizaciones **mantenibles**.
- Reducir el riesgo de **sobre-ingeniería**.
- Guiar el **testing funcional**.
- Alimentar **ADRs** si una automatización impacta arquitectura o seguridad.

Este documento **no define la implementación Flow concreta del MVP**; los ejemplos
son conceptuales. La prosa va en español; los nombres de Flows, recursos, variables,
Apex actions e invocable methods van en inglés.

---

## 2. Principio Principal para Flow

> **Flow no es la primera opción absoluta**; debe venir **después** de validar el
> estándar y la configuración.

Orden de evaluación (alineado con `standard-vs-custom-framework.md`):

1. **Salesforce B2B Commerce estándar**.
2. **Experience Builder / configuración**.
3. **Configuración de datos**.
4. **Flow** si la lógica es declarativa y mantenible.
5. **LWC** si hay un gap UX real.
6. **Apex** si Flow no es suficiente o la lógica requiere control técnico.
7. **Integración externa** si el dato/proceso vive fuera de Salesforce.

Cualquier Flow relevante debe **justificarse** contra el framework estándar vs
custom.

---

## 3. Cuándo Usar Flow

- **Automatizaciones simples**.
- Reglas funcionales de **complejidad baja o media**.
- **Actualizaciones de estado** simples.
- **Notificaciones** internas o funcionales.
- **Validaciones declarativas** mantenibles.
- **Approval por importe** si puede resolverse con claridad.
- **Procesos guiados** internos si aportan valor.
- **Orquestación liviana** sin lógica técnica pesada.
- Acciones **repetibles y de bajo riesgo**.
- Automatizaciones que un **administrador Salesforce** pueda entender y mantener.

---

## 4. Cuándo Evitar Flow

- Si **Salesforce B2B Commerce estándar** resuelve el caso.
- Si la **configuración** resuelve la necesidad.
- Si la lógica requiere **demasiadas ramas**.
- Si el **volumen** puede generar problemas de límites.
- Si requiere **transformaciones complejas**.
- Si requiere **integración REST compleja**.
- Si requiere **manejo sofisticado de errores**.
- Si requiere **transaccionalidad fina**.
- Si sería **más claro y seguro en Apex**.
- Si **no se puede testear** de forma razonable.
- Si el proceso está **fuera del MVP**.

---

## 5. Tipos de Flow a Considerar

| Tipo de Flow | Uso posible | Cuándo evitarlo | Riesgos | Estado |
| --- | --- | --- | --- | --- |
| Record-Triggered Flow | Reaccionar a cambios de registro (estado, validación) | Lógica compleja o alto volumen | Límites, recursividad | Pendiente de validación |
| Screen Flow | Procesos guiados internos | Reemplazar UX estándar del storefront | UX/mobile/seguridad no validadas | Futuro |
| Autolaunched Flow | Lógica reutilizable sin UI | Lógica que exige control técnico | Difícil de depurar si crece | Pendiente de validación |
| Scheduled Flow | Procesos programados | Necesidad de tiempo real | Volumen y límites | Futuro |
| Flow desde una acción | Disparar un proceso desde un botón/acción | Si el estándar ya lo cubre | UX inconsistente | Pendiente de validación |
| Subflow (invocado por otro) | Modularizar lógica común | Sobre-fragmentar sin necesidad | Complejidad de mantenimiento | Pendiente de validación |
| Flow con Apex invocable | Delegar a Apex pasos técnicos | Si Flow solo ya basta | Acoplamiento Flow-Apex | Futuro |

No se inventan Flows concretos; los tipos se evalúan en la org.

---

## 6. Flow vs Apex

| Criterio | Preferir Flow cuando… | Preferir Apex cuando… | Riesgo de elegir mal |
| --- | --- | --- | --- |
| Complejidad | Lógica simple y lineal | Lógica compleja/ramificada | Flow ilegible o Apex innecesario |
| Volumen | Volúmenes moderados | Alto volumen/bulk intensivo | Límites o ineficiencia |
| Integración | Sin callouts | Callouts/transformaciones | Integración frágil en Flow |
| Manejo de errores | Errores simples (fault paths) | Control de errores robusto | Errores no controlados |
| Testing | Validación funcional clara | Testing técnico detallado | Cobertura insuficiente |
| Mantenibilidad | Admin puede mantenerlo | Requiere control de desarrollador | Mantenimiento costoso |
| Seguridad | Reglas declarativas simples | Lógica de acceso fina | Exposición de datos |
| Transaccionalidad | Operaciones simples | Savepoints/consistencia fina | Datos inconsistentes |
| Reutilización | Subflows simples | Servicios reutilizables | Duplicación |
| Necesidad de UI | Screen Flow guiado | Sin UI (servicio) | Herramienta inadecuada |
| Cambios frecuentes | Cambios declarativos rápidos | Cambios que exigen tests | Regresiones |

Coherente con `docs/development/apex-guidelines.md` §2 y §3.

---

## 7. Flow vs LWC

- **Flow** puede servir para **procesos guiados** (Screen Flow).
- **LWC** puede servir para **UI custom interactiva**.
- **No** usar LWC si un Screen Flow resuelve la necesidad.
- **No** usar Screen Flow si la **experiencia storefront estándar** ya cubre el caso.
- **No** introducir Screen Flow en el storefront B2B sin validar **UX, mobile y
  seguridad**.
- Cualquier decisión relevante debe documentarse.

| Necesidad | Preferir Flow | Preferir LWC | Validación requerida |
| --- | --- | --- | --- |
| Proceso guiado interno paso a paso | Sí (Screen Flow) | No | Que no exista capacidad estándar |
| UI interactiva rica en storefront | No | Sí (si hay gap) | UX/mobile/seguridad |
| Automatización sin UI | Sí (Autolaunched) | No | Mantenibilidad |
| Visualización custom de datos | No | Sí (si se justifica) | Gap vs estándar |

> El detalle de LWC vivirá en `docs/development/lwc-guidelines.md` *(documento
> previsto)*; esta sección debe alinearse con él cuando exista.

---

## 8. Naming de Flows y Recursos

- Nombres de Flow en **inglés**, claros y funcionales.
- Variables en **camelCase**.
- Constantes en **UPPER_SNAKE_CASE** si aplica.
- Descripciones **consistentes** (criterio del repositorio).
- Evitar nombres genéricos (`New Flow`, `Test Flow`, `Process 1`).
- Incluir el **dominio funcional** en el nombre cuando aplique.

**Ejemplos recomendados:**

```text
Validate_Order_Approval_Threshold
Update_Pending_Approval_Status
Notify_Credit_Block_Status
```

**Ejemplos a evitar:**

```text
New Flow
Test Flow
Process 1
Flow_Final_v2
```

---

## 9. Estructura y Diseño de Flows

- **Una responsabilidad por Flow**: evitar Flows que lo hagan todo.
- **Modularizar** con subflows solo cuando aporte claridad/reutilización.
- Mantener el Flow **legible**: pocos elementos, ramas claras.
- **Nombrar los elementos** y recursos de forma descriptiva.
- Evitar **lógica duplicada** entre Flows (y entre Flow y Apex).
- Para record-triggered, preferir **before-save** cuando solo se actualiza el
  registro disparador (más eficiente).
- **No** crear múltiples record-triggered Flows que compitan sobre el mismo objeto
  sin un criterio de orden claro.

---

## 10. Manejo de Errores en Flows

- Usar **fault paths / fault connectors** en los elementos que puedan fallar.
- Mostrar **mensajes funcionales** al usuario, no técnicos.
- **No dejar caminos de fallo sin gestionar**.
- Registrar el error de forma **controlada** cuando aplique (sin exponer detalles).
- Para errores complejos o reintentos, **evaluar Apex**.

---

## 11. Bulkificación y Límites

- Los **record-triggered Flows se ejecutan en bulk**: diseñarlos pensándolo.
- **Evitar elementos Get/Create/Update/Delete dentro de loops**.
- **Minimizar** las consultas y los DML.
- Respetar los **governor limits** (incluidos los compartidos con Apex/triggers).
- Vigilar la **recursividad** entre automatizaciones.
- Probar con **volúmenes representativos**.

---

## 12. Seguridad en Flows

- Tener presente el **run context** del Flow (system vs user context): algunos Flows
  **no aplican FLS/sharing** por defecto.
- **No exponer datos** de otra cuenta ni de otro segmento.
- **No confiar solo en la UI**: la lógica de acceso debe sostenerse en backend
  (coherente con `security-model.md`).
- Validar que las **Screen Flows** del storefront respeten visibilidad y permisos.
- **No** usar Flows para sortear controles de seguridad estándar.

---

## 13. Testing de Flows

- Definir el **comportamiento esperado** antes de construir el Flow.
- Usar **Flow Tests** (para record-triggered) donde sea posible.
- Complementar con **pruebas funcionales** alineadas con `b2b-commerce-flows.md`.
- Si el Flow invoca **Apex invocable**, ese Apex debe tener **test classes**
  (ver `apex-guidelines.md` §12).
- Probar **casos positivos, negativos y límite** (p. ej. bajo/sobre umbral de
  aprobación).
- Documentar los **resultados esperados** para QA.

---

## 14. Documentación, Versionado y Mantenimiento

- Añadir **descripción** al Flow y a sus elementos clave.
- Mantener **una sola versión activa** clara; limpiar versiones obsoletas.
- Documentar el **propósito funcional** del Flow y su relación con reglas (`BR-*`).
- Revisar el Flow cuando cambien las reglas de negocio o el alcance.
- Evitar dejar Flows **inactivos confusos** o duplicados.

---

## 15. Anti-patrones a Evitar

- Flow donde **el estándar/configuración** ya resuelve.
- Flows **gigantes** con demasiadas ramas.
- **DML/Get dentro de loops**.
- **Múltiples record-triggered Flows** sin orden claro sobre el mismo objeto.
- **Caminos de fallo** sin gestionar.
- Nombres **genéricos** (`Flow_Final_v2`).
- **Lógica compleja** que debería ser Apex.
- **Screen Flows** en el storefront sin validar UX/mobile/seguridad.
- Automatizaciones **sin testing** ni comportamiento esperado documentado.

---

## 16. Checklist antes de Crear un Flow

- [ ] ¿Lo resuelve el estándar de B2B Commerce?
- [ ] ¿Lo resuelve la configuración?
- [ ] ¿Es la lógica suficientemente simple y declarativa para Flow?
- [ ] ¿Sería más claro/seguro en Apex?
- [ ] ¿Está dentro del MVP?
- [ ] ¿Es bulk-safe y respeta límites?
- [ ] ¿Tiene fault paths y mensajes funcionales?
- [ ] ¿Respeta seguridad (run context, visibilidad por cuenta)?
- [ ] ¿Hay un comportamiento esperado para testing?
- [ ] ¿Requiere un ADR?

---

## 17. Relación con ADRs

Crear un ADR cuando:

- Un Flow implementa **lógica central** (approval, credit, stock).
- Se introduce un **Screen Flow en el storefront** B2B.
- Se combina **Flow + Apex invocable** para lógica relevante.
- Un Flow impacta **seguridad o visibilidad**.
- Se introduce una **excepción** al principio estándar primero.

---

## 18. Supuestos y Decisiones Pendientes

**Supuestos.**

- En el MVP, Flow se usa **solo si** el estándar/configuración no alcanzan y la
  lógica es declarativa y mantenible.
- Los ejemplos de este documento son **conceptuales**.
- La capacidad real de Flow sobre los objetos de Commerce **debe validarse** en la
  org.

**Decisiones pendientes.**

- Si la **aprobación por importe** se resuelve con estándar, Flow o Apex
  (`DEC-014`).
- Si la **validación de crédito** usa Flow o Apex (`DEC-009`).
- Umbral de aprobación (`DEC-008`).
- Estrategia de testing de Flows.

---

## 19. Relación con Otros Documentos

- `docs/architecture/standard-vs-custom-framework.md` define **cuándo Flow está
  justificado**.
- `docs/architecture/solution-architecture.md` enmarca la **capa de automatización**.
- `docs/development/apex-guidelines.md` define el **criterio Flow vs Apex** y los
  servicios Apex.
- `docs/development/lwc-guidelines.md` *(previsto)* definirá el **criterio Flow vs
  LWC**.
- `docs/salesforce/security-model.md` define la **seguridad** que los Flows deben
  respetar.
- `docs/salesforce/configuration-decisions.md` registra **cuándo se usa Flow**.
- `docs/business/b2b-commerce-flows.md` define los **flujos funcionales** que pueden
  apoyarse en Flow.
- `docs/testing/` deberá definir la **estrategia de pruebas**.
- `adr/` registrará las **decisiones de uso de Flow**.
