# Guidelines Apex - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define los **criterios y buenas prácticas** para usar Apex en el
proyecto `LvlUp-Wholesale-B2B`: cuándo está justificado, cómo diseñarlo, cómo
probarlo y qué reglas respetar para mantener el MVP simple, mantenible y alineado
con Salesforce B2B Commerce estándar.

Sirve como base para:

- Decidir **cuándo Apex está justificado**.
- Evitar la **sobre-ingeniería**.
- Mantener **código mantenible**.
- Diseñar **servicios para LWC o integraciones**.
- Diseñar lógica **bulk-safe**.
- Diseñar **test classes**.
- Diseñar **mocks** para callouts.
- Mantener coherencia con el enfoque **estándar primero**.

Este documento **no define la implementación Apex concreta del MVP**; los ejemplos
son **conceptuales/ilustrativos**. La prosa va en español; el código, los nombres y
los comentarios en inglés, según la política de `CLAUDE.md`.

---

## 2. Principio Principal para Apex

> **Apex no es la primera opción.**

Orden de evaluación (alineado con `standard-vs-custom-framework.md`):

1. **Salesforce B2B Commerce estándar**.
2. **Experience Builder / configuración**.
3. **Configuración de datos**.
4. **Flow** si es mantenible.
5. **LWC** si hay un gap UX real.
6. **Apex** si hay lógica compleja, integración o necesidad transaccional.
7. **Integración externa** si el dato/proceso vive fuera de Salesforce.

Cualquier uso relevante de Apex debe **poder justificarse** contra el framework
estándar vs custom y, cuando sea una decisión central, registrarse en un **ADR**.

---

## 3. Cuándo Usar Apex

Escenarios válidos (la mayoría, futuros):

- **Callouts REST** futuros (ERP simulado).
- **Transformación** de request/response.
- **Lógica compleja** no mantenible en Flow.
- **Servicios backend** para LWC custom.
- **Validaciones transaccionales** críticas.
- Procesos con **control de errores robusto**.
- **Operaciones bulk**.
- **Orquestación técnica** que Flow no soporta bien.
- **Mocks** de integración (en tests).
- Procesos donde se requiera **testing técnico detallado**.

---

## 4. Cuándo Evitar Apex

- Si el **estándar de B2B Commerce** resuelve el caso.
- Si **Experience Builder** resuelve la experiencia.
- Si la **configuración** de catálogo/pricing/visibilidad cubre la necesidad.
- Si **Flow** lo resuelve de forma clara y mantenible.
- Si se quiere Apex **solo por comodidad**.
- Si se quiere **evitar aprender** una capacidad estándar.
- Si el requerimiento está **fuera del MVP**.
- Si **no existe una test strategy** clara.
- Si **no existe justificación funcional** documentada.

---

## 5. Reglas de Naming

- Clases en **PascalCase**.
- Métodos y variables en **camelCase**.
- Constantes en **UPPER_SNAKE_CASE**.
- Nombres **descriptivos** que reflejen la responsabilidad.
- Evitar nombres genéricos (`Utils`, `Manager`, `Helper`) salvo justificación.
- **Comentarios en inglés**; documentación del proyecto en español.

**Ejemplo recomendado:**

```apex
public with sharing class CommerceCreditService {
    public CreditStatusResult validateCreditStatus(Id buyerAccountId, Decimal orderTotal) {
        // Implementation pending: evaluate standard/config/Flow before Apex
    }
}
```

**Ejemplo a evitar:**

```apex
// Avoid: generic name, unclear responsibility, no sharing declaration
public class Utils {
    public static Object doStuff(Object input) {
        // Unclear scope and intent
    }
}
```

---

## 6. Estructura y Organización del Código

- **Separar responsabilidades**: evitar clases que mezclen UI, datos y lógica.
- Capas conceptuales recomendadas (sin imponer un framework pesado en el MVP):
  - **Service** (`*Service`): lógica de negocio y orquestación.
  - **Selector** (`*Selector`): consultas SOQL aisladas.
  - **Controller** (`*Controller`): punto de entrada para LWC (`@AuraEnabled`).
  - **Callout/Integration** (`*Callout`/`*Client`): llamadas externas.
  - **Mock** (`*Mock`): dobles para tests.
