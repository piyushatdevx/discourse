# Phase 3: Terminology Transformation

> **Quick Reference:** See [Implementation Guidelines](../FANTRIBE-IMPLEMENTATION-PLAN.md#implementation-guidelines) for design rules.

## Overview
Rename all Discourse terminology to match social media / music community context. Transform "Categories" to "Tribes", "Topics" to "Posts", "Replies" to "Comments", etc.

## Prerequisites
- [ ] Phase 2 completed and approved
- [ ] UI transformation in place

---

## Tasks

### 3.1 Create Custom Translations (Categories → Tribes)
**Goal:** Rename all Discourse terminology to match social media / music community context

**File:** `plugins/fantribe-theme/config/locales/client.en.yml`

```yaml
en:
  js:
    # Categories → Tribes
    category:
      name: "Tribe"
    categories:
      title: "Tribes"
      all: "All Tribes"
      latest: "Latest"
      top: "Top"
      new: "New"
      create: "Create Tribe"
      reorder:
        title: "Reorder Tribes"

    # Topics → Posts
    topic:
      create: "Create Post"
      title: "Post"
    topics:
      none:
        latest: "No posts yet."
        new: "You have no new posts."

    # Replies → Comments
    post:
      reply: "Comment"
      replies: "Comments"
      create: "Write a comment"

    # Users → Members
    user:
      title: "Member"
      profile: "Profile"

    # Navigation
    navigation:
      category: "Tribes"
      latest: "Feed"
      top: "Trending"
      new: "New"

    # Actions
    actions:
      like: "Like"
      share: "Share"
      bookmark: "Save"
      flag: "Report"

    # Notifications (social terminology)
    notifications:
      liked: "<span>{{username}}</span> liked your post"
      liked_2: "<span>{{username}}</span> and <span>{{username2}}</span> liked your post"
      replied: "<span>{{username}}</span> commented on your post"
      mentioned: "<span>{{username}}</span> mentioned you"
      posted: "<span>{{username}}</span> posted in {{topic}}"

    # Composer (post creation)
    composer:
      title_placeholder: "What's on your mind?"
      reply_placeholder: "Write a comment..."
      create_pm: "Send Message"

    # User menu
    user_menu:
      profile: "Profile"
      messages: "Messages"
      bookmarks: "Saved"
      preferences: "Settings"

    # Category/Tribe specific
    tribe:
      join: "Join Tribe"
      leave: "Leave Tribe"
      members: "Members"
      posts: "Posts"
      about: "About"
```

**File:** `plugins/fantribe-theme/config/locales/server.en.yml`

```yaml
en:
  site_settings:
    fantribe_theme_enabled: "Enable FanTribe social theme"

  # Admin terminology
  category:
    name: "Tribe"
  categories:
    title: "Tribes"

  topic:
    title: "Post"
  topics:
    title: "Posts"
```

---

### 3.2 JavaScript Terminology Overrides
**Goal:** Override remaining hardcoded strings in JavaScript

**File:** `plugins/fantribe-theme/assets/javascripts/discourse/initializers/fantribe-terminology.js`

```javascript
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "fantribe-terminology",
  initialize() {
    withPluginApi("1.14.0", (api) => {
      // Override text in various components
      api.modifyClass("component:topic-list", {
        pluginId: "fantribe-theme",

        didInsertElement() {
          this._super(...arguments);
          // Custom modifications
        }
      });

      // Change "Category" to "Tribe" in dropdowns
      api.modifySelectKit("category-drop").modifyContent((content) => {
        return content.map(item => {
          if (item.name.includes("Category")) {
            item.name = item.name.replace("Category", "Tribe");
          }
          return item;
        });
      });

      // Override notification text templates
      api.addNotificationTypes((types) => {
        // Customize notification templates
      });
    });
  }
};
```

---

## Terminology Mapping Reference

| Original (Discourse) | New (FanTribe) |
|---------------------|----------------|
| Category | Tribe |
| Categories | Tribes |
| Topic | Post |
| Topics | Posts |
| Reply | Comment |
| Replies | Comments |
| User | Member |
| Users | Members |
| Forum | Community |
| Bookmark | Save |
| Latest | Feed |
| Top | Trending |

---

## Completion Checklist
- [ ] `client.en.yml` created with all translations
- [ ] `server.en.yml` created for admin/server strings
- [ ] JavaScript overrides for dynamic content
- [ ] All "Category" references show as "Tribe"
- [ ] All "Topic" references show as "Post"
- [ ] All "Reply" references show as "Comment"
- [ ] Navigation shows "Feed", "Tribes", "Trending"
- [ ] Code linted (`bin/lint --fix`)
- [ ] No console errors
- [ ] Tested on desktop and mobile
- [ ] Review requested from user

## Files Created/Modified This Phase
<!-- Fill this section as you implement -->
| File | Action | Purpose |
|------|--------|---------|
| - | - | - |

## Review Notes
<!-- User feedback and approval notes go here -->
