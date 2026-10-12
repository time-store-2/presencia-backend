---
name: Presencia
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0edec'
  surface-container-high: '#ebe7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#464554'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#767586'
  outline-variant: '#c7c4d7'
  surface-tint: '#494bd6'
  primary: '#4648d4'
  on-primary: '#ffffff'
  primary-container: '#6063ee'
  on-primary-container: '#fffbff'
  inverse-primary: '#c0c1ff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#6b38d4'
  on-tertiary: '#ffffff'
  tertiary-container: '#8455ef'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#e9ddff'
  tertiary-fixed-dim: '#d0bcff'
  on-tertiary-fixed: '#23005c'
  on-tertiary-fixed-variant: '#5516be'
  background: '#fcf9f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0.15px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
  max-width: 1200px
---

## Brand & Style
The brand personality is structured, reliable, and modern, designed specifically for youth ministry leaders who require efficiency and clarity. The aesthetic follows a **Corporate / Modern** approach, heavily influenced by Material 3 principles. It prioritizes high legibility and intentional surfaces to manage dense attendance data without cognitive overload.

The target audience is young adult leaders and administrators. The UI should evoke a sense of organized community and "digital-first" professionalism. By utilizing a "Vibrant Indigo" instead of traditional blue, the design system maintains a energetic, modern edge while adhering to strict functional hierarchies. 

The design narrative is built on "Surfaces with Purpose"—using subtle tonal shifts to indicate importance rather than heavy borders or shadows.

## Colors
This design system utilizes a sophisticated Indigo-Emerald palette, strictly avoiding standard Blue to create a unique brand identity. 

- **Primary (Indigo):** Used for key actions, active states, and brand recognition. In dark mode, the indigo is desaturated and brightened (#818CF8) to ensure WCAG AA contrast against charcoal surfaces.
- **Surface Strategy:** We use a neutral grayscale for dark mode (#121212) to avoid "Blue-black" or "Navy" shifts. 
- **Semantic Accents:** 
    - **Emerald:** Represents "Présent" (Present).
    - **Red:** Represents "Absent".
    - **Amber:** Represents "En retard" (Late).
    - **Violet:** Represents "Excusé" (Excused).
- **Text:** Primary text in dark mode uses a high-contrast Slate-off-white (#F1F5F9), while secondary metadata uses a muted Slate-gray (#94A3B8).

## Typography
The typography system uses **Inter** for its neutral, systematic, and highly legible characteristics, essential for a data-entry and management app. 

- **Scale:** All French labels (e.g., "Tableau de bord", "Paramètres") must be accounted for with slightly more horizontal space as French strings are typically 20% longer than English.
- **Hierarchy:** Use `Title-MD` for list items and `Label-LG` for buttons. 
- **Contrast:** On `Surface-Variant` backgrounds, use secondary text colors to maintain a clear visual hierarchy between "Content" and "Description".

## Layout & Spacing
This design system employs a **Fluid Grid** model with fixed maximum widths for desktop environments to maintain readability of list items.

- **Grid:** Use a 4-column grid for mobile, an 8-column grid for tablet, and a 12-column grid for desktop.
- **Gutters:** Standardized 16px (1rem) gutters between all grid cards.
- **Rhythm:** All vertical spacing should be multiples of 4px. Use 16px (MD) for standard padding inside cards and 24px (LG) for section separation.
- **Safe Areas:** Ensure bottom navigation and floating action buttons (FAB) respect device safe areas, particularly on mobile.

## Elevation & Depth
In line with Material 3, we use **Tonal Layers** rather than heavy shadows to denote elevation.

- **Level 0 (Surface):** The base background of the application.
- **Level 1 (Surface-Variant):** Used for search bars, card backgrounds, and inactive navigation elements.
- **Level 2+:** For modals and floating elements, use a very soft, diffused shadow: `0px 4px 20px rgba(0, 0, 0, 0.08)` in light mode, and a slight border in dark mode to provide separation.
- **Interaction:** Upon hover or press, elements should increase their tonal overlay (5-10% primary color tint) rather than increasing shadow depth.

## Shapes
The shape language is friendly yet structured. We use high rounding values to make the application feel approachable and modern.

- **Cards:** 16px (rounded-lg) for container surfaces.
- **Buttons:** 12px (rounded-md) to provide a distinct look from pills or sharp rectangles.
- **Avatars:** Strictly 50% (circular) to signify people/members.
- **Inputs:** 8px (rounded-sm) for text fields to maintain a sense of formal input.

## Components
- **Buttons:** Primary buttons use a solid Indigo fill with White text. Secondary buttons use the Surface-Variant background with Indigo text. Height: 48px for touch targets.
- **Chips:** Used for attendance status. 
    - *Présent:* Emerald background (15% opacity) with Emerald text.
    - *Absent:* Red background (15% opacity) with Red text.
- **Cards:** White or Surface-Variant (#1E1E1E) with 16px corner radius. No border in light mode; 1px border (#2E2E2E) in dark mode.
- **Input Fields:** Outlined style. Label text moves to the top border on focus. Border color changes to Indigo on focus.
- **Lists:** High-density lists for attendance. Each row should be 56px minimum height for mobile accessibility, featuring an avatar (Left), Name/Status (Center), and Toggle/Action (Right).
- **Floating Action Button (FAB):** Rounded 16px square containing the "+" icon, using the primary Indigo color, positioned at the bottom right.