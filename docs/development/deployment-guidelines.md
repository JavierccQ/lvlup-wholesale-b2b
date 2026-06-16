# Guidelines de Deployment - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define los **criterios para preparar, validar y ejecutar
despliegues** en el proyecto `LvlUp-Wholesale-B2B`: metadata, configuración, datos,
documentación, Apex, LWC, Flow, integración futura y decisiones relacionadas con
Salesforce B2B Commerce.

Sirve como base para:

- Separar metadata y datos.
- Evitar despliegues incompletos.
- Validar cambios antes de moverlos.
- Reducir riesgos y mantener trazabilidad.
- Preparar futuras estrategias CI/CD.
- Alinear documentación, configuración y código.
- Alimentar code review y ADRs.

Este documento **no define un pipeline definitivo ni comandos específicos**. La
prosa va en español; los nombres técnicos, metadata types, branches y commits en
inglés. Aplica el principio rector: *Configuration first, customization only when
justified*.

---

## 2. Principios Generales de Deployment

- **No desplegar** cambios sin propósito funcional claro.
- **Validar estándar** antes que custom.
- **Separar metadata de data**.
- **Documentar** decisiones relevantes.
- Mantener cambios **pequeños y trazables**.
- **Probar antes** de desplegar.
- **No mover datos manuales** sin estrategia.
- **No hardcodear IDs**.
- **No mover secrets**.
- **No mover configuración sensible** sin revisión.
- Mantener el **MVP controlado**.
- Crear **ADR** cuando el deployment implique una decisión arquitectónica relevante.

---

## 3. Alcance del Deployment en el Proyecto

### Incluido

- Documentación Markdown.
- Metadata Salesforce.
- Apex (si se justifica).
- LWC (si se justifica).
- Flow (si se justifica).
- Permission Sets (si se validan).
- Experience metadata (si aplica y es deployable).
- Configuración deployable (si se valida).
- Contratos API documentados (si aplica).
- Datos funcionales mediante **estrategia separada**.

### Fuera de alcance inicial

- Pipeline CI/CD definitivo.
- Automatización productiva completa.
- ERP real.
- Secrets productivos.
- Despliegues multi-org complejos.
- Estrategia enterprise de releases.
- Deployment automático de todos los datos B2B Commerce sin validación.

---

## 4. Metadata vs Datos

### Metadata (desplegable)

Apex classes, Apex triggers (si existieran), LWC, Flows, Permission Sets,
Permission Set Groups, custom metadata (si se justifica), Experience Builder
metadata (si está disponible y validada), custom objects/fields (solo si se
justifican), Named Credentials (solo validadas y **sin secretos expuestos**).

### Datos / Registros (no metadata)

Accounts, buyer users, Buyer Groups, Products, Product Catalog, Product Categories,
Price Books, Price Book Entries, visibility/entitlement records, orders de prueba,
y datos funcionales de stock/crédito/approval si se representan.

**Claves:**

- Los **datos no se tratan como metadata**.
- Muchas capacidades de Commerce **dependen de registros**.
- La carga de datos tiene **estrategia propia** (`data-loading-strategy.md`).
- Desplegar **metadata sin data** puede dejar el **storefront incompleto**.

---

## 5. Tipos de Cambio

| Tipo de cambio | Ejemplos | ¿Deployable como metadata? | ¿Requiere data loading? | ¿Requiere testing? | ¿Requiere ADR? |
| --- | --- | --- | --- | --- | --- |
| Documentación | Markdown en `docs/` | No (no es metadata SF) | No | No | No |
| Configuración Salesforce | Ajustes de plataforma | Según el tipo (validar) | A veces | Funcional | A veces |
| Experience Builder | Páginas/layout | Parcial / pendiente de validación | No | Funcional/mobile | Si es relevante |
| Apex | `*Service`, `*Controller` | Sí | No | Sí (test classes) | Si es central |
| LWC | Componentes | Sí | No | Sí (Jest) | Si es relevante |
| Flow | Automatización | Sí | A veces (datos de prueba) | Funcional | Si es central |
| Permission Sets | Acceso | Sí (validar) | No | Permisos | Si cambia el modelo |
| Data B2B Commerce | Productos, pricing, Buyer Groups | No (son registros) | Sí | Funcional | Si cambia el modelo |
| Integración futura | Callouts, Named Credentials | Parcial (sin secretos) | No | Con mocks | Sí |
| Named Credentials | Config de callout | Sí (sin secretos) | No | — | Sí |
| Custom objects/fields | Modelo custom | Sí | A veces | Sí | Sí |
| ADRs | `adr/*.md` | No | No | No | — |

