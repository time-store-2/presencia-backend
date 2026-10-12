---
name: Kindred Path
colors:
  surface: '#fbf8ff'
  surface-dim: '#d6d8f9'
  surface-bright: '#fbf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f2ff'
  surface-container: '#edecff'
  surface-container-high: '#e6e6ff'
  surface-container-highest: '#dfe0ff'
  on-surface: '#161a32'
  on-surface-variant: '#404943'
  inverse-surface: '#2b2e48'
  inverse-on-surface: '#f1efff'
  outline: '#707973'
  outline-variant: '#bfc9c1'
  surface-tint: '#2c694e'
  primary: '#0f5238'
  on-primary: '#ffffff'
  primary-container: '#2d6a4f'
  on-primary-container: '#a8e7c5'
  inverse-primary: '#95d4b3'
  secondary: '#9a442d'
  on-secondary: '#ffffff'
  secondary-container: '#fc9174'
  on-secondary-container: '#742814'
  tertiary: '#49483b'
  on-tertiary: '#ffffff'
  tertiary-container: '#616051'
  on-tertiary-container: '#dddbc8'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b1f0ce'
  primary-fixed-dim: '#95d4b3'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#0e5138'
  secondary-fixed: '#ffdbd2'
  secondary-fixed-dim: '#ffb4a1'
  on-secondary-fixed: '#3c0800'
  on-secondary-fixed-variant: '#7c2e19'
  tertiary-fixed: '#e6e3d0'
  tertiary-fixed-dim: '#c9c7b5'
  on-tertiary-fixed: '#1c1c11'
  on-tertiary-fixed-variant: '#48473a'
  background: '#fbf8ff'
  on-background: '#161a32'
  surface-variant: '#dfe0ff'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
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
  lg: 48px
  xl: 80px
  container-max: 1200px
  gutter: 24px
---

## Brand & Style
The design system is built on a foundation of organic warmth and human-centric clarity, catering to users who value growth, community, and mindful interaction. The aesthetic balances **Minimalism** with **Tactile** warmth, utilizing generous whitespace to ensure the interface feels "airy" and approachable. 

The emotional response should be one of calm reliability—moving away from sterile corporate tech toward a "digital sanctuary" feel. Soft shadows, natural color transitions, and rounded geometry work together to create an inviting environment for both personal reflection and social connection.

## Colors
This design system uses a palette inspired by the natural world. The **Forest Green** (#2d6a4f) serves as the primary anchor for action states and brand presence, while **Terracotta** (#e07a5f) provides a warm, energetic secondary accent for highlights and notifications.

For the **Dark Mode** variation, the background shifts to a deep charcoal-obsidian to maintain contrast without harshness. Surfaces in dark mode use a subtle elevation tint to differentiate from the background. Data visualization should utilize desaturated versions of the primary and secondary colors to ensure accessibility and legibility against dark backgrounds.

## Typography
The system relies exclusively on **Plus Jakarta Sans** for its friendly, open apertures and modern geometric structure. 

- **Headlines:** Use Bold (700) weights with slightly tighter letter-spacing to create a sense of grounded authority.
- **Body:** Use Regular (400) weight for maximum readability. The line height is intentionally generous (1.5x - 1.6x) to maintain the "airy" feel.
- **Labels:** Use Medium (500) or SemiBold (600) for UI elements like buttons, chips, and navigation items to ensure they stand out against body text.

## Layout & Spacing
The layout follows a **Fluid Grid** model with a 12-column structure for desktop and a 4-column structure for mobile. 

- **Margins:** 24px on mobile, increasing to 48px or "Auto" (centered container) on desktop.
- **Rhythm:** All spacing must be a multiple of the 8px base unit. 
- **Account Management:** For login and signup flows, use a centered, narrow column (max-width: 400px) to maintain focus and reduce cognitive load.
- **Data Viz:** Charts should be contained within cards that have a minimum internal padding of 24px (md) to prevent visual clutter.

## Elevation & Depth
Hierarchy is established through **Tonal Layers** and soft, ambient shadows. 

- **Level 0 (Background):** Flat, base color.
- **Level 1 (Cards/Sheet):** Surface color with a very soft, diffused shadow (15% opacity primary color tint, 20px blur, 4px Y-offset).
- **Level 2 (Dropdowns/Modals):** Higher contrast shadow with a slight "glow" effect using the secondary color at 5% opacity to suggest interactivity.
- **Interactive States:** On hover, cards should subtly lift (Y-offset increases) and the shadow should slightly expand, creating a tactile "spring" feel.

## Shapes
The shape language is defined by significant corner rounding to mirror the "friendly and approachable" brand pillars.

- **Cards:** Strictly 20px radius to provide a soft, organic frame for content.
- **Buttons:** Fully pill-shaped (100px) for primary actions to distinguish them clearly from layout containers.
- **Inputs:** 12px radius, offering a balance between the structure of a card and the softness of a button.
- **Chips:** 8px radius for filter chips, ensuring they look distinct from buttons when used in dense filter bars.

## Components

### Account Management
- **Input Fields:** Use a subtle background fill (surface-alt) in the resting state, moving to a white/dark-surface fill with a 2px Forest Green border on focus.
- **Login/Signup Cards:** Centered containers using the 20px radius, featuring a large brand mark at the top.

### Filter Chips
- **States:** Unselected chips use a low-contrast border. Selected chips use a Forest Green background with white text. 
- **Closable:** Advanced filters should include a small "X" icon (16px) for quick removal.

### Data Visualization
- **Charts:** Use a 2px stroke width for line charts.
- **Trend Indicators:** Upward trends use Primary Green; downward trends use a soft muted red (avoid the vibrant Terracotta for negative trends to prevent brand confusion).
- **Tooltips:** Use the 20px card radius but scaled down, with a backdrop blur (Glassmorphism) effect.

### Buttons
- **Primary:** Forest Green background, white text.
- **Secondary:** Transparent background, Forest Green border, 1.5px stroke.
- **Ghost:** Text-only with Forest Green color, used for low-priority actions like "Cancel" or "Skip".