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

## Multi-language (language dropdown)

The **language dropdown is part of fantribe-theme only**. It appears on the login/signup header and on the home page right sidebar. The separate plugin **user-language-switcher** is only needed for saving the selected language (cookies + user locale and Hindi/server locale handling); the dropdown can show without it.

### Why the dropdown does not show on another system

The dropdown is only rendered when the FanTribe theme is active. If it does not show on another system, that system usually has either:

- **fantribe-theme** plugin disabled, or  
- the site setting **“Enable the FanTribe theme and styling”** (`fantribe_theme_enabled`) turned **OFF**.

“user-language-switcher not found” means that plugin is missing or not loaded on that system; it does **not** control whether the dropdown is visible. Visibility is controlled only by fantribe-theme and the setting above.

### Steps on the other system (dropdown must show)

1. **Pull the multi-lingual branch**  
   Ensure the repo has both plugin folders:
   - `plugins/fantribe-theme/`
   - `plugins/user-language-switcher/`  
   If `user-language-switcher` is missing, add and push it to the branch, then pull on the other system.

2. **Enable fantribe-theme**  
   Admin → Plugins → enable **fantribe-theme**.

3. **Turn the FanTribe theme on**  
   Admin → Settings → search “fantribe” or “FanTribe theme” → set **“Enable the FanTribe theme and styling”** to **ON**.

4. **(Optional) Enable user-language-switcher**  
   Admin → Plugins → enable **user-language-switcher** so language choice is saved (cookies + user locale, and Hindi/server behaviour). If this plugin is not installed, the dropdown can still appear but persistence may be limited.

5. **Restart / recompile**  
   Restart the app after pulling. In production, run `bundle exec rake assets:precompile` if needed.

If the dropdown still does not appear, confirm that the **fantribe-theme** plugin is enabled and **fantribe_theme_enabled** is ON; the dropdown is only rendered when the theme is active.

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