---

## 6. Estrategia de Branching Conceptual

- Branches **descriptivas**, en **inglés**, **lowercase + kebab-case**.
- **Una branch por cambio** funcional/documental cuando sea razonable.
- Evitar cambios masivos sin foco.
- Evitar `wip`, `test`, `changes`.
- Relacionar la branch con el documento, feature o fix.

**Ejemplos:** `docs/add-deployment-guidelines`, `docs/update-salesforce-data-model`,
`feature/stock-availability-service`, `fix/checkout-credit-message`.

*(La estrategia final puede evolucionar; coherente con `naming-conventions.md`.)*

---

## 7. Commits

- En **inglés**, breves y claros, estilo Conventional Commits.
- Tipos: `docs:`, `feat:`, `fix:`, `test:`, `refactor:`, `chore:`.
- Evitar commits genéricos.

**Ejemplos:** `docs: add deployment guidelines`,
`docs: update B2B Commerce glossary`, `feat: add stock availability service`,
`test: add credit status service tests`, `fix: handle checkout credit error`.

**Evitar:** `update`, `changes`, `fix`, `cosas`, `wip`.

---

## 8. Pull Requests / Merge Requests

Cada PR/MR relevante debe indicar: objetivo, alcance, tipo de cambio, documentos
actualizados, metadata afectada, datos afectados, testing realizado, riesgos, si
requiere ADR, si requiere validación manual en org y si requiere carga de datos.

**Plantilla conceptual:**

```markdown
## Objetivo
...

## Alcance / Tipo de cambio
docs / feat / fix / config / data

## Metadata afectada
- ...

## Datos afectados (data loading)
- ...

## Documentos actualizados
- ...

## Testing realizado
- ...

## Riesgos
- ...

## ¿Requiere ADR? / ¿Validación manual en org? / ¿Carga de datos?
Sí / No
```

---

## 9. Validación Pre-Deployment

- [ ] ¿El cambio está dentro del MVP?
- [ ] ¿Se validó estándar/configuración primero?
- [ ] ¿Se actualizó la documentación relacionada?
- [ ] ¿Se revisó seguridad?
- [ ] ¿Se revisó el impacto en buyer account?
- [ ] ¿Se revisó pricing/visibilidad si aplica?
- [ ] ¿Se revisó mobile si afecta al storefront?
- [ ] ¿Se revisó metadata vs data?
- [ ] ¿Se identificaron las dependencias?
- [ ] ¿Se ejecutaron las pruebas necesarias?
- [ ] ¿Se creó un ADR si aplica?
- [ ] ¿Existe un plan de rollback conceptual?

---

## 10. Validación de Metadata Salesforce

- [ ] Apex compila.
- [ ] Los tests Apex relevantes pasan (si existen).
- [ ] El LWC no rompe el build (si existe).
- [ ] Los Flows están activos/inactivos según la decisión.
- [ ] Los Permission Sets no conceden permisos excesivos.
- [ ] Los custom fields/objects están justificados (si existen).
- [ ] La Experience metadata fue validada (si aplica).
- [ ] Los Named Credentials no exponen secretos.
- [ ] No hay IDs hardcodeados.
- [ ] No hay URLs hardcodeadas.
- [ ] No hay debug/logging innecesario.

---

## 11. Validación de Datos

- [ ] Datos requeridos identificados.
- [ ] Dependencias documentadas.
- [ ] Buyer accounts existen (si aplica).
- [ ] Buyer users asociados correctamente (si aplica).
- [ ] Buyer Groups asignados (si aplica).
- [ ] Productos asociados a catálogo/categoría.
- [ ] Pricing asignado.
- [ ] Visibilidad/entitlements configurados.
- [ ] Datos de prueba positivos y negativos existen.
- [ ] No se depende de IDs manuales.
- [ ] Los datos son reproducibles.
- [ ] El storefront no queda incompleto por falta de data.

---

## 12. Validación de Documentación

