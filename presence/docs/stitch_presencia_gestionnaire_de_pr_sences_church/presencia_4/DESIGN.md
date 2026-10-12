---
name: Presencia
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#464554'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#767586'
  outline-variant: '#c7c4d7'
  surface-tint: '#494bd6'
  primary: '#4648d4'
  on-primary: '#ffffff'
  primary-container: '#6063ee'
  on-primary-container: '#fffbff'
  inverse-primary: '#c0c1ff'
  secondary: '#6b38d4'
  on-secondary: '#ffffff'
  secondary-container: '#8455ef'
  on-secondary-container: '#fffbff'
  tertiary: '#904900'
  on-tertiary: '#ffffff'
  tertiary-container: '#b55d00'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d0bcff'
  on-secondary-fixed: '#23005c'
  on-secondary-fixed-variant: '#5516be'
  tertiary-fixed: '#ffdcc5'
  tertiary-fixed-dim: '#ffb783'
  on-tertiary-fixed: '#301400'
  on-tertiary-fixed-variant: '#703700'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.2'
  title-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 24px
  margin: 32px
---

## Brand & Style
The design system is built for a presence-tracking and status platform that prioritizes clarity, modern efficiency, and a sophisticated aesthetic. The brand personality is professional yet energetic, moving away from traditional corporate blues in favor of a vibrant, high-energy Indigo. 

The style is **Corporate Modern with a Minimalist lean**. It utilizes a clean, systematic approach to information density, emphasizing high-contrast semantic states to communicate status at a glance. The interface should feel "breathable" with generous whitespace, crisp typography, and subtle depth to guide the user's focus toward actionable data.

## Colors
This design system strictly avoids blue tones, utilizing **Vibrant Indigo** (#6366F1) as the core brand anchor. The palette is designed for high legibility and clear categorization through semantic color-coding.

- **Primary (Indigo):** Used for primary actions, active states, and brand-heavy moments.
- **Success/Present (Emerald):** Denotes positive status or attendance.
- **Danger/Absent (Red):** Flags critical errors or missing status.
- **Warning/Late (Amber):** Indicates caution or delayed status.
- **Excused (Violet):** A distinct, neutral-positive state for approved absences.

In dark mode, surfaces shift to deep charcoals and near-blacks to maintain contrast without the use of navy or midnight blue undertones.

## Typography
**Inter** is the sole typeface for the design system, chosen for its exceptional legibility in data-heavy environments. The typographic scale is highly structured to create a clear information hierarchy.

- **Headlines:** Use tighter letter spacing and heavier weights to create impact and structure.
- **Body Text:** Standardized at 16px for optimal readability, utilizing a 1.6 line height to prevent visual fatigue.
- **Labels:** Small caps and increased letter spacing are used for secondary metadata and status labels to differentiate them from body content.

## Layout & Spacing
The layout follows a **Fluid Grid** model with fixed maximum widths for content readability. A base 4px unit (soft grid) governs all spacing decisions to ensure visual rhythm.

- **Desktop:** 12-column grid, 24px gutters, 32px minimum margins.
- **Tablet:** 8-column grid, 16px gutters, 24px margins.
- **Mobile:** 4-column grid, 16px gutters, 16px margins.

Spacing should be used to group related elements: use `md` (16px) for internal card padding and `xl` (40px) to separate major sections of the interface.

## Elevation & Depth
Depth is conveyed through **Tonal Layers** and extremely soft **Ambient Shadows**. This design system avoids heavy shadows, opting instead for subtle border-strokes to define boundaries.

- **Level 0 (Canvas):** Pure white or light gray background.
- **Level 1 (Cards):** Resting state with a 1px border (#E5E7EB) and a faint, diffused shadow (0px 4px 20px rgba(0,0,0,0.05)).
- **Level 2 (Hover/Popovers):** Slightly more pronounced shadow to indicate interactivity.
- **Dark Mode:** Depth is achieved exclusively through tonal shifting (lighter grays for elevated surfaces) rather than shadows.

## Shapes
The shape language is friendly yet professional, utilizing **Rounded** corners to soften the technical nature of status tracking. 

- **Cards:** Use a generous 16px radius to frame content blocks.
- **Buttons:** Use a 12px radius, creating a distinct "squircle" look that feels modern and approachable.
- **Inputs & Small Components:** Use 8px for a tighter, more functional appearance.

## Components
- **Buttons:** High-contrast Indigo for primary actions. Text is always bold. Use 12px corner radius.
- **Status Chips:** Use semantic background colors with 10% opacity and 100% opacity text of the same color (e.g., Emerald text on a light Emerald tint).
- **Cards:** 16px corner radius, white background, 1px light gray border. Use for grouping user profiles or daily logs.
- **Inputs:** Minimalist with a focus on the active state; the border should transition to Indigo (#6366F1) on focus with a subtle glow.
- **Attendance Lists:** Use "zebra-striping" with the light gray canvas color (#F8F9FA) for readability in dense tables.
- **Presence Indicators:** Small, circular dots using the semantic palette to show real-time status next to user avatars.