- **Una responsabilidad por clase y método**.
- Mantener las clases **pequeñas y cohesivas**.
- No introducir frameworks complejos salvo que un gap lo justifique (ADR).

---

## 7. Patrones de Diseño Recomendados

- **Service layer** para encapsular la lógica de negocio.
- **Selector pattern** para centralizar SOQL y facilitar el testing.
- **Single Responsibility**: cada clase con un propósito claro.
- **Dependency injection ligera** (interfaces) para poder **mockear** integraciones.
- **DTO/Result objects** (p. ej. `CreditStatusResult`) para devolver datos claros a
  LWC o servicios.
- Evitar **lógica en triggers**: delegar a clases handler/service.
- Mantener el diseño **proporcional al MVP**; no sobre-arquitecturar.

---

## 8. Seguridad en Apex

- Declarar **`with sharing`** por defecto en clases que acceden a datos; usar
  `without sharing` o `inherited sharing` solo con justificación.
- Respetar **CRUD/FLS**: comprobar accesibilidad o usar
  `Security.stripInaccessible` / `WITH SECURITY_ENFORCED` según el caso.
- **No confiar solo en la UI**: la lógica de acceso/visibilidad debe sostenerse en
  backend (coherente con `security-model.md`).
- **Evitar SOQL injection**: usar binding de variables, nunca concatenar entrada de
  usuario en consultas dinámicas.
- **No exponer datos** de otra cuenta; respetar el aislamiento por Buyer Account.
- **No exponer errores técnicos** al buyer; devolver mensajes funcionales.
- **No hardcodear** secretos ni endpoints (usar Named Credentials).

---

## 9. Bulkificación y Governor Limits

- Diseñar **siempre para bulk**: asumir colecciones, no registros sueltos.
- **No** poner SOQL ni DML **dentro de bucles**.
- **Consultar y actualizar en colecciones** (listas/mapas).
- Respetar los **governor limits** (SOQL, DML, CPU, heap, callouts).
- Usar **maps** para relacionar registros eficientemente.
- Considerar **asíncrono** (Queueable/Batch/Future) solo si el caso lo requiere.
- Probar con **volúmenes representativos** en los tests.

---

## 10. Manejo de Errores y Excepciones

- Usar **excepciones personalizadas** (`*Exception`) para errores de negocio.
- **No silenciar** excepciones (`catch` vacío).
- Diferenciar **error funcional** (mensaje al buyer) de **error técnico** (traza).
- Devolver **resultados claros** a LWC (objetos result, no excepciones crudas).
- Registrar el error de forma **controlada** (ver §13), sin exponer detalles.
- Mantener la **consistencia transaccional** (Database methods / savepoints cuando
  aplique).

---

## 11. Callouts e Integración

- **No hay callouts en el MVP**; esta sección aplica a la fase de integración.
- Usar **Named Credentials** para endpoint y autenticación; **no** hardcodear.
- Aislar las llamadas en una **capa de integración** (`*Callout`/`*Client`).
- Diseñar para **timeouts y fallos**; definir comportamiento (degradar/reintentar).
- **Mockear** los callouts en tests con `HttpCalloutMock` (ver §12).
- Mapear request/response a **DTOs** internos.
- Coherente con `integration-architecture.md` (REST, JSON, Postman Mock Server,
  contratos pendientes). Introducir Apex de integración es una **decisión de ADR**.

---

## 12. Testing de Apex

- **Toda clase Apex requiere test classes** con asserts significativos (no solo
  cobertura por cobertura).
- Usar **`@isTest`** y datos creados en el test (idealmente **`@testSetup`**).
- **Nunca** usar `SeeAllData=true`.
- Envolver la lógica bajo prueba en **`Test.startTest()` / `Test.stopTest()`**.
- Probar **casos positivos, negativos y límite** (stock, crédito, visibilidad).
- Probar en **bulk** (colecciones), no solo un registro.
- Probar **seguridad** con **`System.runAs`** (acceso por usuario/perfil).
- **Mockear callouts** con `HttpCalloutMock` / `Test.setMock`; mockear dependencias
  con interfaces o `StubProvider`.
