# FanTribe Theme Plugin

A Discourse theme plugin that transforms the forum interface into a social-media-style music community platform.

## Features

- **Custom Design System**: Brand colors, typography (Outfit font), spacing, and shadows
- **Pastel Color Palette**: Soft, soothing colors for a calming user experience
- **Glassmorphism Effects**: Modern glass-like visual effects for cards and overlays
- **Social Media UI Components**: Post cards, user cards, tribe cards, engagement buttons
- **Responsive Layout**: Mobile-first design with desktop optimizations

## Installation

This plugin is automatically loaded when placed in the `plugins/` directory of your Discourse installation.

## Configuration

The following site settings are available under Admin > Settings > FanTribe Theme:

- `fantribe_theme_enabled`: Enable/disable the FanTribe theme
- `fantribe_show_trending_tribes`: Show trending tribes in sidebar
- `fantribe_show_suggested_users`: Show suggested users to follow
- `fantribe_enable_glassmorphism`: Enable glassmorphism visual effects
- `fantribe_primary_color`: Primary brand color (hex code)

## Design Tokens

The design system is defined in `assets/stylesheets/common/design-tokens.scss` and includes:

- Brand colors (primary red #FF1744)
- Pastel palette for soft UI elements
- Typography scale using Outfit font
- Spacing system (4px increments)
- Border radius variants
- Shadow definitions
- Glassmorphism variables
- Z-index scale

## File Structure

```
plugins/fantribe-theme/
├── plugin.rb                 # Plugin registration
├── config/
│   ├── settings.yml          # Site settings
│   └── locales/
│       ├── client.en.yml     # Client-side translations
│       └── server.en.yml     # Server-side translations
├── assets/
│   ├── stylesheets/
│   │   ├── common/           # Shared styles
│   │   ├── desktop/          # Desktop-specific styles
│   │   └── mobile/           # Mobile-specific styles
│   └── javascripts/
│       └── discourse/
│           └── initializers/ # JavaScript initializers
└── README.md
```

## Development

### Testing

```bash
# Start Discourse development server
bin/rails server

# Compile assets
bin/ember-cli

# Visit http://localhost:3000
```

### Linting

```bash
bin/lint plugins/fantribe-theme/
bin/lint --fix plugins/fantribe-theme/
```

## License

MIT
