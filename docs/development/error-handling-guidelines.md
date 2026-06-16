# Guidelines de Manejo de Errores - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define cómo deben **clasificarse, manejarse, comunicarse y trazarse**
los errores en el proyecto `LvlUp-Wholesale-B2B`, de forma transversal: errores
funcionales, técnicos, de seguridad, de datos, de configuración, de integración, y
en Apex, LWC, Flow, carrito, checkout, pricing, visibilidad, stock, crédito y
aprobación.

Sirve como base para: UX del storefront, Apex, LWC, Flow, integraciones futuras,
testing, seguridad, code review, ADRs y soporte/debugging.

Este documento **no define una implementación concreta de logging ni una clase de
errores definitiva**. La prosa va en español; los códigos de error, clases,
métodos, DTOs y comentarios en inglés.

---

## 2. Principios Generales

- **Diferenciar** errores funcionales de errores técnicos.
- **No exponer** stack traces al buyer.
- **No exponer** detalles internos de Salesforce.
- **No exponer** detalles de seguridad, permisos o integración.
- Los mensajes visibles deben ser **claros y accionables**.
- El buyer debe entender **qué ocurrió y qué puede hacer**.
- Los errores técnicos deben ser **trazables internamente**.
- **No silenciar** errores sin justificación.
- **No usar errores genéricos** cuando hay una causa funcional clara.
- Mantener **consistencia** entre PLP, PDP, carrito, checkout, historial y reorder.
- El manejo de errores complejo o persistente puede **requerir ADR**.

---

## 3. Clasificación de Errores

- **Error funcional.** Condición esperada del negocio que impide o condiciona una
  acción (stock insuficiente, producto no visible, precio no disponible, crédito
  bloqueado, requiere aprobación, producto no disponible en reorder).
- **Error técnico.** Fallo inesperado o de plataforma (exception Apex, timeout,
  response inválida, error de configuración/permisos/parsing, error desconocido).
- **Error de seguridad.** Intento de acceder a datos o acciones no permitidas
  (producto restringido, pedido de otra cuenta, pricing no autorizado).
- **Error de datos.** Datos incompletos o mal relacionados (producto sin categoría,
  sin pricing, buyer sin Buyer Group, usuario sin buyer account).
- **Error de configuración.** Configuración incompleta o incorrecta (storefront
  incompleto, Permission Set faltante, componente no configurado, página no
  disponible).

| Tipo de error | Definición | Ejemplo | Visible para buyer | Trazabilidad interna | Prioridad MVP |
| --- | --- | --- | --- | --- | --- |
| Funcional | Condición de negocio esperada | Stock insuficiente | Sí (mensaje funcional) | Opcional | Alta |
| Técnico | Fallo inesperado/plataforma | Timeout de integración | Mensaje genérico seguro | Sí | Alta |
| Seguridad | Acceso no permitido | Producto restringido | Mensaje neutro/seguro | Sí (evento a revisar) | Alta |
| Datos | Datos inconsistentes | Producto sin pricing | Indirecto/seguro | Sí | Media |
| Configuración | Configuración incompleta | Storefront no listo | No (idealmente) | Sí | Media |

---

## 4. Mensajes para Buyer

- Usar **lenguaje claro**; evitar tecnicismos.
- Explicar la **causa funcional** cuando sea seguro.
- Proponer una **acción siguiente**.
- **No culpar** al usuario.
- **No revelar** lógica interna, IDs técnicos, stack traces ni nombres de
  clases/Flows/endpoints.
- **Diferenciar** error temporal de bloqueo funcional.

**Formato recomendado:** 1) qué ocurrió, 2) qué significa, 3) qué puede hacer el
buyer.

**Ejemplo:** "Este producto no tiene stock suficiente para la cantidad solicitada.
Ajusta la cantidad o revisa productos alternativos."

---

## 5. Mensajes Internos / Técnicos

- Deben **ayudar al debugging** con contexto suficiente.
- **No** contener datos sensibles innecesarios.
- **Separar** causa, contexto y acción.
- **Correlacionables** con buyer account, cart, order o request cuando aplique.
- **Evitar ruido** excesivo.

Información útil (conceptual, no implementación): `errorCode`, `errorType`,
`context`, `buyerAccountId` (si es seguro), `cartId`, `orderId`,
`externalServiceName`, `timestamp`, `correlationId` (futuro).

---

## 6. Códigos de Error Conceptuales

Convención conceptual (UPPER_SNAKE_CASE, coherente con `naming-conventions.md`); no
es implementación definitiva.

