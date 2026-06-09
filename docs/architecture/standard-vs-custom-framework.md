# Framework Estándar vs Custom - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define el **marco de decisión** para elegir entre configuración
estándar, automatización declarativa, desarrollo custom e integración externa en
el proyecto `LvlUp-Wholesale-B2B`. Establece criterios arquitectónicos, no
implementación concreta.

Sirve como base para:

- Decisiones de arquitectura.
- Evaluación de requerimientos.
- Prevención de sobre-ingeniería.
- ADRs.
- Diseño de agentes de IA.
- Revisión de soluciones técnicas.
- Control de scope.
- Testing y mantenibilidad.

Este documento **no reemplaza la documentación oficial de Salesforce** ni define la
implementación técnica final. Aplica el principio rector del proyecto:
*Configuration first, customization only when justified*.

---

## 2. Principio Arquitectónico Principal

> **Configuration first, customization only when justified.**

En este proyecto significa evaluar las opciones en este orden, deteniéndose en la
primera que resuelva el requerimiento de forma mantenible:

1. Primero, **capacidades estándar de Salesforce B2B Commerce**.
2. Luego, **configuración en Experience Builder**.
3. Luego, **Flow** si es mantenible.
4. Luego, **LWC** si la UI estándar no cubre la necesidad.
5. Luego, **Apex** si la lógica excede las capacidades declarativas.
6. Luego, **integración externa** si la información no vive en Salesforce o debe
   sincronizarse con un sistema externo.

Cada nivel adicional añade coste de mantenimiento, riesgo y complejidad; por eso
solo se desciende cuando el nivel anterior es insuficiente y se puede justificar.

---

## 3. Orden de Decisión Recomendado

| Paso | Pregunta | Opción preferida | Cuándo avanzar al siguiente nivel | Riesgo si se omite |
| --- | --- | --- | --- | --- |
| 1 | ¿Se resuelve con estándar de B2B Commerce? | Estándar B2B Commerce | El estándar no cubre el caso | Reinventar lo que ya existe |
| 2 | ¿Se resuelve con Experience Builder? | Configuración de experiencia | La configuración no alcanza | UI custom innecesaria |
| 3 | ¿Se resuelve con datos/catálogo/pricing/Buyer Groups? | Configuración de datos | Los datos no bastan | Lógica donde debería haber datos |
| 4 | ¿Se resuelve con Flow de forma mantenible? | Flow declarativo | La lógica es demasiado compleja | Apex prematuro |
| 5 | ¿Requiere LWC por una necesidad UX real? | LWC custom justificado | La UI estándar es insuficiente | Sobre-ingeniería de UI |
| 6 | ¿Requiere Apex por lógica/transaccionalidad/límites? | Apex justificado | Flow no es viable | Apex evitable y costoso |
| 7 | ¿Requiere integración externa? | Integración (simulada primero) | El dato vive fuera de Salesforce | Acoplamiento externo prematuro |
| 8 | ¿Requiere una decisión registrada en ADR? | Crear ADR | La decisión es relevante | Decisiones no trazables |
| 9 | ¿Está dentro del MVP? | Respetar el alcance | El caso es futuro | Scope creep |
| 10 | ¿Cómo se prueba y mantiene? | Definir testing/mantenibilidad | — | Deuda técnica oculta |

---

## 4. Nivel 1: Salesforce B2B Commerce Estándar

**Cuándo preferirlo.** Catálogo, categorías, storefront, PLP/PDP estándar, carrito
estándar, checkout estándar cuando cubra el caso, Buyer Groups, visibilidad
estándar, pricing estándar cuando sea suficiente, e historial/reorder si están
disponibles en las capacidades estándar.

- **Beneficios.** Menor coste, mantenibilidad, upgradeability, alineación con el
  roadmap de la plataforma.
- **Riesgos.** Forzar el estándar a casos que no encajan; desconocer sus límites.
- **Criterios de aceptación.** El estándar cubre el comportamiento esperado en los
  flujos y reglas documentados, sin contradecir la UX.
- **Señales de que el estándar es suficiente.** El caso es común en B2B Commerce;
  existe un componente o capacidad nativa; la configuración cubre las variantes.
