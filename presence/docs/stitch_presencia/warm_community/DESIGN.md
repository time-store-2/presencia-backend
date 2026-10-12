---
name: Warm Community
colors:
  surface: '#fff8f6'
  surface-dim: '#e7d7d0'
  surface-bright: '#fff8f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff1eb'
  surface-container: '#fceae3'
  surface-container-high: '#f6e5de'
  surface-container-highest: '#f0dfd8'
  on-surface: '#221a16'
  on-surface-variant: '#57423b'
  inverse-surface: '#382e2a'
  inverse-on-surface: '#ffede6'
  outline: '#8b716a'
  outline-variant: '#dec0b7'
  surface-tint: '#a43c17'
  primary: '#a13a15'
  on-primary: '#ffffff'
  primary-container: '#c2522b'
  on-primary-container: '#fffcff'
  inverse-primary: '#ffb59d'
  secondary: '#805600'
  on-secondary: '#ffffff'
  secondary-container: '#fdba49'
  on-secondary-container: '#704b00'
  tertiary: '#6949ab'
  on-tertiary: '#ffffff'
  tertiary-container: '#8262c6'
  on-tertiary-container: '#fffcff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbd0'
  primary-fixed-dim: '#ffb59d'
  on-primary-fixed: '#390b00'
  on-primary-fixed-variant: '#842600'
  secondary-fixed: '#ffddaf'
  secondary-fixed-dim: '#fdba49'
  on-secondary-fixed: '#281800'
  on-secondary-fixed-variant: '#614000'
  tertiary-fixed: '#eaddff'
  tertiary-fixed-dim: '#d2bcff'
  on-tertiary-fixed: '#25005a'
  on-tertiary-fixed-variant: '#533294'
  background: '#fff8f6'
  on-background: '#221a16'
  surface-variant: '#f0dfd8'
typography:
  display-lg:
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
    letterSpacing: 0.01em
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
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 20px
  gutter: 12px
---

## Brand & Style

This design system centers on the concept of "Radical Hospitality." Designed for a youth church environment, the visual language balances professional administration with a warm, communal embrace. It avoids the clinical coldness of enterprise software in favor of a **Corporate Modern** style infused with **Tactile** warmth. 

The aesthetic is grounded in organic, earthy tones that evoke a sense of belonging and "home." Every interaction should feel supportive rather than surveillance-oriented. The design emphasizes clarity, accessibility, and an inviting interface that encourages participation and leadership development among young users.

## Colors

The palette is anchored by **Deep Terracotta**, a primary color that suggests strength and earthiness. It is supported by a range of tinted neutrals and functional "status" colors adjusted for high legibility and warmth.

- **Primary & Tints:** Use Deep Terracotta for primary actions. Use Primary Light (#FDF0EB) for large surface areas like card backgrounds to reduce visual fatigue.
- **Accents:** Amber Gold provides a vibrant secondary highlight for interactive elements, while Soft Plum (Excused) offers a distinct but harmonious third category.
- **Neutrals:** Avoid pure blacks or greys. All neutrals are "warmed" with brown/red undertones to maintain a cozy atmosphere.
- **Functional Semantics:** Status colors (Present, Absent, Late) use high-contrast text against soft-tinted backgrounds for maximum glanceability in fast-paced ministry environments.

## Typography

The typography utilizes **Inter** to ensure high legibility on mobile devices while maintaining a clean, modern appearance. 

The hierarchy is structured to support the French language, which often requires more horizontal space than English. Titles use a slightly tighter letter-spacing and heavier weights to create a sense of authority and structure. 

Body text should maintain a generous line height (1.5x) to ensure the interface feels airy and readable during quick scrolling. Labels and status badges utilize a semi-bold weight to remain distinct even at smaller sizes.

## Layout & Spacing

This design system follows a **Mobile-First Fluid Grid** model. Given the nature of church attendance tracking, the layout is optimized for one-handed operation on smartphones.

- **Grid:** A 4-column layout for mobile, scaling to 12 columns for tablet/desktop. 
- **Rhythm:** An 8px base unit (referenced as units of 4px) governs all spacing.
- **Safe Areas:** Generous 20px margins on mobile ensure content is not clipped by physical device edges or cases.
- **Verticality:** Use vertical stacking for student lists, with high-touch targets (48px minimum height) for all attendance toggles.

## Elevation & Depth

Depth is conveyed through **Tonal Layering** and **Ambient Shadows**. This design system avoids harsh, high-contrast drop shadows.

- **Base Layer:** The warm off-white background (#FAF7F5) acts as the canvas.
- **Surface Layer:** White cards (#FFFFFF) sit slightly above the background with a soft, warm-tinted shadow (Color: #7A6358 at 8% opacity, Y: 4, Blur: 12).
- **Interactive States:** When a card or button is pressed, it should "sink" slightly, reducing its shadow to create a tactile, physical response.
- **Overlays:** Modals and bottom sheets use a backdrop blur (10px) with a semi-transparent dark-brown overlay to maintain focus without losing the context of the warm environment.

## Shapes

The shape language is consistently **Rounded**. This choice reinforces the "welcoming" brand attribute by removing sharp corners that can feel aggressive or overly formal.

- **Cards:** Use a 16px corner radius (rounded-lg) to create a soft, friendly container for student data.
- **Buttons:** Use a 12px corner radius (rounded-md) to distinguish them from cards while maintaining the rounded aesthetic.
- **Input Fields:** Follow the 12px button radius for consistency.
- **Badges:** Use fully pill-shaped (rounded-full) geometry to make status indicators stand out as distinct elements.

## Components

### Buttons
- **Primary:** Deep Terracotta background, White text. 12px radius.
- **Secondary:** Pale Terracotta background, Deep Terracotta text. Used for "Add Note" or "Details."
- **Tertiary:** Transparent background, Medium Brown text with underline.

### Status Badges (French Language)
- **Présent:** Bg #EAF5EF, Text #2D7A56.
- **Absent:** Bg #FDECEA, Text #C0392B.
- **En retard:** Bg #FEF3C7, Text #D97706.
- **Excusé:** Bg #F0EBF8, Text #6B4CAE.
*All badges are pill-shaped with bold label-sm typography.*

### Cards
- **Student Card:** White background, 16px radius, subtle warm shadow. Features a circular avatar on the left and attendance status toggle on the right.
- **Summary Card:** Pale Terracotta background (#FDF0EB) with no shadow, used for top-level stats (e.g., "Total Présents").

### Input Fields
- **Search:** Border #EDE3DE, background #FFFFFF, 12px radius. Left-aligned search icon in Medium Brown.
- **Forms:** Labels in Warm Dark Brown, input fields with 1.5pt border. Focus state uses a 2px Deep Terracotta border.

### Navigation
- **Bottom Bar:** Soft-blur background, icons in Medium Brown (Inactive) and Deep Terracotta (Active). Labels in label-sm typography.