# Chat Plugin Customizations

FanTribe modifications to Discourse's native chat plugin, transforming it into a modern WhatsApp/iMessage-like messaging experience with the FanTribe design system.

## Overview

| Property | Value |
|----------|-------|
| **Base Plugin** | Discourse Chat (built-in) |
| **Modifications** | Component + CSS changes |
| **Integration** | via fantribe-theme plugin |
| **Description** | Tab-based navigation, message bubbles, brand styling |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     FANTRIBE-THEME PLUGIN                            │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ initializers/fantribe-chat-layout.js                           │  │
│  │   └── Modifies chat controller                                 │  │
│  │       └── Forces channels list visible (except mobile)        │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                               │                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ stylesheets/common/chat.scss (1,400+ lines)                    │  │
│  │   └── Complete chat UI redesign                                │  │
│  │       ├── Two-panel layout                                     │  │
│  │       ├── Tab navigation                                       │  │
│  │       ├── Message bubbles                                      │  │
│  │       ├── Composer styling                                     │  │
│  │       └── Animations                                           │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                                │
                        Depends on
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  DISCOURSE CHAT PLUGIN (Modified)                    │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ components/channels-list.gjs                                   │  │
│  │   └── Tab-based navigation (Channels / Messages)              │  │
│  │       ├── @tracked activeTab                                   │  │
│  │       ├── Unread count badges                                  │  │
│  │       └── Tab switching logic                                  │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ stylesheets/common/ (Minor CSS tweaks)                         │  │
│  │   ├── base-common.scss      → background color                │  │
│  │   ├── chat-message.scss     → edited indicator color          │  │
│  │   └── chat-message-separator.scss → border-radius             │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ stylesheets/desktop/                                           │  │
│  │   └── chat-index-full-page.scss → sidebar border-radius       │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Modified Files Summary

| File | Location | Change Type | Description |
|------|----------|-------------|-------------|
| channels-list.gjs | chat plugin | Component | Tab-based navigation |
| base-common.scss | chat plugin | CSS | Background color |
| chat-message.scss | chat plugin | CSS | Edited indicator color |
| chat-message-separator.scss | chat plugin | CSS | Border-radius |
| chat-index-full-page.scss | chat plugin | CSS (desktop) | Sidebar radius |
| chat.scss | fantribe-theme | CSS (1400+ lines) | Complete redesign |
| fantribe-chat-layout.js | fantribe-theme | Initializer | Controller modification |

---

## Component Changes

### channels-list.gjs

**Location:** `plugins/chat/assets/javascripts/discourse/components/channels-list.gjs`

Converts the channels list from showing both public channels and DMs simultaneously to a tabbed interface.

#### New Architecture

```
┌─────────────────────────────────────────┐
│ ┌─────────────┐ ┌─────────────────────┐ │
│ │  Channels   │ │     Messages        │ │
│ │    (3)      │ │        (5)          │ │
│ └─────────────┘ └─────────────────────┘ │
├─────────────────────────────────────────┤
│                                         │
│  [Channel/DM list based on active tab]  │
│                                         │
└─────────────────────────────────────────┘
```

#### Added Properties

| Property | Type | Description |
|----------|------|-------------|
| `activeTab` | @tracked string | "channels" or "messages" |

#### Added Computed Getters

| Getter | Returns | Description |
|--------|---------|-------------|
| `isChannelsTab` | boolean | Is channels tab active |
| `isDMsTab` | boolean | Is messages tab active |
| `channelsUnreadCount` | number | Unread count for channels |
| `dmsUnreadCount` | number | Unread count for DMs |

#### Added Actions

| Action | Description |
|--------|-------------|
| `switchTab(tabId)` | Switch between "channels" and "messages" |

#### Injected Services

| Service | Usage |
|---------|-------|
| `chatChannelsManager` | Track unread message counts |

#### Tab Behavior

- "Channels" tab: Shows public chat channels
- "Messages" tab: Shows direct messages
- Messages tab only visible if user can access DMs
- Each tab displays unread count badge

---

## CSS Modifications (Chat Plugin)