- **Señales de que el estándar no alcanza.** Necesidad UX crítica no cubierta;
  lógica de negocio no expresable por configuración; comportamiento fuera del
  modelo estándar.

Las capacidades exactas deben **validarse en la org** antes de decidir; este
documento fija el criterio, no la lista de funcionalidades.

---

## 5. Nivel 2: Experience Builder / Configuración

**Cuándo preferirlo.** Layouts, páginas, componentes estándar, navegación, Home,
organización visual, configuración de la experiencia y ajustes de contenido.

- **Beneficios.** Cambios declarativos, rápidos y mantenibles; sin código.
- **Límites.** Personalización acotada a los componentes y opciones disponibles.
- **Riesgos.** Intentar lograr con configuración algo que requiere lógica o UI
  específica.
- **Cuándo documentar una limitación.** Cuando un requerimiento UX no se puede
  configurar; debe registrarse antes de proponer custom.
- **Cuándo considerar LWC custom.** Solo tras confirmar que Experience Builder no
  cubre la necesidad funcional (ver nivel 5).

---

## 6. Nivel 3: Configuración de Datos B2B Commerce

**Decisiones relacionadas con datos:** Product Catalog, Product Categories,
Product2, Price Books, Buyer Groups, entitlements/visibilidad, comportamiento
basado en Account y datos de prueba del MVP.

> **Importante:** el catálogo, los productos, los precios y los entitlements son
> **datos/registros**, no necesariamente metadata desplegable. No deben mezclarse
> en el mismo flujo el deploy de metadata y la migración de registros.

- **Beneficios.** Resolver con datos/configuración evita código y mantiene la
  flexibilidad de negocio.
- **Riesgos de mezclar metadata y data.** Despliegues frágiles, entornos
  inconsistentes y dificultad de reproducción.
- **Necesidad futura.** Documentar una **estrategia de carga de datos** (catálogo,
  pricing, Buyer Groups) en `docs/salesforce/` cuando el proyecto llegue a esa
  fase.

---

## 7. Nivel 4: Flow

**Cuándo usar Flow.** Automatizaciones simples o moderadas; procesos declarativos
mantenibles; reglas de aprobación simples si aplica; notificaciones o
actualizaciones sencillas; orquestación de pasos de negocio sin lógica compleja.

**Cuándo no usar Flow.** Lógica compleja difícil de mantener; alto volumen con
riesgo de límites; integraciones complejas; transformaciones de datos complejas;
control transaccional avanzado; testing técnico complejo.

- **Flow vs Apex.** Flow si es declarativo y mantenible; Apex si hay complejidad,
  transaccionalidad o límites (ver nivel 6).
- **Riesgos de sobredimensionar Flow.** Flujos enormes e ilegibles, difíciles de
  depurar y mantener.
- **Reglas de mantenibilidad.** Mantener los Flows pequeños, con responsabilidad
  clara y documentados.

---

## 8. Nivel 5: LWC Custom

**Cuándo considerarlo.** La experiencia estándar no cubre una necesidad UX crítica;
se requiere UI no disponible en componentes estándar; interacción avanzada en
PLP, PDP, carrito o checkout; visualización especial de stock, pricing, aprobación
o reorder; con justificación clara desde UX y negocio.

**Cuándo evitarlo.** Solo por estética; para replicar algo ya estándar; sin validar
primero Experience Builder; si aumenta el mantenimiento sin valor funcional; si
compromete la upgradeability.

**Checklist antes de crear un LWC.**

- [ ] Se confirmó que el estándar y Experience Builder no cubren la necesidad.
- [ ] Existe una necesidad UX/negocio concreta y documentada.
- [ ] Se evaluó el impacto en mantenimiento y upgradeability.
- [ ] Se evaluó el comportamiento mobile-first.
- [ ] Se decidió si requiere ADR.

- **Riesgos.** Deuda técnica, coste de mantenimiento, ruptura de upgrades.
- **Criterios de aceptación.** Resuelve una necesidad real y se integra con la
  experiencia estándar.
- **Relación con UX.** Debe alinearse con `docs/ux/` (principios, journey,
  guidelines y estados).

---

## 9. Nivel 6: Apex

