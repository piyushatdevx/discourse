# Phase 1: Foundation Setup

> **Quick Reference:** See [Implementation Guidelines](../FANTRIBE-IMPLEMENTATION-PLAN.md#implementation-guidelines) for design rules (pastel colors, review checkpoints).

## Overview
Set up the theme plugin structure, define brand variables and design system foundation, and configure initial site settings.

## Prerequisites
- [ ] Discourse development environment running
- [ ] Access to `plugins/` directory

---

## Tasks

### 1.1 Create Theme Plugin Structure
**Goal:** Set up a new theme component plugin for all customizations

**Plugin structure:**
```
plugins/fantribe-theme/
├── plugin.rb
├── config/
│   ├── settings.yml
│   └── locales/
│       ├── client.en.yml
│       └── server.en.yml
├── assets/
│   ├── stylesheets/
│   │   ├── common/
│   │   │   ├── base.scss
│   │   │   ├── variables.scss
│   │   │   ├── components/
│   │   │   │   ├── header.scss
│   │   │   │   ├── feed.scss
│   │   │   │   ├── post-card.scss
│   │   │   │   ├── user-profile.scss
│   │   │   │   ├── tribe-page.scss
│   │   │   │   └── buttons.scss
│   │   │   └── utilities/
│   │   │       ├── glassmorphism.scss
│   │   │       ├── shadows.scss
│   │   │       └── typography.scss
│   │   ├── mobile/
│   │   │   └── mobile-overrides.scss
│   │   └── desktop/
│   │       └── desktop-overrides.scss
│   └── javascripts/
│       └── discourse/
│           └── initializers/
│               └── fantribe-customizations.js
└── README.md
```

**Files to create:**
- `plugins/fantribe-theme/plugin.rb` - Main plugin registration
- `plugins/fantribe-theme/config/settings.yml` - Theme settings
- Base SCSS structure as above

**Commands:**
```bash
mkdir -p plugins/fantribe-theme/{config/locales,assets/stylesheets/{common/components,common/utilities,mobile,desktop},assets/javascripts/discourse/initializers}
```

---

### 1.2 Define Brand Variables & Base Styles
**Goal:** Set up design system foundation

**File:** `plugins/fantribe-theme/assets/stylesheets/common/variables.scss`

**Content:**
```scss
// Brand Colors (Primary - Use for CTAs, important actions)
$fantribe-primary: #FF1844;
$fantribe-primary-hover: #E01539;
$fantribe-dark: #1A1A1A;
$fantribe-button-text: #FFFFFF;
$fantribe-bg: #FAFAFA;
$fantribe-card-bg: #FFFFFF;

// ============================================================
// PASTEL COLORS FOR SOOTHING EXPERIENCE
// ============================================================
// DESIGN GUIDELINE: When making design decisions or when specific
// colors are not mentioned, ALWAYS prefer pastel/soft colors for
// a calming, soothing user experience. Reserve primary red (#FF1844)
// for important CTAs and key actions only.
// ============================================================

// Pastel Palette (Use these for backgrounds, accents, states)
$fantribe-pastel-pink: #FFE4E8;        // Light pink - soft backgrounds
$fantribe-pastel-red: #FFCCD5;         // Muted red - hover states, light accents
$fantribe-pastel-peach: #FFE5D9;       // Peach - warm accents
$fantribe-pastel-lavender: #E8E0F0;    // Lavender - secondary accents
$fantribe-pastel-mint: #D4F0E7;        // Mint - success states, positive feedback
$fantribe-pastel-sky: #E0F2FE;         // Sky blue - info states, links
$fantribe-pastel-cream: #FFF8F0;       // Cream - alternative backgrounds
$fantribe-pastel-gray: #F5F5F7;        // Soft gray - neutral backgrounds

// Pastel Usage Guidelines:
// - Card hover backgrounds: $fantribe-pastel-pink or $fantribe-pastel-cream
// - Success messages/badges: $fantribe-pastel-mint
// - Info/notification backgrounds: $fantribe-pastel-sky
// - Secondary buttons hover: $fantribe-pastel-red
// - Tag/badge backgrounds: $fantribe-pastel-lavender, $fantribe-pastel-peach
// - Empty states: $fantribe-pastel-gray
// - Tribe category colors: Mix of pastels for visual variety

// Semantic Colors (Soft versions for soothing UX)
$fantribe-success: #10B981;            // Green for success
$fantribe-success-light: #D1FAE5;      // Pastel green background
$fantribe-warning: #F59E0B;            // Amber for warnings
$fantribe-warning-light: #FEF3C7;      // Pastel amber background
$fantribe-error: #EF4444;              // Red for errors (use sparingly)
$fantribe-error-light: #FEE2E2;        // Pastel red background
$fantribe-info: #3B82F6;               // Blue for info
$fantribe-info-light: #DBEAFE;         // Pastel blue background

// Typography
$fantribe-font-family: 'Outfit', -apple-system, BlinkMacSystemFont, 'SF Pro', 'Inter', sans-serif;
$fantribe-font-size-base: 16px;
$fantribe-font-size-small: 14px;
$fantribe-font-size-large: 18px;

// Spacing
$fantribe-spacing-xs: 8px;
$fantribe-spacing-sm: 16px;
$fantribe-spacing-md: 24px;
$fantribe-spacing-lg: 32px;
$fantribe-spacing-xl: 48px;

// Border Radius
$fantribe-radius-sm: 8px;
$fantribe-radius-md: 12px;
$fantribe-radius-lg: 16px;

// Shadows
$fantribe-shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.06);
$fantribe-shadow-md: 0 4px 16px rgba(0, 0, 0, 0.08);
$fantribe-shadow-lg: 0 8px 24px rgba(0, 0, 0, 0.12);

// Glassmorphism
$fantribe-glass-bg: rgba(255, 255, 255, 0.8);
$fantribe-glass-border: rgba(255, 255, 255, 0.3);
$fantribe-glass-blur: 12px;

// Breakpoints (matching design specs)
$mobile-s: 320px;
$mobile-m: 375px;
$mobile-l: 425px;
$tablet: 768px;
$laptop: 1024px;
$desktop: 1440px;
$desktop-l: 1920px;

// Layout
$fantribe-max-width: 1200px;
$fantribe-gutter-mobile: 16px;
$fantribe-gutter-tablet: 24px;
$fantribe-gutter-desktop: 24px;
```

**File:** `plugins/fantribe-theme/assets/stylesheets/common/base.scss`
```scss
@import "variables";

// Import Google Font
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap');

// Global Overrides
body {
  font-family: $fantribe-font-family;
  background-color: $fantribe-bg;
  color: $fantribe-dark;
}

// Override Discourse color scheme
:root {
  --primary: #{$fantribe-primary};
  --primary-medium: #{$fantribe-primary-hover};
  --secondary: #{$fantribe-card-bg};
  --tertiary: #{$fantribe-primary};
  --header_background: #{$fantribe-card-bg};
  --header_primary: #{$fantribe-dark};
}

// Global card style
.card-style {
  background: $fantribe-card-bg;
  border-radius: $fantribe-radius-md;
  box-shadow: $fantribe-shadow-sm;
  transition: all 0.3s ease;

  &:hover {
    box-shadow: $fantribe-shadow-md;
    transform: translateY(-2px);
  }
}

// Glassmorphism utility
.glass {
  background: $fantribe-glass-bg;
  backdrop-filter: blur($fantribe-glass-blur);
  -webkit-backdrop-filter: blur($fantribe-glass-blur);
  border: 1px solid $fantribe-glass-border;
}
```

---

### 1.3 Configure Site Settings
**Goal:** Configure Discourse settings for social media behavior

**Location:** Admin Panel → Settings or `config/site_settings.yml`

**Key Settings to Configure:**
```yaml
# Authentication
enable_local_logins: true
enable_google_oauth2_logins: true
enable_facebook_logins: true
must_approve_users: false

# User Experience
invite_only: false
login_required: false
allow_new_registrations: true

# Content
min_post_length: 1
min_first_post_length: 1
max_post_length: 5000
allow_uploaded_avatars: true
max_image_size_kb: 10240  # 10MB
max_attachment_size_kb: 51200  # 50MB

# Social Features
enable_emoji: true
enable_mentions: true
max_mentions_per_post: 20
max_users_notified_per_group_mention: 100

# Categories (Tribes)
allow_uncategorized_topics: false
default_navigation_menu_categories: latest|new|top

# Notifications
enable_personal_messages: true
notification_email: noreply@fantribe.com

# Mobile
enable_mobile_theme: true

# Performance
max_topics_per_page: 30
```

**Action:** Create configuration script or manual setup checklist

---

## Completion Checklist
- [ ] Plugin directory structure created
- [ ] `plugin.rb` file created and working
- [ ] `variables.scss` with all design tokens
- [ ] `base.scss` with global styles
- [ ] Site settings configured
- [ ] Code linted (`bin/lint --fix`)
- [ ] No console errors
- [ ] Plugin loads without errors
- [ ] Review requested from user

## Files Created/Modified This Phase

| File | Action | Purpose |
|------|--------|---------|
| `plugins/fantribe-theme/plugin.rb` | Modified | Added `enabled_site_setting :fantribe_theme_enabled` |
| `plugins/fantribe-theme/config/settings.yml` | Created | Theme settings (enabled, trending, glassmorphism, etc.) |
| `plugins/fantribe-theme/config/locales/client.en.yml` | Created | Client-side translations and terminology placeholders |
| `plugins/fantribe-theme/config/locales/server.en.yml` | Created | Server-side setting descriptions |
| `plugins/fantribe-theme/assets/stylesheets/common/design-tokens.scss` | Modified | Added pastel color palette for soothing UX |
| `plugins/fantribe-theme/assets/stylesheets/common/typography.scss` | Modified | Added Outfit font import from Google Fonts |
| `plugins/fantribe-theme/assets/javascripts/discourse/initializers/fantribe-customizations.js` | Created | Adds body classes for CSS targeting |
| `plugins/fantribe-theme/README.md` | Created | Plugin documentation |

## Review Notes
<!-- User feedback and approval notes go here -->
