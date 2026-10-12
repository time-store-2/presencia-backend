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
  on-surface-variant: '#464555'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#777587'
  outline-variant: '#c7c4d8'
  surface-tint: '#4d44e3'
  primary: '#3525cd'
  on-primary: '#ffffff'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#c3c0ff'
  secondary: '#4648d4'
  on-secondary: '#ffffff'
  secondary-container: '#6063ee'
  on-secondary-container: '#fffbff'
  tertiary: '#005338'
  on-tertiary: '#ffffff'
  tertiary-container: '#006e4b'
  on-tertiary-container: '#67f4b7'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
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
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
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
    letterSpacing: 0.1px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
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
  container-padding: 16px
  gutter: 12px
---

## Brand & Style

The design system is built for a youth attendance management platform, prioritizing clarity, speed of interaction, and a sense of modern reliability. The aesthetic follows a **Modern / Corporate** direction heavily inspired by Material 3 principles: it utilizes significant whitespace, a structured tonal palette, and purposeful motion.

The interface should feel "lightweight" yet robust. It avoids unnecessary decorative elements, focusing instead on high-contrast typography and clear containment to guide the user through administrative tasks. The emotional response should be one of professional ease—reducing the friction of taking attendance while maintaining an energetic, community-focused spirit.

## Colors

The color strategy uses a high-contrast foundation to ensure legibility in varying lighting conditions (common in youth event spaces). 

- **Primary (Indigo):** Reserved for the "Source of Truth" and primary actions like "Confirmer l'appel" (Confirm attendance).
- **Surface Logic:** In Light mode, pure white surfaces sit atop a very light gray background to create subtle depth. In Dark mode, deep black provides the canvas for slightly lighter charcoal surfaces.
- **Functional Colors:** Success, Danger, and Warning colors are vibrant and meet AA accessibility standards against both light and dark surfaces. Use these specifically for status chips (e.g., "Présent", "Absent", "Retard").
- **Tints:** Use 10% opacity tints of the status colors for background containers of labels/chips to keep the UI from feeling overly heavy.

## Typography

This design system uses **Inter** for all levels to achieve a systematic, utilitarian look that remains highly readable. 

- **Scale:** Use `Display` and `Headline-lg` for screen titles (e.g., "Tableau de bord"). 
- **Hierarchy:** `Title-md` is the default for list item headers (e.g., names of youth members). `Label-md` should be used for all-caps or small metadata.
- **Language Consideration:** French text can often be 15-20% longer than English. Ensure that containers for labels and buttons have sufficient horizontal flex or truncation rules to prevent layout breaking.

## Layout & Spacing

The layout is optimized for mobile-first interaction using a **Fluid Grid** approach. 

- **Grid:** A 4-column grid for mobile devices with 16px side margins. 
- **Rhythm:** All spacing is based on a 4px baseline. Use 16px (`md`) for standard padding within cards and 8px (`sm`) for spacing between related elements like a label and an input field.
- **Touch Targets:** Ensure all interactive elements have a minimum touch target area of 48x48px, even if the visual element is smaller.

## Elevation & Depth

In line with modern Material standards, the design system utilizes **Tonal Layers** rather than heavy shadows to define hierarchy.

- **Level 0 (Background):** Used for the main page canvas.
- **Level 1 (Surface):** Used for cards and primary content containers. These use a minimal shadow (`0 1px 3px rgba(0,0,0,0.08)`) to lift slightly off the background.
- **Level 2 (Overlays):** Used for Bottom Sheets and Modals. These should have a slightly more pronounced shadow or a 10% black/white overlay backdrop to focus the user's attention.
- **Dark Mode Elevation:** In dark mode, elevation is communicated by lightening the surface color rather than increasing shadow opacity.

## Shapes

The shape language is friendly but disciplined. 

- **Cards:** 16px (`rounded-lg`) to create a soft, modern container.
- **Buttons & Inputs:** 12px (`rounded-md`) to provide a distinct look from cards while maintaining a consistent radius language.
- **Avatars:** 50% (Circle) for all user and youth member profile photos.
- **Chips:** 8px for status indicators to keep them compact.

## Components

- **Buttons:** Primary buttons use a solid Indigo fill with white text. Secondary buttons use a tonal background (Indigo at 10% opacity) with Indigo text. All buttons use 12px rounding and `Label-lg` typography.
- **Cards:** White surfaces with a 1px subtle border (#E5E7EB) in light mode. They house the list of youth members.
- **Attendance Chips:** Small, rounded-pill containers. Use Emerald for "Présent", Red for "Absent", and Amber for "Retard". 
- **Input Fields:** Outlined style with a 12px radius. The border color changes to Primary (Indigo) on focus. Labels should be persistent or floating.
- **Navigation:** Use a Bottom Navigation Bar for main sections (Appel, Rapports, Profil) with active states indicated by a pill-shaped tonal highlight behind the icon.
- **Lists:** Clean list items with a 56px height minimum. Include a circular avatar on the left and a status toggle or chevron on the right.