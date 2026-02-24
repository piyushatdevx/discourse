# FanTribe Theme Admin Plugin

A modernized Discourse admin UI theme that applies the FanTribe design language to the admin interface. This is a purely visual plugin that enhances the admin experience with consistent styling and custom components.

## Overview

| Property | Value |
|----------|-------|
| **Name** | fantribe-theme-admin |
| **Version** | 0.1.0 |
| **Location** | `plugins/fantribe-theme-admin/` |
| **Enabled by** | `fantribe_theme_admin_enabled` |
| **Requires** | Discourse 2.7.0+ |
| **Description** | Admin UI modernization with FanTribe design system |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DISCOURSE ADMIN                               │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    STYLESHEET CASCADE                                │
│  (Loaded in specific order for CSS precedence)                       │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │ 1. admin-tokens.scss    (Design tokens - LOAD FIRST)        │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                               │                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │ 2. admin-sidebar.scss   (Sidebar navigation styling)        │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                               │                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │ 3. admin-components.scss (Custom components)                 │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                               │                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │ 4. admin-dashboard.scss (Dashboard-specific)                 │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                               │                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │ 5. admin-overrides.scss (Global overrides - LOAD LAST)       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         COMPONENTS                                   │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ admin-dashboard-top (connector)                                │  │
│  │     └── FantribeAttentionPanel                                 │  │
│  │         ├── Flagged Posts Count                                │  │
│  │         ├── Pending Users Count                                │  │
│  │         └── Pending Reviewables Count                          │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ FtAdminStatCard (reusable component)                           │  │
│  │     ├── Title + Icon                                           │  │
│  │     ├── Value (formatted)                                      │  │
│  │     ├── Sparkline SVG (optional)                               │  │
│  │     └── Trend Indicator (up/down/neutral)                      │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Plugin Registration (plugin.rb)

### Metadata

```ruby
# frozen_string_literal: true
# name: fantribe-theme-admin
# about: FanTribe admin panel styling
# version: 0.1.0
# authors: FanTribe
# url: https://github.com/fantribe
# required_version: 2.7.0
```

### Registered Assets

| Order | File | Purpose |
|-------|------|---------|
| 1 | admin-tokens.scss | Design tokens (colors, typography, spacing) |
| 2 | admin-sidebar.scss | Sidebar visual refinement |
| 3 | admin-components.scss | Custom component styles |
| 4 | admin-dashboard.scss | Dashboard-specific styling |
| 5 | admin-overrides.scss | Global admin overrides |

**Critical:** Load order matters for CSS precedence.

---

## Site Settings

| Setting | Type | Default | Client | Description |
|---------|------|---------|--------|-------------|
| `fantribe_theme_admin_enabled` | boolean | true | yes | Enable admin styling |

---

## File Structure

```
plugins/fantribe-theme-admin/
├── plugin.rb                                    # Plugin registration
├── config/
│   ├── settings.yml                             # Site settings
│   └── locales/
│       ├── client.en.yml                        # Client translations
│       └── server.en.yml                        # Server translations
├── spec/
│   └── system/
│       └── core_features_spec.rb                # System tests
└── assets/
    ├── javascripts/discourse/
    │   ├── components/
    │   │   └── ft-admin-stat-card.gjs           # Stat card component
    │   └── connectors/
    │       └── admin-dashboard-top/
    │           └── fantribe-attention-panel.gjs # Attention panel
    └── stylesheets/common/
        ├── admin-tokens.scss                    # Design tokens
        ├── admin-sidebar.scss                   # Sidebar styling
        ├── admin-components.scss                # Component styles
        ├── admin-dashboard.scss                 # Dashboard styling
        └── admin-overrides.scss                 # Global overrides
```

---

## Components

### FantribeAttentionPanel

**Location:** `connectors/admin-dashboard-top/fantribe-attention-panel.gjs`

A dashboard connector component that displays quick-access cards showing admin items requiring attention.

#### Data Loading

```javascript
// Fetches data via AJAX on construction
/admin/users/list/pending.json  → pending user counts
/admin/reports/bulk.json        → flagged posts report
```

#### Tracked Properties

| Property | Type | Description |
|----------|------|-------------|
| `flaggedCount` | number | Number of flagged posts |
| `pendingUsersCount` | number | Number of pending users |
| `loaded` | boolean | Data load state |

#### Visibility Rules