Prefijos: `FUNC_` (funcional), `TECH_` (técnico), `SEC_` (seguridad), `DATA_`
(datos), `CONFIG_` (configuración), `INT_` (integración).

**Ejemplos:** `FUNC_INSUFFICIENT_STOCK`, `FUNC_APPROVAL_REQUIRED`,
`FUNC_CREDIT_BLOCKED`, `SEC_PRODUCT_NOT_VISIBLE`, `DATA_MISSING_PRICE`,
`CONFIG_STOREFRONT_NOT_READY`, `INT_TIMEOUT`, `INT_INVALID_RESPONSE`,
`TECH_UNEXPECTED_ERROR`.

*(Códigos conceptuales; deben validarse antes de implementarse.)*

---

## 7. Manejo de Errores en PLP y Search

| Escenario | Mensaje para buyer | Acción | ¿Bloquea? | Trazabilidad | Estado |
| --- | --- | --- | --- | --- | --- |
| Sin productos visibles | "No hay productos disponibles en esta categoría para tu cuenta." | Explorar otras categorías | No | No | MVP |
| Sin resultados de búsqueda | "No encontramos productos para tu búsqueda." | Revisar términos | No | No | MVP |
| Error cargando productos | "No pudimos cargar los productos. Inténtalo de nuevo." | Reintentar | No (degrada) | Sí (`TECH_`) | MVP |
| Producto restringido | (no aparece) | — | — | Sí si hay acceso directo (`SEC_`) | MVP |
| Pricing no disponible | (evitar precio ambiguo) | Reintentar/volver | No | Sí (`DATA_`) | MVP |
| Stock no disponible | Indicador de no disponibilidad | Ver alternativas | No | Opcional | MVP |

---

## 8. Manejo de Errores en PDP

| Escenario | Mensaje para buyer | Acción | ¿Bloquea? | Trazabilidad | Estado |
| --- | --- | --- | --- | --- | --- |
| Producto no visible | "Este producto no está disponible para tu cuenta." | Volver al catálogo | Sí (compra) | Sí (`SEC_`) | MVP |
| Producto no disponible | "Producto no disponible actualmente." | Ver alternativas | Sí (compra) | Opcional | MVP |
| Producto sin pricing | "El precio no está disponible en este momento." | Reintentar/volver | Sí (compra) | Sí (`DATA_`) | MVP |
| Stock insuficiente | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad | Condiciona | Opcional | MVP |
| Cantidad inválida | "Introduce una cantidad válida." | Corregir cantidad | Sí (acción) | No | MVP |
| Error al agregar al carrito | "No pudimos añadir el producto. Inténtalo de nuevo." | Reintentar | Sí (acción) | Sí (`TECH_`) | MVP |
| Error técnico al cargar PDP | "No pudimos cargar el producto. Inténtalo de nuevo." | Reintentar | Sí | Sí (`TECH_`) | MVP |

---

## 9. Manejo de Errores en Cart

| Escenario | Mensaje para buyer | Acción | ¿Continuar? | Trazabilidad | Estado |
| --- | --- | --- | --- | --- | --- |
| Producto ya no visible | "Este producto ya no está disponible para tu cuenta." | Eliminar la línea | Con los válidos | Sí (`SEC_`) | MVP |
| Producto ya no disponible | "Este producto ya no está disponible." | Eliminar/alternativa | Con los válidos | Opcional | MVP |
| Pricing actualizado | "El precio de algunos productos se ha actualizado." | Revisar antes de confirmar | Sí | Opcional | MVP |
| Precio no disponible | "El precio no está disponible en este momento." | Reintentar | Bloquea la línea | Sí (`DATA_`) | MVP |
| Stock insuficiente | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad | Condiciona | Opcional | MVP |
| Cantidad inválida | "Introduce una cantidad válida." | Corregir | Sí | No | MVP |
| Error al modificar/eliminar | "No pudimos actualizar tu carrito. Inténtalo de nuevo." | Reintentar | Sí | Sí (`TECH_`) | MVP |
| Error al cargar carrito | "No pudimos cargar tu carrito. Inténtalo de nuevo." | Reintentar | — | Sí (`TECH_`) | MVP |

---

## 10. Manejo de Errores en Checkout

Los **pagos, tax y shipping reales están fuera del MVP**.

