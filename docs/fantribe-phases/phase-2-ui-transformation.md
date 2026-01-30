# Phase 2: Social Media UI Transformation

> **Quick Reference:** See [Implementation Guidelines](../FANTRIBE-IMPLEMENTATION-PLAN.md#implementation-guidelines) for design rules (pastel colors, review checkpoints).

## Overview
Transform Discourse's traditional forum interface into a modern social media UI with custom header, feed view, post cards, user profiles, tribe pages, buttons, mobile responsiveness, and glassmorphism effects.

## Prerequisites
- [ ] Phase 1 completed and approved
- [ ] Plugin structure in place
- [ ] Design system variables defined

---

## CRITICAL: Dark Mode Compatibility Rule

**All components in Phase 2.2-2.8 MUST use CSS custom properties for colors.**

This ensures automatic dark mode support without retrofitting.

```scss
// ✅ DO THIS - Use CSS variables
background: var(--ft-white);
color: var(--ft-dark);
border: var(--ft-glass-border-subtle);
box-shadow: var(--ft-shadow-md);

// ❌ NOT THIS - No hardcoded colors
background: #ffffff;
color: #1a1a1a;
border: 1px solid rgba(26, 26, 26, 0.08);
box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
```

**Available variables:** See `design-tokens.scss` for full list (`--ft-*` prefix).

---

## Sub-Phase Progress
| Sub-Phase | Component | Status |
|-----------|-----------|--------|
| 2.1 | Custom Header | ✅ completed |
| 2.2 | Feed View | ✅ completed |
| 2.3 | Post Cards | ⏳ pending |
| 2.4 | User Profiles | ⏳ pending |
| 2.5 | Tribe Pages | ⏳ pending |
| 2.6 | Buttons | ⏳ pending |
| 2.7 | Mobile Responsive | ⏳ pending |
| 2.8 | Glassmorphism | ⏳ pending |
| 2.9 | Dark Theme Support | ⏳ pending |

---

## 2.1 Custom Header Component (BUILD FROM SCRATCH)
**Goal:** Build a completely custom social media header, NOT just styling Discourse's native header

**IMPORTANT:** Do NOT simply style Discourse's native header. Create a custom Glimmer component that replaces it entirely for full control over the UI.

### 2.1.1 Plugin Structure for Custom Header

**Update plugin directory structure:**
```
plugins/fantribe-theme/
├── assets/
│   ├── javascripts/
│   │   └── discourse/
│   │       ├── components/
│   │       │   ├── fantribe-header.gjs          # Main custom header
│   │       │   ├── fantribe-nav-item.gjs        # Navigation item component
│   │       │   ├── fantribe-search-button.gjs   # Search trigger
│   │       │   ├── fantribe-notifications.gjs   # Notifications dropdown
│   │       │   ├── fantribe-user-menu.gjs       # User avatar/menu
│   │       │   └── fantribe-mobile-nav.gjs      # Mobile bottom navigation
│   │       ├── connectors/
│   │       │   └── below-site-header/
│   │       │       └── fantribe-header-connector.gjs
│   │       └── initializers/
│   │           └── fantribe-header-init.js
│   └── stylesheets/
│       └── common/
│           └── components/
│               ├── header.scss
│               └── mobile-nav.scss
```

### 2.1.2 Hide Discourse Native Header

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/initializers/fantribe-header-init.js`

```javascript
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "fantribe-hide-native-header",
  initialize() {
    withPluginApi("1.14.0", (api) => {
      // Hide native Discourse header via CSS class
      api.onPageChange(() => {
        document.body.classList.add("fantribe-custom-header");
      });
    });
  }
};
```

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/header.scss`

```scss
// CRITICAL: Hide Discourse's native header when custom header is active
body.fantribe-custom-header {
  .d-header {
    display: none !important;
  }
}
```

### 2.1.3 Create Main Custom Header Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-header.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import FantribeNavItem from "./fantribe-nav-item";
import FantribeSearchButton from "./fantribe-search-button";
import FantribeNotifications from "./fantribe-notifications";
import FantribeUserMenu from "./fantribe-user-menu";

export default class FantribeHeader extends Component {
  @service router;
  @service currentUser;
  @service siteSettings;
  @service site;

  @tracked mobileMenuOpen = false;

  get logoUrl() {
    return this.siteSettings.logo_url || "/images/logo.png";
  }

  get isLoggedIn() {
    return !!this.currentUser;
  }

  get currentPath() {
    return this.router.currentRouteName;
  }

  @action
  navigateToHome() {
    this.router.transitionTo("discovery.latest");
  }

  @action
  toggleMobileMenu() {
    this.mobileMenuOpen = !this.mobileMenuOpen;
  }

  <template>
    <header class="fantribe-header">
      <div class="fantribe-header__container">
        {{! Logo }}
        <div class="fantribe-header__logo" {{on "click" this.navigateToHome}} role="button">
          <img src={{this.logoUrl}} alt="FanTribe" class="fantribe-header__logo-img" />
        </div>

        {{! Desktop Navigation }}
        <nav class="fantribe-header__nav fantribe-header__nav--desktop">
          <FantribeNavItem
            @route="discovery.latest"
            @label="Feed"
            @icon="home"
            @isActive={{eq this.currentPath "discovery.latest"}}
          />
          <FantribeNavItem
            @route="discovery.categories"
            @label="Tribes"
            @icon="users"
            @isActive={{eq this.currentPath "discovery.categories"}}
          />
          <FantribeNavItem
            @route="discovery.top"
            @label="Trending"
            @icon="fire"
            @isActive={{eq this.currentPath "discovery.top"}}
          />
        </nav>