**Cuándo usar Apex.** Lógica compleja; integraciones REST/SOAP; transformación de
datos; operaciones transaccionales; validaciones no viables en Flow; servicios
para LWC; control de errores robusto; testing avanzado.

**Cuándo evitar Apex.** Si Flow/configuración resuelve el caso; si solo se busca
evitar aprender la configuración estándar; si la lógica puede mantenerse
declarativamente; si añade complejidad innecesaria al MVP.

- **Apex vs Flow.** Apex cuando hay complejidad/transaccionalidad/límites; Flow
  para lo declarativo y mantenible.
- **Apex vs estándar.** Nunca sustituir una capacidad estándar suficiente por Apex.
- **Riesgos de governor limits.** Diseñar para bulk y respetar los límites de la
  plataforma.
- **Test classes.** Obligatorias, con cobertura significativa y asserts útiles.
- **Mocks para integraciones.** Necesarios para aislar callouts en los tests.

---

## 10. Nivel 7: Integraciones Externas

**Cuándo considerarlas.** Stock externo, pricing externo, crédito del cliente,
estado de pedidos, facturas, ERP simulado y, en general, sistemas que no viven en
Salesforce.

**Enfoque del proyecto.**

- El **ERP real está fuera del MVP**.
- La integración será **simulada a futuro** vía REST / Postman Mock Server.
- **Named Credentials** cuando aplique.
- **Contratos request/response documentados**.
- **Callouts** solo cuando la fase lo requiera.

- **Riesgos.** Acoplamiento externo prematuro; dependencia de sistemas no
  disponibles; complejidad de errores y latencia.
- **Decisiones pendientes.** Fuente real de stock/crédito; momento de introducir la
  simulación.
- **Cuándo crear ADR.** Al decidir integrar, su patrón y sus contratos.
- **Cuándo usar mocks.** Siempre que se prueben callouts o no exista el sistema
  real.

---

## 11. Matriz de Decisión por Tipo de Requerimiento

| Tipo de requerimiento | Primera opción | Segunda opción | Custom permitido si… | ADR requerido si… | Ejemplo en el proyecto |
| --- | --- | --- | --- | --- | --- |
| Catálogo | Estándar + datos | Experience Builder | UX crítica no cubierta | Se descarta el estándar | Product Catalog del MVP |
| Categorías | Estándar + datos | Experience Builder | Jerarquía no soportada | Modelo no estándar | Categorías de catálogo |
| PLP | Estándar / Experience Builder | LWC | Interacción/visual no cubierta | Se sustituye la PLP estándar | Listado por categoría |
| PDP | Estándar / Experience Builder | LWC | Datos B2B no representables | Se sustituye la PDP estándar | Detalle con SKU y stock |
| Carrito | Estándar | LWC / Flow | Interacción avanzada real | Carrito custom | Carrito del MVP |
| Checkout | Estándar | Flow / Apex | Validación no estándar | Checkout custom | Checkout básico |
| Pricing | Datos (Price Books/Buyer Groups) | Flow | Lógica no expresable por datos | Motor de pricing custom | Pricing por segmento (`PR-*`) |
| Visibilidad | Buyer Groups / entitlements | Configuración | Regla no soportada | Visibilidad custom | Catálogo restringido (`PV-*`) |
| Stock | Estándar / funcional | Integración simulada | Necesidad real no cubierta | Integración de stock | Stock insuficiente |
| Aprobación por importe | Estándar / Flow | Apex | Flow no alcanza | Aprobación custom | Aprobación por umbral (`BR-APPROVAL-*`) |
| Crédito | Flow / Apex | Integración simulada | Regla compleja real | Validación/integración de crédito | Validación de crédito (`BR-CREDIT-*`) |
| Reorder | Estándar | LWC / Apex | No disponible en estándar | Reorder custom | Reorder desde historial |
| Historial | Estándar | LWC | Presentación especial | Sustituir el estándar | Historial de pedidos |
| Quote request | Estándar / Flow | Apex | Alcance lo exige | Automatización de quoting | Solicitud de cotización |
| Home | Experience Builder | LWC | Componente no disponible | Home custom relevante | Home orientada a recurrencia |
| Estados empty/error/loading | Estándar / Experience Builder | LWC | Estado no soportado | Patrón de estados custom | Mensajes de `empty-error-loading-states.md` |