### base-common.scss

**Location:** `plugins/chat/assets/stylesheets/common/base-common.scss`

```scss
.full-page-chat {
  background: rgb(240, 239, 239);
}
```

**Purpose:** Sets subtle light gray background for main chat container.

---

### chat-message.scss

**Location:** `plugins/chat/assets/stylesheets/common/chat-message.scss`

```scss
.chat-message-edited {
  color: white;  // Changed from var(--primary-medium)
}
```

**Purpose:** Updates "edited" indicator text to white for visibility on dark backgrounds.

---

### chat-message-separator.scss

**Location:** `plugins/chat/assets/stylesheets/common/chat-message-separator.scss`

```scss
.chat-message-separator__text {
  border-radius: 1rem;
}
```

**Purpose:** Adds pill-style rounded borders to date/time separators.

---

### chat-index-full-page.scss (Desktop)

**Location:** `plugins/chat/assets/stylesheets/desktop/chat-index-full-page.scss`

```scss
.channels-list {
  border-radius: 1rem;
}
```

**Purpose:** Adds rounded corners to channels list sidebar on desktop.

---

## Comprehensive Styling (fantribe-theme)

### fantribe-chat-layout.js

**Location:** `plugins/fantribe-theme/assets/javascripts/discourse/initializers/fantribe-chat-layout.js`

Modifies the core chat controller to control sidebar visibility.

```javascript
// Injected getter
get shouldUseChatSidebar() {
  return !this.site.mobileView;
}
```

**Behavior:**
- Desktop: Shows two-panel layout (channels list + chat view)
- Mobile: Shows single panel (content toggles between lists)

---

### chat.scss (1,400+ lines)

**Location:** `plugins/fantribe-theme/assets/stylesheets/common/chat.scss`

The primary customization file that completely transforms the chat UI.

#### Design Tokens Used

```scss
// Primary Colors
--ft-vibrant-red: #ff1744;

// Neutral Colors
--ft-neutral-50 through --ft-neutral-900;

// Accents
--ft-mint: (online status)
--ft-amber: (bookmarks)

// Spacing
--ft-space-1 through --ft-space-8;

// Shadows
Multiple shadow levels for depth

// Border Radius
12px - 24px throughout
```

---

#### Layout Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Full Page Chat Container                  │
│                                                              │
│  ┌─────────────────┐ ┌───────────────────────────────────┐  │
│  │                 │ │                                   │  │
│  │  Channels List  │ │        Chat Messages              │  │
│  │     (30%)       │ │          (flex: 1)                │  │
│  │                 │ │                                   │  │
│  │  ┌───────────┐  │ │  ┌─────────────────────────────┐  │  │
│  │  │ Tabs      │  │ │  │ Channel Header              │  │  │
│  │  ├───────────┤  │ │  ├─────────────────────────────┤  │  │
│  │  │           │  │ │  │                             │  │  │
│  │  │ Channel   │  │ │  │  Message Bubbles            │  │  │
│  │  │ List      │  │ │  │                             │  │  │
│  │  │           │  │ │  │   ┌────────────┐            │  │  │
│  │  │           │  │ │  │   │ Received   │            │  │  │
│  │  │           │  │ │  │   └────────────┘            │  │  │
│  │  │           │  │ │  │                             │  │  │
│  │  │           │  │ │  │        ┌────────────┐       │  │  │
│  │  │           │  │ │  │        │    Sent    │       │  │  │
│  │  │           │  │ │  │        └────────────┘       │  │  │
│  │  │           │  │ │  │                             │  │  │
│  │  └───────────┘  │ │  ├─────────────────────────────┤  │  │
│  │                 │ │  │ Composer                    │  │  │
│  └─────────────────┘ │  └─────────────────────────────┘  │  │
│                      └───────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Responsive:**
- Desktop: Full two-panel layout
- Mobile: Stacked layout, single panel visible

---

#### Tab Interface Styling

