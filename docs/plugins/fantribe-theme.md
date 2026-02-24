# FanTribe Theme Plugin

The core theme plugin that transforms Discourse into a modern social media platform with glassmorphism UI, social feed layout, and comprehensive component library.

## Overview

| Property | Value |
|----------|-------|
| **Name** | fantribe-theme |
| **Version** | 0.1.0 |
| **Location** | `plugins/fantribe-theme/` |
| **Enabled by** | `fantribe_theme_enabled` |
| **Description** | FanTribe social platform design system — glassmorphism UI, brand tokens, and component styles |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DISCOURSE CORE                                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PLUGIN INITIALIZERS                                  │
│  ┌─────────────────────┐ ┌─────────────────────┐ ┌─────────────────────┐    │
│  │fantribe-customizations│ │fantribe-header-init│ │fantribe-chat-layout│    │
│  │  • Body classes      │ │  • Hide native     │ │  • Chat sidebar     │    │
│  │  • Theme state       │ │    header          │ │    visibility       │    │
│  └─────────────────────┘ └─────────────────────┘ └─────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       OUTLET CONNECTORS                                      │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ below-site-header → FantribeHeader + FantribeMobileNav + FantribeFab │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ discovery-list-area → FantribeFeedWrapper → FantribeFeedLayout       │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ login-before-modal-body → FantribeLoginLogo                          │   │
│  │ create-account-before-modal-body → FantribeSignupLogo                │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      COMPONENT COMPOSITION                                   │
│                                                                              │
│  FantribeFeedLayout ─────────────────────────────────────────────────────   │
│  │                                                                       │   │
│  ├── FantribeComposeBox (logged-in only)                                 │   │
│  │                                                                       │   │
│  ├── FantribeFeedCard (for each topic)                                   │   │
│  │   ├── Header (avatar, author, timestamp, menu)                        │   │
│  │   ├── Body (title, excerpt, read-more)                                │   │
│  │   ├── Media (photos, videos, oneboxes)                                │   │
│  │   └── FantribeEngagementBar (likes, comments, shares)                 │   │
│  │                                                                       │   │
│  └── FantribeRightSidebar                                                │   │
│      ├── FantribeTrendingPanel                                           │   │
│      └── FantribeTribesPanel                                             │   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SERVICES (State Management)                           │
│  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────────────┐     │
│  │ fantribeFilter   │ │ fantribeCreate   │ │ fantribeSidebarState     │     │
│  │ • Category IDs   │ │ • Menu state     │ │ • Collapsed state        │     │
│  │ • Filter actions │ │ • Modal state    │ │ • Mobile drawer state    │     │
│  └──────────────────┘ └──────────────────┘ └──────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DESIGN SYSTEM (CSS Variables)                             │
│  design-tokens.scss → colors, typography, spacing, shadows, breakpoints      │
│              ↓                                                               │
│  Component stylesheets → UI composition                                      │
│              ↓                                                               │
│  fantribe-overrides.scss → Discourse core patches (loaded last)              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Plugin Registration (plugin.rb)

### Metadata

```ruby
# frozen_string_literal: true
# name: fantribe-theme
# about: FanTribe social platform design system
# version: 0.1.0
# authors: FanTribe
# url: https://github.com/fantribe
```

### SVG Icons (62 registered)

The plugin registers 62 SVG icons for use throughout the UI:

| Category | Icons |
|----------|-------|
| Content Creation | image, video, music, tag, plus |
| Social | heart, comment, share, bookmark, eye |
| Navigation | home, compass, bell, user, filter |
| Utility | pencil, trash, lock, check, ellipsis |
| Brand-specific | fire, arrow-trend-up, tower-broadcast |

### Stylesheets (30+ registered)

Stylesheets are loaded in specific order for CSS precedence:

**Common (all viewports):**
- design-tokens, typography, glassmorphism
- buttons, inputs, cards, avatars, badges
- auth, layout, navigation

**Components:**
- header, mobile-nav, feed-layout, tribes-panel
- trending-panel, feed-card, compose-box
- avatar, badge, gear-pill, reaction-bar
- post-menu, engagement-bar, create-menu, create-post-modal

**Responsive:**
- desktop/desktop.scss
- mobile/mobile.scss
- fantribe-overrides.scss (loaded last)

### Backend Modifications

**ListableTopicSerializer Patches:**

```ruby
# Always include excerpts when FanTribe is enabled
# Add image_urls field (multi-image support from first post uploads)
# Add first_onebox_html field (link previews from oneboxes)
# Preloads first_post uploads to prevent N+1 queries
```

**Other:**
- Favicon override with FanTribe custom favicon
- OAuth auto-configuration (Google, Facebook) from environment variables

---

