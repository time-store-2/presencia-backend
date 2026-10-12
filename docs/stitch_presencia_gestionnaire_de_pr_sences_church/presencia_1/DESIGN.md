---
name: Presencia
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daef'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3ff'
  surface-container: '#e9edff'
  surface-container-high: '#e1e8fd'
  surface-container-highest: '#dce2f7'
  on-surface: '#141b2b'
  on-surface-variant: '#464555'
  inverse-surface: '#293040'
  inverse-on-surface: '#edf0ff'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#585f6c'
  on-secondary: '#ffffff'
  secondary-container: '#dce2f3'
  on-secondary-container: '#5e6572'
  tertiary: '#7e3000'
  on-tertiary: '#ffffff'
  tertiary-container: '#a44100'
  on-tertiary-container: '#ffd2be'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#dce2f3'
  secondary-fixed-dim: '#c0c7d6'
  on-secondary-fixed: '#151c27'
  on-secondary-fixed-variant: '#404754'
  tertiary-fixed: '#ffdbcc'
  tertiary-fixed-dim: '#ffb695'
  on-tertiary-fixed: '#351000'
  on-tertiary-fixed-variant: '#7b2f00'
  background: '#f9f9ff'
  on-background: '#141b2b'
  surface-variant: '#dce2f7'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
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
---

## Brand & Style

The design system is built on a foundation of **Modern Corporate** aesthetics, heavily influenced by Material 3 principles. It prioritizes clarity, utility, and a sense of "digital hospitality" for church administrators and youth leaders. 

The visual language is structured, reliable, and highly accessible, utilizing a clean grid and purposeful color application. By blending a systematic approach with soft geometry, the design system achieves a professional yet approachable feel that ensures the focus remains on people and attendance data rather than the interface itself.

## Colors

This design system utilizes an adaptive palette designed to transition seamlessly between light and dark modes while strictly avoiding deep blue tones in the dark theme to maintain a neutral, slate-like depth.

- **Primary Indigo:** Acts as the high-energy focal point for actions and active states. In dark mode, the primary shifts to a higher luminance to ensure AAA accessibility.
- **Semantic Logic:** Success (Emerald) and Danger (Red) are used for attendance marking (Present/Absent).
- **Surface Strategy:** Light mode uses a subtle off-white to reduce glare, while dark mode uses a tiered grayscale (#121212 to #1E1E1E) to create depth without relying on traditional navy or midnight blues.

## Typography

The design system employs **Inter** as its sole typeface to leverage its exceptional legibility and systematic feel. 

- **Headlines:** Use tighter letter spacing and semi-bold/bold weights to create a strong information hierarchy.
- **Labels:** Small labels use increased letter spacing and medium weights to ensure readability at small scales, particularly in data-heavy attendance lists.
- **Body:** Standardized at 16px for primary reading tasks to ensure the app remains accessible to users of all ages.

## Layout & Spacing

The layout is governed by a **4px baseline grid** and a flexible fluid column system.

- **Mobile:** 4-column grid with 16px margins. Primary interaction areas (like attendance buttons) should span the full width or 2 columns.
- **Tablet/Desktop:** 12-column grid with a max-width container of 1200px. Content is centered with 32px margins.
- **Rhythm:** Vertical spacing between cards and list items follows the `md` (16px) unit, while internal padding within cards uses `lg` (24px) for a spacious, premium feel.

## Elevation & Depth

Hierarchy is established through **Tonal Layering** in dark mode and **Subtle Shadows** in light mode.

- **Light Mode:** Uses `shadow-sm` (0 1px 2px 0 rgba(0, 0, 0, 0.05)) for standard cards. Floating Action Buttons (FAB) and Modals use a more pronounced elevation to indicate they sit above the primary surface.
- **Dark Mode:** Shadows are largely replaced by "Surface Tints." Higher elevation elements use the `Surface-Container` (#1E1E1E) color. A very soft, low-opacity primary-colored glow (2-4% opacity) may be applied to active cards to signify focus without looking "heavy."

## Shapes

The shape language is friendly and modern, utilizing varied radii to distinguish between containers and interactive elements.

- **Containers:** Large cards use a 16px radius to feel soft and approachable.
- **Interactions:** Buttons use a 12px radius, providing a distinct "squircle" look that aligns with Material 3's evolved aesthetic.
- **Identity:** User and student avatars are always circular (50% radius) to differentiate human elements from structural UI components.

## Components

### Buttons
- **Primary:** Filled with Primary Indigo, 12px roundedness.
- **Secondary:** Outlined with a 1px border using Secondary Gray.
- **Attendance Toggles:** Large, tactile buttons. "Present" uses a Success Green fill when active; "Absent" uses a Danger Red fill when active.

### Cards
- **Student Cards:** 16px roundedness. Includes a leading avatar, student name as `label-lg`, and a trailing status icon.
- **Summary Cards:** Use `Surface-Container` in dark mode to group statistics like "Total Attendance."

### Input Fields
- **Search & Text Entry:** 8px roundedness. In light mode, uses a subtle 1px gray border. In dark mode, uses a filled style with `Surface-Container` background and no border unless focused.

### Chips
- **Status Tags:** Used for "Visitor," "Leader," or "Member." Small 12px height with `label-md` typography and 4px roundedness.

### Lists
- **Attendance List:** Elements are separated by 8px of vertical space rather than dividers to maintain a modern, airy feel. Each list item should have a minimum touch target height of 56px.