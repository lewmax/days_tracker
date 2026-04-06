# DaysTracker - Design Tokens

This document defines the canonical design token set for DaysTracker. All values target the single dark theme. There is no light mode variant in MVP.

Tokens are named by role, not by visual value, so that downstream tools (Flutter `ThemeData`, Penpot color styles) can reference roles directly and evolve the exact values without renaming.

---

## 1. Color Palette

### Surface colors

| Token | Hex | Role |
|---|---|---|
| `surface-base` | `#121218` | App background, root canvas |
| `surface-card` | `#1C1C24` | Card backgrounds, list item backgrounds |
| `surface-elevated` | `#24242E` | Bottom sheets, modals, elevated containers |
| `surface-overlay` | `#000000` at 50% opacity | Scrim behind bottom sheets and dialogs |

### Content colors (on-surface)

| Token | Hex | Role |
|---|---|---|
| `on-surface-primary` | `#EAEAF0` | Primary text, headings, key numbers |
| `on-surface-secondary` | `#9E9EB0` | Secondary text, metadata, helper text |
| `on-surface-disabled` | `#5A5A6E` | Disabled labels, placeholder text |

### Accent colors

| Token | Hex | Role |
|---|---|---|
| `primary` | `#5AABB5` | Main accent: active tab, primary buttons, links, interactive highlights |
| `primary-muted` | `#3D7A82` | Pressed state for primary elements, secondary emphasis |
| `on-primary` | `#FFFFFF` | Text and icons placed on `primary` backgrounds |
| `secondary` | `#D4A96A` | Supporting accent: secondary chips, warm highlights, country fill on map |
| `secondary-muted` | `#A07D4E` | Pressed state for secondary elements |
| `on-secondary` | `#121218` | Text and icons placed on `secondary` backgrounds |

### Outline and dividers

| Token | Hex | Role |
|---|---|---|
| `outline` | `#2E2E3A` | Card borders, input field outlines, dividers |
| `outline-focus` | `#5AABB5` | Focused input border (matches `primary`) |

### Semantic colors

| Token | Hex | Role |
|---|---|---|
| `success` | `#6BBF8A` | Confirmation, import accepted, positive outcomes |
| `on-success` | `#121218` | Text on success backgrounds |
| `warning` | `#E0A64A` | Approaching limits, caution states |
| `on-warning` | `#121218` | Text on warning backgrounds |
| `error` | `#D4736A` | Destructive actions, error messages, validation failures |
| `on-error` | `#FFFFFF` | Text on error backgrounds |

### Schengen-specific colors

These are semantic aliases that map to the base semantic set. Separated here so Schengen logic reads clearly in component specs.

| Token | Alias of | Role |
|---|---|---|
| `schengen-safe` | `success` | Comfortable: well within the 90-day limit |
| `schengen-caution` | `warning` | Approaching limit: fewer than 15 days remaining |
| `schengen-over` | `error` | Over limit: more than 90 days used |

---

## 2. Typography

System font strategy: platform default sans-serif. On iOS this resolves to SF Pro, on Android to Roboto, via Flutter's default font family. No custom font import needed for MVP.

### Type scale

| Token | Size (sp) | Weight | Line height | Letter spacing | Use |
|---|---|---|---|---|---|
| `display` | 28 | SemiBold (600) | 36 | -0.2 | Screen titles |
| `headline` | 22 | SemiBold (600) | 28 | -0.1 | Section headers, large stat numbers |
| `title` | 18 | Medium (500) | 24 | 0 | Card titles, list group headers |
| `body` | 16 | Regular (400) | 22 | 0 | Primary reading text, descriptions |
| `body-small` | 14 | Regular (400) | 20 | 0.1 | Secondary descriptions, metadata |
| `caption` | 12 | Regular (400) | 16 | 0.2 | Timestamps, badge labels, helper text |
| `overline` | 11 | Medium (500) | 16 | 1.0 | Category labels, section markers (uppercase) |

### Text color mapping

- Headings and titles: `on-surface-primary`.
- Body and descriptions: `on-surface-primary` or `on-surface-secondary` depending on hierarchy.
- Metadata, timestamps, helper text: `on-surface-secondary`.
- Disabled or placeholder text: `on-surface-disabled`.

---

## 3. Spacing

Base unit: 4px.

| Token | Value | Common use |
|---|---|---|
| `space-xs` | 4 | Tight internal gaps (icon-to-label inside a chip) |
| `space-sm` | 8 | List item internal padding, inline gaps |
| `space-md` | 12 | Card internal padding (secondary axis), small section breaks |
| `space-lg` | 16 | Screen-edge horizontal padding, card internal padding (primary axis) |
| `space-xl` | 24 | Section gaps between content groups |
| `space-2xl` | 32 | Major section separation, breathing room before/after prominent elements |
| `space-3xl` | 48 | Large vertical gaps (e.g. between onboarding steps) |
| `space-4xl` | 64 | Reserved for extreme spacing cases |

