# Imágenes de producto — hosting externo (GitHub raw)

Imágenes de producto (generadas con ChatGPT) que se **sirven por URL** desde este
repo vía `raw.githubusercontent.com` y se referencian en Salesforce B2B Commerce.

**Por qué externo y no en el CMS:** la org es Developer Edition y su File Storage
(~limitado) no soporta 50 imágenes en el CMS (`STORAGE_LIMIT_EXCEEDED`). El enfoque
soportado es alojarlas en un host externo y añadir ese host como *Trusted URL* en el
store, así no consumen File Storage de Salesforce.

## Regla de nombrado (importante)

- **Un archivo por producto.**
- **El nombre del archivo debe ser EXACTAMENTE el SKU** del producto, en mayúsculas.
  - ✅ `LVL-CON-001.png`
  - ❌ `consola pro x.png`, `LVL_CON_001.png`, `lvl-con-001 (1).png`
- Formato: **PNG**, cuadrado 1:1 (2048×2048).

La URL de cada imagen se deriva del SKU, así que el nombre debe ser exacto:

```
https://raw.githubusercontent.com/JavierccQ/lvlup-wholesale-b2b/main/data/product-images/<SKU>.png
```

## Flujo

1. Pega aquí las imágenes renombradas por SKU.
2. Commit + push a `main` (el repo debe ser **público** para que las raw URLs
   funcionen sin token).
3. Añadir `raw.githubusercontent.com` como **Trusted URL** del store.
4. Crear el `ProductMedia` de cada producto apuntando a su URL externa.
5. Reindexar el store (Settings | Search | Update) para verlas en PLP/PDP.

## Checklist de archivos esperados (50)

Consolas: LVL-CON-001 · LVL-CON-002 · LVL-CON-003 · LVL-CON-004 · LVL-CON-005 · LVL-CON-006 · LVL-CON-007
Videojuegos: LVL-VGM-001 · LVL-VGM-002 · LVL-VGM-003 · LVL-VGM-004 · LVL-VGM-005 · LVL-VGM-006 · LVL-VGM-007 · LVL-VGM-008
Portátiles: LVL-LAP-001 · LVL-LAP-002 · LVL-LAP-003 · LVL-LAP-004 · LVL-LAP-005 · LVL-LAP-006 · LVL-LAP-007
Monitores: LVL-MON-001 · LVL-MON-002 · LVL-MON-003 · LVL-MON-004 · LVL-MON-005 · LVL-MON-006
Periféricos: LVL-PER-001 · LVL-PER-002 · LVL-PER-003 · LVL-PER-004 · LVL-PER-005 · LVL-PER-006 · LVL-PER-007 · LVL-PER-008
Networking: LVL-NET-001 · LVL-NET-002 · LVL-NET-003 · LVL-NET-004 · LVL-NET-005
Accesorios: LVL-ACC-001 · LVL-ACC-002 · LVL-ACC-003 · LVL-ACC-004 · LVL-ACC-005 · LVL-ACC-006
Bundles: LVL-BND-001 · LVL-BND-002 · LVL-BND-003
