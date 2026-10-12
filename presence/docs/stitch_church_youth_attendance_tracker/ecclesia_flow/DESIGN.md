---
name: Ecclesia Flow
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#464555'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#571ac0'
  on-tertiary: '#ffffff'
  tertiary-container: '#6f3dd9'
  on-tertiary-container: '#e3d5ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#e9ddff'
  tertiary-fixed-dim: '#d0bcff'
  on-tertiary-fixed: '#23005c'
  on-tertiary-fixed-variant: '#5516be'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  display:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
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
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
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
  margin-tablet: 32px
---

## Brand & Style
The design system is centered on clarity, reliability, and community engagement. It targets young church members and administrators, requiring a balance between spiritual warmth and modern administrative efficiency. 

The aesthetic follows a **Corporate / Modern** direction with a focus on high legibility and a systematic "App-first" feel. It prioritizes a clean, structured interface that mimics the precision of high-end productivity tools while remaining approachable through soft indigo tones and generous whitespace.

## Colors
The palette is anchored by a deep Indigo primary color, conveying trust and stability. The Emerald green serves as the high-energy accent for successful actions and "present" statuses. 

We use a layered neutral approach:
- **Primary Indigo (#4F46E5):** Used for main actions, active states, and branding.
- **Surface & Background:** A subtle distinction between the main background (#F9FAFB) and pure white cards (#FFFFFF) creates depth without heavy shadows.
- **Semantic Colors:** Red and Orange are reserved strictly for "absent" states, late warnings, or destructive actions.
- **Violet Neutrals:** Used sparingly for decorative elements or secondary category tagging to maintain a sophisticated color harmony.

## Typography
The system utilizes **Inter** for its exceptional readability on mobile screens and its neutral, modern character. 

- **Headlines:** Use tighter letter spacing and semi-bold weights to create a strong visual anchor.
- **Body Text:** Standard weight for maximum legibility. Use `text_secondary` for metadata to maintain hierarchy.
- **Labels:** Uppercase is permitted only for `label-md` when used in small badges or overline headers to differentiate from body content.

## Layout & Spacing
This design system employs a **4px baseline grid** to ensure consistent vertical rhythm. 

- **Mobile Layout:** A 4-column fluid grid with 16px side margins and 16px gutters.
- **Container Strategy:** Content should be grouped in white cards with 16px internal padding. 
- **Vertical Rhythm:** Use 24px (lg) spacing between logical sections and 8px (sm) between related elements within a card.

## Elevation & Depth
Hierarchy is achieved through **Tonal Layering** supplemented by subtle **Ambient Shadows**. 

- **Level 0 (Background):** #F9FAFB.
- **Level 1 (Cards/Surface):** Pure White (#FFFFFF) with a `shadow-sm`: 0px 1px 2px 0px rgba(0, 0, 0, 0.05).
- **Level 2 (Modals/Popovers):** Pure White with a medium shadow: 0px 4px 6px -1px rgba(0, 0, 0, 0.1).
- **Interactions:** Buttons use a very slight inner glow or shadow to appear tactile but stay within the modern flat-plus aesthetic.

## Shapes
The shape language is friendly and contemporary, utilizing significant rounding to reduce visual tension.

- **Cards & Containers:** 16px (`rounded-xl`) to create a distinct "pod" feel for user profiles or event cards.
- **Buttons & Inputs:** 12px (`rounded-lg`) to balance the larger radius of the containers.
- **Badges/Chips:** Fully rounded (pill) for status indicators like "Present" or "Excused."

## Components

### Buttons
- **Primary:** Background #4F46E5, Text #FFFFFF. 12px border radius. Medium weight text.
- **Secondary:** Background #EEF2FF, Text #4F46E5. Used for less prominent actions like "View Details."

### Input Fields
- **Default:** 1px border #E5E7EB, background #FFFFFF, 12px radius.
- **Focus:** 2px border #4F46E5. 

### Attendance Chips
- **Present:** Background #D1FAE5, Text #065F46 (Emerald scale).
- **Absent:** Background #FEE2E2, Text #991B1B (Red scale).
- **Late:** Background #FEF3C7, Text #92400E (Orange scale).

### Lists & Cards
- **User Card:** White background, 16px radius, 16px padding. Includes a circular avatar (40px) and primary/secondary text stack.
- **Actionable List Item:** Subtle chevron-right icon in #9CA3AF to indicate navigability.

### Checkboxes
- Custom 24px square with 6px radius. When checked, use #4F46E5 with a white checkmark.