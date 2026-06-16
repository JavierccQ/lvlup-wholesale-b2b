# Checklist de Code Review - LvlUp WholeSale

## 1. Propósito del Documento

Este documento define una **checklist transversal de revisión técnica** para el
proyecto `LvlUp-Wholesale-B2B`, aplicable a cambios de configuración, datos,
Experience Builder, Flow, LWC, Apex, integración, seguridad, UX, testing,
documentación y ADRs.

Sirve para revisar: configuración Salesforce, datos funcionales, Experience
Builder, Flow, LWC, Apex, integraciones, seguridad, UX, testing, documentación y
ADRs.

Este documento **no reemplaza las guidelines específicas** (`apex-guidelines.md`,
`flow-guidelines.md`, `integration-guidelines.md`, etc.); las **consolida como
checklist práctica**. La prosa va en español; los nombres técnicos en inglés.

---

## 2. Principios Generales de Review

- Revisar **estándar antes que custom**.
- Revisar el **impacto funcional** antes que el técnico.
- Revisar **seguridad siempre**.
- Revisar **testing siempre**.
- Revisar la **documentación relacionada**.
- Revisar **mobile** si afecta al storefront.
- Revisar **datos y metadata por separado**.
- Revisar si **requiere ADR**.
- Mantener el **MVP controlado**.
- Evitar cambios **sin propósito funcional claro**.

---

## 3. Resultado Esperado de una Review

| Resultado | Significado | Acción siguiente |
| --- | --- | --- |
| Aprobado | Cumple guidelines y alcance | Integrar |
| Aprobado con comentarios menores | Correcto, con ajustes leves | Ajustar e integrar |
| Requiere cambios | Hay problemas a resolver | Corregir y re-revisar |
| Requiere validación en org | Depende de capacidad no verificada | Validar en la org |
| Requiere ADR | Implica decisión relevante | Crear ADR y re-revisar |
| Rechazado por estar fuera del MVP | No corresponde a esta fase | Diferir |
| Rechazado por customización no justificada | No se validó el estándar/gap | Reevaluar con estándar primero |

---

## 4. Checklist General

- [ ] ¿El cambio tiene un objetivo funcional claro?
- [ ] ¿Está dentro del MVP?
- [ ] ¿Se validó estándar/configuración primero?
- [ ] ¿Se documentó el gap si hay customización?
- [ ] ¿Respeta *Configuration first, customization only when justified*?
- [ ] ¿Afecta buyer account, pricing, visibilidad o checkout?
- [ ] ¿Afecta seguridad?
- [ ] ¿Afecta mobile?
- [ ] ¿Afecta datos?
- [ ] ¿Afecta testing?
- [ ] ¿Requiere actualización documental?
- [ ] ¿Requiere ADR?

---

## 5. Review de Alcance MVP

- [ ] ¿El cambio está incluido en `mvp-scope.md`?
- [ ] ¿Evita pagos reales?
- [ ] ¿Evita tax real?
- [ ] ¿Evita shipping real?
- [ ] ¿Evita ERP real?
- [ ] ¿Evita OMS avanzado?
- [ ] ¿Evita promociones complejas?
- [ ] ¿Evita multi-idioma/multi-divisa?
- [ ] ¿Evita marketplace?
- [ ] ¿No introduce complejidad fuera de fase?
- [ ] ¿Si está fuera del MVP, está diferido correctamente?

---

## 6. Review de Estándar vs Custom

- [ ] ¿Se revisó Salesforce B2B Commerce estándar?
- [ ] ¿Se revisó Experience Builder?
- [ ] ¿Se revisaron componentes estándar?
- [ ] ¿Se revisó la configuración de datos?
- [ ] ¿Se revisó Flow antes de Apex cuando aplica?
- [ ] ¿Se justificó el LWC custom?
- [ ] ¿Se justificó Apex?
- [ ] ¿Se justificó la integración?
- [ ] ¿Existe evidencia del gap?
- [ ] ¿Se actualizó `configuration-decisions.md`?
- [ ] ¿Requiere ADR?

---

## 7. Review de Configuración Salesforce

