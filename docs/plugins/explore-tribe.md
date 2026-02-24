# Explore Tribes Plugin

An "Explore Tribes" page that allows users to browse and discover community tribes (categories) in an engaging, card-based interface with filtering capabilities.

## Overview

| Property | Value |
|----------|-------|
| **Name** | explore-tribes |
| **Version** | 0.1.0 |
| **Location** | `plugins/explore-tribe/` |
| **Enabled by** | `explore_tribes_enabled` |
| **Route** | `/explore` |
| **Description** | Explore Tribes page — browse and discover community tribes |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DISCOURSE CORE                                │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ Router                                                         │  │
│  │   GET /explore → explore_tribes/explore#index                  │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      EMBER ROUTE LAYER                               │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ explore-tribes-route-map.js                                    │  │
│  │   └── Registers "explore" route in Discourse's route system   │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                               │                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ routes/explore.js                                              │  │
│  │   └── ExploreRoute extends DiscourseRoute                      │  │
│  │       └── model() → returns site.categories                    │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                               │                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ templates/explore.gjs                                          │  │
│  │   └── Renders <FantribeExplorePage @categories={{@model}} />   │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    COMPONENT HIERARCHY                               │
│                                                                      │
│  FantribeExplorePage ────────────────────────────────────────────   │
│  │                                                                   │
│  ├── Header                                                          │
│  │   └── Title: "Explore Tribes" + subtitle                         │
│  │                                                                   │
│  ├── Filter Dropdown ────────────────────────────────────────────   │
│  │   ├── Trigger Button (sliders icon + filter name + chevron)     │
│  │   └── Dropdown Menu                                              │
│  │       └── Filter options (All + parent categories)              │
│  │                                                                   │
│  ├── Results Count ──────────────────────────────────────────────   │
│  │   └── "Showing X tribes" (+ "in {category}" if filtered)        │
│  │                                                                   │
│  └── Content Area ───────────────────────────────────────────────   │
│      │                                                               │
│      ├── [If categories exist]                                       │
│      │   └── Tribe Grid                                             │
│      │       └── FantribeTribeCard (×n)                             │
│      │           ├── Cover (background image/gradient)              │
│      │           ├── Parent badge                                   │
│      │           ├── Icon (logo/emoji/FA/colored dot)              │
│      │           ├── Name + metadata                                │
│      │           ├── Description (truncated)                        │
│      │           ├── Activity indicator (dots + count)              │
│      │           └── "Join Tribe" button                            │
│      │                                                               │
│      └── [If no categories]                                          │
│          └── Empty State                                             │
│              └── "No tribes found" message                          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Plugin Registration (plugin.rb)

### Metadata

```ruby
# frozen_string_literal: true
# name: explore-tribes
# about: Explore Tribes page — browse and discover community tribes
# version: 0.1.0
# authors: FanTribe
# url: https://github.com/fantribe
```

### Route Registration

```ruby
Discourse::Application.routes.append do
  get "/explore" => "explore_tribes/explore#index"
end
```

### Controller

```ruby
class ExploreTrribes::ExploreController < ApplicationController
  def index
    render html: "", layout: "default"
  end
end
```

### Registered Assets

| File | Purpose |
|------|---------|
| explore-page.scss | Main page layout and sections |
| tribe-grid.scss | Responsive grid system |
| tribe-card.scss | Individual tribe card styling |
| filter-dropdown.scss | Filter dropdown control |

---

## Site Settings

| Setting | Type | Default | Client | Description |
|---------|------|---------|--------|-------------|
| `explore_tribes_enabled` | boolean | true | yes | Enable the Explore Tribes page |

---

## File Structure

