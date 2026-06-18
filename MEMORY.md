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

> Sin reglas por ahora. Las reglas se añaden numeradas
> (`REGLA-NNN — título`) **solo** tras confirmación explícita del usuario y
> **solo** si cumplen los criterios anteriores.

<!-- Plantilla para nuevas reglas:

### REGLA-001 — <título corto>

- **Regla:** <qué se debe hacer o evitar>.
- **Ámbito:** <Apex | LWC | Flow | docs | commits | ...>.
- **Origen:** <fecha o conversación donde se acordó>.
-->