## Site Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `fantribe_theme_enabled` | boolean | true | Master toggle for FanTribe theme |
| `fantribe_show_trending_tribes` | boolean | true | Show trending tribes sidebar widget |
| `fantribe_show_suggested_users` | boolean | true | Show suggested users widget |
| `fantribe_enable_glassmorphism` | boolean | true | Enable glass UI effects (backdrop blur) |
| `fantribe_primary_color` | string | #FF1744 | Brand color override |

All settings are client-accessible for JavaScript use.

---

## File Structure

```
plugins/fantribe-theme/
├── plugin.rb                              # Plugin registration
├── config/
│   ├── settings.yml                       # Site settings
│   └── locales/
│       ├── client.en.yml                  # Client translations
│       └── server.en.yml                  # Server translations
├── public/images/
│   ├── logo.svg                           # Main logo
│   ├── logo1.svg                          # Alternative logo
│   ├── favicon.png                        # Custom favicon
│   ├── comment.svg                        # Comment icon
│   └── share.svg                          # Share icon
└── assets/
    ├── javascripts/discourse/
    │   ├── components/                    # 23 Glimmer components
    │   │   ├── fantribe-header.gjs
    │   │   ├── fantribe-feed-layout.gjs
    │   │   ├── fantribe-feed-card.gjs
    │   │   ├── fantribe-engagement-bar.gjs
    │   │   ├── fantribe-compose-box.gjs
    │   │   ├── fantribe-right-sidebar.gjs
    │   │   ├── fantribe-left-sidebar.gjs
    │   │   ├── fantribe-mobile-nav.gjs
    │   │   ├── fantribe-trending-panel.gjs
    │   │   ├── fantribe-tribes-panel.gjs
    │   │   ├── fantribe-avatar.gjs
    │   │   ├── fantribe-badge.gjs
    │   │   ├── fantribe-tribe-button.gjs
    │   │   ├── fantribe-post-menu.gjs
    │   │   ├── fantribe-reaction-bar.gjs
    │   │   ├── fantribe-gear-pill.gjs
    │   │   ├── fantribe-fab.gjs
    │   │   ├── fantribe-filter-dropdown.gjs
    │   │   ├── fantribe-mobile-tribe-chips.gjs
    │   │   ├── fantribe-media-photo-grid.gjs
    │   │   ├── fantribe-media-single-image.gjs
    │   │   ├── fantribe-media-video.gjs
    │   │   ├── ft-create-menu.gjs
    │   │   └── ft-create-post-modal.gjs
    │   ├── services/                      # 3 services
    │   │   ├── fantribe-filter.js
    │   │   ├── fantribe-create.js
    │   │   └── fantribe-sidebar-state.js
    │   ├── initializers/                  # 3 initializers
    │   │   ├── fantribe-customizations.js
    │   │   ├── fantribe-header-init.js
    │   │   └── fantribe-chat-layout.js
    │   ├── connectors/                    # 4 connector outlets
    │   │   ├── below-site-header/
    │   │   │   └── fantribe-header-connector.gjs
    │   │   ├── discovery-list-area/
    │   │   │   └── fantribe-feed-wrapper.gjs
    │   │   ├── login-before-modal-body/
    │   │   │   └── fantribe-login-logo.gjs
    │   │   └── create-account-before-modal-body/
    │   │       └── fantribe-signup-logo.gjs
    │   ├── helpers/
    │   │   └── ft-icon.js                 # SVG icon helper (77+ icons)
    │   └── lib/
    │       └── spring-animation.js        # Physics-based animations
    └── stylesheets/
        ├── common/
        │   ├── design-tokens.scss         # CSS variables
        │   ├── typography.scss
        │   ├── glassmorphism.scss
        │   ├── buttons.scss
        │   ├── inputs.scss
        │   ├── cards.scss
        │   ├── avatars.scss
        │   ├── badges.scss
        │   ├── navigation.scss
        │   ├── overlays.scss
        │   ├── feedback.scss
        │   ├── layout.scss
        │   ├── auth.scss
        │   ├── login-signup.scss
        │   ├── chat.scss                  # Chat customizations
        │   └── fantribe-overrides.scss    # Core overrides
        ├── common/components/
        │   ├── header.scss
        │   ├── mobile-nav.scss
        │   ├── app-layout.scss
        │   ├── feed-layout.scss
        │   ├── feed-card.scss
        │   ├── tribes-panel.scss
        │   ├── trending-panel.scss
        │   ├── compose-box.scss
        │   ├── avatar.scss
        │   ├── badge.scss
        │   ├── gear-pill.scss
        │   ├── reaction-bar.scss
        │   ├── post-menu.scss
        │   ├── right-sidebar.scss
        │   ├── left-sidebar.scss
        │   ├── create-menu.scss
        │   ├── create-post-modal.scss
        │   ├── engagement-bar.scss
        │   ├── mobile-tribe-chips.scss
        │   └── feed-animations.scss
        ├── desktop/
        │   └── desktop.scss
        └── mobile/
            └── mobile.scss
```

