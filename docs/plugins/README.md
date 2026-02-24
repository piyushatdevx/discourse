# FanTribe Plugins Documentation

This documentation covers the custom Discourse plugins built for the FanTribe social platform.

## Overview

FanTribe transforms Discourse from a traditional forum into a modern social media platform with a TikTok/Instagram-like experience. The customization is achieved through four interconnected plugins:

```
┌─────────────────────────────────────────────────────────────────┐
│                     DISCOURSE CORE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────────┐   ┌──────────────────┐                   │
│   │  fantribe-theme  │   │  fantribe-theme  │                   │
│   │     (Main)       │   │     -admin       │                   │
│   │                  │   │                  │                   │
│   │  • Design System │   │  • Admin UI      │                   │
│   │  • Social Feed   │   │  • Dashboard     │                   │
│   │  • Components    │   │  • Stat Cards    │                   │
│   │  • Chat Styling  │   │  • Attention     │                   │
│   └────────┬─────────┘   └──────────────────┘                   │
│            │                                                     │
│   ┌────────┴─────────┐   ┌──────────────────┐                   │
│   │   explore-tribe  │   │       chat       │                   │
│   │                  │   │  (modifications) │                   │
│   │  • Tribe Browser │   │                  │                   │
│   │  • Category Grid │   │  • Tab Nav       │                   │
│   │  • Filtering     │   │  • Message UI    │                   │
│   └──────────────────┘   └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Plugin Summary

| Plugin | Purpose | Key Features |
|--------|---------|--------------|
| [fantribe-theme](./fantribe-theme.md) | Main theme & design system | Social feed, 23+ components, glassmorphism UI, 3-column layout |
| [fantribe-theme-admin](./fantribe-theme-admin.md) | Admin panel styling | Attention panel, stat cards, dashboard redesign |
| [explore-tribe](./explore-tribe.md) | Category discovery | Card-based tribe browsing, filtering, responsive grid |
| [chat-customizations](./chat-customizations.md) | Chat UI transformation | Tab-based channels, WhatsApp-style bubbles |

## Architecture

### Design Token Flow

```
fantribe-theme/design-tokens.scss
         │
         ├──────────────────────────────────────┐
         │                                      │
         ▼                                      ▼
fantribe-theme components              fantribe-theme-admin
         │                              (inherits tokens)
         │
         ├──────────────────────────────────────┐
         │                                      │
         ▼                                      ▼
  explore-tribe                         chat modifications
  (uses tokens)                         (uses tokens)
```

### Component Hierarchy

```
Discourse Core
    │
    ├── below-site-header (connector)
    │   └── FantribeHeader + MobileNav + FAB
    │
    ├── discovery-list-area (connector)
    │   └── FantribeFeedLayout
    │       ├── FantribeComposeBox
    │       ├── FantribeFeedCard[]
    │       │   ├── Media (photos/videos/oneboxes)
    │       │   └── FantribeEngagementBar
    │       └── FantribeRightSidebar
    │           ├── FantribeTrendingPanel
    │           └── FantribeTribesPanel
    │
    ├── admin-dashboard-top (connector)
    │   └── FantribeAttentionPanel
    │
    └── /explore (custom route)
        └── FantribeExplorePage
            └── FantribeTribeCard[]
```

## Quick Reference

### Site Settings

| Setting | Plugin | Default | Description |
|---------|--------|---------|-------------|
| `fantribe_theme_enabled` | fantribe-theme | true | Master toggle for FanTribe theme |
| `fantribe_show_trending_tribes` | fantribe-theme | true | Show trending tribes sidebar |
| `fantribe_show_suggested_users` | fantribe-theme | true | Show suggested users |
| `fantribe_enable_glassmorphism` | fantribe-theme | true | Enable glass UI effects |
| `fantribe_primary_color` | fantribe-theme | #FF1744 | Brand color override |
| `fantribe_theme_admin_enabled` | fantribe-theme-admin | true | Enable admin styling |
| `explore_tribes_enabled` | explore-tribe | true | Enable explore page |

### Key File Locations

```
plugins/
├── fantribe-theme/
│   ├── plugin.rb                    # Plugin registration
│   ├── config/settings.yml          # Site settings
│   └── assets/
│       ├── javascripts/discourse/
│       │   ├── components/          # 23 Glimmer components
│       │   ├── services/            # 3 services
│       │   ├── initializers/        # 3 initializers
│       │   └── connectors/          # 4 outlet connectors
│       └── stylesheets/
│           ├── common/              # Shared styles
│           ├── desktop/             # Desktop overrides
│           └── mobile/              # Mobile overrides
│
├── fantribe-theme-admin/
│   ├── plugin.rb
│   └── assets/
│       ├── javascripts/discourse/
│       │   ├── components/          # Stat card
│       │   └── connectors/          # Attention panel
│       └── stylesheets/common/      # 5 SCSS files
│
├── explore-tribe/
│   ├── plugin.rb
│   └── assets/
│       ├── javascripts/discourse/
│       │   ├── routes/              # Explore route
│       │   ├── templates/           # Explore template
│       │   └── components/          # Page + card components
│       └── stylesheets/common/      # 4 SCSS files
│
└── chat/                            # Modified Discourse plugin
    └── assets/
        ├── javascripts/discourse/
        │   └── components/
        │       └── channels-list.gjs  # Tab navigation
        └── stylesheets/
            └── common/               # CSS modifications
```

## Design System

### Color Palette

| Token | Value | Usage |
|-------|-------|-------|
| `--ft-vibrant-red` | #FF1744 | Primary brand, CTAs |
| `--ft-electric-blue` | #0080FF | Links, secondary actions |
| `--ft-deep-charcoal` | #1A1D23 | Dark text |
| `--ft-warm-white` | #FAFAFA | Backgrounds |
| `--ft-coral` | #FF6B6B | Accent |
| `--ft-amber` | #FFB300 | Warnings, bookmarks |
| `--ft-mint` | #00C896 | Success, online status |

### Typography

- **Font Family:** Inter (system fallback)
- **Sizes:** 12px (xs) → 24px (2xl)
- **Weights:** 400 (normal), 700 (bold)

### Spacing

- **Base unit:** 4px
- **Scale:** 4, 8, 12, 16, 20, 24, 32, 40, 48px

## Development

### Running the App

```bash
# Start Discourse with all plugins
bin/ember-cli -u
```

### Linting

```bash
# Lint plugin files
bin/lint plugins/fantribe-theme/
bin/lint plugins/fantribe-theme-admin/
bin/lint plugins/explore-tribe/
```

### Testing

```bash
# Run plugin system tests
bin/rspec plugins/fantribe-theme-admin/spec/
```

## Dependencies

- **Discourse:** 2.7.0+
- **Ruby:** As per Discourse requirements
- **Node:** 22+
- **pnpm:** 10.28.0+
