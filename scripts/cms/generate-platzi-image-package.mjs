/**
 * ============================================================================
 *  generate-platzi-image-package.mjs
 * ============================================================================
 *  Genera el paquete de import de Managed Content (Enhanced CMS) con las
 *  imágenes de los productos externos de Platzi, replicando el formato real que
 *  usan los productos internos (verificado con un export del CMS):
 *
 *    product-images/<CONTENT_KEY>/
 *       ├─ content.json   ← type sfdc_cms__image, source.type "url" -> URL externa
 *       └─ _meta.json     ← { contentKey, path, taxonomyTerms }
 *
 *  NO descarga binarios ni usa _media/: el contenido es una REFERENCIA a la URL
 *  externa de la imagen (la de Platzi). El `title` = ProductCode, que es lo que
 *  queda en ManagedContent.Name y permite el casado por código en el pipeline.
 *
 *  Uso:     node scripts/cms/generate-platzi-image-package.mjs [--limit N]
 *  Produce: scripts/cms/out/platzi-media-content.zip  (subir manual al CMS)
 *  Requiere: sf CLI autenticado (alias commerce-b2b-dev).
 * ============================================================================
 */
import { execSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { crc32 } from 'node:zlib';
import { mkdirSync, writeFileSync, rmSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const TARGET_ORG = 'commerce-b2b-dev';
const PRODUCT_CODE_PREFIX = 'EXT-PLATZI-';
const CMS_PATH = 'product-images';

const here = dirname(fileURLToPath(import.meta.url));
const stagingDir = resolve(here, 'staging');
const outDir = resolve(here, 'out');
const zipPath = resolve(outDir, 'platzi-media-content.zip');

const limitArg = process.argv.indexOf('--limit');
const limit = limitArg > -1 ? Number(process.argv[limitArg + 1]) : null;

// Base32 (RFC 4648, sin padding) en MAYÚSCULAS, como las content keys del CMS.
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
// Content key determinista a partir del ProductCode (re-import = update, no dup).
function contentKeyFor(code) {
    return 'MC' + base32(createHash('sha1').update(code).digest()).slice(0, 26);
}

// ZIP "stored" (sin compresión) con rutas "/". entries: [{ name, data:Buffer }]
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

function queryProducts() {
    const soql =
        "SELECT External_Id__c, External_Image_URL__c " +
        "FROM External_Product__c " +
        "WHERE External_Source__c = 'Platzi' AND External_Image_URL__c != null " +
        "ORDER BY External_Id__c";
    const raw = execSync(
        `sf data query --query "${soql}" --target-org ${TARGET_ORG} --json`,
        { encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 }
    );
    return JSON.parse(raw).result.records;
}

// Valida que la URL responda 200 (evita importar referencias rotas).
async function isReachable(url) {
    try {
        const res = await fetch(url, { method: 'GET' });
        return res.ok;
    } catch {
        return false;
    }
}

async function main() {
    console.log('Consultando productos externos...');
    let records = queryProducts();
    if (limit) records = records.slice(0, limit);
    console.log(`Productos con imagen: ${records.length}`);

    rmSync(stagingDir, { recursive: true, force: true });
    mkdirSync(stagingDir, { recursive: true });
    mkdirSync(outDir, { recursive: true });

    const zipEntries = [];
    let included = 0;
    for (const rec of records) {
        const code = PRODUCT_CODE_PREFIX + rec.External_Id__c;
        const url = rec.External_Image_URL__c;
        if (!(await isReachable(url))) {
            console.log(`  SKIP ${code}: URL no responde 200`);
            continue;
        }
        const key = contentKeyFor(code);
        const base = `${CMS_PATH}/${key}`;

        // Formato verificado con export del CMS: referencia externa por URL.
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

        // Copia en staging para inspección.
        const contentDir = resolve(stagingDir, CMS_PATH, key);
        mkdirSync(contentDir, { recursive: true });
        writeFileSync(resolve(contentDir, 'content.json'), content);
        writeFileSync(resolve(contentDir, '_meta.json'), meta);

        included++;
        console.log(`  OK  ${code} -> ${key}`);
    }

    if (included === 0) {
        console.log('No se incluyó ninguna imagen; no se genera ZIP.');
        return;
    }
    rmSync(zipPath, { force: true });
    writeFileSync(zipPath, createZip(zipEntries));
    console.log(`\nPaquete generado: ${zipPath}`);
    console.log(`Contenidos: ${included}. Súbelo manualmente al CMS de la store.`);
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