- Only shows for admins/moderators
- Shows cards if items exist
- Shows "all clear" message if none

#### Card Types

| Type | Color | Usage |
|------|-------|-------|
| Warning | Yellow/Orange | Pending reviews |
| Danger | Red | Flagged posts |
| Info | Blue | Pending users |

#### Error Handling

Gracefully handles API failures (e.g., 403 for moderators accessing restricted endpoints).

---

### FtAdminStatCard

**Location:** `components/ft-admin-stat-card.gjs`

A reusable data visualization component for displaying metrics with trends.

#### Arguments

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `@title` | string | required | Card label |
| `@value` | number | required | Primary metric |
| `@trendPercent` | number | null | Percentage change |
| `@higherIsBetter` | boolean | true | Affects trend interpretation |
| `@sparklineData` | array | null | Array of numbers for chart |
| `@icon` | string | null | Optional icon name |
| `@subtitle` | string | null | Optional subtitle |
| `@className` | string | null | Custom CSS class |

#### Computed Properties

| Property | Description |
|----------|-------------|
| `formattedValue` | Locale-aware number formatting (1000 → "1,000") |
| `trendIcon` | Up/down arrow based on percentage |
| `trendLabel` | Human-readable trend text ("vs last period") |
| `trendClass` | CSS class (positive/negative/neutral) |
| `sparklinePath` | SVG path for inline sparkline chart |

#### Rendering

```
┌─────────────────────────────────────┐
│ [icon] TITLE                        │
│                                     │
│         1,234                       │
│   [sparkline chart]                 │
│                                     │
│   ↑ +12.5% vs last period          │
└─────────────────────────────────────┘
```

---

## Stylesheets

### admin-tokens.scss

**Scope:** `.admin-area` & `body.admin-interface`

Defines FanTribe design tokens for the admin interface:

#### Colors

| Token | Value | Usage |
|-------|-------|-------|
| `--ft-primary` | #ff1744 | Primary actions |
| `--ft-primary-hover` | #e50030 | Hover state |
| `--ft-gray-50` to `--ft-gray-900` | Grayscale | UI elements |
| `--ft-success` | #10b981 | Success states |
| `--ft-error` | #ef4444 | Error states |
| `--ft-warning` | #f59e0b | Warning states |
| `--ft-info` | #3b82f6 | Info states |

#### Surfaces

| Token | Value | Usage |
|-------|-------|-------|
| `--ft-surface` | #ffffff | Card backgrounds |
| `--ft-sidebar-bg` | #ffffff | Sidebar background |
| `--ft-content-bg` | #f5f5f5 | Page background |

#### Other Tokens

```scss
// Typography
--ft-font-family: 'Inter', system-ui, sans-serif;
--ft-font-normal: 400;
--ft-font-semibold: 600;
--ft-font-bold: 700;

// Spacing
--ft-radius-md: 8px;
--ft-radius-lg: 12px;
--ft-radius-full: 9999px;
```

---

### admin-sidebar.scss

**Scope:** `.admin-area .sidebar-*`

Styles the left admin navigation sidebar:

#### Features

| Element | Styling |
|---------|---------|
| Panel | White background |
| Section headers | Uppercase, muted, small caps |
| Row height | 2.5em |
| Links | Gray text, smooth transitions |
| Active link | 3px left border + pink tint background |
| Icons | Default gray, pink on active/hover |
| Badges | Pill-shaped, primary color background |
| Search input | Rounded corners, focus state |
| Back-to-forum | Styled link at bottom |

#### Active State

```scss
.sidebar-row.active {
  border-left: 3px solid var(--ft-primary);
  background: rgba(255, 23, 68, 0.08);

  .sidebar-row__icon {
    color: var(--ft-primary);
  }
}
```

---

### admin-components.scss

**Scope:** `.ft-stat-card`, `.ft-attention-panel`

#### Stat Card Styling

```
┌────────────────────────────────┐
│  White background              │
│  Border: 1px solid gray-200    │
│  Shadow: subtle                │
│  Hover: elevation increase     │
│                                │
│  Title: uppercase, small       │
│  Value: large, bold            │
│  Sparkline: red, 50% opacity   │
│  Trend: colored by direction   │
└────────────────────────────────┘
```

#### Attention Panel Styling

| Element | Style |
|---------|-------|
| Header | Warning icon (orange), bold title |
| Grid | Auto-fit, 180px min column width |
| Cards | Colored variants (warning/danger/info) |
| Hover | 2px lift animation |
| All-clear | Mint background, success icon |

