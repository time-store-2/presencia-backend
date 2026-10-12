---
name: Kindred Path
colors:
  surface: '#f8faf6'
  surface-dim: '#d8dbd7'
  surface-bright: '#f8faf6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f0'
  surface-container: '#eceeea'
  surface-container-high: '#e7e9e5'
  surface-container-highest: '#e1e3df'
  on-surface: '#191c1a'
  on-surface-variant: '#404943'
  inverse-surface: '#2e312f'
  inverse-on-surface: '#eff1ed'
  outline: '#707973'
  outline-variant: '#bfc9c1'
  surface-tint: '#2c694e'
  primary: '#0f5238'
  on-primary: '#ffffff'
  primary-container: '#2d6a4f'
  on-primary-container: '#a8e7c5'
  inverse-primary: '#95d4b3'
  secondary: '#4c6357'
  on-secondary: '#ffffff'
  secondary-container: '#cfe9d8'
  on-secondary-container: '#526a5c'
  tertiary: '#713638'
  on-tertiary: '#ffffff'
  tertiary-container: '#8d4d4e'
  on-tertiary-container: '#ffcfce'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b1f0ce'
  primary-fixed-dim: '#95d4b3'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#0e5138'
  secondary-fixed: '#cfe9d8'
  secondary-fixed-dim: '#b3ccbd'
  on-secondary-fixed: '#092016'
  on-secondary-fixed-variant: '#354c3f'
  tertiary-fixed: '#ffdad9'
  tertiary-fixed-dim: '#ffb3b3'
  on-tertiary-fixed: '#390b0e'
  on-tertiary-fixed-variant: '#6f3537'
  background: '#f8faf6'
  on-background: '#191c1a'
  surface-variant: '#e1e3df'
typography:
  display:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-bold:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: 0.05em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.2'
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: '1.3'
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
  xl: 32px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 40px
---

## Brand & Style

The design system is built upon a foundation of warmth, community, and human connection. Designed specifically for church youth management, the aesthetic moves away from cold, systematic "tech" vibes in favor of an airy, approachable, and professional atmosphere. 

The style utilizes a **Modern Minimalist** approach with a **Tactile** edge. It prioritizes clarity and breathing room (whitespace) to reduce cognitive load for volunteers and leaders. By combining natural, earthy tones with soft geometry, the UI feels like a digital extension of a physical community space—reliable and organized, yet deeply welcoming.

## Colors

The palette is anchored by **Forest Green**, signaling growth and vitality, balanced by a **Terracotta** accent that provides warmth without the aggression of a standard red. 

- **Primary & Earth Tones:** Use Forest Green for primary actions and brand presence. Use Soft Brown for secondary statuses to maintain the organic feel.
- **Surface Strategy:** The "Warm Off-White" page background prevents screen fatigue. Use "Secondary Background" (Cream) to differentiate sections within a page without using heavy borders.
- **Functional States:** Status colors follow a "Muted-High-Contrast" logic—text is dark and legible, while backgrounds are desaturated and airy to ensure the interface doesn't feel cluttered when viewing large lists of names.

## Typography

This design system uses **Plus Jakarta Sans** for its friendly, modern, and highly legible character. 

- **Weight Contrast:** High contrast between Bold (700-800) titles and Regular (400) body text creates a clear hierarchy.
- **Editorial Touch:** Large display titles should use tighter letter-spacing (-0.02em) to feel more cohesive and professional.
- **Readability:** Body text uses a generous 1.6 line-height to ensure that student lists and notes are easy to scan during busy events.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** model with generous safe areas. 

- **Mobile First:** Given the use case (attendance on the go), the system prioritizes a single-column layout on mobile with 20px side margins.
- **Rhythm:** A 4px baseline grid ensures consistent vertical rhythm. Standard components (Inputs, Buttons) should typically be 48px or 56px in height to remain "finger-friendly."
- **Sectioning:** Use `spacing.xl` to separate major content groups. Use `spacing.md` for elements within a card or list item.

## Elevation & Depth

This design system avoids heavy shadows and floating effects to maintain its "airy" and "grounded" personality.

- **Tonal Depth:** Depth is primarily achieved through color layering rather than shadows. Cards sit on the Page Background (`#FAFAF8`) with a simple white fill and a subtle 1px border.
- **Subtle Shadow:** For primary containers (Cards), a very soft shadow is used: `0 1px 3px rgba(0,0,0,0.05)`. This provides just enough lift to signify interactability without feeling "techy."
- **Active States:** When an element is pressed, it should not lift further; instead, it should slightly darken or use a subtle inner stroke to feel "pressed" into the surface.

## Shapes

The shape language is "Organic Geometric." High corner radii are used to evoke a sense of softness and safety.

- **Cards:** Use `20px` to create a friendly, containerized look.
- **Buttons:** A `14px` radius strikes a balance between professional and approachable.
- **Inputs:** A slightly tighter `12px` radius helps inputs feel distinct from action buttons.
- **Badges:** `8px` ensures they remain readable while still feeling like part of the same family.

## Components

### Buttons
- **Primary:** Forest Green background, White text. Bold 14px radius. 
- **Accent:** Terracotta background, White text. Reserved for the most important "Check-In" or "Add Student" actions.
- **Ghost:** Primary color border and text, transparent background.

### Cards & Lists
- **Attendance Card:** White background, 20px radius, 1px Border (`#E8E8E4`). Includes a left-hand accent strip or icon in the student's status color.
- **List Items:** Use `spacing.md` padding. Bottom border only (`#F0F0EC`) for list items to maintain an airy feel.

### Form Inputs
- **Style:** Background `#F7F7F5`, no border in default state. On focus, add a 2px solid Forest Green border.
- **Labels:** Use `label-bold` in Secondary Text color.

### Navigation
- **Bottom Bar:** Fixed to the bottom. Background `#FFFFFF` with a 1px top border in `#F0F0EC`.
- **Icons:** 24px size. Active icons use Forest Green; inactive icons use `#BCBCBC`.

### Status Badges
- **Present:** Forest Green text on Primary Light background.
- **Absent:** Crimson text on pale red background.
- **Late:** Soft Brown text on Light Neutral background.
- **Excused:** Dark Grey text on Light Grey background.
- All badges use `radius_badge` (8px) and horizontal padding of `12px`.