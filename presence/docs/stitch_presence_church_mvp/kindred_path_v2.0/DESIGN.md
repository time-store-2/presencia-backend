---
name: Kindred Path V2.0
colors:
  surface: '#f7fce3'
  surface-dim: '#d8dcc4'
  surface-bright: '#f7fce3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f6dd'
  surface-container: '#ecf0d8'
  surface-container-high: '#e6ebd2'
  surface-container-highest: '#e0e5cc'
  on-surface: '#191d0e'
  on-surface-variant: '#404943'
  inverse-surface: '#2e3222'
  inverse-on-surface: '#eff3da'
  outline: '#707973'
  outline-variant: '#bfc9c1'
  surface-tint: '#2c694e'
  primary: '#0f5238'
  on-primary: '#ffffff'
  primary-container: '#2d6a4f'
  on-primary-container: '#a8e7c5'
  inverse-primary: '#95d4b3'
  secondary: '#a33d23'
  on-secondary: '#ffffff'
  secondary-container: '#ff8162'
  on-secondary-container: '#731a04'
  tertiary: '#653e1b'
  on-tertiary: '#ffffff'
  tertiary-container: '#805530'
  on-tertiary-container: '#ffd0ad'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b1f0ce'
  primary-fixed-dim: '#95d4b3'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#0e5138'
  secondary-fixed: '#ffdad2'
  secondary-fixed-dim: '#ffb4a2'
  on-secondary-fixed: '#3c0700'
  on-secondary-fixed-variant: '#83260e'
  tertiary-fixed: '#ffdcc2'
  tertiary-fixed-dim: '#f4bb8e'
  on-tertiary-fixed: '#2e1500'
  on-tertiary-fixed-variant: '#653e1b'
  background: '#f7fce3'
  on-background: '#191d0e'
  surface-variant: '#e0e5cc'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 60px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
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
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
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
    letterSpacing: 0.02em
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
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style
The design system for this platform is rooted in the concept of "Sacred Community"—a digital space that feels as welcoming and grounded as a physical sanctuary. The brand personality is warm, human, and professional, balancing the administrative needs of church management with the empathetic touch required for ministry.

The visual style is a hybrid of **Modern Corporate** and **Tactile Minimalism**. It avoids the coldness of typical SaaS products by utilizing organic color palettes and soft geometry. The emotional response should be one of peace, reliability, and belonging. It prioritizes clarity and ease of use to ensure that technology never becomes a barrier to community connection.

## Colors
The palette is inspired by natural elements—forests, earth, and clay—to evoke a sense of growth and stability.

- **Primary Forest Green (#2D6A4F):** Used for primary actions, navigation headers, and representing growth.
- **Secondary Terracotta (#E76F51):** Used for accents, notifications, and "human-centric" highlights like community events or birthdays.
- **Neutral Warm Brown (#B5835A):** Used for secondary UI elements, iconography, and decorative borders to maintain warmth.
- **Backgrounds:** The interface uses **Warm White (#FAFAF8)** as the primary canvas to reduce eye strain, with **Secondary Cream (#F5F5F0)** utilized for sidebars and card groupings.

**Dark Mode Strategy:**
Dark mode must avoid pure blacks. Use a deep charcoal-brown (#1C1C1A) for backgrounds and a slightly lighter warm-grey (#262623) for surfaces. Text should be shifted to a soft off-white to maintain high legibility without harsh contrast.

## Typography
Plus Jakarta Sans is the sole typeface for the design system. Its soft, rounded terminals and open apertures provide the "human" touch necessary for a church environment while remaining highly legible for administrative tasks.

- **Headlines:** Use Bold or Semi-Bold weights with slight negative letter-spacing for a modern, compact look.
- **Body Text:** Use Regular weight for maximum readability. Line heights are generous to create an airy, calm reading experience.
- **Labels:** Use Semi-Bold for buttons and navigation items to ensure they stand out as interactive elements.

## Layout & Spacing
The design system utilizes a **Fluid Grid** model based on an 8px spacing rhythm. 

- **Desktop:** 12-column grid with 24px gutters and 40px outer margins.
- **Tablet:** 8-column grid with 24px gutters and 24px outer margins.
- **Mobile:** 4-column grid with 16px gutters and 16px outer margins.

Spacing should prioritize "breathing room" (negative space) to reflect a sense of peace. Large sections of data or member lists should be grouped in cards with 24px internal padding.

## Elevation & Depth
The design system uses a combination of **Tonal Layering** and **Ambient Shadows** to create a soft, approachable hierarchy.

- **Surface Levels:** The primary background is the lowest level. Cards and containers sit on top with a subtle 1px border colored in a desaturated version of the Neutral Warm Brown (at 20% opacity).
- **Shadows:** Use a "Sanctuary Shadow"—a very soft, diffused drop shadow with a hint of the Primary Green or Warm Brown in the hex code to keep it from looking grey and "muddy." 
  - *Example:* `0px 4px 20px rgba(45, 106, 79, 0.05)`
- **Interactions:** On hover, cards should lift slightly (increase shadow spread) rather than changing color significantly, maintaining a tactile feel.

## Shapes
The shape language is defined by pronounced, friendly curves. 

- **Cards & Large Containers:** Use a 20px corner radius to create a soft, framing effect for content.
- **Buttons:** Use a 14px corner radius. This "squircle" look feels more modern than a standard pill but more welcoming than a sharp rectangle.
- **Inputs & Smaller Elements:** Use a 12px corner radius to maintain consistency with the larger components.

## Components
- **Buttons:** Primary buttons are solid Forest Green with white text. Secondary buttons use a Terracotta outline with 1px thickness. Both use the 14px radius.
- **Cards:** White or Cream background, 20px radius, 1px soft brown border, and the "Sanctuary Shadow."
- **Input Fields:** Use a subtle Cream background (#F5F5F0) instead of pure white to make them feel "recessed" into the surface. 12px radius.
- **Chips/Badges:** Use low-opacity versions of the Primary or Secondary colors (e.g., 10% opacity Forest Green with solid Forest Green text) for member tags (e.g., "Volunteer," "New Member").
- **Lists:** Member lists should use "Divideless" design where possible, using vertical spacing and subtle background shifts on hover to separate entries rather than harsh lines.
- **Prayer/Request Cards:** A specialized component using the Secondary Terracotta as a top-border accent to denote its "human/emotional" importance.