---

## JavaScript Architecture

### Services

#### fantribe-filter.js
Category/tribe filtering service.

```javascript
// Tracked state
selectedCategoryIds: TrackedSet

// Actions
toggleCategory(id)    // Toggle category selection
selectCategory(id)    // Add category to selection
deselectCategory(id)  // Remove category from selection
clearFilters()        // Clear all selections
setFilters(ids)       // Set specific category IDs
```

#### fantribe-create.js
Create post/content flow service.

```javascript
// Tracked state
isCreateMenuOpen: boolean
isCreatePostModalOpen: boolean

// Actions
toggleCreateMenu()      // Open/close create menu
openCreatePostModal()   // Open create post modal
closeCreatePostModal()  // Close create post modal
```

#### fantribe-sidebar-state.js
Sidebar state management service.

```javascript
// Tracked state
isCollapsed: boolean  // Desktop sidebar collapsed state
isMobileOpen: boolean // Mobile drawer open state

// Actions
toggle()       // Toggle sidebar state
closeMobile()  // Close mobile drawer
```

### Initializers

#### fantribe-customizations.js
Adds body classes for theme state:
- `fantribe-theme` - Always added
- `fantribe-glassmorphism` - When glassmorphism enabled
- `fantribe-anon` - When user not logged in

#### fantribe-header-init.js
- Hides native Discourse header
- Adds `fantribe-custom-header` class on page change
- Ensures custom FanTribe header always displays

#### fantribe-chat-layout.js
Chat controller modification:
- Forces channels list to display inside chat view (except mobile)
- Maintains sidebar behavior for core navigation

### Helper: ft-icon.js

Inline SVG icon renderer with 77+ Lucide-compatible icons.

```javascript
// Usage in templates
{{ft-icon "heart" size=24 class="text-red" fill="currentColor"}}

// Parameters
name: string    // Icon name
size: number    // Size in pixels (default: 24)
class: string   // CSS classes
fill: string    // Fill color
```

### Utility: spring-animation.js

Physics-based spring animations.

```javascript
// Parameters
damping: 25      // Damping factor
stiffness: 300   // Spring stiffness
mass: 1          // Mass

// Animated properties
opacity, scale, x, y (transforms)

// Convenience functions
animateModalIn(element)
animateModalOut(element)
```

### Major Components

#### FantribeHeader
Top navigation bar.
- Logo (clickable, navigates home)
- Search input with keyboard shortcuts
- Create button (logged-in users only)
- Mobile menu toggle
- Auth buttons (login/signup) or user menu

#### FantribeFeedLayout
Main feed layout (3-column grid).
- Filters topics by selected tribes
- Calculates trending topics (likes + views/10)
- Displays empty state when no topics
- Includes compose box, period chooser
- Right sidebar with trending/tribes panels

#### FantribeFeedCard
Individual post card.

| Section | Features |
|---------|----------|
| Header | Avatar, author name, timestamp, menu dropdown |
| Body | Title, excerpt with "read more" expansion |
| Media | Oneboxes (links), photo grids, videos |
| Engagement | Likes, comments, shares via FantribeEngagementBar |
| Expanded | Loads full post HTML via `/posts/{id}/cooked.json` |

#### FantribeEngagementBar
Like/comment/share interactions.
- Like toggle with count
- Comment count (read-only)
- Share/view count (read-only)
- Tracks `opLiked` and `opCanLike` state

### Connectors

| Outlet | Component | Purpose |
|--------|-----------|---------|
| `below-site-header` | fantribe-header-connector.gjs | Injects header, mobile nav, FAB |
| `discovery-list-area` | fantribe-feed-wrapper.gjs | Wraps topic lists with feed layout |
| `login-before-modal-body` | fantribe-login-logo.gjs | Custom logo on login modal |
| `create-account-before-modal-body` | fantribe-signup-logo.gjs | Custom logo on signup modal |

---

## Design System

### Color Palette (60-30-10 Rule)

**30% Primary Brand Colors:**

| Token | Value | Usage |
|-------|-------|-------|
| `--ft-vibrant-red` | #FF1744 | Main action color |
| `--ft-vibrant-red-hover` | #E50030 | Hover state |
| `--ft-vibrant-red-light` | rgba(255,23,68,0.1) | Light backgrounds |
| `--ft-electric-blue` | #0080FF | Links, secondary |
| `--ft-deep-charcoal` | #1A1D23 | Dark text |

**60% Neutral Colors:**