```
plugins/explore-tribe/
├── plugin.rb                                    # Plugin registration
├── config/
│   ├── settings.yml                             # Site settings
│   └── locales/
│       ├── client.en.yml                        # Client translations (empty)
│       └── server.en.yml                        # Server translations
└── assets/
    ├── javascripts/discourse/
    │   ├── explore-tribes-route-map.js          # Route mapper
    │   ├── routes/
    │   │   └── explore.js                       # Route handler
    │   ├── templates/
    │   │   └── explore.gjs                      # Main template
    │   └── components/
    │       ├── fantribe-explore-page.gjs        # Explore page component
    │       └── fantribe-tribe-card.gjs          # Tribe card component
    └── stylesheets/common/
        ├── explore-page.scss                    # Page layout
        ├── tribe-grid.scss                      # Grid layout
        ├── tribe-card.scss                      # Card styling
        └── filter-dropdown.scss                 # Filter UI
```

---

## Components

### Route Mapping (explore-tribes-route-map.js)

Registers the `explore` route in Discourse's route system.

```javascript
export default {
  resource: "explore",
  path: "/explore"
};
```

### Route Handler (routes/explore.js)

```javascript
import DiscourseRoute from "discourse/routes/discourse";
import { service } from "@ember/service";

export default class ExploreRoute extends DiscourseRoute {
  @service site;

  model() {
    return this.site.categories || [];
  }
}
```

**Purpose:** Loads all available categories to pass to the template.

---

### FantribeExplorePage

**Location:** `components/fantribe-explore-page.gjs`

Main page component with filtering and grid display.

#### Tracked Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `activeFilter` | string | "All" | Currently selected category filter |
| `isFilterOpen` | boolean | false | Filter dropdown visibility |

#### Computed Getters

| Getter | Returns | Description |
|--------|---------|-------------|
| `parentCategories` | array | Top-level categories (excludes uncategorized) |
| `filterOptions` | array | ["All"] + unique parent category names |
| `allDisplayCategories` | array | All non-uncategorized categories |
| `filteredCategories` | array | Categories matching active filter |
| `showCategoryLabel` | boolean | Whether to show category name in count |

#### Actions

| Action | Description |
|--------|-------------|
| `toggleFilter()` | Open/close filter dropdown |
| `closeFilter()` | Close filter dropdown |
| `selectFilter(filter)` | Change active filter |

#### Template Sections

1. **Header**
   - Title: "Explore Tribes"
   - Subtitle: Descriptive text

2. **Filter Dropdown**
   - Trigger: Sliders icon + current filter + chevron
   - Menu: List of filter options

3. **Results Count**
   - Shows: "Showing X tribes"
   - Conditional: "in {category}" when filtered

4. **Tribe Grid / Empty State**
   - Grid: Displays tribe cards
   - Empty: "No tribes found" message

---

### FantribeTribeCard

**Location:** `components/fantribe-tribe-card.gjs`

Individual category card component.

#### Arguments

| Argument | Type | Description |
|----------|------|-------------|
| `@category` | object | Category object from Discourse |

#### Computed Getters

| Getter | Returns | Description |
|--------|---------|-------------|
| `coverStyle` | string | Background CSS (image or gradient) |
| `topicCount` | number | Number of topics in category |
| `memberLabel` | string | Formatted count ("1.2K" for 1000+) |
| `truncatedDescription` | string | First 100 chars + "..." |
| `iconColorStyle` | string | Background color for icon dot |
| `subcategoryCount` | number | Number of subcategories |
| `hasEmoji` | boolean | Category has emoji icon |
| `hasIcon` | boolean | Category has FA icon |
| `hasLogo` | boolean | Category has logo image |

#### Cover Style Priority

```
1. uploaded_background (if exists) → background-image
2. uploaded_logo (if exists) → background-image
3. category.color → gradient background
```

#### Actions

| Action | Description |
|--------|-------------|
| `handleCardClick()` | Navigate to category page |
| `handleJoinClick(event)` | Stop propagation + navigate |

#### Card Layout