- [ ] ¿La configuración fue validada en la org?
- [ ] ¿No se asumieron capacidades no verificadas?
- [ ] ¿Está documentado el estado de validación?
- [ ] ¿No se crearon permisos excesivos?
- [ ] ¿No se alteró seguridad sin revisión?
- [ ] ¿No se mezcló configuración con datos?
- [ ] ¿La configuración respeta el mínimo privilegio?
- [ ] ¿Afecta storefront, catálogo, pricing, visibilidad o checkout?
- [ ] ¿Se actualizó la documentación Salesforce correspondiente?

---

## 8. Review de Datos

- [ ] ¿El dato tiene propósito funcional?
- [ ] ¿Respeta dependencias?
- [ ] ¿No depende de IDs hardcodeados?
- [ ] ¿Está relacionado correctamente con buyer account, catálogo, pricing o
      visibilidad?
- [ ] ¿Permite probar escenarios positivos?
- [ ] ¿Permite probar escenarios negativos?
- [ ] ¿No mezcla metadata y data?
- [ ] ¿Es reproducible?
- [ ] ¿Se actualizó `data-loading-strategy.md` si aplica?
- [ ] ¿Se validó con un buyer user si corresponde?

---

## 9. Review de Experience Builder / Storefront

- [ ] ¿Se usó Experience Builder antes que LWC?
- [ ] ¿El layout respeta la UX B2B?
- [ ] ¿Funciona en mobile?
- [ ] ¿No rompe la navegación?
- [ ] ¿No duplica componentes estándar?
- [ ] ¿Los mensajes son claros?
- [ ] ¿Respeta PLP/PDP/cart/checkout definidos?
- [ ] ¿Maneja empty/error/loading states?
- [ ] ¿No expone datos restringidos visualmente?
- [ ] ¿Se documentó cualquier limitación?

---

## 10. Review de LWC

- [ ] ¿El LWC está justificado?
- [ ] ¿Existe un gap UX/funcional validado?
- [ ] ¿Tiene responsabilidad única?
- [ ] ¿El nombre es claro y en inglés?
- [ ] ¿No replica el estándar sin motivo?
- [ ] ¿Es mobile-first?
- [ ] ¿Maneja loading, empty, error, pending y validation states?
- [ ] ¿No expone datos sensibles?
- [ ] ¿No expone pricing indebido?
- [ ] ¿No permite productos restringidos?
- [ ] ¿No hardcodea IDs, URLs o secretos?
- [ ] ¿Usa Apex solo si está justificado?
- [ ] ¿Tiene estrategia de testing?
- [ ] ¿Requiere ADR?

> El detalle vivirá en `docs/development/lwc-guidelines.md` *(previsto)*.

---

## 11. Review de Apex

- [ ] ¿Apex está justificado?
- [ ] ¿Se validó estándar/configuración/Flow primero?
- [ ] ¿Las clases y métodos tienen nombres claros en inglés?
- [ ] ¿Los métodos están en camelCase?
- [ ] ¿Está bulkificado?
- [ ] ¿No hay SOQL en loops?
- [ ] ¿No hay DML en loops?
- [ ] ¿Consulta solo los campos necesarios?
- [ ] ¿Respeta `with sharing` o justifica la excepción?
- [ ] ¿Revisa CRUD/FLS cuando aplica?
- [ ] ¿No expone datos de otra buyer account?
- [ ] ¿No expone pricing indebido?
- [ ] ¿Maneja errores correctamente?
- [ ] ¿No silencia excepciones?
- [ ] ¿Tiene tests útiles?
- [ ] ¿No depende de datos existentes?
- [ ] ¿No hardcodea IDs?
- [ ] ¿Requiere ADR?

---

## 12. Review de Flow

- [ ] ¿Flow está justificado?
- [ ] ¿Se validó estándar/configuración primero?
- [ ] ¿El Flow tiene responsabilidad clara?
- [ ] ¿No tiene demasiadas ramas?
- [ ] ¿No duplica lógica estándar?
- [ ] ¿No usa IDs hardcodeados?
- [ ] ¿Maneja fault paths?
- [ ] ¿Respeta seguridad?
- [ ] ¿No altera pricing/visibilidad sin justificación?
- [ ] ¿Tiene datos de prueba?
- [ ] ¿Tiene testing funcional?
- [ ] ¿Está documentado?
- [ ] ¿Requiere ADR?