| Escenario | Mensaje para buyer | Acción | Efecto | Trazabilidad | Estado |
| --- | --- | --- | --- | --- | --- |
| Producto no autorizado | "Algunos productos ya no son válidos para este pedido." | Volver al carrito | Bloquea confirmación | Sí (`SEC_`) | MVP |
| Pricing no vigente | "El precio de algunos productos se ha actualizado." | Revisar antes de confirmar | Bloquea hasta revisar | Sí (`DATA_`) | MVP |
| Crédito bloqueado | "No es posible confirmar el pedido por el estado de crédito de tu cuenta." | Contacto comercial | Bloquea confirmación | Sí (`FUNC_`) | MVP |
| Crédito excedido | "El importe del pedido supera el crédito disponible de tu cuenta." | Ajustar/contactar | Bloquea/condiciona | Sí (`FUNC_`) | MVP |
| Stock insuficiente | "Algunos productos no tienen stock suficiente para la cantidad solicitada." | Ajustar/volver | Bloquea confirmación | Opcional | MVP |
| Requiere aprobación | "Este pedido supera el importe permitido y requiere aprobación." | Enviar solicitud | Genera solicitud pendiente | Sí (`FUNC_`) | MVP |
| Error funcional | "No pudimos completar el pedido. Revisa los avisos." | Revisar | Bloquea | Sí | MVP |
| Error técnico inesperado | "Ocurrió un problema al procesar tu pedido. Inténtalo de nuevo." | Reintentar | Bloquea | Sí (`TECH_`) | MVP |
| Sesión expirada | "Tu sesión ha caducado. Inicia sesión de nuevo." | Reautenticar | Bloquea | Sí | MVP |

---

## 11. Manejo de Errores en Orders, Historial y Reorder

| Escenario | Mensaje para buyer | Acción | Efecto | Trazabilidad | Estado |
| --- | --- | --- | --- | --- | --- |
| Sin pedidos anteriores | "Todavía no tienes pedidos." | Ir al catálogo | No bloquea | No | MVP |
| Error al cargar historial | "No pudimos cargar tu historial. Inténtalo de nuevo." | Reintentar | Degrada | Sí (`TECH_`) | MVP |
| Pedido no disponible | "Este pedido no está disponible." | Volver al historial | No bloquea | Sí (`SEC_`/`DATA_`) | MVP |
| Producto anterior no visible | "Algunos productos ya no están disponibles para tu cuenta." | Buscar alternativa | Reorder parcial | Sí (`SEC_`) | MVP |
| Producto anterior sin pricing | "El precio de algunos productos se ha actualizado." | Revisar | Reorder parcial | Sí (`DATA_`) | MVP |
| Producto anterior sin stock | "Algunos productos no tienen stock suficiente." | Ajustar | Reorder parcial | Opcional | MVP |
| Reorder parcial | "Algunos productos no se pudieron añadir." | Revisar y continuar | Continúa con válidos | Opcional | MVP |
| Error al iniciar reorder | "No pudimos preparar el reorder. Inténtalo de nuevo." | Reintentar | Degrada | Sí (`TECH_`) | MVP |

---

## 12. Manejo de Errores en Apex

- **No** usar `catch` vacío.
- **No** atrapar `Exception` genérica sin manejo claro.
- **Diferenciar** errores esperados de inesperados.
- Convertir errores técnicos en **respuestas seguras** para la UI.
- **No** devolver `e.getMessage()` directamente al buyer.
- Usar **excepciones custom** solo si están justificadas.
- **Registrar contexto** cuando sea seguro.
- Métodos **pequeños** y con responsabilidad clara.
- Los **tests deben cubrir** los errores.

**Ejemplo a evitar:**

```apex
try {
    // ...
} catch (Exception e) {
    // Avoid: empty catch swallows the error
}
// Avoid: leaking technical detail to the UI
// throw new AuraHandledException(e.getMessage());
```

**Ejemplo recomendado (conceptual):**

```apex
try {
    return stockClient.getStockBySku(skus);
} catch (CalloutException e) {
    // Log technical detail internally; return a safe functional result
    Logger.error('INT_TIMEOUT', e); // conceptual logging
    return StockResult.unavailable();
}
```

---

## 13. Manejo de Errores en LWC

- Mostrar **errores funcionales claros**.
- Manejar **loading, empty, error y validation states**.
- **No** mostrar errores técnicos crudos.
- Permitir **retry** cuando aplique.
- **Bloquear acciones críticas** cuando falte validación.
- **No** ocultar errores silenciosamente.
- **No** usar `console.log` como estrategia de manejo.
- **No** exponer datos sensibles en el browser.

---

## 14. Manejo de Errores en Flow

- Usar **fault paths** cuando aplique.
- **No** dejar Flows sin salida controlada.
- Mensajes visibles **claros**; **no** exponer detalles técnicos.
- **Documentar** qué ocurre en los errores.
- Si el manejo se vuelve complejo, **evaluar Apex**.
- Si el Flow **bloquea checkout** o altera pricing/visibilidad, puede **requerir
  ADR**.