- Asserts con **mensajes claros** del comportamiento esperado.

**Ejemplo conceptual de mock de callout:**

```apex
@isTest
private class CommerceStockClientTest {
    private class StockCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"items":[{"sku":"LVL-CON-001","available":true}]}');
            return res;
        }
    }
    // @isTest method would set Test.setMock and assert the mapped result
}
```

---

## 13. Logging y Trazabilidad

- Registrar errores de forma **controlada** y **sin datos sensibles**.
- **No** exponer stack traces al buyer.
- Registrar **correlación funcional** cuando aplique (cuenta, pedido, carrito,
  integración).
- Evitar **debug logs ruidosos** en producción.
- La estrategia de logging detallada se definirá más adelante (decisión pendiente).

---

## 14. Documentación del Código (ApexDoc)

- Documentar clases y métodos públicos con **ApexDoc** (en inglés).
- Describir **propósito, parámetros y retorno**.
- Mantener la documentación **junto al código** y actualizada.
- La documentación funcional/de negocio vive en `docs/` (en español); el código se
  autodocumenta en inglés.

---

## 15. Anti-patrones a Evitar

- Apex donde **el estándar/configuración/Flow** ya resuelve.
- **SOQL/DML en bucles**.
- Clases **"god object"** (`Utils`, `Manager` que lo hacen todo).
- **Lógica en triggers** sin handler.
- **`catch` vacíos** o silenciar errores.
- **Hardcodear** IDs, endpoints o secretos.
- **`SeeAllData=true`** en tests.
- Tests **sin asserts** (solo cobertura).
- Ignorar **CRUD/FLS** y `with sharing`.
- Customizar **antes de validar** el estándar en la org.

---

## 16. Checklist antes de Escribir Apex

- [ ] ¿Lo resuelve el estándar de B2B Commerce?
- [ ] ¿Lo resuelve Experience Builder o la configuración?
- [ ] ¿Lo resuelve Flow de forma mantenible?
- [ ] ¿Existe una necesidad funcional clara y documentada?
- [ ] ¿Está dentro del MVP?
- [ ] ¿Hay una test strategy definida?
- [ ] ¿Se respetan seguridad (sharing, CRUD/FLS) y bulkificación?
- [ ] ¿Las integraciones están aisladas y mockeables?
- [ ] ¿Requiere un ADR?

---

## 17. Relación con ADRs

Crear un ADR cuando:

- Se introduce **Apex para lógica central** (approval, credit, stock, checkout).
- Se introduce **Apex de integración** (callouts).
- Se crea un **objeto custom** asociado a la lógica Apex.
- Se adopta un **framework/patrón** de Apex relevante.
- Se introduce una **excepción** al principio estándar primero.

---

## 18. Supuestos y Decisiones Pendientes

**Supuestos.**

- En el MVP, Apex se usa **solo si** el estándar/configuración/Flow no alcanzan.
- Las integraciones (y por tanto los callouts) son **futuras**.
- Los ejemplos de este documento son **conceptuales**.

**Decisiones pendientes.**

- Si approval/credit/stock requerirán Apex (`DEC-014`, `DEC-009`, gaps de la org).
- Estrategia de logging.
- Framework/patrón de Apex si el proyecto crece.
- Contratos REST y momento de introducir callouts.

---

## 19. Relación con Otros Documentos

- `docs/architecture/standard-vs-custom-framework.md` define **cuándo Apex está
  justificado**.
- `docs/architecture/solution-architecture.md` enmarca la **capa de automatización**.
- `docs/architecture/integration-architecture.md` define los **callouts y la
  integración** futura.
- `docs/salesforce/security-model.md` define la **seguridad** que Apex debe
  respetar.
- `docs/salesforce/configuration-decisions.md` registra **cuándo se escala a Apex**.
- Este documento define las **guidelines de desarrollo Apex**.
- `docs/development/flow-guidelines.md` deberá definir el **criterio Flow vs Apex**.
- `docs/development/lwc-guidelines.md` deberá definir los **servicios Apex para LWC**.
- `docs/testing/` deberá definir la **estrategia de pruebas** detallada.
- `adr/` registrará las **decisiones de uso de Apex**.