---

## 13. Review de Integración

- [ ] ¿La integración está justificada?
- [ ] ¿Está dentro de fase o es futura?
- [ ] ¿El ERP real sigue fuera del MVP?
- [ ] ¿Existe contrato funcional?
- [ ] ¿Existe contrato técnico si aplica?
- [ ] ¿Usa REST si corresponde?
- [ ] ¿Usa JSON si corresponde?
- [ ] ¿Usa Named Credentials si hay callout?
- [ ] ¿No hardcodea endpoints/secrets?
- [ ] ¿Tiene mocks?
- [ ] ¿Maneja timeout?
- [ ] ¿Maneja errores funcionales?
- [ ] ¿Maneja errores técnicos?
- [ ] ¿Respeta la seguridad del buyer?
- [ ] ¿No expone errores técnicos al buyer?
- [ ] ¿Requiere ADR?

---

## 14. Review de Seguridad

- [ ] ¿Respeta el mínimo privilegio?
- [ ] ¿El buyer solo ve datos de su cuenta?
- [ ] ¿El buyer solo ve el catálogo permitido?
- [ ] ¿El buyer solo ve el pricing aplicable?
- [ ] ¿PLP/search no muestran productos restringidos?
- [ ] ¿La PDP directa restringida se maneja de forma segura?
- [ ] ¿El cart revalida productos y pricing?
- [ ] ¿El checkout revalida productos, pricing y visibilidad?
- [ ] ¿El historial muestra solo pedidos de la cuenta?
- [ ] ¿El reorder revalida las reglas actuales?
- [ ] ¿No se confía solo en la UI?
- [ ] ¿No se exponen errores técnicos?
- [ ] ¿Se probaron los permisos?

---

## 15. Review de UX

- [ ] ¿La experiencia es clara para el buyer B2B?
- [ ] ¿La acción principal es evidente?
- [ ] ¿El diseño es mobile-first?
- [ ] ¿Los mensajes son no técnicos?
- [ ] ¿Se contemplan empty/error/loading states?
- [ ] ¿Se diferencia pedido confirmado de solicitud pendiente?
- [ ] ¿Se informa el stock insuficiente claramente?
- [ ] ¿Se informa crédito/aprobación claramente?
- [ ] ¿No se usa lenguaje B2C excesivamente promocional?
- [ ] ¿La experiencia respeta los wireframes y journeys?

---

## 16. Review de Pricing y Visibilidad

- [ ] ¿El pricing es consistente en PLP, PDP, cart y checkout?
- [ ] ¿No se expone pricing de otro segmento?
- [ ] ¿Un producto restringido no aparece donde no debe?
- [ ] ¿El reorder revalida el pricing actual?
- [ ] ¿El cart y el checkout revalidan el pricing?
- [ ] ¿Los cambios de pricing se comunican de forma funcional?
- [ ] ¿No se implementan promociones complejas fuera del MVP?
- [ ] ¿No se introduce multi-divisa fuera del MVP?

---

## 17. Review de Cart, Checkout y Orders

- [ ] ¿El cart permite revisar productos y cantidades?
- [ ] ¿El cart maneja productos no válidos?
- [ ] ¿El checkout revalida las condiciones críticas?
- [ ] ¿El checkout diferencia confirmado vs pendiente?
- [ ] ¿Los pagos reales siguen fuera del MVP?
- [ ] ¿El tax real sigue fuera del MVP?
- [ ] ¿El shipping real sigue fuera del MVP?
- [ ] ¿Orders/historial respetan la buyer account?
- [ ] ¿El reorder no salta las reglas actuales?
- [ ] ¿Los estados son claros?

---

## 18. Review de Testing