---

## 12. Checklist de Justificación Custom

Obligatorio antes de proponer LWC, Apex o integración:

- [ ] ¿Se revisó el estándar de Salesforce B2B Commerce?
- [ ] ¿Se revisó Experience Builder?
- [ ] ¿Se revisó la configuración de datos?
- [ ] ¿Se revisó Flow?
- [ ] ¿Cuál es la necesidad funcional concreta?
- [ ] ¿Qué problema de negocio resuelve?
- [ ] ¿Qué alternativa estándar se descartó y por qué?
- [ ] ¿Cuál es el impacto en mantenimiento?
- [ ] ¿Cuál es el impacto en testing?
- [ ] ¿Cuál es el impacto en seguridad?
- [ ] ¿Está dentro del MVP?
- [ ] ¿Requiere ADR?
- [ ] ¿Puede implementarse más tarde?

---

## 13. Criterios para Crear un ADR

Crear un ADR cuando:

- Se decide usar **LWC custom** para un comportamiento relevante.
- Se decide usar **Apex** para lógica central.
- Se decide **integrar** con un sistema externo.
- Se decide **no usar** una capacidad estándar importante.
- Se introduce una **excepción** al principio estándar primero.
- Se **cambia el alcance** del MVP.
- Se adopta un **patrón de arquitectura** relevante.

---

## 14. Riesgos Arquitectónicos

- **Customizar demasiado pronto**.
- Usar **Apex para evitar configuración**.
- Usar **Flow para lógica demasiado compleja**.
- Crear **LWC por estética**.
- **Mezclar data y metadata**.
- Implementar **integración real antes de necesitarla**.
- **No documentar** decisiones.
- **No probar** el impacto en mobile.
- **No considerar** permisos/seguridad.
- **Romper la upgradeability** de Salesforce B2B Commerce.

---

## 15. Aplicación al MVP

- **Catálogo:** estándar/configuración primero.
- **PLP/PDP:** estándar/Experience Builder primero.
- **Carrito/checkout:** estándar primero.
- **Pricing/visibilidad:** capacidades estándar/configuración (Price Books, Buyer
  Groups, entitlements) primero.
- **Stock:** funcional/documentado, con integración simulada a futuro.
- **Aprobación/crédito:** documentar el flujo y evaluar estándar/Flow antes de Apex.
- **UX custom:** solo si una necesidad crítica no está cubierta.
- **Integraciones:** fuera del MVP real, simuladas a futuro.

---

## 16. Supuestos Actuales

- La Developer Org tiene B2B Commerce y un Site activo.
- Se prioriza el **aprendizaje del estándar**.
- El MVP **no debe sobredimensionarse**.
- La **integración ERP real está fuera**.
- El **estándar de Salesforce debe evaluarse antes** que el custom.
- Los datos de catálogo/pricing pueden requerir una **estrategia de carga**
  separada.
- Algunas capacidades deben **validarse en la org** antes de decidir.

---

## 17. Decisiones Pendientes

- Capacidades estándar realmente disponibles en la org.
- Componentes estándar disponibles para PLP/PDP/carrito/checkout.
- Nivel de configuración posible en Experience Builder.
- Estrategia final de Buyer Groups.
- Estrategia final de pricing.
- Si la aprobación requiere Flow, configuración estándar o custom.
- Si el crédito se documenta, simula o automatiza.
- Cuándo implementar el Postman Mock Server.
- Qué escenarios requerirán ADR.

---

## 18. Relación con Otros Documentos

- `PROJECT_CONTEXT.md` define el **contexto general** del proyecto.
- `docs/business/` define **negocio, reglas, flujos y alcance**.
- `docs/ux/` define la **experiencia y el comportamiento esperado**.
- Este documento define el **framework de decisión estándar vs custom**.
- `docs/architecture/solution-architecture.md` deberá definir la **arquitectura
  general**.
- `docs/architecture/integration-architecture.md` deberá definir la **integración**.
- `docs/salesforce/` deberá documentar las **capacidades y la configuración**.
- `adr/` registrará las **decisiones relevantes**.
- `agents/` deberá usar este framework como **criterio para sus recomendaciones**.
- `evals/` podrá **evaluar** si los agentes respetan este framework.