### Layout constants

| Constant | Value | Note |
|---|---|---|
| Screen horizontal padding | `space-lg` (16) | Both edges on phone |
| Card internal padding | `space-lg` (16) | All sides |
| List item vertical gap | `space-sm` (8) | Between cards in a list |
| Section gap | `space-xl` (24) | Between distinct content groups on a screen |
| Bottom nav height | 64 | Includes safe area padding on notched devices |
| Top bar height | 56 | Standard app bar |

---

## 4. Border Radii

| Token | Value | Use |
|---|---|---|
| `radius-sm` | 8 | Small chips, badges, confidence labels |
| `radius-md` | 12 | Cards, inputs, buttons |
| `radius-lg` | 16 | Bottom sheets, modals, large containers |
| `radius-full` | 9999 | Circular elements: icon buttons, avatars, dots |

---

## 5. Elevation and Shadow

Dark mode uses minimal shadow because dark surfaces already separate visually through brightness steps. Elevation is communicated primarily through surface color tokens (`surface-base` → `surface-card` → `surface-elevated`).

| Level | Surface token | Shadow | Use |
|---|---|---|---|
| 0 (base) | `surface-base` | None | App background |
| 1 (card) | `surface-card` | `0 1px 3px rgba(0,0,0,0.4)` | Cards, list items |
| 2 (elevated) | `surface-elevated` | `0 4px 12px rgba(0,0,0,0.5)` | Bottom sheets, dialogs, modals |

Bottom sheet scrim: `surface-overlay` (`#000000` at 50% opacity) behind the sheet.

---

## 6. Iconography

- Style: outlined, 24x24 default size, 1.5px stroke weight.
- Color: `on-surface-primary` for active, `on-surface-disabled` for inactive.
- Bottom nav icons: 24x24, with `primary` for active tab and `on-surface-disabled` for inactive tabs.
- Flag icons: emoji flags for inline use (country lists, visit cards). No custom flag assets in MVP.

---

## 7. Motion

MVP uses two transition curves. No decorative animations.

| Token | Curve | Duration | Use |
|---|---|---|---|
| `motion-standard` | `ease-out` | 200ms | Screen transitions, tab switches, chip selection, card expand/collapse |
| `motion-sheet` | `cubic-bezier(0.2, 0.9, 0.3, 1.0)` | 300ms | Bottom sheet open/close, dialog enter/exit (spring-like overshoot) |

All other state changes (e.g. toggle flips, progress bar fills) should use `motion-standard` as the default. No staggered list animations, parallax effects, or scroll-triggered motion in MVP.

---

## 8. Component Token Mapping

Quick reference for how tokens apply to the main component families. Detailed per-component specs live in `04_screens_and_components.md`.

### Buttons

| Variant | Background | Text/icon | Border |
|---|---|---|---|
| Primary | `primary` | `on-primary` | None |
| Primary (pressed) | `primary-muted` | `on-primary` | None |
| Secondary | Transparent | `primary` | `outline` |
| Secondary (pressed) | `primary` at 10% opacity | `primary` | `primary` |
| Text | Transparent | `primary` | None |
| Destructive | `error` | `on-error` | None |

### Cards

| Part | Token |
|---|---|
| Background | `surface-card` |
| Border | `outline` (optional, 1px) |
| Title text | `on-surface-primary` / `title` |
| Body text | `on-surface-secondary` / `body-small` |
| Radius | `radius-md` |

### Bottom navigation

| Part | Token |
|---|---|
| Background | `surface-elevated` |
| Active icon + label | `primary` |
| Inactive icon + label | `on-surface-disabled` |
| Divider top edge | `outline` |

### Chips (period / view mode)

| State | Background | Text | Border |
|---|---|---|---|
| Unselected | Transparent | `on-surface-secondary` | `outline` |
| Selected | `primary` at 15% opacity | `primary` | `primary` |

### Schengen progress bar

| Segment | Color token |
|---|---|
| Filled (safe) | `schengen-safe` |
| Filled (caution) | `schengen-caution` |
| Filled (over) | `schengen-over` |
| Track (unfilled) | `outline` |

### Confidence badges

| Variant | Background | Text |
|---|---|---|
| Confirmed | `success` at 15% opacity | `success` |
| Possible | `warning` at 15% opacity | `warning` |
| Manual | `primary` at 15% opacity | `primary` |

---

## 9. Token Naming Convention

All tokens follow a flat `{category}-{role}` or `{category}-{role}-{modifier}` pattern:

- Colors: `surface-base`, `on-surface-primary`, `primary`, `schengen-safe`.
- Typography: `display`, `headline`, `body-small`.
- Spacing: `space-lg`, `space-xl`.
- Radii: `radius-md`, `radius-full`.
- Motion: `motion-standard`, `motion-sheet`.

This maps directly to Penpot color styles, text styles, and (in Flutter) named constants or `ThemeExtension` fields.