---

### admin-dashboard.scss

**Scope:** `body.admin-interface .dashboard*`

Styles dashboard-specific sections:

#### Styled Sections

| Section | Styling |
|---------|---------|
| Page title | 1.75rem, bold |
| Version checks | Card with section title |
| Problems/advice | Dismissible list items |
| Charts | Grid layout with gaps |
| Counters | Styled list headers |
| Storage stats | Card wrapper |
| Top topics | Card wrapper |
| Trending searches | Card wrapper |
| New features | Section styling |
| Community health | Section columns |

#### Card Pattern

All sections wrapped in white cards with:
- Border: 1px solid light gray
- Border radius: 8px
- Box shadow: subtle
- Padding: consistent spacing

---

### admin-overrides.scss

**Scope:** `body.admin-interface`

Global overrides for all admin pages.

#### Surfaces

```scss
body.admin-interface {
  background: #f5f5f5;

  .admin-contents {
    padding: 24px;
  }
}
```

#### Typography

| Element | Style |
|---------|-------|
| h1 (page headers) | 1.75rem, bold, dark gray |
| h2 (subheadings) | 1.1rem, semibold |
| Page descriptions | Small, muted gray |
| Breadcrumbs | Caption size, muted, pink hover |

#### Buttons

| Type | Style |
|------|-------|
| All buttons | border-radius: 8px |
| Primary/CTA | Pink (#ff1744), hover darkening |
| Secondary | White, gray border, hover gray |
| Danger | Red with rounded corners |
| Transitions | 150ms smooth |

#### Tables

```scss
table {
  border-collapse: separate;
  background: white;
  border: 1px solid light-gray;
  border-radius: 8px;

  th {
    background: light-gray;
    text-transform: uppercase;
    font-size: smaller;
  }

  tr:hover {
    background: very-light-gray;
  }
}
```

#### Form Elements

| Element | Style |
|---------|-------|
| Inputs | border-radius: 8px |
| Focus state | Pink border + 8% pink shadow |
| Transitions | 150ms smooth |

#### Navigation Pills

```scss
.nav-pills .nav-link {
  border-radius: 8px;

  &:hover {
    background: light-gray;
  }

  &.active {
    background: pink-tint;
    color: pink;
  }
}
```

#### Misc

- Badges: fully rounded (9999px)
- Horizontal rules: light gray
- Scrollbars: custom webkit (6px width)

---

## Localization

### Client Translations (client.en.yml)

```yaml
fantribe_admin:
  attention_panel:
    title: "Attention Needed"
    flagged_posts: "Flagged Posts"
    pending_users: "Pending Users"
    pending_reviewables: "Pending Reviews"
    all_clear: "All clear — nothing needs your attention."
  stat_card:
    vs_last_period: "vs last period"
    no_change: "No change"
```

### Server Translations (server.en.yml)

```yaml
site_settings:
  fantribe_theme_admin_enabled: "Enable FanTribe admin styling"
```

---

## Testing

**Test File:** `spec/system/core_features_spec.rb`

System tests verify core Discourse functionality works with the plugin:
- Login
- Likes
- Profile
- Topics (read/reply/create)
- Search

Uses helper: `it_behaves_like "having working core features"`

---

## Integration with Parent Theme

The plugin relies on CSS custom properties from `fantribe-theme`:

| Token | Source |
|-------|--------|
| `--ft-primary` | fantribe-theme/design-tokens.scss |
| `--ft-gray-*` | fantribe-theme/design-tokens.scss |
| `--ft-radius-*` | fantribe-theme/design-tokens.scss |
| `--ft-font-*` | fantribe-theme/design-tokens.scss |
| `--ft-space-*` | fantribe-theme/design-tokens.scss |
| `--ft-transition-*` | fantribe-theme/design-tokens.scss |

If `fantribe-theme` is disabled, the admin plugin still functions with hardcoded fallback values.

---

## Key Design Principles

1. **Consistency** - Uses same design tokens as main FanTribe theme
2. **Non-invasive** - Pure CSS overrides, no backend changes
3. **Scoped** - All styles scoped to `.admin-area` or `body.admin-interface`
4. **Progressive** - Graceful fallbacks if parent theme disabled
5. **Load Order** - Critical for CSS specificity (tokens → components → overrides)