```
┌─────────────────────────────────────────┐
│ [Cover Section]                          │
│   ┌────────────────┐                    │
│   │ Parent Badge   │                    │
│   └────────────────┘                    │
│         (background image/gradient)      │
│         (optional overlay gradient)      │
└─────────────────────────────────────────┘
│ [Card Body]                              │
│   ┌───────┐                             │
│   │ Icon  │  Tribe Name                 │
│   └───────┘  🌐 Public · 👥 1.2K        │
│                                          │
│   Truncated description text that       │
│   shows first 100 characters...         │
│                                          │
│   ●●● 42 active today                   │
│                                          │
│   ┌─────────────────────────────────┐   │
│   │        Join Tribe               │   │
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

#### Icon Rendering Priority

```
1. Category logo image → <img>
2. Emoji → {{replace-emoji emoji}}
3. FontAwesome icon → {{d-icon}}
4. Fallback → colored dot with category color
```

---

## Stylesheets

### Design Tokens Used

The plugin uses FanTribe design system CSS variables:

| Token Category | Examples |
|----------------|----------|
| Colors | `--ft-primary`, `--ft-white`, `--ft-dark`, `--ft-gray-*` |
| Spacing | `--ft-space-*` (24px gap) |
| Radius | `--ft-radius-*` (lg, full, xl) |
| Shadows | `--ft-shadow-*` (sm, md, lg) |
| Typography | `--ft-font-*`, `--ft-line-height-*` |
| Transitions | `--ft-transition-*` |

---

### explore-page.scss

Main page layout and sections.

#### Layout

```scss
.fantribe-explore-page {
  min-height: 100vh;
  background: linear-gradient(
    to bottom,
    var(--ft-gray-100),
    var(--ft-white),
    rgba(255, 23, 68, 0.05)  // pink tint at bottom
  );
}

