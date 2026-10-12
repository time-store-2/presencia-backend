---
name: Ethereal Serenity
colors:
  surface: '#111413'
  surface-dim: '#111413'
  surface-bright: '#373a39'
  surface-container-lowest: '#0c0f0e'
  surface-container-low: '#191c1b'
  surface-container: '#1d201f'
  surface-container-high: '#282b29'
  surface-container-highest: '#323534'
  on-surface: '#e1e3e1'
  on-surface-variant: '#c2c8c4'
  inverse-surface: '#e1e3e1'
  inverse-on-surface: '#2e3130'
  outline: '#8c928e'
  outline-variant: '#424845'
  surface-tint: '#b1cdc1'
  primary: '#c3dfd3'
  on-primary: '#1d352d'
  primary-container: '#a8c3b8'
  on-primary-container: '#395148'
  inverse-primary: '#4b645a'
  secondary: '#a0cfcc'
  on-secondary: '#003735'
  secondary-container: '#1e4e4c'
  on-secondary-container: '#8fbeba'
  tertiary: '#d6dad8'
  on-tertiary: '#2d3130'
  tertiary-container: '#babebc'
  on-tertiary-container: '#484d4c'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#cde9dd'
  primary-fixed-dim: '#b1cdc1'
  on-primary-fixed: '#072019'
  on-primary-fixed-variant: '#334c43'
  secondary-fixed: '#bbece8'
  secondary-fixed-dim: '#a0cfcc'
  on-secondary-fixed: '#00201f'
  on-secondary-fixed-variant: '#1e4e4c'
  tertiary-fixed: '#dfe3e1'
  tertiary-fixed-dim: '#c3c7c6'
  on-tertiary-fixed: '#181c1c'
  on-tertiary-fixed-variant: '#434847'
  background: '#111413'
  on-background: '#e1e3e1'
  surface-variant: '#323534'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '600'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.3'
    letterSpacing: 0em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: 0.01em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.4'
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.4'
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  container-padding-mobile: 20px
  container-padding-desktop: 120px
  gutter: 16px
---

## Brand & Style

This design system is built on the principles of **Glassmorphism** and **Soft Minimalism**, specifically tailored for a mental health and community context. The brand personality is empathetic, tranquil, and deeply professional. It aims to reduce cognitive load and provide a "digital sanctuary" for users.

The visual language utilizes high-diffusion background blurs, organic layering, and ethereal light sources to create a sense of depth without weight. The experience should feel like looking through a frosted window onto a calm morning landscape.

**Design Principles:**
- **Translucency:** Every container should feel like light, frosted glass.
- **Organic Depth:** Use subtle environmental lighting rather than harsh shadows.
- **Spaciousness:** Generous negative space to encourage breathing room.
- **Clarity:** Despite the ethereal aesthetic, functional elements must remain highly legible and accessible.

## Colors

The palette is inspired by misty mornings and forest floors. It uses a range of desaturated greens and teals to evoke a sense of safety and renewal.

- **Primary (Soft Sage):** Used for key actions and highlights. It is a healing, neutral green.
- **Secondary (Misty Teal):** Used for depth, accents, and secondary information.
- **Surface (Glass):** A semi-transparent white (`rgba(255, 255, 255, 0.12)`) with a high backdrop-blur (40px-60px).
- **Text:** High-contrast off-whites for readability against dark or busy backgrounds, and muted teals for less critical information.

The background should always consist of high-quality, out-of-focus natural scenery photography with a dark overlay to ensure text contrast.

## Typography

This design system uses **Plus Jakarta Sans** for its modern, clean, and approachable character. The typography relies on generous line heights and increased letter spacing for body text to ensure maximum readability and a relaxed feel.

- **Display & Headlines:** Use medium weights to maintain a soft but authoritative presence. Letter spacing is slightly tightened to keep the words visually cohesive.
- **Body Text:** Use regular weights with increased leading (line height) to create an "airy" reading experience.
- **Labels:** Small labels utilize a higher tracking (letter-spacing) and a semi-bold weight to ensure clarity even at reduced sizes on translucent backgrounds.

## Layout & Spacing

The layout philosophy is centered around a **fluid grid** with wide margins to create a sense of focus.

- **Mobile:** A 4-column system with 20px side margins and 16px gutters.
- **Desktop:** A 12-column system with a max-width of 1440px, centered on the screen, with 120px side margins.
- **Rhythm:** All spacing (margins, padding, gaps) follows a base-8 increment system to maintain mathematical harmony while allowing for the visual "softness" of the brand.

Elements should be grouped into cards with significant vertical spacing (`lg` or `xl`) between distinct sections to avoid visual clutter and overwhelming the user.

## Elevation & Depth

Hierarchy is communicated through **translucency and backdrop-blur intensity** rather than traditional drop shadows.

- **Level 1 (Base Cards):** Background blur of 40px, 12% white fill, and a 1px white border at 15% opacity.
- **Level 2 (Modals/Popovers):** Background blur of 60px, 18% white fill, and a 1px white border at 25% opacity. Includes a soft, large-radius "glow" shadow (e.g., `0 20px 40px rgba(0,0,0,0.1)`).
- **Environmental Light:** Subtle, non-directional gradients may be placed behind glass elements to suggest a soft light source, enhancing the "ethereal" quality.

## Shapes

The shape language is organic and soft. Sharp corners are avoided to maintain a welcoming and safe environment.

- **Primary Containers:** 1rem (16px) corner radius for most cards and sections.
- **Interactive Elements:** Buttons and tags utilize a **pill-shape** (fully rounded) to differentiate them from static content containers.
- **Icons:** Icons should feature rounded terminals and consistent stroke weights (1.5px or 2px) to match the softness of the UI.

## Components

### Buttons
- **Primary:** Pill-shaped, solid white or soft sage green text on a high-blur glass background. For high-emphasis actions, use a solid white background with dark teal text.
- **Secondary/Ghost:** Pill-shaped, 1px white border (30% opacity) with white text.

### Cards
All cards must use the glass effect defined in the Elevation section. Padding within cards should be generous (typically `md` or 24px).

### Input Fields
Inputs are pill-shaped or rounded containers with a subtle `rgba(255,255,255,0.08)` fill and a 1px border. Placeholder text should be a muted teal or soft white.

### Chips & Tags
Small, pill-shaped elements used for categorization. They use a slightly more opaque background blur to stand out from the parent card.

### Progress Indicators
Progress bars should be thin and use a soft sage green as the active color, with a highly desaturated, low-opacity teal as the track.

### Navigation
Bottom navigation on mobile should be a floating glass bar with a 32px-40px radius, using minimal line-art icons and label text only for the active state.