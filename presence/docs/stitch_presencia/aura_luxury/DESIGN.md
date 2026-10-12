---
name: Aura Luxury
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1b1b1b'
  on-surface-variant: '#4c4546'
  inverse-surface: '#303030'
  inverse-on-surface: '#f1f1f1'
  outline: '#7e7576'
  outline-variant: '#cfc4c5'
  surface-tint: '#5e5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1b1b1b'
  on-primary-container: '#848484'
  inverse-primary: '#c6c6c6'
  secondary: '#5c5f60'
  on-secondary: '#ffffff'
  secondary-container: '#e1e3e4'
  on-secondary-container: '#626566'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#161c22'
  on-tertiary-container: '#7e848c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2e2e2'
  primary-fixed-dim: '#c6c6c6'
  on-primary-fixed: '#1b1b1b'
  on-primary-fixed-variant: '#474747'
  secondary-fixed: '#e1e3e4'
  secondary-fixed-dim: '#c5c7c8'
  on-secondary-fixed: '#191c1d'
  on-secondary-fixed-variant: '#454748'
  tertiary-fixed: '#dde3eb'
  tertiary-fixed-dim: '#c1c7cf'
  on-tertiary-fixed: '#161c22'
  on-tertiary-fixed-variant: '#41474e'
  background: '#f9f9f9'
  on-background: '#1b1b1b'
  surface-variant: '#e2e2e2'
typography:
  display-lg:
    fontFamily: Playfair Display
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Playfair Display
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Playfair Display
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-md:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0.05em
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 26px
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.1em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 20px
  margin-desktop: 64px
  section-gap: 80px
---

## Brand & Style

The design system is engineered for a high-end AI e-commerce experience where exclusivity meets intelligence. The brand personality is sophisticated, calm, and hyper-curated, targeting a discerning audience that values time and aesthetic precision.

The visual direction combines **Minimalism** with **Glassmorphism**. It utilizes expansive white space to denote luxury and breathing room, while employing frosted, translucent layers to signify the "AI" or digital intelligence layer—invisible yet pervasive. The emotional response is one of effortless prestige: the interface should feel less like a tool and more like a digital concierge.

## Colors

The palette is anchored in a high-contrast monochromatic base, accented by ethereal gradients that represent AI interaction points.

- **Primary (Crisp Black):** Used for critical typography and primary actions to ensure authority and readability.
- **Secondary (Off-White):** A soft, warm white used for backgrounds to reduce eye strain compared to pure white, maintaining a premium feel.
- **Sophisticated Gradients:** Subtle, multi-stop transitions (Indigo to Rose) are reserved for active AI states, progress indicators, or premium highlights.
- **Glass Stroke:** A semi-transparent white or silver border used to define edges on glassmorphic containers.

## Typography

This design system utilizes a classic pairing of a high-contrast Serif and a technical Sans-Serif.

- **Headlines:** `Playfair Display` provides an editorial, fashion-forward tone. It should be used for product names and major section titles.
- **UI & Body:** `Manrope` is used for its modern, balanced proportions. For UI labels, increased letter-spacing is applied to enhance the "luxury" feel and improve legibility at small sizes.
- **AI Text:** When the AI is "speaking" or processing, use `Manrope` in a medium weight with subtle tracking to distinguish it from standard product descriptions.

## Layout & Spacing

The layout philosophy is based on a **Fluid Grid** with intentional "dead zones" of whitespace to emphasize hero imagery. 

- **Grid:** A 12-column grid for desktop, 8-column for tablet, and 4-column for mobile.
- **Whitespace:** Employs a generous 8px base unit. Section gaps are intentionally large (80px+) to ensure the interface never feels cluttered.
- **Alignment:** Centralized content blocks for luxury storytelling, with left-aligned data for utility-heavy views (like bidding or specs).

## Elevation & Depth

Hierarchy is achieved through **Glassmorphism** and tonal stacking rather than heavy shadows.

- **Surface Tiers:** Backgrounds use the `surface_off_white`. Secondary containers use a translucent blur (20px-30px) with a 1px solid white border at 20% opacity.
- **Shadows:** Use only one type of shadow: a very soft, "Ambient" shadow for floating elements. 
  - *Specs:* 0px 12px 32px rgba(0, 0, 0, 0.04).
- **Interactive Depth:** When a card or button is hovered, the backdrop-blur intensity increases slightly, and the border opacity rises.

## Shapes

The design system uses a **Pill-shaped** geometry. This extreme roundedness suggests a "soft" intelligence—friendly, approachable, yet modern. All buttons, input fields, and tags should follow the pill convention. 

Larger containers (cards, image blocks) should use `rounded-xl` (3rem/48px) to maintain harmony with the pill elements while providing enough internal space for content.

## Components

### Buttons
- **Primary:** Pill-shaped, solid black background with white `label-caps` text. No shadow.
- **Secondary/AI:** Pill-shaped, glassmorphic (blurred) background with a subtle gradient border.

### Cards
- **Product Card:** `rounded-xl` corners. Background is either a soft off-white or a glass blur. 1px light border. Images should have a subtle inner-glow to feel "embedded" into the surface.

### Inputs & Search
- **AI Search Bar:** A large, pill-shaped input with a glassmorphic fill. Use the gradient sparingly for the "Send" or "Ask" button within the input.

### Chips & Badges
- Used for categories (e.g., "Luxury," "Daily"). Always pill-shaped. Active states use a soft grey fill or a thin black outline.

### Lists
- High vertical padding between items (16px-24px). Use thin, 1px horizontal dividers in a light grey (`tertiary_color_hex`) at 50% opacity.