```scss
.channels-tabs {
  display: flex;
  gap: 8px;
  padding: 12px;
  border-bottom: 1px solid var(--ft-neutral-200);

  .tab {
    padding: 8px 16px;
    border-radius: 8px;
    font-weight: 500;
    transition: all 150ms;

    &:hover {
      background: var(--ft-neutral-100);
    }

    &.active {
      background: var(--ft-vibrant-red);
      color: white;
    }
  }

  .unread-badge {
    background: var(--ft-vibrant-red);
    color: white;
    border-radius: 9999px;
    padding: 2px 8px;
    font-size: 12px;
    font-weight: 600;
  }
}
```

---

#### Message Bubble Styling

**Received Messages (Left-aligned):**

```scss
.chat-message.is-not-mine {
  .chat-message-content {
    background: #f1f5f9;  // Light slate
    color: var(--ft-neutral-900);
    border-radius: 16px 16px 16px 4px;  // Sharp tail bottom-left
    max-width: 70%;
  }
}
```

**Sent Messages (Right-aligned):**

```scss
.chat-message.is-mine {
  justify-content: flex-end;

  .chat-message-content {
    background: var(--ft-vibrant-red);  // #ff1744
    color: white;
    border-radius: 16px 16px 4px 16px;  // Sharp tail bottom-right
    max-width: 70%;
  }
}
```

**Message Grouping:**

```scss
// Consecutive messages from same user
.chat-message.is-grouped {
  margin-top: 2px;  // Reduced from normal spacing

  .chat-message-avatar,
  .chat-message-header {
    display: none;
  }

  // Smooth bubble corners for grouped messages
  &.is-not-mine .chat-message-content {
    border-radius: 4px 16px 16px 4px;
  }

  &.is-mine .chat-message-content {
    border-radius: 16px 4px 4px 16px;
  }
}
```

---

#### Composer Styling

```scss
.chat-composer {
  padding: 12px 16px;
  background: white;
  border-top: 1px solid var(--ft-neutral-200);

  .chat-composer-input {
    border-radius: 16px;
    padding: 12px 16px;
    border: 1px solid var(--ft-neutral-300);
    transition: all 150ms;

    &:focus {
      border-color: var(--ft-vibrant-red);
      box-shadow: 0 0 0 3px rgba(255, 23, 68, 0.1);
    }
  }

  .chat-composer-send-btn {
    background: linear-gradient(135deg, #ff1744, #ff6b6b);
    color: white;
    border-radius: 50%;
    width: 40px;
    height: 40px;

    &:hover {
      transform: scale(1.05);
    }
  }
}
```

---

#### Avatar & Online Status

```scss
.chat-channel-dm-avatar {
  position: relative;
  width: 48px;
  height: 48px;

  img {
    border-radius: 50%;
  }

  .online-indicator {
    position: absolute;
    bottom: 0;
    right: 0;
    width: 12px;
    height: 12px;
    background: var(--ft-mint);  // Green
    border: 2px solid white;
    border-radius: 50%;
  }
}
```

---

#### Animations

```scss
// Message entry animation
.chat-message {
  animation: messageSlideIn 200ms ease-out;
}

@keyframes messageSlideIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

// Sent messages slide from right
.chat-message.is-mine {
  animation: messageSentSlideIn 200ms ease-out;
}

@keyframes messageSentSlideIn {
  from {
    opacity: 0;
    transform: translateX(10px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

// Tab transitions
.channels-tabs .tab {
  transition: all 150ms ease;
}

// Reaction interactions
.chat-message-reaction {
  transition: transform 100ms;

  &:hover {
    transform: scale(1.1);
  }

  &:active {
    transform: scale(0.95);
  }
}

// Accessibility
@media (prefers-reduced-motion: reduce) {
  .chat-message,
  .channels-tabs .tab,
  .chat-message-reaction {
    animation: none;
    transition: none;
  }
}
```

---

#### Message States

**Highlighted:**
```scss
.chat-message.is-highlighted {
  background: rgba(255, 23, 68, 0.08);
}
```

**Bookmarked:**
```scss
.chat-message.is-bookmarked {
  border-left: 3px solid var(--ft-amber);
  background: rgba(255, 179, 0, 0.05);
}
```