        {{! Right Side Actions }}
        <div class="fantribe-header__actions">
          <FantribeSearchButton />

          {{#if this.isLoggedIn}}
            <FantribeNotifications />
            <FantribeUserMenu @user={{this.currentUser}} />
          {{else}}
            <a href="/login" class="fantribe-header__login-btn">Log In</a>
            <a href="/signup" class="fantribe-header__signup-btn">Sign Up</a>
          {{/if}}
        </div>
      </div>
    </header>
  </template>
}
```

### 2.1.4 Navigation Item Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-nav-item.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import icon from "discourse-common/helpers/d-icon";

export default class FantribeNavItem extends Component {
  @service router;

  get activeClass() {
    return this.args.isActive ? "fantribe-nav-item--active" : "";
  }

  @action
  navigate() {
    this.router.transitionTo(this.args.route);
  }

  <template>
    <button
      class="fantribe-nav-item {{this.activeClass}}"
      {{on "click" this.navigate}}
      type="button"
    >
      {{icon @icon}}
      <span class="fantribe-nav-item__label">{{@label}}</span>
    </button>
  </template>
}
```

### 2.1.5 Search Button Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-search-button.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import icon from "discourse-common/helpers/d-icon";

export default class FantribeSearchButton extends Component {
  @service search;

  @action
  openSearch() {
    // Trigger Discourse's native search modal
    this.search.set("visible", true);
  }

  <template>
    <button
      class="fantribe-search-btn"
      {{on "click" this.openSearch}}
      type="button"
      aria-label="Search"
    >
      {{icon "search"}}
    </button>
  </template>
}
```

### 2.1.6 Notifications Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-notifications.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import icon from "discourse-common/helpers/d-icon";

export default class FantribeNotifications extends Component {
  @service currentUser;
  @service router;

  @tracked dropdownOpen = false;

  get unreadCount() {
    return this.currentUser?.unread_notifications || 0;
  }

  get hasUnread() {
    return this.unreadCount > 0;
  }

  @action
  toggleDropdown() {
    this.dropdownOpen = !this.dropdownOpen;
  }

  @action
  goToNotifications() {
    this.router.transitionTo("userNotifications", this.currentUser.username);
    this.dropdownOpen = false;
  }

  <template>
    <div class="fantribe-notifications">
      <button
        class="fantribe-notifications__btn"
        {{on "click" this.toggleDropdown}}
        type="button"
        aria-label="Notifications"
      >
        {{icon "bell"}}
        {{#if this.hasUnread}}
          <span class="fantribe-notifications__badge">
            {{if (gt this.unreadCount 99) "99+" this.unreadCount}}
          </span>
        {{/if}}
      </button>

      {{#if this.dropdownOpen}}
        <div class="fantribe-notifications__dropdown">
          <div class="fantribe-notifications__header">
            <span>Notifications</span>
            <button {{on "click" this.goToNotifications}}>See All</button>
          </div>
          <div class="fantribe-notifications__list">
            {{! Render notifications here using Discourse's notification data }}
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
```

### 2.1.7 User Menu Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-user-menu.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import avatar from "discourse/helpers/avatar";
import icon from "discourse-common/helpers/d-icon";

export default class FantribeUserMenu extends Component {
  @service router;
  @service currentUser;

  @tracked menuOpen = false;

  @action
  toggleMenu() {
    this.menuOpen = !this.menuOpen;
  }

  @action
  goToProfile() {
    this.router.transitionTo("user", this.currentUser.username);
    this.menuOpen = false;
  }

  @action
  goToSettings() {
    this.router.transitionTo("preferences", this.currentUser.username);
    this.menuOpen = false;
  }

  @action
  goToMessages() {
    this.router.transitionTo("userPrivateMessages", this.currentUser.username);
    this.menuOpen = false;
  }

  @action
  logout() {
    window.location.href = "/logout";
  }

  <template>
    <div class="fantribe-user-menu">
      <button
        class="fantribe-user-menu__trigger"
        {{on "click" this.toggleMenu}}
        type="button"
      >
        {{avatar @user imageSize="small"}}
      </button>

      {{#if this.menuOpen}}
        <div class="fantribe-user-menu__dropdown">
          <div class="fantribe-user-menu__header">
            {{avatar @user imageSize="medium"}}
            <div class="fantribe-user-menu__info">
              <span class="fantribe-user-menu__name">{{@user.name}}</span>
              <span class="fantribe-user-menu__username">@{{@user.username}}</span>
            </div>
          </div>

          <nav class="fantribe-user-menu__nav">
            <button {{on "click" this.goToProfile}}>
              {{icon "user"}} Profile
            </button>
            <button {{on "click" this.goToMessages}}>
              {{icon "envelope"}} Messages
            </button>
            <button {{on "click" this.goToSettings}}>
              {{icon "cog"}} Settings
            </button>
            <hr />
            <button {{on "click" this.logout}} class="fantribe-user-menu__logout">
              {{icon "sign-out-alt"}} Log Out
            </button>
          </nav>
        </div>
      {{/if}}
    </div>
  </template>
}
```

### 2.1.8 Mobile Bottom Navigation Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-mobile-nav.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import icon from "discourse-common/helpers/d-icon";

export default class FantribeMobileNav extends Component {
  @service router;
  @service currentUser;
  @service composer;

  get currentPath() {
    return this.router.currentRouteName;
  }

  @action
  goToFeed() {
    this.router.transitionTo("discovery.latest");
  }

  @action
  goToSearch() {
    this.router.transitionTo("full-page-search");
  }

  @action
  createPost() {
    this.composer.open({
      action: "createTopic",
      draftKey: "new_topic"
    });
  }

  @action
  goToNotifications() {
    if (this.currentUser) {
      this.router.transitionTo("userNotifications", this.currentUser.username);
    } else {
      this.router.transitionTo("login");
    }
  }

  @action
  goToProfile() {
    if (this.currentUser) {
      this.router.transitionTo("user", this.currentUser.username);
    } else {
      this.router.transitionTo("login");
    }
  }

  <template>
    <nav class="fantribe-mobile-nav">
      <button
        class="fantribe-mobile-nav__item {{if (eq this.currentPath 'discovery.latest') 'active'}}"
        {{on "click" this.goToFeed}}
        type="button"
      >
        {{icon "home"}}
        <span>Feed</span>
      </button>

      <button
        class="fantribe-mobile-nav__item"
        {{on "click" this.goToSearch}}
        type="button"
      >
        {{icon "search"}}
        <span>Search</span>
      </button>

      <button
        class="fantribe-mobile-nav__item fantribe-mobile-nav__item--create"
        {{on "click" this.createPost}}
        type="button"
      >
        {{icon "plus"}}
      </button>

      <button
        class="fantribe-mobile-nav__item"
        {{on "click" this.goToNotifications}}
        type="button"
      >
        {{icon "bell"}}
        <span>Alerts</span>
      </button>

      <button
        class="fantribe-mobile-nav__item {{if (eq this.currentPath 'user.index') 'active'}}"
        {{on "click" this.goToProfile}}
        type="button"
      >
        {{icon "user"}}
        <span>Profile</span>
      </button>
    </nav>
  </template>
}
```

### 2.1.9 Render Custom Header via Plugin Outlet

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/connectors/below-site-header/fantribe-header-connector.gjs`

```javascript
import Component from "@glimmer/component";
import FantribeHeader from "../../components/fantribe-header";
import FantribeMobileNav from "../../components/fantribe-mobile-nav";

export default class FantribeHeaderConnector extends Component {
  <template>
    <FantribeHeader />
    <FantribeMobileNav />
  </template>
}
```

### 2.1.10-2.1.11 Header & Mobile Nav Styles

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/header.scss`

See the full SCSS in the original implementation plan. Key sections:
- Custom Header Styles (`.fantribe-header`)
- Navigation Item (`.fantribe-nav-item`)
- Search Button (`.fantribe-search-btn`)
- Notifications (`.fantribe-notifications`)
- User Menu (`.fantribe-user-menu`)
- Body padding for fixed header

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/mobile-nav.scss`

Mobile bottom navigation styles with:
- Fixed bottom position
- 5-item navigation
- Elevated create button
- Active state highlighting

### 2.1.12 Header Component Documentation

After building, create: `plugins/fantribe-theme/docs/components/header.md`

---

## 2.2 Feed View - Three-Column Layout with Social Feed

**Goal:** Create a responsive three-column layout with tribes navigation, main feed, and trending widget.

### 2.2.1 Layout Overview

**Desktop (≥1024px):** Three-column grid
```
┌──────────────┬─────────────────────────────┬───────────────────┐
│   TRIBES     │         MAIN FEED           │    TRENDING       │
│   NAV        │                             │    TOPICS         │
│   (~220px)   │      (flex: 1, fluid)       │    (~280px)       │
│   (sticky)   │        (scrollable)         │     (sticky)      │
└──────────────┴─────────────────────────────┴───────────────────┘
```

**Tablet (768-1023px):** Two-column grid (trending hidden)
```
┌──────────────┬───────────────────────────────┐
│   TRIBES     │         MAIN FEED             │
│   (~200px)   │      (flex: 1, fluid)         │
└──────────────┴───────────────────────────────┘
```

**Mobile (<768px):** Single column with filter tabs
```
┌──────────────────────────────┐
│   [All ▼] [Trending] [New]   │  ← Filter tabs
├──────────────────────────────┤
│         MAIN FEED            │
│       (full width)           │
└──────────────────────────────┘
```

---

### 2.2.2 Feed Layout Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-feed-layout.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import FantribeTribesSidebar from "./fantribe-tribes-sidebar";
import FantribeTrendingWidget from "./fantribe-trending-widget";
import FantribeMobileFilterTabs from "./fantribe-mobile-filter-tabs";

export default class FantribeFeedLayout extends Component {
  @service site;
  @service router;

  get categories() {
    return this.site.categories || [];
  }

  <template>
    <div class="fantribe-feed-layout">
      {{! Mobile filter tabs - visible on mobile only }}
      <FantribeMobileFilterTabs
        @categories={{this.categories}}
        class="fantribe-feed-layout__mobile-tabs"
      />

      {{! Left sidebar - tribes navigation }}
      <aside class="fantribe-feed-layout__sidebar fantribe-feed-layout__sidebar--left">
        <FantribeTribesSidebar @categories={{this.categories}} />
      </aside>

      {{! Center - main feed content }}
      <main class="fantribe-feed-layout__content">
        {{yield}}
      </main>

      {{! Right sidebar - trending }}
      <aside class="fantribe-feed-layout__sidebar fantribe-feed-layout__sidebar--right">
        <FantribeTrendingWidget />
      </aside>
    </div>
  </template>
}
```

---

### 2.2.3 Feed Layout Styles

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/feed-layout.scss`

```scss
@import "../variables";

.fantribe-feed-layout {
  display: grid;
  grid-template-columns: 220px minmax(0, 1fr) 280px;
  grid-template-areas: "left-sidebar content right-sidebar";
  gap: $fantribe-spacing-md;
  max-width: 1400px;
  margin: 0 auto;
  padding: $fantribe-spacing-md;
  min-height: calc(100vh - 64px);

  &__mobile-tabs {
    display: none;
  }

  &__sidebar {
    position: sticky;
    top: calc(64px + $fantribe-spacing-md);
    height: fit-content;
    max-height: calc(100vh - 64px - $fantribe-spacing-md * 2);
    overflow-y: auto;

    &--left {
      grid-area: left-sidebar;
    }

    &--right {
      grid-area: right-sidebar;
    }
  }

  &__content {
    grid-area: content;
    min-width: 0;
  }

  // Tablet: Hide right sidebar
  @media (max-width: $laptop - 1px) {
    grid-template-columns: 200px minmax(0, 1fr);
    grid-template-areas: "left-sidebar content";

    &__sidebar--right {
      display: none;
    }
  }

  // Mobile: Single column
  @media (max-width: $tablet - 1px) {
    display: flex;
    flex-direction: column;
    padding: $fantribe-spacing-sm;
    gap: $fantribe-spacing-sm;

    &__mobile-tabs {
      display: flex;
      order: -1;
    }

    &__sidebar {
      display: none;

      &--left,
      &--right {
        display: none;
      }
    }

    &__content {
      width: 100%;
    }
  }
}
```

---

### 2.2.4 Tribes Sidebar Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-tribes-sidebar.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import icon from "discourse-common/helpers/d-icon";

export default class FantribeTribesSidebar extends Component {
  @service router;

  @tracked selectedCategory = null;

  get sortedCategories() {
    return (this.args.categories || [])
      .filter(c => !c.isUncategorized)
      .sort((a, b) => a.position - b.position);
  }

  @action
  selectCategory(category) {
    this.selectedCategory = category;
    if (category) {
      this.router.transitionTo("discovery.category", category.slug);
    } else {
      this.router.transitionTo("discovery.latest");
    }
  }

  <template>
    <nav class="fantribe-tribes-sidebar">
      <h3 class="fantribe-tribes-sidebar__title">
        {{icon "users"}} Tribes
      </h3>

      <ul class="fantribe-tribes-sidebar__list">
        <li>
          <button
            class="fantribe-tribes-sidebar__item {{unless this.selectedCategory 'active'}}"
            {{on "click" (fn this.selectCategory null)}}
            type="button"
          >
            {{icon "globe"}}
            <span>All Tribes</span>
          </button>
        </li>

        {{#each this.sortedCategories as |category|}}
          <li>
            <button
              class="fantribe-tribes-sidebar__item {{if (eq this.selectedCategory category) 'active'}}"
              {{on "click" (fn this.selectCategory category)}}
              type="button"
            >
              <span
                class="fantribe-tribes-sidebar__color"
                style="background-color: #{{category.color}}"
              ></span>
              <span>{{category.name}}</span>
              <span class="fantribe-tribes-sidebar__count">{{category.topic_count}}</span>
            </button>
          </li>
        {{/each}}
      </ul>
    </nav>
  </template>
}
```

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/tribes-sidebar.scss`

```scss
@import "../variables";

.fantribe-tribes-sidebar {
  background: $fantribe-card-bg;
  border-radius: $fantribe-radius-md;
  padding: $fantribe-spacing-md;
  box-shadow: $fantribe-shadow-sm;

  &__title {
    display: flex;
    align-items: center;
    gap: $fantribe-spacing-xs;
    font-size: $fantribe-font-size-base;
    font-weight: 600;
    color: $fantribe-dark;
    margin-bottom: $fantribe-spacing-md;
    padding-bottom: $fantribe-spacing-sm;
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);

    .d-icon {
      color: $fantribe-primary;
    }
  }

  &__list {
    list-style: none;
    margin: 0;
    padding: 0;
  }

  &__item {
    width: 100%;
    display: flex;
    align-items: center;
    gap: $fantribe-spacing-sm;
    padding: $fantribe-spacing-sm;
    border: none;
    background: transparent;
    border-radius: $fantribe-radius-sm;
    cursor: pointer;
    font-size: $fantribe-font-size-small;
    color: rgba($fantribe-dark, 0.8);
    text-align: left;
    transition: all 0.2s ease;

    &:hover {
      background: $fantribe-pastel-cream;
    }

    &.active {
      background: $fantribe-pastel-pink;
      color: $fantribe-primary;
      font-weight: 500;
    }
  }

  &__color {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    flex-shrink: 0;
  }

  &__count {
    margin-left: auto;
    font-size: 12px;
    color: rgba($fantribe-dark, 0.5);
    background: $fantribe-pastel-gray;
    padding: 2px 8px;
    border-radius: 10px;
  }
}
```

---

### 2.2.5 Trending Widget Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-trending-widget.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import icon from "discourse-common/helpers/d-icon";

export default class FantribeTrendingWidget extends Component {
  @service store;
  @service router;

  @tracked trendingTopics = [];
  @tracked isLoading = true;

  constructor() {
    super(...arguments);
    this.loadTrendingTopics();
  }

  async loadTrendingTopics() {
    try {
      const result = await this.store.findFiltered("topicList", {
        filter: "top/weekly",
        params: { per_page: 5 }
      });
      this.trendingTopics = result.topics?.slice(0, 5) || [];
    } catch (e) {
      console.error("Failed to load trending topics", e);
    } finally {
      this.isLoading = false;
    }
  }

  @action
  goToTopic(topic) {
    this.router.transitionTo("topic", topic.slug, topic.id);
  }

  <template>
    <aside class="fantribe-trending-widget">
      <h3 class="fantribe-trending-widget__title">
        {{icon "fire"}} Trending
      </h3>

      {{#if this.isLoading}}
        <div class="fantribe-trending-widget__loading">Loading...</div>
      {{else}}
        <ul class="fantribe-trending-widget__list">
          {{#each this.trendingTopics as |topic index|}}
            <li>
              <button
                class="fantribe-trending-widget__item"
                {{on "click" (fn this.goToTopic topic)}}
                type="button"
              >
                <span class="fantribe-trending-widget__rank">{{add index 1}}</span>
                <div class="fantribe-trending-widget__content">
                  <span class="fantribe-trending-widget__topic-title">{{topic.title}}</span>
                  <span class="fantribe-trending-widget__meta">
                    {{topic.like_count}} likes · {{topic.posts_count}} comments
                  </span>
                </div>
              </button>
            </li>
          {{/each}}
        </ul>
      {{/if}}

      <a href="/top" class="fantribe-trending-widget__see-all">
        See all trending →
      </a>
    </aside>
  </template>
}
```

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/trending-widget.scss`

```scss
@import "../variables";

.fantribe-trending-widget {
  background: $fantribe-card-bg;
  border-radius: $fantribe-radius-md;
  padding: $fantribe-spacing-md;
  box-shadow: $fantribe-shadow-sm;

  &__title {
    display: flex;
    align-items: center;
    gap: $fantribe-spacing-xs;
    font-size: $fantribe-font-size-base;
    font-weight: 600;
    color: $fantribe-dark;
    margin-bottom: $fantribe-spacing-md;
    padding-bottom: $fantribe-spacing-sm;
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);

    .d-icon {
      color: #F59E0B; // Amber for fire icon
    }
  }

  &__loading {
    padding: $fantribe-spacing-md;
    text-align: center;
    color: rgba($fantribe-dark, 0.5);
  }

  &__list {
    list-style: none;
    margin: 0;
    padding: 0;
  }

  &__item {
    width: 100%;
    display: flex;
    align-items: flex-start;
    gap: $fantribe-spacing-sm;
    padding: $fantribe-spacing-sm;
    border: none;
    background: transparent;
    border-radius: $fantribe-radius-sm;
    cursor: pointer;
    text-align: left;
    transition: all 0.2s ease;

    &:hover {
      background: $fantribe-pastel-cream;
    }
  }

  &__rank {
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: $fantribe-pastel-lavender;
    border-radius: 50%;
    font-size: 12px;
    font-weight: 600;
    color: $fantribe-dark;
    flex-shrink: 0;
  }

  &__content {
    flex: 1;
    min-width: 0;
  }

  &__topic-title {
    display: block;
    font-size: $fantribe-font-size-small;
    font-weight: 500;
    color: $fantribe-dark;
    line-height: 1.3;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
  }

  &__meta {
    display: block;
    font-size: 12px;
    color: rgba($fantribe-dark, 0.5);
    margin-top: 4px;
  }

  &__see-all {
    display: block;
    text-align: center;
    padding: $fantribe-spacing-sm;
    margin-top: $fantribe-spacing-sm;
    color: $fantribe-primary;
    font-size: $fantribe-font-size-small;
    font-weight: 500;
    text-decoration: none;
    border-top: 1px solid rgba(0, 0, 0, 0.06);

    &:hover {
      text-decoration: underline;
    }
  }
}
```

---

### 2.2.6 Mobile Filter Tabs Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-mobile-filter-tabs.gjs`

```javascript
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import icon from "discourse-common/helpers/d-icon";

export default class FantribeMobileFilterTabs extends Component {
  @service router;

  @tracked showCategoryDropdown = false;
  @tracked selectedCategory = null;

  @action
  toggleCategoryDropdown() {
    this.showCategoryDropdown = !this.showCategoryDropdown;
  }

  @action
  selectCategory(category) {
    this.selectedCategory = category;
    this.showCategoryDropdown = false;
    if (category) {
      this.router.transitionTo("discovery.category", category.slug);
    } else {
      this.router.transitionTo("discovery.latest");
    }
  }

  @action
  goToTrending() {
    this.router.transitionTo("discovery.top");
  }

  <template>
    <div class="fantribe-mobile-filter-tabs">
      <button
        class="fantribe-mobile-filter-tabs__tab"
        {{on "click" this.toggleCategoryDropdown}}
        type="button"
      >
        {{icon "filter"}}
        {{if this.selectedCategory this.selectedCategory.name "All Tribes"}}
        {{icon "chevron-down"}}
      </button>

      <button
        class="fantribe-mobile-filter-tabs__tab"
        {{on "click" this.goToTrending}}
        type="button"
      >
        {{icon "fire"}}
        Trending
      </button>

      {{#if this.showCategoryDropdown}}
        <div class="fantribe-mobile-filter-tabs__dropdown">
          <button {{on "click" (fn this.selectCategory null)}}>All Tribes</button>
          {{#each @categories as |category|}}
            <button {{on "click" (fn this.selectCategory category)}}>
              {{category.name}}
            </button>
          {{/each}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/mobile-filter-tabs.scss`

```scss
@import "../variables";

.fantribe-mobile-filter-tabs {
  display: none; // Hidden on desktop
  position: relative;

  @media (max-width: $tablet - 1px) {
    display: flex;
    gap: $fantribe-spacing-sm;
    padding: $fantribe-spacing-sm 0;
  }

  &__tab {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: $fantribe-spacing-xs;
    padding: $fantribe-spacing-sm $fantribe-spacing-md;
    background: $fantribe-card-bg;
    border: 1px solid rgba(0, 0, 0, 0.06);
    border-radius: $fantribe-radius-md;
    font-size: $fantribe-font-size-small;
    font-weight: 500;
    color: $fantribe-dark;
    cursor: pointer;
    transition: all 0.2s ease;

    &:hover {
      background: $fantribe-pastel-cream;
    }

    .d-icon {
      font-size: 14px;
    }
  }

  &__dropdown {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: $fantribe-card-bg;
    border-radius: $fantribe-radius-md;
    box-shadow: $fantribe-shadow-lg;
    z-index: 100;
    margin-top: $fantribe-spacing-xs;
    max-height: 300px;
    overflow-y: auto;

    button {
      width: 100%;
      padding: $fantribe-spacing-sm $fantribe-spacing-md;
      border: none;
      background: transparent;
      text-align: left;
      font-size: $fantribe-font-size-small;
      color: $fantribe-dark;
      cursor: pointer;

      &:hover {
        background: $fantribe-pastel-cream;
      }

      &:not(:last-child) {
        border-bottom: 1px solid rgba(0, 0, 0, 0.06);
      }
    }
  }
}
```

---

### 2.2.7 Responsive Behavior Summary

| Breakpoint | Layout | Left Sidebar | Right Sidebar | Tribes Filter |
|------------|--------|--------------|---------------|---------------|
| ≥1024px (Desktop) | 3-column grid | Visible (220px) | Visible (280px) | Sidebar |
| 768-1023px (Tablet) | 2-column grid | Visible (200px) | Hidden | Sidebar |
| <768px (Mobile) | Single column | Hidden | Hidden | Dropdown tabs |

---

### 2.2.8 Feed Card Styling

The center column displays topic list items styled as social media cards.

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/feed.scss`

```scss
@import "../variables";

// Transform topic list items into feed cards
.topic-list-item {
  display: block;
  background: $fantribe-card-bg;
  border-radius: $fantribe-radius-md;
  padding: $fantribe-spacing-md;
  margin-bottom: $fantribe-spacing-md;
  box-shadow: $fantribe-shadow-sm;
  border: none;
  transition: all 0.2s ease;

  &:hover {
    box-shadow: $fantribe-shadow-md;
    transform: translateY(-2px);
  }

  // Hide forum-style metadata
  .num.posts,
  .num.views,
  .num.likes,
  .category,
  .posters {
    display: none;
  }

  // Style as social post card
  .main-link {
    display: flex;
    flex-direction: column;
    gap: $fantribe-spacing-sm;

    .topic-title {
      font-size: $fantribe-font-size-large;
      font-weight: 600;
      color: $fantribe-dark;
      margin: 0;
    }

    .topic-excerpt {
      color: rgba($fantribe-dark, 0.7);
      font-size: $fantribe-font-size-base;
      line-height: 1.5;
    }
  }

  // Author info at top
  .topic-poster {
    display: flex;
    align-items: center;
    gap: $fantribe-spacing-sm;
    margin-bottom: $fantribe-spacing-sm;

    .avatar {
      width: 40px;
      height: 40px;
      border-radius: 50%;
    }

    .username {
      font-weight: 600;
      color: $fantribe-dark;
    }

    .relative-date {
      color: rgba($fantribe-dark, 0.5);
      font-size: $fantribe-font-size-small;
    }
  }

  // Engagement bar at bottom
  .topic-stats {
    display: flex;
    gap: $fantribe-spacing-md;
    padding-top: $fantribe-spacing-sm;
    border-top: 1px solid rgba(0, 0, 0, 0.06);
    margin-top: $fantribe-spacing-sm;

    .stat {
      display: flex;
      align-items: center;
      gap: 4px;
      color: rgba($fantribe-dark, 0.6);
      font-size: $fantribe-font-size-small;

      &:hover {
        color: $fantribe-primary;
      }
    }
  }
}
```

---

## 2.3 Post Card Component (Individual Posts)
**Goal:** Style individual posts as social media cards

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/post-card.scss`

**Target:** `.topic-post` (individual post/reply in a topic)

Key styles:
- Card layout with shadow
- Author info at top (avatar, name, timestamp)
- Content area with image grid support
- Post actions bar (like, reply, share)
- Hide forum-style elements

---

## 2.4 User Profile Page Transformation
**Goal:** Social media style profile with cover photo, bio, activity feed

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/user-profile.scss`

**Target:** `.user-main` (user profile page)

Key elements:
- Cover photo area (gradient default)
- Avatar overlapping cover
- Name, username, bio section
- Stats row (followers, following, posts)
- Activity tabs as pills
- User's post feed

---

## 2.5 Tribe (Category) Page Redesign
**Goal:** Transform category page into social-style tribe page

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/tribe-page.scss`

**Target:** `.category-page` (category landing page)

Key elements:
- Banner image
- Tribe logo (circular, overlapping)
- Name, description
- Stats (members, posts)
- Join/Leave button
- Tabs (Feed, Members, About)
- Post feed

---

## 2.6 Button Styles & Interactive Elements
**Goal:** Consistent button styling across platform

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/buttons.scss`

Button types:
- Primary (red, filled)
- Secondary (outlined)
- Ghost (transparent)
- Icon buttons
- Like button with animation

---

## 2.7 Mobile Responsive Design
**Goal:** Ensure perfect mobile experience across all breakpoints

**File:** `plugins/fantribe-theme/assets/stylesheets/mobile/mobile-overrides.scss`

Breakpoints:
- Mobile S (320px)
- Mobile M (375px)
- Mobile L (425px)
- Tablet (768px)
- Laptop (1024px)
- Desktop (1440px)

Key responsive behaviors:
- Stack stats vertically on small screens
- Full-width buttons on mobile
- Two-column grid on tablet
- Max-width containers on desktop
- Mobile bottom navigation

---

## 2.8 Glassmorphism Effects & Utilities
**Goal:** Apply modern glassmorphism design to key elements

**File:** `plugins/fantribe-theme/assets/stylesheets/common/utilities/glassmorphism.scss`

Apply to:
- Modal overlay
- Header
- Modal inner container
- Glass cards
- Hover effects

---

## 2.9 Dark Theme Support
**Goal:** Add automatic dark mode support with a soft, pastel-inspired dark theme

### 2.9.1 Add Dark Mode CSS Variables

**File:** `plugins/fantribe-theme/assets/stylesheets/common/design-tokens.scss`

Add a `@media (prefers-color-scheme: dark)` block after the existing `:root` block with inverted/softened color values:

**Key color mappings for dark mode:**
| Light Mode | Dark Mode | Purpose |
|------------|-----------|---------|
| `#ff1744` | `#ff6b8a` | Primary (softer red) |
| `#1a1a1a` | `#e8e8ec` | Text (soft white) |
| `#ffffff` | `#1a1a2e` | Background (dark navy) |
| `#f5f5f5` | `#12121f` | Page background |
| `#ffe4e8` | `#3d2d35` | Pastel pink (muted) |

**Glassmorphism adjustments:**
- Glass backgrounds use `rgba(30, 30, 50, 0.85)` instead of white
- Borders use `rgba(255, 255, 255, 0.08)` for subtle visibility
- Shadows are deeper: `rgba(0, 0, 0, 0.3-0.5)`

### 2.9.2 Fix Hardcoded Colors in Components

Audit and replace all hardcoded `rgba()` values with CSS custom properties.

**Files to update:**
- `components/header.scss` - Replace `rgba(255, 255, 255, 0.85)` with `var(--ft-glass-card-bg)`
- `components/mobile-nav.scss` - Same treatment for glassmorphism values
- All future components must use variables only

### 2.9.3 Theme Toggle Component

**Goal:** Add a sun/moon toggle button in the header for manual light/dark mode switching.

#### Component File
**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-theme-toggle.gjs`

```javascript
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import icon from "discourse-common/helpers/d-icon";

const THEME_KEY = "fantribe-theme-preference";

export default class FantribeThemeToggle extends Component {
  @tracked currentTheme = this.getInitialTheme();

  getInitialTheme() {
    // Check localStorage first, then system preference
    const stored = localStorage.getItem(THEME_KEY);
    if (stored) {
      return stored;
    }
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  }

  constructor() {
    super(...arguments);
    this.applyTheme(this.currentTheme);
  }

  @action
  toggleTheme() {
    this.currentTheme = this.currentTheme === "light" ? "dark" : "light";
    localStorage.setItem(THEME_KEY, this.currentTheme);
    this.applyTheme(this.currentTheme);
  }

  applyTheme(theme) {
    const root = document.documentElement;
    if (theme === "dark") {
      root.setAttribute("data-theme", "dark");
      root.classList.add("ft-dark-theme");
      root.classList.remove("ft-light-theme");
    } else {
      root.setAttribute("data-theme", "light");
      root.classList.add("ft-light-theme");
      root.classList.remove("ft-dark-theme");
    }
  }

  get isDark() {
    return this.currentTheme === "dark";
  }

  get iconName() {
    return this.isDark ? "sun" : "moon";
  }

  get ariaLabel() {
    return this.isDark ? "Switch to light mode" : "Switch to dark mode";
  }

  <template>
    <button
      class="fantribe-theme-toggle"
      {{on "click" this.toggleTheme}}
      type="button"
      aria-label={{this.ariaLabel}}
      title={{this.ariaLabel}}
    >
      {{icon this.iconName}}
    </button>
  </template>
}
```

#### Update Header Component

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/components/fantribe-header.gjs`

Add the toggle to the header actions section:

```javascript
// Add import at top
import FantribeThemeToggle from "./fantribe-theme-toggle";

// In the template, add before search button in __actions:
<FantribeThemeToggle />
```

#### Update Design Tokens for Manual Toggle

**File:** `plugins/fantribe-theme/assets/stylesheets/common/design-tokens.scss`

Replace the media query approach with class-based theming:

```scss
// Light theme (default)
:root {
  // ... existing light mode variables ...
}

// Dark theme - activated by class OR system preference
:root.ft-dark-theme,
:root:not(.ft-light-theme):not(.ft-dark-theme) {
  @media (prefers-color-scheme: dark) {
    // ... dark mode variables ...
  }
}

// Force dark theme when class is present (overrides system preference)
:root.ft-dark-theme {
  // ... dark mode variables (same as above, but outside media query) ...
}
```

**Simplified approach - add this after existing dark media query:**

```scss
// Manual dark theme override (when user explicitly selects dark)
html.ft-dark-theme {
  // Copy all dark mode variables here (same as @media block)
  --ft-primary: #ff6b8a;
  --ft-dark: #e8e8ec;
  --ft-white: #1a1a2e;
  // ... rest of dark variables ...
}

// Manual light theme override (when user explicitly selects light)
html.ft-light-theme {
  // Forces light theme even if system prefers dark
  // Uses default :root values, no override needed
}
```

#### Toggle Button Styles

**File:** `plugins/fantribe-theme/assets/stylesheets/common/components/header.scss`

Add styles for the toggle button:

```scss
.fantribe-theme-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: transparent;
  border: none;
  border-radius: var(--ft-radius-full);
  color: var(--ft-gray-600);
  cursor: pointer;
  transition: all var(--ft-transition-fast);

  .d-icon {
    font-size: 18px;
    transition: transform var(--ft-transition-normal);
  }

  &:hover {
    background: var(--ft-pastel-cream);
    color: var(--ft-dark);

    .d-icon {
      transform: rotate(15deg);
    }
  }
}
```

#### Initializer for Theme Persistence

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/initializers/fantribe-theme-init.js`

```javascript
import { withPluginApi } from "discourse/lib/plugin-api";

const THEME_KEY = "fantribe-theme-preference";

export default {
  name: "fantribe-theme-persistence",
  initialize() {
    withPluginApi("1.14.0", () => {
      // Apply saved theme preference on page load
      const savedTheme = localStorage.getItem(THEME_KEY);
      const root = document.documentElement;

      if (savedTheme === "dark") {
        root.setAttribute("data-theme", "dark");
        root.classList.add("ft-dark-theme");
      } else if (savedTheme === "light") {
        root.setAttribute("data-theme", "light");
        root.classList.add("ft-light-theme");
      }
      // If no saved preference, CSS media query handles it automatically
    });
  }
};
```

### 2.9.4 Testing Dark Mode

1. **System preference:** Set OS to dark mode, verify automatic switch (when no manual preference set)
2. **Manual toggle:** Click sun/moon icon, verify theme switches immediately
3. **Persistence:** Refresh page, verify theme preference is remembered
4. **Override:** Set system to light, manually select dark - dark should persist
5. **Glassmorphism:** Check blur effects work in both modes
6. **Accessibility:** Ensure sufficient contrast ratios (4.5:1 minimum)

### 2.9.5 Optional: Discourse ColorScheme Integration

Create color schemes in Admin > Customize > Colors for deeper integration:
- **FanTribe Light** - Default light scheme
- **FanTribe Dark** - Soft dark pastel scheme

This enables user preference override via Discourse settings.

---

## Completion Checklist

### Sub-Phase Checklists
**2.1 Header:**
- [ ] Native header hidden
- [ ] Custom header renders
- [ ] Navigation works
- [ ] Search triggers modal
- [ ] Notifications dropdown works
- [ ] User menu works
- [ ] Mobile nav visible on small screens

**2.2 Feed:**
- [ ] Cards display correctly
- [ ] Author info at top
- [ ] Engagement bar at bottom
- [ ] Responsive layout

**2.3 Post Cards:**
- [ ] Individual posts styled
- [ ] Actions bar functional
- [ ] Images display correctly

**2.4 User Profiles:**
- [ ] Cover photo area
- [ ] Avatar positioned correctly
- [ ] Stats display
- [ ] Activity feed styled

**2.5 Tribe Pages:**
- [ ] Banner displays
- [ ] Join button works
- [ ] Tabs functional
- [ ] Feed displays

**2.6 Buttons:**
- [ ] Primary buttons styled
- [ ] Secondary buttons styled
- [ ] Like animation works

**2.7 Mobile:**
- [ ] All breakpoints tested
- [ ] Bottom nav functional
- [ ] Touch targets adequate

**2.8 Glassmorphism:**
- [ ] Header has blur effect
- [ ] Modals have blur backdrop

**2.9 Dark Theme:**
- [x] Dark mode variables added to design-tokens.scss
- [x] Hardcoded colors replaced with CSS variables (header, mobile-nav)
- [ ] Theme toggle component created (fantribe-theme-toggle.gjs)
- [ ] Toggle added to header actions
- [ ] Theme initializer for persistence (fantribe-theme-init.js)
- [ ] Toggle button styled in header.scss
- [ ] Manual override CSS classes work (ft-dark-theme, ft-light-theme)
- [ ] Light mode renders correctly
- [ ] Dark mode renders correctly (system preference + manual toggle)
- [ ] Theme preference persists across page refresh
- [ ] Glassmorphism effects work in both modes
- [ ] No harsh whites or blacks in dark mode

### Overall
- [ ] All sub-phases complete
- [ ] Code linted (`bin/lint --fix`)
- [ ] No console errors
- [ ] Tested on desktop and mobile
- [ ] Review requested from user

## Files Created/Modified This Phase
<!-- Fill this section as you implement -->
| File | Action | Purpose |
|------|--------|---------|
| `assets/javascripts/discourse/initializers/fantribe-header-init.js` | Created | Hide native Discourse header |
| `assets/javascripts/discourse/components/fantribe-header.gjs` | Created | Main custom header component |
| `assets/javascripts/discourse/components/fantribe-nav-item.gjs` | Created | Navigation item component |
| `assets/javascripts/discourse/components/fantribe-search-button.gjs` | Created | Search button component |
| `assets/javascripts/discourse/components/fantribe-notifications.gjs` | Created | Notifications dropdown component |
| `assets/javascripts/discourse/components/fantribe-user-menu.gjs` | Created | User menu dropdown component |
| `assets/javascripts/discourse/components/fantribe-mobile-nav.gjs` | Created | Mobile bottom navigation |
| `assets/javascripts/discourse/connectors/below-site-header/fantribe-header-connector.gjs` | Created | Plugin outlet connector |
| `assets/stylesheets/common/components/header.scss` | Created | Header styles |
| `assets/stylesheets/common/components/mobile-nav.scss` | Created | Mobile nav styles |
| `plugin.rb` | Modified | Register new stylesheet assets |

## Review Notes
<!-- User feedback and approval notes go here -->