---

## 15. Manejo de Errores en Integraciones

Errores **futuros** (fase de integración). Mensajes al buyer **funcionales y
seguros**, no técnicos.

| Tipo de error | Mensaje buyer | Acción | Retry | Logging | ¿Bloquea checkout? | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| Timeout | "No pudimos completar la operación. Inténtalo de nuevo." | Reintentar | Limitado | Sí (`INT_TIMEOUT`) | Si es validación crítica | Futuro |
| HTTP 400 | "No pudimos procesar la solicitud." | Revisar/volver | No | Sí (`INT_`) | Según caso | Futuro |
| HTTP 401/403 | "No pudimos completar la operación." | Reintentar más tarde | No | Sí (`SEC_`/`INT_`) | Sí | Futuro |
| HTTP 404 | "La información no está disponible." | Volver | No | Sí (`INT_`) | Según caso | Futuro |
| HTTP 500 | "El servicio no está disponible ahora." | Reintentar más tarde | Limitado | Sí (`INT_`) | Si es crítica | Futuro |
| Servicio no disponible | "El servicio no está disponible ahora." | Reintentar más tarde | Limitado | Sí (`INT_`) | Si es crítica | Futuro |
| Response inválida | "No pudimos completar la operación." | Reintentar | No | Sí (`INT_INVALID_RESPONSE`) | Según caso | Futuro |
| JSON mal formado | "No pudimos completar la operación." | Reintentar | No | Sí (`INT_INVALID_RESPONSE`) | Según caso | Futuro |
| Campo obligatorio faltante | "No pudimos completar la operación." | Reintentar/contactar | No | Sí (`INT_`/`DATA_`) | Según caso | Futuro |
| Stock no disponible | "No pudimos comprobar la disponibilidad. Inténtalo de nuevo." | Reintentar | Limitado | Sí (`INT_`) | Si bloquea compra | Futuro |
| Crédito no disponible | "No pudimos validar el crédito. Inténtalo de nuevo." | Reintentar | Limitado | Sí (`INT_`) | Según regla | Futuro |
| Precio final no disponible | "El precio no está disponible en este momento." | Reintentar/volver | Limitado | Sí (`INT_`/`DATA_`) | Sí | Futuro |

---

## 16. Retry y Fallback

- **No** hacer retry indiscriminado.
- Retry **solo si el error es temporal** (timeout, servicio no disponible).
- **No** hacer retry para errores funcionales.
- Timeout puede admitir **retry limitado** en fase futura.
- **Fallback** solo si no compromete seguridad ni pricing.
- **No** usar datos cacheados de pricing si pueden exponer un precio incorrecto.
- El **checkout debe bloquearse** si falla una validación crítica.

---

## 17. Seguridad y Errores

- **No revelar** si un producto existe cuando el buyer no tiene acceso (salvo
  comportamiento estándar seguro).
- **No revelar** pricing de otro segmento.
- **No revelar** reglas internas de visibilidad.
- **No revelar** detalles de permisos.
- **No revelar** endpoints, tokens ni nombres internos.
- **No revelar** información de otra buyer account.
- Los **errores de seguridad** deben tratarse como **eventos relevantes para
  revisión** (coherente con `security-model.md`).

---

## 18. Logging Relacionado con Errores

A nivel conceptual:

- **Qué trazar:** errores técnicos, de integración y de seguridad.
- **Contexto mínimo:** `errorCode`, `errorType`, contexto funcional, correlación
  segura.
- **Qué no registrar:** datos sensibles, secretos, payloads completos.
- **Debugging temporal** puede bastar en fases tempranas.
- El **logging persistente** puede requerir **ADR**.
- **No** se diseña aquí el framework de logging; eso se profundizará en
  `docs/development/logging-guidelines.md` *(previsto)*.

---

## 19. Matriz de Errores Recomendados

