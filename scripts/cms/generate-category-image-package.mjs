/**
 * ============================================================================
 *  generate-category-image-package.mjs
 * ============================================================================
 *  Generates the Managed Content (Enhanced CMS) import package with the
 *  category tile images hosted in the GitHub repo, using the same URL-reference
 *  format as generate-platzi-image-package.mjs (verified with a CMS export):
 *
 *    category-images/<CONTENT_KEY>/
 *       ├─ content.json   <- type sfdc_cms__image, source.type "url" -> external URL
 *       └─ _meta.json     <- { contentKey, path, taxonomyTerms }
 *
 *  No binaries, no _media/ folder: each content item is a REFERENCE to the
 *  external image URL (GitHub raw), so it consumes 0 bytes of File Storage.
 *  The `title` becomes ManagedContent.Name and uses the CAT-<SLUG> convention
 *  so category media can be matched by name later.
 *
 *  Usage:    node scripts/cms/generate-category-image-package.mjs [--only <slug>]
 *  Produces: scripts/cms/out/category-image-content.zip  (manual upload to CMS)
 * ============================================================================
 */
import { createHash } from 'node:crypto';
import { crc32 } from 'node:zlib';
import { mkdirSync, writeFileSync, rmSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const BASE_URL =
    'https://raw.githubusercontent.com/JavierccQ/lvlup-wholesale-b2b/main/data/product-images/category-images';
const CMS_PATH = 'category-images';

// slug = file name in the repo; categoryName = ProductCategory.Name in the org.
const CATEGORIES = [
    { slug: 'consolas-gaming', categoryName: 'Consolas de gaming' },
    { slug: 'videojuegos', categoryName: 'Videojuegos' },
    { slug: 'portatiles', categoryName: 'Portátiles' },
    { slug: 'monitores', categoryName: 'Monitores' },
    { slug: 'perifericos', categoryName: 'Periféricos' },
    { slug: 'networking', categoryName: 'Networking' },
    { slug: 'accesorios', categoryName: 'Accesorios' },
    { slug: 'bundles-enterprise', categoryName: 'Bundles enterprise' },
    { slug: 'smartphones', categoryName: 'SmartPhones' },
    { slug: 'productos-platzi', categoryName: 'Productos de Platzi' }
];

const here = dirname(fileURLToPath(import.meta.url));
const stagingDir = resolve(here, 'staging-categories');
const outDir = resolve(here, 'out');
const zipPath = resolve(outDir, 'category-image-content.zip');

const onlyArg = process.argv.indexOf('--only');
const only = onlyArg > -1 ? process.argv[onlyArg + 1] : null;

// Base32 (RFC 4648, no padding) uppercase, like real CMS content keys.
const B32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
function base32(buffer) {
    let bits = 0, value = 0, out = '';
    for (const byte of buffer) {
        value = (value << 8) | byte;
        bits += 8;
        while (bits >= 5) {
            out += B32[(value >>> (bits - 5)) & 31];
            bits -= 5;
        }
    }
    return out;
}
// Deterministic content key from the title code (re-import = update, no dup).
function contentKeyFor(code) {
    return 'MC' + base32(createHash('sha1').update(code).digest()).slice(0, 26);
}

// "Stored" ZIP (no compression) with "/" paths. entries: [{ name, data:Buffer }]
function createZip(entries) {
    const parts = [], central = [];
    let offset = 0;
    const DOS_TIME = 0, DOS_DATE = 0x21; // 1980-01-01
    for (const { name, data } of entries) {
        const nameBuf = Buffer.from(name, 'utf8');
        const crc = crc32(data) >>> 0;
        const size = data.length;
        const local = Buffer.alloc(30);
        local.writeUInt32LE(0x04034b50, 0);
        local.writeUInt16LE(20, 4);
        local.writeUInt16LE(0, 8); // store
        local.writeUInt16LE(DOS_TIME, 10);
        local.writeUInt16LE(DOS_DATE, 12);
        local.writeUInt32LE(crc, 14);
        local.writeUInt32LE(size, 18);
        local.writeUInt32LE(size, 22);
        local.writeUInt16LE(nameBuf.length, 26);
        parts.push(local, nameBuf, data);
        const cen = Buffer.alloc(46);
        cen.writeUInt32LE(0x02014b50, 0);
        cen.writeUInt16LE(20, 4);
        cen.writeUInt16LE(20, 6);
        cen.writeUInt16LE(0, 10);
        cen.writeUInt16LE(DOS_TIME, 12);
        cen.writeUInt16LE(DOS_DATE, 14);
        cen.writeUInt32LE(crc, 16);
        cen.writeUInt32LE(size, 20);
        cen.writeUInt32LE(size, 24);
        cen.writeUInt16LE(nameBuf.length, 28);
        cen.writeUInt32LE(offset, 42);
        central.push(Buffer.concat([cen, nameBuf]));
        offset += local.length + nameBuf.length + size;
    }
    const centralBuf = Buffer.concat(central);
    const end = Buffer.alloc(22);
    end.writeUInt32LE(0x06054b50, 0);
    end.writeUInt16LE(entries.length, 8);
    end.writeUInt16LE(entries.length, 10);
    end.writeUInt32LE(centralBuf.length, 12);
    end.writeUInt32LE(offset, 16);
    return Buffer.concat([...parts, centralBuf, end]);
}

// Validates the URL responds 200 (avoids importing broken references).
async function isReachable(url) {
    try {
        const res = await fetch(url, { method: 'GET' });
        return res.ok;
    } catch {
        return false;
    }
}

async function main() {
    let categories = CATEGORIES;
    if (only) {
        categories = CATEGORIES.filter((c) => c.slug === only);
        if (categories.length === 0) {
            console.error(`Unknown slug "${only}". Valid slugs: ${CATEGORIES.map((c) => c.slug).join(', ')}`);
            process.exit(1);
        }
    }

    rmSync(stagingDir, { recursive: true, force: true });
    mkdirSync(stagingDir, { recursive: true });
    mkdirSync(outDir, { recursive: true });

    const zipEntries = [];
    let included = 0;
    for (const { slug, categoryName } of categories) {
        const code = 'CAT-' + slug.toUpperCase();
        const url = `${BASE_URL}/${slug}.png`;
        if (!(await isReachable(url))) {
            console.log(`  SKIP ${code}: URL does not respond 200 (${url})`);
            continue;
        }
        const key = contentKeyFor(code);
        const base = `${CMS_PATH}/${key}`;

        const content = Buffer.from(JSON.stringify({
            type: 'sfdc_cms__image',
            title: code,
            contentBody: {
                'sfdc_cms:media': {
                    source: { fileSize: null, mimeType: null, type: 'url', url: url },
                    url: url
                }
            },
            urlName: code.toLowerCase()
        }, null, 2));
        const meta = Buffer.from(JSON.stringify(
            { contentKey: key, path: CMS_PATH, taxonomyTerms: [] }, null, 2
        ));

        zipEntries.push({ name: `${base}/content.json`, data: content });
        zipEntries.push({ name: `${base}/_meta.json`, data: meta });

        // Staging copy for inspection.
        const contentDir = resolve(stagingDir, CMS_PATH, key);
        mkdirSync(contentDir, { recursive: true });
        writeFileSync(resolve(contentDir, 'content.json'), content);
        writeFileSync(resolve(contentDir, '_meta.json'), meta);

        included++;
        console.log(`  OK  ${code} (${categoryName}) -> ${key}`);
    }

    if (included === 0) {
        console.log('No images included; ZIP not generated.');
        return;
    }
    rmSync(zipPath, { force: true });
    writeFileSync(zipPath, createZip(zipEntries));
    console.log(`\nPackage generated: ${zipPath}`);
    console.log(`Contents: ${included}. Upload it manually to the store CMS workspace.`);
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
