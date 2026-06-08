# CLAUDE.md

Este archivo proporciona orientación a Claude Code (claude.ai/code) al trabajar con el código de este repositorio.

## Idioma

- Mis inputs y nuestras conversaciones serán en español; responde y explica en español.
- **Español** para documentación de contexto, negocio, arquitectura, UX, agentes, análisis funcional, ADRs y evaluaciones.
- **Inglés** para código, nombres de clases/métodos/variables, comentarios técnicos dentro del código, contratos de API y mensajes de commit.
- No mezclar idiomas dentro del mismo archivo, salvo términos técnicos propios del ecosistema Salesforce (p. ej. B2B Commerce, Experience Cloud, Buyer Group, Price Book, LWC, Apex, Flow).

## Descripción del Proyecto

Este es un proyecto de Salesforce DX que implementa un portal de B2B Commerce (Commerce Cloud) para "LvlUp WholeSale". La org utiliza páginas de Digital Experience como UI principal, respaldadas por controladores Apex, con páginas Visualforce para flujos legacy del portal de comunidad. Versión de API: 66.0.

El proyecto es personal, con fines de práctica y construcción de requerimientos de B2B Commerce. La org es Developer Edition, con alias `commerce-b2b-dev`.

## Comandos Comunes

### Desplegar y Recuperar Metadata
```bash
# Desplegar a la org por defecto
sf project deploy start --source-dir force-app

# Desplegar un tipo de metadata o archivo específico
sf project deploy start --source-dir force-app/main/default/classes/MyClass.cls

# Validar un despliegue sin aplicarlo (dry-run)
sf project deploy start --source-dir force-app --dry-run

# Recuperar toda la metadata de la org (usando package.xml)
sf project retrieve start --manifest package.xml

# Recuperar un componente específico
sf project retrieve start --source-dir force-app/main/default/classes

# Consultar el estado de un despliegue
sf project deploy resume --job-id <JobID>

# Abrir la org en el navegador
sf org open --target-org commerce-b2b-dev
```

### Scratch Org
```bash
# Crear scratch org desde la configuración
sf org create scratch --definition-file config/project-scratch-def.json --alias my-scratch-org --set-default

# Subir el source a la scratch org
sf project deploy start

# Traer cambios desde la scratch org
sf project retrieve start
```

### Ejecutar Apex y SOQL
```bash
# Ejecutar Apex anónimo (edita scripts/apex/hello.apex primero)
sf apex run --file scripts/apex/hello.apex

# Ejecutar una consulta SOQL (edita scripts/soql/account.soql primero)
sf data query --file scripts/soql/account.soql
```

### Linting y Formateo
```bash
npm run lint              # ESLint para Aura y LWC
npm run prettier          # Formatea todos los archivos Apex, XML, JSON, YAML
npm run prettier:verify   # Verifica el formato sin escribir cambios
```

### Testing
```bash
npm run test:unit         # Ejecuta todos los tests unitarios Jest de LWC
npm run test:unit:watch   # Modo watch para los tests Jest
npm run test:unit:debug   # Modo debug para los tests Jest

# Ejecutar tests Apex
sf apex run test --test-level RunLocalTests --output-dir ./.testresults

# Ejecutar tests Apex con cobertura, formato legible
sf apex run test --target-org commerce-b2b-dev --code-coverage --result-format human
```

## Arquitectura

### Estructura de Metadata

```
force-app/main/default/
├── classes/           # Apex (20 clases: controladores de login/password/self-reg de comunidad + tests)
├── digitalExperiences/# UI principal del portal (67 vistas a través de breakpoints, 2 sites)
│   ├── site/LevelUp_Wholesale1/  # Site principal del portal B2B
│   └── site/sfpwebhook1/         # Site de webhook/integración
├── flows/             # 7 flows de automatización de negocio
├── flexipages/        # 16 Lightning record pages
├── objects/Account/   # 43 campos custom para datos de buyer/seller B2B
├── pages/             # 23 páginas Visualforce (portal de comunidad legacy)
├── components/        # 4 componentes Visualforce
├── permissionsets/    # 2 permission sets
├── permissionsetgroups/ # 19 permission set groups
└── remoteSiteSettings/  # 10 endpoints de integración con APIs externas
```

### Decisiones Arquitectónicas Clave

**UI de dos capas**: El portal tiene tanto páginas de Digital Experience (modernas, principales) como páginas Visualforce (fallback legacy/flujos del portal de comunidad). Las vistas de Digital Experience se almacenan como JSON bajo `digitalExperiences/site/LevelUp_Wholesale1/`.

**Control de acceso**: 19 permission set groups controlan el acceso a funcionalidades para los roles de buyer/seller B2B. Cualquier funcionalidad nueva probablemente requiera actualizar un permission set.

**Integraciones externas**: 10 remote site settings definen los endpoints externos permitidos. Las nuevas llamadas salientes (callouts) requieren una nueva entrada de `RemoteSiteSettings` antes de funcionar.

**Modelo de datos centrado en Account**: La personalización de buyer/seller B2B vive en el objeto Account (43 campos custom). Es el hub para las cuentas de buyer, los niveles de pricing y las configuraciones de wholesale.

**Controladores Apex**: Las clases en `force-app/main/default/classes/` sirven principalmente como controladores de páginas del portal de comunidad (login, self-registration, gestión de contraseñas). Siguen el patrón de nomenclatura `*Controller.cls` + `*ControllerTest.cls`.

### Arquitectura de B2B Commerce

- El store es un sitio LWR; la UI vive en el DigitalExperienceBundle.
- Objetos clave del data model: WebStore, Product2, ProductCatalog, ProductCategory, Pricebook2/PricebookEntry, BuyerGroup, CommerceEntitlementPolicy.
- **Importante**: el catálogo, los productos, los precios y los entitlements son DATOS (registros), no metadata. No mezclar el deploy de metadata con la migración de registros (Data Loader / `sf data`).

### Pre-commit Hooks

Husky ejecuta `lint-staged` en cada commit, que auto-formatea los archivos en staging con Prettier y verifica LWC/Aura con ESLint. Si un commit es bloqueado, ejecuta `npm run prettier` y `npm run lint` para corregir los problemas antes de reintentar.

### Configuración de la Scratch Org

La scratch org (`config/project-scratch-def.json`) es de edición Developer con Lightning Experience habilitado. La feature `EnableSetPasswordInApi` es necesaria para los flujos de self-registration de comunidad.