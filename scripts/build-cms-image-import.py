#!/usr/bin/env python3
"""
Build a Salesforce CMS "Import Content" ZIP that creates URL-based image content
(sfdc_cms__image whose source is an EXTERNAL URL) for the product catalog.

URL-based content references the image on GitHub raw and consumes ZERO File
Storage (unlike file-based content). Format mirrors this org's own export of a
URL image (verified):

    product-images/<SKU>/content.json   (type sfdc_cms__image, source.type = "url")
    product-images/<SKU>/_meta.json     (path + taxonomyTerms; no contentKey = new)

Title = SKU so ManagedContent.Name matches Product2.StockKeepingUnit (ASCII, no
accent/normalization issues) when wiring ProductMedia afterwards.

LVL-CON-001 is excluded (already created manually + linked).

Run: python scripts/build-cms-image-import.py
Output: data/cms-import/lvlup-product-images-url.zip  -> import in CMS workspace.
"""
import json
import shutil
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IMAGES_DIR = ROOT / "data" / "product-images"
OUT_DIR = ROOT / "data" / "cms-import"
ZIP_PATH = OUT_DIR / "lvlup-product-images-url.zip"
WORKSPACE_FOLDER = "product-images"
RAW_BASE = "https://raw.githubusercontent.com/JavierccQ/lvlup-wholesale-b2b/main/data/product-images"
ALREADY_DONE = {"LVL-CON-001"}

skus = sorted(p.stem for p in IMAGES_DIR.glob("LVL-*.png") if p.stem not in ALREADY_DONE)

build = OUT_DIR / "build"
if build.exists():
    shutil.rmtree(build)

for sku in skus:
    url = f"{RAW_BASE}/{sku}.png"
    cfolder = build / WORKSPACE_FOLDER / sku
    cfolder.mkdir(parents=True, exist_ok=True)
    content = {
        "type": "sfdc_cms__image",
        "title": sku,
        "contentBody": {
            "sfdc_cms:media": {
                "source": {"fileSize": None, "mimeType": None, "type": "url", "url": url},
                "url": url,
            }
        },
        "urlName": sku.lower(),
    }
    meta = {"path": WORKSPACE_FOLDER, "taxonomyTerms": []}
    (cfolder / "content.json").write_text(json.dumps(content, ensure_ascii=False, indent=2), encoding="utf-8")
    (cfolder / "_meta.json").write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")

OUT_DIR.mkdir(parents=True, exist_ok=True)
if ZIP_PATH.exists():
    ZIP_PATH.unlink()
with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as zf:
    for f in sorted(build.rglob("*")):
        if f.is_file():
            zf.write(f, f.relative_to(build).as_posix())

# Validate all JSON parses
with zipfile.ZipFile(ZIP_PATH) as zf:
    for n in zf.namelist():
        if n.endswith(".json"):
            json.loads(zf.read(n))

print(f"Contents (URL-based): {len(skus)}  (excluded: {sorted(ALREADY_DONE)})")
print(f"ZIP: {ZIP_PATH.relative_to(ROOT)}")
print("Sample content.json (first SKU):")
print((build / WORKSPACE_FOLDER / skus[0] / "content.json").read_text(encoding="utf-8"))