- [ ] `PROJECT_CONTEXT.md` actualizado si cambia el contexto general.
- [ ] `DOCUMENTATION_INDEX.md` actualizado si se agrega un documento.
- [ ] Business docs actualizados si cambia una regla/alcance.
- [ ] UX docs actualizados si cambia la experiencia.
- [ ] Architecture docs actualizados si cambia el diseño.
- [ ] Salesforce docs actualizados si cambia configuración/data.
- [ ] Development docs actualizados si cambia un patrón técnico.
- [ ] Testing docs actualizados si cambia la cobertura esperada.
- [ ] ADR creado si hay una decisión relevante.
- [ ] Glossary actualizado si aparece un término nuevo.

---

## 13. Deployment de Apex

- Apex **solo si está justificado**; debe respetar `apex-guidelines.md`.
- Debe **tener tests**.
- Debe **evitar IDs hardcodeados** y **manejar errores**.
- Debe **respetar la seguridad** (with sharing, CRUD/FLS).
- Los **callouts requieren mocks**; las integraciones relevantes requieren **ADR**.
- **No desplegar Apex** para algo que la configuración/Flow resuelve con claridad.

---

## 14. Deployment de LWC

- LWC **solo si está justificado**; debe respetar `lwc-guidelines.md`.
- Validado en **desktop y mobile**.
- Maneja **loading/empty/error states**.
- Respeta la **seguridad de la buyer account**.
- **No expone** pricing ni productos restringidos.
- **No usa** Apex innecesario.
- Un LWC relevante en el storefront puede **requerir ADR**.

---

## 15. Deployment de Flow

- Flow **solo si está justificado**; debe respetar `flow-guidelines.md`.
- **Responsabilidad clara** y **fault paths**.
- **Sin IDs hardcodeados**; con **datos de prueba** y **documentado**.
- Un Flow central de approval/checkout/pricing/visibilidad puede **requerir ADR**.

---

## 16. Deployment de Integraciones

- El **ERP real está fuera del MVP**.
- Las integraciones futuras respetan `integration-guidelines.md`.
- **Named Credentials** si hay callouts; **no hardcodear** endpoints ni secrets.
- **Contratos documentados** y **mocks disponibles**.
- **Error handling** y **logging** definidos.
- **ADR** si se implementa un callout relevante o el Postman Mock Server.

---

## 17. Deployment de Experience Builder / Storefront

- Validar **qué cambios son metadata deployable** y cuáles requieren
  **configuración manual** (pendiente de validación).
- **No asumir** que toda la configuración visual se despliega igual.
- **Documentar** los cambios manuales si existen.
- Validar **navegación, PLP/PDP/cart/checkout, mobile y buyer autenticado**.
- Validar **estados empty/error/loading**.
- Si hay una limitación, actualizar `configuration-decisions.md`.

---

## 18. Deployment de Seguridad y Permisos

- Respetar el **mínimo privilegio**.
- Validar **Permission Sets**, **buyer access**, **catálogo restringido**,
  **pricing por buyer/segmento** e **historial/reorder**.
- **No asignar permisos amplios** por rapidez.
- **Probar con un usuario buyer**, no solo admin.
- Las decisiones relevantes **requieren ADR**.

---

## 19. Post-Deployment Validation

- [ ] Storefront accesible.
- [ ] Login funciona.
- [ ] Home funciona.
- [ ] PLP muestra los productos esperados.
- [ ] PDP abre un producto permitido.
- [ ] Un producto restringido no aparece.
- [ ] Pricing correcto.
- [ ] Cart funciona.
- [ ] Checkout funciona según el alcance.
- [ ] Historial funciona (si aplica).
- [ ] Reorder funciona (si aplica).
- [ ] Mobile básico validado.
- [ ] Los errores funcionales muestran mensajes seguros.
- [ ] No hay errores técnicos visibles al buyer.
- [ ] Documentos actualizados.

---

## 20. Rollback Conceptual

- Cada cambio relevante debe tener una **forma conceptual de revertirse**.
- El **rollback de metadata** no es igual que el de **datos**.
- Los cambios de datos pueden requerir un **proceso inverso futuro**.
- Los cambios en **Permission Sets** deben poder revertirse.
- Los cambios en **Experience Builder** pueden requerir **restauración manual**.
- Si el rollback **no es simple**, documentarlo **antes** del deployment.
- Las decisiones críticas pueden **requerir ADR**.

---

## 21. Manejo de Secrets y Configuración Sensible