| Código conceptual | Tipo | Escenario | Mensaje buyer recomendado | Acción | ¿Bloquea? | Logging | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FUNC_INSUFFICIENT_STOCK | Funcional | Stock insuficiente | "Stock insuficiente para la cantidad solicitada." | Ajustar cantidad | Condiciona | Opcional | MVP |
| FUNC_APPROVAL_REQUIRED | Funcional | Importe sobre umbral | "Este pedido supera el importe permitido y requiere aprobación." | Enviar solicitud | Genera pendiente | Opcional | MVP |
| FUNC_CREDIT_BLOCKED | Funcional | Crédito bloqueado | "No es posible confirmar el pedido por el estado de crédito de tu cuenta." | Contacto comercial | Sí | Sí | MVP |
| FUNC_PRICE_UPDATED | Funcional | Precio actualizado | "El precio de algunos productos se ha actualizado." | Revisar | Hasta revisar | Opcional | MVP |
| SEC_PRODUCT_NOT_VISIBLE | Seguridad | Producto restringido | "Este producto no está disponible para tu cuenta." | Volver al catálogo | Sí | Sí | MVP |
| SEC_ORDER_NOT_ACCESSIBLE | Seguridad | Pedido de otra cuenta | "Este pedido no está disponible." | Volver al historial | Sí | Sí | MVP |
| DATA_MISSING_PRICE | Datos | Producto sin pricing | "El precio no está disponible en este momento." | Reintentar/volver | Sí (línea) | Sí | MVP |
| DATA_PRODUCT_WITHOUT_CATEGORY | Datos | Producto sin categoría | (no exponer; manejar internamente) | — | No | Sí | MVP |
| CONFIG_MISSING_BUYER_ACCESS | Configuración | Buyer sin acceso configurado | "No pudimos cargar tu catálogo. Inténtalo de nuevo." | Reintentar/soporte | Sí | Sí | MVP |
| INT_TIMEOUT | Integración | Timeout de servicio | "No pudimos completar la operación. Inténtalo de nuevo." | Reintentar | Si es crítica | Sí | Futuro |
| INT_INVALID_RESPONSE | Integración | Response inválida | "No pudimos completar la operación." | Reintentar | Según caso | Sí | Futuro |
| TECH_UNEXPECTED_ERROR | Técnico | Error inesperado | "Ocurrió un problema. Inténtalo de nuevo." | Reintentar | Sí | Sí | MVP |

---

## 20. Testing de Errores

Deben probarse:

- Escenarios **positivos**.
- Errores **funcionales, técnicos, de seguridad, de datos y de configuración**.
- Errores de **integración futura**.
- **Mensajes UX**.
- **Bloqueo/no bloqueo** del flujo.
- **Reorder parcial**.
- **Checkout bloqueado**.
- **Sesión expirada**.

Los casos detallados se derivarán a `docs/testing/`.

---

## 21. Checklist de Review de Manejo de Errores

- [ ] ¿El error está clasificado?
- [ ] ¿El mensaje para buyer es claro?
- [ ] ¿No expone detalles técnicos?
- [ ] ¿No expone datos sensibles?
- [ ] ¿La acción siguiente es clara?
- [ ] ¿El sistema bloquea solo cuando debe?
- [ ] ¿Hay trazabilidad interna suficiente?
- [ ] ¿Se cubre en testing?
- [ ] ¿Se actualiza la documentación UX si cambia el mensaje?
- [ ] ¿Requiere logging persistente?
- [ ] ¿Requiere ADR?

---

## 22. Riesgos

- Mostrar **errores técnicos** al buyer.
- **Silenciar** errores.
- Usar **mensajes genéricos** para todo.
- **No diferenciar** pendiente de error.
- **No bloquear checkout** cuando debería.
- **Bloquear navegación** por errores no críticos.
- **Registrar datos sensibles**.
- **No probar** escenarios negativos.
- **No manejar timeouts**.
- **Ocultar** restricciones de seguridad.
- Usar **Apex/LWC/Flow sin estrategia de errores**.

---

## 23. ADRs Relacionados

Crear un ADR si:

- Se crea una **estrategia de logging persistente**.
- Se crea una **clase/framework central de errores**.
- Se **bloquea checkout** por integración externa.
- Se introduce **manejo custom de errores** para pricing/visibilidad.
- Se exponen **estados críticos** mediante LWC custom.
- Se decide una **política de retry** relevante.
- Se crea un **objeto custom** para errores/logs.
- Se cambia el **comportamiento estándar** de errores de B2B Commerce.

---

## 24. Relación con Otros Documentos

- `docs/ux/empty-error-loading-states.md` define los **estados y mensajes UX**.
- `docs/development/apex-guidelines.md` define los **criterios Apex**.
- `docs/development/lwc-guidelines.md` define los **criterios LWC**.
- `docs/development/flow-guidelines.md` define los **criterios Flow**.
- `docs/development/integration-guidelines.md` define los **errores de integración**.
- `docs/development/logging-guidelines.md` *(previsto)* profundizará en **logging**.
- `docs/development/code-review-checklist.md` debe **usar esta guía**.
- `docs/salesforce/security-model.md` define la **seguridad** Salesforce-relevante.
- `docs/testing/` deberá derivar las **pruebas de errores**.
- `adr/` registrará las **decisiones relevantes**.