| Token | Value | Usage |
|-------|-------|-------|
| `--ft-warm-white` | #FAFAFA | Page backgrounds |
| `--ft-light-mist` | #F5F5F5 | Card backgrounds |
| `--ft-slate-50` to `--ft-slate-900` | Grayscale | Text, borders |
| `--ft-neutral-50` to `--ft-neutral-900` | Grayscale | Alternative neutrals |

**10% Accent Colors:**

| Token | Value | Usage |
|-------|-------|-------|
| `--ft-coral` | #FF6B6B | Accent |
| `--ft-amber` | #FFB300 | Warnings, bookmarks |
| `--ft-mint` | #00C896 | Success, online |
| `--ft-purple` | #7C3AED | Special features |

**Verification Rings:**

| Tier | Color |
|------|-------|
| Bronze | #CD7F32 |
| Silver | #C0C0C0 |
| Gold | #FFD700 |
| Blue | #1DA1F2 |

### Typography

```scss
--ft-font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;

// Sizes
--ft-font-xs: 12px;
--ft-font-sm: 14px;
--ft-font-base: 16px;
--ft-font-lg: 18px;
--ft-font-xl: 20px;
--ft-font-2xl: 24px;

// Weights
--ft-font-normal: 400;
--ft-font-bold: 700;
```

### Spacing

4px increment system:

```scss
--ft-space-1: 4px;
--ft-space-2: 8px;
--ft-space-3: 12px;
--ft-space-4: 16px;
--ft-space-5: 20px;
--ft-space-6: 24px;
--ft-space-8: 32px;
--ft-space-10: 40px;
--ft-space-12: 48px;
```

### Shadows & Effects

```scss
// Shadows
--ft-shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
--ft-shadow-md: 0 4px 6px rgba(0,0,0,0.1);
--ft-shadow-lg: 0 10px 15px rgba(0,0,0,0.1);

// Glassmorphism
--ft-glass-bg: rgba(255,255,255,0.8);
--ft-glass-blur: blur(10px);
--ft-glass-border: 1px solid rgba(255,255,255,0.2);
```

### Responsive Breakpoints

Tailwind-style system:

```scss
// Mobile first
@media (min-width: 640px)  { /* sm */ }
@media (min-width: 768px)  { /* md */ }
@media (min-width: 1024px) { /* lg */ }
@media (min-width: 1280px) { /* xl */ }
```

---

## Key Features

### 1. Social Media-Style Feed
- Three-column layout (left sidebar, feed, right sidebar)
- Topic cards with author info, media, engagement metrics
- Category filtering (Tribes)
- Trending topics ranking algorithm

### 2. Content Discovery
- Trending topics widget (ranked by likes + views/10)
- Suggested users display (optional)
- Followed tribes list
- Search with keyboard shortcuts

### 3. Content Creation
- Create menu (post, video, link options)
- Compose box at top of feed
- Create post modal with spring animations
- Category/tribe selection

### 4. Engagement System
- Like button with count (first post specific)
- Comment count display
- View/share count
- Post menu (edit, delete, report, pin)

### 5. Responsive Design
- Mobile: Bottom navigation, burger menu, drawer sidebar
- Desktop: Full 3-column layout
- Tablet: Adaptive breakpoints

### 6. Authentication UI
- Custom login/signup modals with FanTribe logo
- OAuth integration (Google, Facebook)
- Auto-login requirement when plugin enabled

### 7. Visual Effects
- Glassmorphism with backdrop blur
- Spring physics animations
- Smooth transitions
- Brand color customization via settings

### 8. Chat Integration
- Channels list always visible in chat (non-mobile)
- Custom chat UI styling (see chat-customizations.md)

---

## Localization

### Client Translations (client.en.yml)

- Empty state messages customized for FanTribe
- Terminology overrides:
  - Categories → Tribes
  - Topics → Posts
  - New terms: Members, Followers, Following, Join Tribe, Leave Tribe

### Server Translations (server.en.yml)

- Admin panel descriptions for all site settings

---

## Serializer Extensions

The plugin patches `ListableTopicSerializer` to add:

| Field | Type | Description |
|-------|------|-------------|
| `excerpt` | string | Always included when FanTribe enabled |
| `image_urls` | array | Multi-image URLs from first post uploads |
| `first_onebox_html` | string | Link preview HTML from oneboxes |

**N+1 Prevention:** Preloads first_post uploads via `includes(:uploads)`.

---

## Integration Points

### Discourse Core Modifications

1. **SiteIconManager** - Overrides favicon with FanTribe custom favicon
2. **OAuth** - Auto-enables Google/Facebook OAuth from environment variables
3. **TopicList** - Adds engagement data to topic serialization
4. **Header** - Hidden via initializer, replaced with custom component

### CSS Override Strategy

1. Design tokens loaded first (establish variables)
2. Component styles use tokens
3. `fantribe-overrides.scss` loaded last to override Discourse defaults
4. Scoped selectors ensure proper specificity