- [ ] ¿Hay escenarios positivos?
- [ ] ¿Hay escenarios negativos?
- [ ] ¿Hay prueba de seguridad?
- [ ] ¿Hay prueba de permisos/visibilidad?
- [ ] ¿Hay prueba de pricing?
- [ ] ¿Hay prueba de mobile/UX si aplica?
- [ ] ¿Hay test Apex si hay Apex?
- [ ] ¿Hay mock si hay callout?
- [ ] ¿Hay datos de prueba claros?
- [ ] ¿No depende de datos existentes no controlados?
- [ ] ¿Se documentaron los casos pendientes?

---

## 19. Review de Documentación

- [ ] ¿Se actualizó el documento funcional correspondiente?
- [ ] ¿Se actualizó UX si cambia la experiencia?
- [ ] ¿Se actualizó arquitectura si cambia el diseño?
- [ ] ¿Se actualizaron los Salesforce docs si cambia la configuración?
- [ ] ¿Se actualizaron los development docs si cambia un patrón?
- [ ] ¿Se actualizaron los testing docs si agrega casos?
- [ ] ¿Se actualizó el glossary si aparece un término nuevo?
- [ ] ¿Se actualizó `configuration-decisions.md`?
- [ ] ¿Se actualizó `limitations-and-assumptions.md`?
- [ ] ¿Se creó un ADR si aplica?

---

## 20. Review de ADR

- [ ] ¿El cambio introduce LWC custom relevante?
- [ ] ¿El cambio introduce Apex relevante?
- [ ] ¿El cambio introduce un Flow central?
- [ ] ¿El cambio introduce integración?
- [ ] ¿El cambio altera seguridad?
- [ ] ¿El cambio altera checkout?
- [ ] ¿El cambio altera pricing/visibilidad?
- [ ] ¿El cambio reemplaza el estándar?
- [ ] ¿El cambio cambia el alcance del MVP?
- [ ] ¿La decisión queda suficientemente documentada sin ADR, o requiere ADR?

---

## 21. Señales de Alerta

Frases que deben **activar una revisión más profunda** (y por qué):

- "Lo hacemos en Apex más rápido." → Apex sin validar estándar/Flow.
- "Creamos un LWC porque queda más bonito." → custom por estética, sin gap.
- "Ocultamos el dato con CSS." → seguridad solo visual; no protege el dato.
- "Dejamos el error técnico tal cual." → expone detalles al buyer.
- "Usamos el ID de la org." → ID hardcodeado, no reproducible.
- "Lo probamos con mi usuario admin." → no valida permisos del buyer.
- "Después documentamos." → deuda documental; se pospone indefinidamente.
- "No hace falta test porque es pequeño." → sin testing ni asserts.
- "Conectamos directo al ERP real." → integración real fuera del MVP, sin ADR.
- "El buyer no debería entrar por URL directa." → confía en que no ocurra, no lo
  bloquea.
- "Copiamos este Flow y lo ajustamos rápido." → duplicación de lógica sin diseño.

---

## 22. Plantilla de Resultado de Review

```markdown
## Resultado de Review

**Cambio revisado:**
...

**Resultado:**
Aprobado / Aprobado con comentarios / Requiere cambios / Requiere validación en org /
Requiere ADR / Fuera del MVP

**Observaciones principales:**
- ...

**Riesgos detectados:**
- ...

**Cambios requeridos:**
- ...

**Documentos a actualizar:**
- ...

**ADR requerido:**
Sí / No

**Decisión final:**
...
```

---

## 23. Relación con Otros Documentos

- `docs/architecture/standard-vs-custom-framework.md` define el **criterio estándar
  vs custom** que rige la review.
- `docs/business/mvp-scope.md` define el **alcance** a verificar.
- `docs/development/apex-guidelines.md`, `flow-guidelines.md`,
  `integration-guidelines.md` y `lwc-guidelines.md` *(previsto)* definen las
  **guidelines** que esta checklist consolida.
- `docs/salesforce/security-model.md` y `docs/architecture/security-architecture.md`
  definen la **seguridad** a revisar.
- `docs/salesforce/configuration-decisions.md` y
  `docs/architecture/limitations-and-assumptions.md` se **actualizan** tras la
  review.
- `docs/ux/` define la **experiencia** a validar.
- `docs/testing/` deberá definir el **testing** detallado.
- `adr/` registra las **decisiones** que la review identifique como relevantes.
