# MEMORY.md

## Propósito

Memoria operativa **ligera** de `LvlUp-Wholesale-B2B`. Captura reglas,
preferencias e instrucciones recurrentes que el usuario indica durante el
trabajo diario y que **todavía no están** en la documentación formal del
proyecto.

No sustituye a `PROJECT_CONTEXT.md`, `CLAUDE.md`, `docs/DOCUMENTATION_INDEX.md`,
`docs/development/`, `docs/architecture/`, `docs/salesforce/`, `agents/`,
`evals/` ni `adr/`. Cuando una regla ya vive en uno de esos documentos, esa es
la **fuente de verdad**: aquí no se duplica.

---

## Uso obligatorio

- Antes de ejecutar una tarea, Claude lee este archivo junto con
  `CLAUDE.md` y `PROJECT_CONTEXT.md`.
- Si una instrucción del usuario introduce una regla nueva que no existe en la
  documentación actual, Claude **pregunta antes** de añadirla aquí.
- Claude **nunca** añade reglas automáticamente sin confirmación explícita del
  usuario.

---

## Criterios para añadir una regla

Añadir aquí **solo si** la regla:

- Es recurrente o reutilizable.
- Afecta cómo se trabaja en el proyecto.
- No está ya documentada en otro `.md`.
- No contradice el MVP, los ADRs ni el principio *standard-first*.
- No merece todavía un ADR ni una actualización formal de documentación.

**No** añadir aquí:

- Decisiones arquitectónicas relevantes (→ `adr/`).
- Cambios de alcance (→ `docs/business/mvp-scope.md`, ADRs).
- Reglas ya documentadas (p. ej. naming → `docs/development/naming-conventions.md`).
- Preferencias temporales o de una sola tarea.
- Información que pertenezca claramente a otro documento existente.

---

## Flujo de captura (ejemplo)

Demuestra el comportamiento esperado cuando el usuario corrige con una regla
aparentemente reutilizable.

> Usuario: *"Evita usar guiones o caracteres especiales al nombrar funciones.
> Usa nombres cortos, descriptivos y en camelCase."*

1. Claude verifica primero si la regla ya está documentada.
2. En este caso **sí lo está**: vive en `docs/development/naming-conventions.md`
   (§7 Apex Methods, §10 LWC JavaScript, §19 tabla resumen) —
   `mi-funcion()` → `miFuncion()`.
3. Por tanto Claude responde indicando **dónde** está definida y la aplica;
   **no** la añade a `MEMORY.md`.

Si la regla **no** estuviera documentada, Claude preguntaría:
*"Esta regla no parece estar documentada todavía. ¿Quieres que la añada a
`MEMORY.md`?"*, y solo la añadiría tras confirmación explícita.

---

## Reglas operativas

> Reglas operativas reutilizables descubiertas durante el desarrollo del feature
> *Contextual Quick Buy* (sesión 2026-06-23), añadidas a petición explícita del
> usuario. Son lecciones recurrentes de B2B Commerce/LWR que ahorran tiempo en
> features futuros. El detalle completo vive en
> `docs/development/contextual-quick-buy-code-walkthrough.md`,
> `docs/salesforce/manual-inventory-setup-runbook.md` y
> `docs/ux/contextual-quick-buy-architecture.html`.

### REGLA-001 — Probar el storefront como Buyer real, no como Admin

- **Regla:** Para validar UI, visibilidad, precios, carrito o Apex de comprador, iniciar sesión como un **Buyer User real** en el sitio **publicado**. El Admin salta entitlements y sharing → oculta bugs. El "Preview as Authenticated User" del Builder es poco fiable; las extensiones tipo Adblock rompen el preview.
- **Ámbito:** QA / B2B Commerce.
- **Origen:** Sesión 2026-06-23 (Contextual Quick Buy).

### REGLA-002 — Cadena de habilitación de un Buyer de prueba

- **Regla:** Crear un comprador: Account → habilitar como Buyer (`BuyerAccount.IsActive = true`; **no** basta `BuyerStatus`) → `BuyerGroupMember` (hereda entitlement + price book) → Contact → Customer Community Plus User + membresía del sitio → contraseña. En dev org no llega el email de bienvenida → fijar con `System.setPassword`. "Habilitar buyer" y "añadir al grupo" van en **transacciones Apex separadas**.
- **Ámbito:** B2B Commerce / datos.
- **Origen:** Sesión 2026-06-23.

### REGLA-003 — Visibilidad de productos = entitlement + reindex

- **Regla:** Un buyer solo ve productos listados en `CommerceEntitlementProduct` de la política de su Buyer Group. Precio + categoría **no bastan**. Tras altas o cambios de entitlement, **reconstruir el índice de búsqueda**. Los seed scripts de catálogo deben entitlar cada producto.
- **Ámbito:** B2B Commerce / datos.
- **Origen:** Sesión 2026-06-23.

### REGLA-004 — Apex de storefront: `without sharing` + acceso a la clase

- **Regla:** Controllers llamados por compradores que consulten `Product2`/objetos de commerce deben ser **`without sharing`** (`with sharing` → 0 filas para el buyer, porque la visibilidad la da el entitlement, no el sharing). Además, conceder al perfil/permission set del buyer **acceso a la clase Apex** (si falta → `400` en `/webruntime/api/apex/execute`).
- **Ámbito:** Apex / B2B Commerce.
- **Origen:** Sesión 2026-06-23.

### REGLA-005 — PLP custom por producto: Grid + "Nested Expression"

- **Regla:** La "Results" estándar no admite hijos. Para inyectar componentes por card: **Grid (Repeaters)** con data source **Nested Expression** = `{!Search.Results.cardCollection}`, prefijo `Item`, + Product Card (`{!Item}`). Paths del item: `{!Item.id}`, SKU `{!Item.fields.StockKeepingUnit.value}`, imagen `{!Item.defaultImage.url}`. Las `@api` de componentes custom **no tienen autocompletado** en el Builder (teclear la expresión a mano).
- **Ámbito:** Experience Builder / LWC.
- **Origen:** Sesión 2026-06-23.

### REGLA-006 — Imágenes CMS con URL externa no renderizan en la card del grid

- **Regla:** Imágenes `sfdc_cms__image` con URL externa (0 File Storage) se ven en la **PDP** pero **no** en la miniatura de la Product Card del grid (no genera renditions). Workaround: LWC propio que pinte la URL (`lvlupProductImage`).
- **Ámbito:** B2B Commerce / LWC.
- **Origen:** Sesión 2026-06-23.

### REGLA-007 — Cambios de código LWC requieren Publish; Apex es inmediato

- **Regla:** En LWR, los cambios de **código LWC** se sirven cacheados → **republicar** el sitio (Experience Builder → Publish) para verlos. Los cambios de **Apex** aplican al instante.
- **Ámbito:** Deploy / LWR.
- **Origen:** Sesión 2026-06-23.

<!-- Plantilla para nuevas reglas:

### REGLA-001 — <título corto>

- **Regla:** <qué se debe hacer o evitar>.
- **Ámbito:** <Apex | LWC | Flow | docs | commits | ...>.
- **Origen:** <fecha o conversación donde se acordó>.
-->