**Deleted:**
```scss
.chat-message.is-deleted {
  background: rgba(239, 68, 68, 0.1);
}
```

**Muted Channel:**
```scss
.chat-channel.is-muted {
  opacity: 0.5;
}
```

---

#### Date Separators

```scss
.chat-message-separator {
  text-align: center;
  margin: 16px 0;

  &__text {
    display: inline-block;
    padding: 4px 12px;
    background: var(--ft-neutral-100);
    color: var(--ft-neutral-600);
    border-radius: 9999px;
    font-size: 12px;
    font-weight: 500;
    text-transform: uppercase;
  }
}
```

---

#### Responsive Breakpoints

```scss
// Desktop (1024px+)
@media (min-width: 1024px) {
  .full-page-chat {
    display: flex;

    .channels-list {
      width: 30%;
      min-width: 280px;
      max-width: 360px;
    }

    .chat-messages-container {
      flex: 1;
    }
  }
}

// Tablet (768px - 1023px)
@media (min-width: 768px) and (max-width: 1023px) {
  .chat-message-content {
    max-width: 75%;
  }
}

// Mobile (< 768px)
@media (max-width: 767px) {
  .full-page-chat {
    flex-direction: column;
  }

  .channels-list {
    width: 100%;
  }

  .chat-message-content {
    max-width: 85%;
  }
}
```

---

#### Floating Action Menu

```scss
.chat-message-actions-menu {
  position: absolute;
  background: white;
  border-radius: 8px;
  box-shadow: var(--ft-shadow-lg);
  padding: 8px;

  .action-button {
    padding: 8px 12px;
    border-radius: 6px;
    transition: background 150ms;

    &:hover {
      background: var(--ft-neutral-100);
    }
  }
}
```

---

## Design Principles Achieved

### 1. Modern Messaging UX

- WhatsApp/iMessage-style bubbles with directional tails
- Clear visual distinction between sent/received
- Message grouping for consecutive messages

### 2. Brand Consistency

- Vibrant red (#ff1744) accent color throughout
- Consistent with main FanTribe theme
- Glassmorphism-inspired clean surfaces

### 3. Responsive Design

- Two-panel desktop → single panel mobile
- Adaptive message width constraints
- Touch-friendly tap targets

### 4. Accessibility

- Proper semantic HTML
- Keyboard navigation support
- `prefers-reduced-motion` respected
- Sufficient color contrast

### 5. Visual Hierarchy

- Color-coded sent/received messages
- Unread indicators on tabs
- Clear message grouping
- Date separators

### 6. Polish & Micro-interactions

- Smooth entrance animations
- Hover effects on buttons
- Scale transforms on reactions
- Subtle transitions (150ms)

### 7. Performance

- CSS transforms (GPU accelerated)
- `will-change` for animated elements
- Minimal JavaScript for styling

---

## Integration Points

### With fantribe-theme

The chat styling relies on design tokens from `fantribe-theme/design-tokens.scss`:

| Token | Usage in Chat |
|-------|---------------|
| `--ft-vibrant-red` | Sent message bubbles, active tabs |
| `--ft-neutral-*` | Received bubbles, backgrounds |
| `--ft-mint` | Online status indicator |
| `--ft-amber` | Bookmarked messages |
| `--ft-shadow-*` | Cards, menus, dropdowns |
| `--ft-space-*` | Consistent spacing |

### With Discourse Chat Plugin

| Discourse Class | FanTribe Override |
|-----------------|-------------------|
| `.chat-message` | Bubble styling |
| `.chat-channel` | Channel list styling |
| `.chat-composer` | Input/send button |
| `.channels-list` | Tab navigation |
| `.chat-message-separator` | Date pills |

---

## Testing Considerations

1. **Tab Switching** - Verify Channels/Messages tabs work
2. **Unread Badges** - Counts update correctly
3. **Message Rendering** - Bubbles display properly
4. **Responsive** - Desktop/tablet/mobile layouts
5. **Animations** - Smooth, no jank
6. **Accessibility** - Keyboard nav, screen readers
7. **Performance** - No lag with many messages