- **No guardar secretos** en el repositorio.
- **No hardcodear** tokens ni URLs sensibles.
- **Named Credentials** para callouts.
- **Diferenciar** configuración local/dev de la futura productiva.
- **No incluir** credenciales en documentación.
- **No incluir** tokens en logs.
- La **integración real futura** requiere revisión de seguridad.

---

## 22. Estrategia de Ambientes

- Actualmente el proyecto se desarrolla en una **Developer Org**.
- **No asumir** un pipeline multi-org todavía.
- Futuro posible: **scratch org**, **sandbox**, **integration org**,
  **production-like org**.
- Cualquier estrategia multi-org deberá **documentarse** más adelante.
- **No sobredimensionar** el MVP.

---

## 23. Deployment y Datos B2B Commerce

- Productos, categorías, catálogo, pricing y visibilidad pueden requerir **data
  loading**.
- El **deployment de metadata no garantiza** un storefront funcional.
- Los datos deben seguir el **orden conceptual de carga**
  (`data-loading-strategy.md`).
- **Validar dependencias**.
- **Evitar carga manual** sin documentación.
- La **herramienta definitiva** de data loading queda **pendiente** (`DEC-015`).
- Si se adopta una herramienta relevante, puede **requerir ADR**.

---

## 24. Release Notes Internas

Cada release/cambio relevante debería poder resumirse con: qué cambió, por qué,
qué área afecta, qué datos requiere, qué pruebas se hicieron, qué riesgos quedan,
qué documentos se actualizaron y qué decisiones quedan pendientes.

**Plantilla breve:**

```markdown
## Release / Cambio
- Qué cambió:
- Por qué:
- Área afectada:
- Datos requeridos:
- Pruebas realizadas:
- Riesgos pendientes:
- Documentos actualizados:
- Decisiones pendientes:
```

---

## 25. Riesgos de Deployment

- Desplegar **metadata sin datos** necesarios.
- **Confundir data con metadata**.
- Desplegar **permisos excesivos**.
- Romper la **visibilidad** de catálogo.
- Romper el **pricing**.
- Romper el **checkout**.
- Mover cambios **no documentados**.
- **No probar** con buyer user.
- **No validar** mobile.
- **No tener rollback**.
- **Hardcodear** IDs.
- **Hardcodear** URLs/secrets.
- Desplegar **customización no justificada**.
- **No actualizar** ADRs/documentación.

---

## 26. ADRs Relacionados con Deployment

Crear un ADR si:

- Se define un **pipeline CI/CD**.
- Se adopta una **herramienta de data loading**.
- Se define una **estrategia multi-org**.
- Se **automatiza** el deployment de datos Commerce.
- Se introduce una **integración con secrets**.
- Se despliega una **customización crítica**.
- Se adopta una **estrategia de rollback** relevante.
- Se introduce una **Experience Builder deployment strategy** no trivial.

---

## 27. Checklist Final de Deployment

- [ ] ¿Cambio dentro del MVP?
- [ ] ¿Estándar/configuración validado?
- [ ] ¿Metadata identificada?
- [ ] ¿Datos identificados?
- [ ] ¿Dependencias claras?
- [ ] ¿Seguridad revisada?
- [ ] ¿Testing realizado?
- [ ] ¿Buyer user probado si aplica?
- [ ] ¿Mobile probado si aplica?
- [ ] ¿Documentación actualizada?
- [ ] ¿ADR creado si aplica?
- [ ] ¿Rollback conceptual definido?
- [ ] ¿No hay secrets/IDs hardcodeados?
- [ ] ¿Post-deployment validation definida?

---

## 28. Relación con Otros Documentos

- `docs/development/code-review-checklist.md` define la **revisión previa**.
- `docs/development/apex-guidelines.md` define los **criterios Apex**.
- `docs/development/lwc-guidelines.md` define los **criterios LWC**.
- `docs/development/flow-guidelines.md` define los **criterios Flow**.
- `docs/development/integration-guidelines.md` define los **criterios de
  integración**.
- `docs/salesforce/data-loading-strategy.md` define la **estrategia de datos**.
- `docs/salesforce/org-validation-checklist.md` define la **validación de org**.
- `docs/salesforce/configuration-decisions.md` registra las **decisiones**.
- `docs/architecture/limitations-and-assumptions.md` consolida **riesgos y
  supuestos**.
- `adr/` registrará las **decisiones relevantes de deployment**.