.explore-container {
  max-width: 1280px;
  margin: 0 auto;
  padding: 32px;  // 12px on mobile
}
```

#### Results Count

```scss
.explore-results-count {
  // Styled numbers
  .count-number {
    color: var(--ft-primary);
    font-weight: bold;
  }

  // Category name
  .category-name {
    color: var(--ft-primary);
  }
}
```

#### Empty State

```scss
.explore-empty-state {
  text-align: center;
  padding: 64px;

  .empty-icon {
    font-size: 48px;
    margin-bottom: 16px;
  }
}
```

---

### tribe-grid.scss

Responsive grid system.

```scss
.tribe-grid {
  display: grid;
  gap: 24px;

  // Mobile (default): 1 column
  grid-template-columns: 1fr;

  // Tablet (768px+): 2 columns
  @media (min-width: 768px) {
    grid-template-columns: repeat(2, 1fr);
  }

  // Desktop (1024px+): 3 columns
  @media (min-width: 1024px) {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

---

### tribe-card.scss

Individual card styling.

#### Card Container

```scss
.tribe-card {
  border-radius: 16px;
  background: var(--ft-white);
  overflow: hidden;
  cursor: pointer;
  transition: all 150ms ease;

  &:hover {
    box-shadow: var(--ft-shadow-lg);
    border-color: var(--ft-primary);

    .tribe-name {
      color: var(--ft-primary);
    }
  }
}
```

#### Cover Section

```scss
.tribe-cover {
  aspect-ratio: 16 / 9;
  position: relative;
  background-size: cover;
  background-position: center;

  .tribe-cover-overlay {
    // Optional gradient overlay
    background: linear-gradient(
      to bottom,
      transparent,
      rgba(0, 0, 0, 0.3)
    );
  }
}
```

#### Icon

```scss
.tribe-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  border: 2px solid var(--ft-white);
  background: linear-gradient(135deg, white, var(--ft-gray-50));
  box-shadow: var(--ft-shadow-sm);

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}
```

#### Activity Indicator

```scss
.tribe-activity {
  display: flex;
  align-items: center;
  gap: 8px;

  .activity-dots {
    display: flex;

    .dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin-left: -4px;  // overlap effect

      &:nth-child(1) { background: linear-gradient(...); }
      &:nth-child(2) { background: linear-gradient(...); }
      &:nth-child(3) { background: linear-gradient(...); }
    }
  }
}
```

#### Join Button

```scss
.tribe-join-btn {
  width: 100%;
  padding: 12px;
  border-radius: 8px;
  background: var(--ft-primary);
  color: var(--ft-white);
  font-weight: 600;

  &:hover {
    background: var(--ft-primary-hover);
  }
}
```

---

### filter-dropdown.scss

Filter dropdown control.

#### Trigger Button

```scss
.filter-trigger {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 8px;
  background: var(--ft-white);
  border: 1px solid var(--ft-gray-200);

  .chevron {
    transition: transform 150ms;

    &.open {
      transform: rotate(180deg);
    }
  }
}
```

#### Dropdown Menu

```scss
.filter-dropdown-menu {
  position: absolute;
  width: 224px;
  background: var(--ft-white);
  border-radius: 8px;
  box-shadow: var(--ft-shadow-lg);
  z-index: 100;

  .filter-option {
    padding: 12px 16px;

    &:hover {
      background: var(--ft-gray-50);
    }

    &.active {
      background: rgba(255, 23, 68, 0.1);
      color: var(--ft-primary);
    }
  }
}
```

#### Backdrop

```scss
.filter-backdrop {
  position: fixed;
  inset: 0;
  z-index: 99;
  // Click outside to close
}
```

---

## Data Flow

```
┌──────────────────┐
│   site.categories │
│   (Discourse)     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   ExploreRoute   │
│   model()        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  explore.gjs     │
│  (template)      │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│  FantribeExplorePage                                      │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ parentCategories                                     │ │
│  │   = categories.filter(c => !c.parent_category_id)   │ │
│  └─────────────────────────────────────────────────────┘ │
│                         │                                 │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ filterOptions                                        │ │
│  │   = ["All", ...parentCategories.map(c => c.name)]   │ │
│  └─────────────────────────────────────────────────────┘ │
│                         │                                 │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ filteredCategories                                   │ │
│  │   = activeFilter === "All"                           │ │
│  │     ? allDisplayCategories                           │ │
│  │     : categories matching activeFilter               │ │
│  └─────────────────────────────────────────────────────┘ │
│                         │                                 │
│                         ▼                                 │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ {{#each filteredCategories as |category|}}          │ │
│  │   <FantribeTribeCard @category={{category}} />       │ │
│  │ {{/each}}                                            │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                           │
└───────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│  FantribeTribeCard                                        │
│                                                           │
│  @category → coverStyle, topicCount, description, etc.   │
│                                                           │
│  handleCardClick() → router.transitionTo(                │
│    "discovery.category",                                  │
│    category.slug,                                        │
│    category.id                                           │
│  )                                                        │
└──────────────────────────────────────────────────────────┘
```

---

## Key Features

### 1. Category Browsing

- Displays all non-uncategorized categories as discoverable "tribes"
- Shows category metadata: name, description, topic count
- Visual customization based on category settings

### 2. Filtering by Parent Category

- Dropdown filter with all parent categories + "All" option
- Filters both parent and child categories
- Results count updates dynamically
- Filter state managed via tracked property

### 3. Visual Customization

- Supports category emoji, icon (FA), or logo image
- Uses category color for fallback gradients
- Parent category badge display on cover
- 16:9 aspect ratio cover images

### 4. Activity Metrics

- Shows topic count as "X active today"
- Formatted as "1.2K" for 1000+ topics
- Animated activity dots (3 gradient circles)

### 5. Navigation

- "Join Tribe" button navigates to category discovery page
- Full card clickable for navigation
- Uses Ember router for SPA navigation (no page reloads)

### 6. Responsive Design

- Mobile-first approach
- Adaptive grid: 1 → 2 → 3 columns
- Responsive typography and spacing
- Touch-friendly button sizing (48px min)

---

## Dependencies

### Ember Services

| Service | Usage |
|---------|-------|
| `@service site` | Access to categories list |
| `@service router` | Navigation between routes |

### Discourse Helpers

| Helper | Usage |
|--------|-------|
| `d-icon` | Render Discourse icons |
| `replace-emoji` | Convert emoji codes to emojis |

### Data Source

- All data from `site.categories` (no external API calls)
- Client-side filtering only
- Categories loaded on initial page load

---

## Extensibility

Potential future enhancements:

1. Server-side filtering/sorting endpoint
2. Search functionality for tribe names
3. Category subscription/following feature
4. Sorting options (newest, most active)
5. Advanced filtering (by subcategories)
6. Tribe "favoriting" with local storage
7. Server-rendered initial state for SEO
