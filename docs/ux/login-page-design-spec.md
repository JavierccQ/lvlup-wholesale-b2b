# Spec de Diseño — Login Page (Propuesta A aprobada)

## 1. Propósito y Referencias

Guía de referencia del rediseño **aprobado** de la Login Page del storefront B2B
(sesión 2026-07-14). Corresponde a la **Propuesta A ("Panel de marca — split
45/55")** de `docs/ux/login-page-proposals.html`, refinada visualmente con
ChatGPT sobre esa base.

- **Mockup aprobado (fuente de verdad visual):** `docs/ux/login-page-approved-mockup.png`
  (exportado de ChatGPT; guardar el PNG junto a este documento).
- **Propuestas originales A/B:** `docs/ux/login-page-proposals.html`.
- **Vista implementada:** `force-app/.../sfdc_cms__view/login_main/content.json`.
- **CSS:** bloque "Login page" del head markup en
  `force-app/.../sfdc_cms__appPage/mainAppPage/content.json`.

Principio aplicado: _Configuration first_ — el componente estándar
`community_login:loginForm` queda intacto; todo el rediseño es layout de
Experience Builder (sección de 2 columnas + bloques HTML) más CSS global.

## 2. Layout

### Desktop (≥ 768px)

- Sección de **2 columnas: 5/12 (panel de marca) + 7/12 (formulario)** (~42/58,
  aproximación en grid de 12 del split 45/55 del mockup).
- **Columna izquierda — panel de marca** (bloque HTML `lvlup-login-panel`):
  - Fondo: degradado `#1C2049 → #11132C` (150°) + glow radial violeta arriba-izquierda
    (`rgba(109,40,217,.32)`) + glow verde tenue abajo-derecha (`rgba(25,224,139,.10)`).
  - Textura: chevrones diagonales casi imperceptibles (`repeating-linear-gradient`,
    blanco al 2.5%), herencia del motivo "level-up" del logo.
  - Contenido (alineado a la **izquierda**, decisión UX validada — no centrar):
    1. Logo oficial (asset CMS `MCLZA5OAFLIZBLVIGJ7MXPSHXEVA`, ~200px).
    2. Tagline: `Tecnología y gaming al por mayor.` — "gaming" en verde `#19E08B`.
    3. 3 value points con chevron verde `»`:
       `Precios negociados por cuenta` · `Stock y disponibilidad al momento` ·
       `Reorder en un clic desde tu historial`.
    4. Pie anclado abajo: `Portal exclusivo para clientes mayoristas.`
- **Columna derecha — formulario**:
  - Card centrada (max 420px) sobre superficie `#1C2049`, borde
    `rgba(109,40,217,.35)`, radio 10px. Se compone de **dos bloques apilados
    sin costura**: cabecera HTML (`lvlup-login-card-head`: título
    `Accede a tu cuenta` + subtítulo `Introduce tus credenciales de cliente`)
    y el `loginForm` estándar estilizado como parte inferior de la card.

### Mobile (< 768px)

- La sección apila columnas (comportamiento nativo del Builder).
- El panel colapsa a **strip compacto**: logo + tagline centrados; los value
  points y el pie se ocultan (`display:none`).

## 3. Tokens (del branding set `B2B_Commerce` — no inventar valores)

| Uso                                        | Valor                                               |
| ------------------------------------------ | --------------------------------------------------- |
| Fondo página / panel                       | `#11132C` / degradado a `#1C2049`                   |
| Superficie card                            | `#1C2049`                                           |
| CTA (botón Iniciar sesión)                 | fondo `#19E08B`, texto `#06281C`, hover `#39E99E`   |
| Acento links                               | violeta claro `#854BDF`                             |
| Verde de marca (chevrons, "gaming", focus) | `#19E08B`                                           |
| Inputs                                     | blanco, borde `#E5E5E5`, texto `#1A1A1A`, radio 6px |
| Tipografías                                | Space Grotesk (títulos/tagline) · Inter (cuerpo)    |

## 4. Copy (todo en español)

| Elemento          | Texto                                    |
| ----------------- | ---------------------------------------- |
| Label usuario     | `Usuario`                                |
| Label contraseña  | `Contraseña`                             |
| Botón             | `Iniciar sesión`                         |
| Link recuperación | `¿Olvidaste tu contraseña?`              |
| Link alta         | `¿Aún no eres cliente? Solicita tu alta` |
| Título card       | `Accede a tu cuenta`                     |
| Subtítulo card    | `Introduce tus credenciales de cliente`  |

## 5. Interacciones y Accesibilidad

- Focus de inputs: borde + glow verde (`rgba(25,224,139,.25)`), visible con teclado.
- Hover del CTA: `#39E99E`.
- Contraste AA sobre fondos oscuros; el color no es el único portador de estado.
- Sin banners promocionales, fotos de personas ni contenido B2C (principios
  `docs/ux/ux-principles.md`).

## 6. Criterios de Aceptación

- [ ] Desktop: panel de marca a la izquierda (~42%), formulario a la derecha.
- [ ] Logo real visible arriba-izquierda del panel.
- [ ] Card con título dentro y CTA verde (no violeta).
- [ ] Labels y links en español.
- [ ] Mobile: strip compacto (logo + tagline) sobre el formulario.
- [ ] `community_login:loginForm` estándar sin customizar (solo labels + CSS).

## 7. Notas de Implementación

- La "card única" se logra apilando la cabecera HTML (bordes top) y el
  `loginForm` (bordes bottom) con el mismo fondo; si el Builder introduce
  separación entre bloques, ajustar márgenes en el CSS del head markup.
- El CSS vive en el head markup global pero **solo matchea en el login** (las
  clases `lvlup-login-*` y el elemento `community_login-login-form` no existen
  en otras páginas).
- Cambios de vista/CSS requieren **Publish** del sitio (REGLA-007).
