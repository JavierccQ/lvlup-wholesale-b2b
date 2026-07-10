# Runbook de Configuración Manual - Buyer Group Catalog Pulse (CDC + Platform Events)

Este runbook describe los pasos que **no viven en el repo** y deben ejecutarse en
Salesforce Setup para que el feature _Buyer Group Catalog Pulse_ funcione end-to-end.
Complementa el `adr/0007-event-driven-catalog-pulse-architecture.md` (decisión) y la
guía de despliegue. No duplica el diseño: aquí solo van los **pasos operativos**.

Arquitectura resumida (ver ADR-0007):

```
Product2 (pipeline o admin) → CDC Product2ChangeEvent → LvlupProduct2ChangeEventTrigger
   → LvlupCatalogPulseCuration → Catalog_Pulse_Event__e (Platform Event)
   → LvlupCatalogPulseEventTrigger → LvlupCatalogPulseSubscriber → Catalog_Pulse_Item__c
   → LvlupCatalogPulseController (entitlement-aware) → lvlupCatalogPulseCarousel (LWR)
```

---

## 1. Desplegar la metadata

Desde la raíz del repo:

```bash
sf project deploy start --source-dir force-app --dry-run
sf project deploy start --source-dir force-app
```

Incluye: Platform Event `Catalog_Pulse_Event__e`, objeto `Catalog_Pulse_Item__c`,
triggers y clases Apex, LWC `lvlupCatalogPulseCarousel`, y los permission sets
`LvlUp_Catalog_Pulse_Buyer` / `LvlUp_Catalog_Pulse_Admin`.

> Verificado en org: el deploy del trigger sobre `Product2ChangeEvent` entra sin
> configuración previa de CDC.

---

## 2. Change Data Capture (verificado: NO requiere paso manual para este pipeline)

**Verificado en org (2026-07-07):** el pipeline funciona **sin** tocar Setup. Definir
el trigger Apex sobre `Product2ChangeEvent` (ya desplegado) **auto-suscribe** la captura
para Apex: al crear/editar un `Product2`, se genera el `Catalog_Pulse_Item__c`
automáticamente. La prueba de humo (alta de Product2 → item `NEW`) lo confirmó.

Solo necesitas habilitar CDC en **Setup** si además quieres **suscriptores externos**
(Streaming API / `empApi` / otra org escuchando el canal estándar):

1. Setup → **Change Data Capture**.
2. En **Available Entities**, selecciona **Product** (`Product2`) → **Selected Entities** → Guardar.

Developer Edition tiene un cupo limitado de entidades CDC; si está lleno, libera una.

---

## 3. Asignar permission sets

- **Buyer de prueba** (usuario Customer Community Plus del storefront):
  asignar **`LvlUp Catalog Pulse Buyer`**. Es lo que concede acceso a la clase
  `LvlupCatalogPulseController` (sin él, la llamada del carrusel da 400; REGLA-004).
- **Admin/operador** que quiera curar novedades a mano o **ver el feed** en list
  views/reports/consultas: **`LvlUp Catalog Pulse Admin`**. Sin FLS (sin este permset),
  una query del feed devuelve `No such column` aunque el campo exista (verificado en org).

```bash
sf org assign permset --name LvlUp_Catalog_Pulse_Buyer --target-org commerce-b2b-dev
```

(o asignarlo al usuario buyer concreto con `--on-behalf-of`).

---

## 4. Colocar el carrusel en el storefront y publicar

1. Experience Builder → abre la página donde quieras el carrusel (p. ej. Home).
2. Arrastra **LvlUp Catalog Pulse Carousel** a la zona deseada.
3. Configura las propiedades (Título, Máximo de novedades, Ocultar si no hay novedades).
4. **Publish** del site (REGLA-007): los cambios de código LWC se sirven cacheados y
   solo se ven tras republicar. Los cambios de Apex aplican al instante.

---

## 5. Generar novedades y verificar el feed

1. Provoca un cambio de catálogo: corre el pipeline Platzi o **edita/crea un
   `Product2`** en Setup (alta → `NEW`, subir `Inventory_Quantity__c` desde 0 → `RESTOCK`).
2. Comprueba que se materializó una novedad:

```bash
sf data query --query "SELECT Name, Change_Type__c, Segment_Key__c, Status__c, Product__c FROM Catalog_Pulse_Item__c ORDER BY CreatedDate DESC LIMIT 10" --target-org commerce-b2b-dev
```

3. Si no aparece nada: revisa que CDC esté habilitado (paso 2), que el producto esté
   **activo**, y los logs del trigger.

---

## 6. Probar como Buyer real (REGLA-001)

El comportamiento de visibilidad **debe** probarse como Buyer real en el site
publicado, no como Admin (el Admin salta entitlements y oculta bugs).

1. Inicia sesión como el Buyer de prueba en el storefront publicado.
2. El carrusel debe mostrar **solo** novedades de productos que ese Buyer está
   **entitled** a ver (`CommerceEntitlementProduct` de las políticas de su Buyer Group)
   y de su segmento (o globales). Verifica que un producto **no entitled** con novedad
   **no** aparece.
3. Recuerda: cambios de entitlement pueden requerir **reindexar** el search index
   (REGLA-003) para que el producto sea comprable, aunque la novedad ya exista.

---

## 7. Contrato futuro para Agentforce (no implementado)

La misma capa de servicio queda lista para una futura **Agentforce Action** que
reutilice `LvlupCatalogPulseController` sin duplicar lógica de seguridad:

- `getCatalogPulseForBuyer(maxItems)` → novedades vigentes, segmentadas y entitled
  del comprador (ya existe; una acción invocable puede envolverla).
- `summarizeNewProductsForBuyer(period)` → futura: resumir las novedades del periodo
  ("¿qué productos nuevos tengo esta semana?"). Consumiría `Catalog_Pulse_Item__c`
  filtrado por entitlement, devolviendo un texto para el agente.

No se asume licencia ni disponibilidad de Agentforce en la org. Cuando se aborde,
evaluar si requiere ADR propio.

---

## 8. Limitaciones conocidas

- CDC de `Product2` no detecta `PRICE_DROP` (el precio vive en `PricebookEntry`).
  Queda soportado en el modelo para una futura CDC de `PricebookEntry` o publicación
  desde el pipeline de precios.
- El `Segment_Key__c` publicado desde CDC es global; el afinado por Buyer Group
  concreto es una extensión futura.
- Vigencia por defecto de una novedad: 14 días (`Expiration_Date__c`), configurable en
  `LvlupCatalogPulseSubscriber`.

---

## 9. Referencias

- `adr/0007-event-driven-catalog-pulse-architecture.md`
- `docs/salesforce/integracion-productos-externos-guion-narrativo.md` (patrón de capas)
- `docs/salesforce/manual-add-product-runbook.md` (alta de producto y reindex)
- `MEMORY.md` — REGLA-001, REGLA-003, REGLA-004, REGLA-007, REGLA-011, REGLA-017
