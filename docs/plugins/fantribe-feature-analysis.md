# FanTribe Feature Analysis: Figma vs Discourse Native

## Overview
This document compares features present in the Figma designs (CretorTribe-V1) against Discourse native capabilities, mapped to the Phase 1 Project Charter modules.

### Key Decisions Made
- **Reactions**: Use Discourse native single-like for Phase 1 (not multi-reactions)
- **Post Menu Features**: ALL features are P0 (Save, Hide, Mute, Block, Follow, Pin to Profile, Turn Off Comments)
- **Gear Tags**: Deferred to Phase 2
- **Marketplace**: Removed from scope

---

## Category 1: Present in Figma AND Available in Discourse Native (Direct Match)

These features exist in both Figma and Discourse with minimal/no customization needed.

### Home Feed Module
| Feature | Figma Component | Discourse Native | Notes |
|---------|----------------|------------------|-------|
| Edit Post | PostMenu.tsx (own posts) | `post/menu/buttons/edit.gjs` | Direct match |
| Delete Post | PostMenu.tsx (own posts) | `post/menu/buttons/delete.gjs` | Direct match |
| Copy Link | PostMenu.tsx | `post/menu/buttons/copy-link.gjs` | Direct match |
| Report/Flag Post | PostMenu.tsx (other posts) | `post/menu/buttons/flag.gjs` | Direct match |
| Comment/Reply | PostCard.tsx | `post/menu/buttons/reply.gjs` | Direct match |
| Infinite Scroll | SocialFeed.tsx (Load More) | TopicList loadMore action | Direct match |
| Media Upload | CreatePostModal.tsx | Discourse composer upload system | Direct match |

### Explore Tribes Module
| Feature | Figma Component | Discourse Native | Notes |
|---------|----------------|------------------|-------|
| Category Grid | ExploreTribes.tsx | `site.categories` | Direct match - uses categories as tribes |
| Filter by Parent Category | ExploreTribes.tsx | Category parent filtering | Direct match |
| Responsive Grid | ExploreTribes.tsx | CSS Grid | Direct match |
| Empty State | ExploreTribes.tsx | Custom empty state | Direct match |
| Navigate to Category | TribeCard.tsx | `discovery.category` route | Direct match |

### Chat Module
| Feature | Figma Component | Discourse Native | Notes |
|---------|----------------|------------------|-------|
| Direct Messages | N/A (uses native) | Discourse Chat Plugin | Available |
| Group Chats | N/A (uses native) | Discourse Chat Plugin | Available |
| Channels | N/A (uses native) | Discourse Chat Plugin | Available |
| Emoji Reactions in Chat | N/A | `chat-message-reaction.gjs` | Available |

### User Profile Module
| Feature | Figma Component | Discourse Native | Notes |
|---------|----------------|------------------|-------|
| User Bio | UserProfilePage.tsx | User card/profile | Direct match |
| User Location | UserProfilePage.tsx | User custom fields | Direct match |
| Join Date | UserProfilePage.tsx | User profile | Direct match |
| Website Link | UserProfilePage.tsx | User profile | Direct match |
| User Posts Tab | UserProfilePage.tsx | User activity stream | Direct match |

### Admin Features
| Feature | Figma Component | Discourse Native | Notes |
|---------|----------------|------------------|-------|
| Moderation Actions | N/A | `admin-post-menu.gjs` | Full admin menu available |
| User Management | N/A | Admin panel | Direct match |
| Content Management | N/A | Topic admin menu | Direct match |

---

## Category 2: NOT Present in Figma but Available in Discourse Native

Features Discourse provides that aren't shown in Figma designs. Consider whether to:
- Enable and style to match FanTribe theme
- Hide/disable if not needed
- Defer to Phase 2+

### Post/Topic Features
| Discourse Feature | Component | Recommendation |
|------------------|-----------|----------------|
| Post Translations | `buttons/add-translation.gjs` | Disable for Phase 1 |
| Wiki Mode | `buttons/edit.gjs` | Keep hidden, useful for documentation |
| Post Notices | Admin menu | Enable for admin use |
| Slow Mode | Topic admin | Enable for admin use |
| Topic Timer/Scheduled Close | Topic admin | Enable for admin use |
| Permanently Delete | Admin menu | Enable for admin use |
| Change Post Owner | Admin menu | Enable for admin use |
| Rebake Post | Admin menu | Enable for admin use |
| Grant Badge | Admin menu | Consider enabling |
| Desktop Notifications | `desktop-notification-config.gjs` | Enable for engagement |
| Topic Notification Levels | `topic-notifications-button.gjs` | Enable (Watch/Track/Mute) |
| Category Notifications | `category-notifications-tracking.gjs` | Enable for Tribes |
| Archive Topic | Topic admin | Enable for admin |
| Convert to PM | Topic admin | Enable for admin |
| Multi-Select Posts | Topic admin | Enable for admin |
| Post Read Indicator | `buttons/read.gjs` | Consider enabling |
| Who Liked List | `liked-users-list.gjs` | Enable (engagement feature) |

### User Features
| Discourse Feature | Component | Recommendation |
|------------------|-----------|----------------|
| Ignore User | `ignored-user-list.gjs` | Enable |
| User Card Actions | `user-card-contents.gjs` | Enable/style |
| Invite to Topic | `invite-panel.gjs` | Enable |
| Bulk Invites | `create-invite-bulk.gjs` | Enable for admin |

---

## Category 3: Present in Figma AND Available in Discourse with Tweaks

Features that exist in both but need customization to match Figma design.

### Home Feed Module
| Feature | Figma Design | Discourse Native | Required Tweaks |
|---------|-------------|------------------|-----------------|
| **Save/Bookmark Post** | PostMenu.tsx: "Save Post" with Bookmark icon, shows in action bar | `bookmark-menu.gjs` with reminder system | Style bookmark button to match Figma; hide reminders UI initially; show filled icon when saved |
| **Like Reactions** | ReactionBar.tsx: Multiple emoji reactions (❤️🔥👏🎵💯🚀) | `buttons/like.gjs`: Single heart like | **DECISION**: Use native single-like for Phase 1; style to match Figma heart icon |
| **Share Modal** | ShareModal.tsx: Copy link + Twitter, Facebook, WhatsApp, Email | `share-panel.gjs`: Basic share | Add social sharing buttons; style modal to match Figma |
| **Post Card Layout** | PostCard.tsx: Avatar with verification ring, badge, gear tags | Standard post rendering | Custom CSS for avatar rings, badges; custom fields for gear tags |
| **Category Selector** | CreatePostModal.tsx: Dropdown in compose | CategoryChooser in composer | Style to match; label as "Tribe" |
| **Visibility Settings** | CreatePostModal.tsx: Public/Followers/Private | Topic visibility + trust levels | Map to Discourse permissions system |
| **Post Scheduling** | CreatePostModal.tsx: Schedule for later | Timed topic publishing (admin) | Enable scheduled publishing; build user-facing UI |

### Explore Tribes Module
| Feature | Figma Design | Current Implementation | Required Tweaks |
|---------|-------------|------------------------|-----------------|
| **Tribe Card Cover** | TribeCard.tsx: 16:9 cover image | `fantribe-tribe-card.gjs`: Cover with gradient fallback | Implemented ✅ |
| **Category Badge** | TribeCard.tsx: Category label top-left | `fantribe-tribe-card.gjs`: Parent badge | Implemented ✅ |
| **Tribe Icon** | TribeCard.tsx: Emoji icon in square | `fantribe-tribe-card.gjs`: Emoji/FA/logo support | Implemented ✅ |
| **Description Truncation** | TribeCard.tsx: 2-line clamp | `fantribe-tribe-card.gjs`: 100 char truncation | Implemented ✅ |
| **Activity Dots** | TribeCard.tsx: 3 colored circles + count | `fantribe-tribe-card.gjs`: Activity indicator | Implemented ✅ |
| **Join Button** | TribeCard.tsx: "Join Tribe" / "Request to Join" | `fantribe-tribe-card.gjs`: Join button | Navigates to category page (not actual join) |
| **Filter Dropdown** | ExploreTribes.tsx: Category filter | `fantribe-explore-page.gjs`: Filter dropdown | Implemented ✅ |
| **Results Count** | ExploreTribes.tsx: "Showing X tribes" | `fantribe-explore-page.gjs`: Results count | Implemented ✅ |

### User Profile Module
| Feature | Figma Design | Discourse Native | Required Tweaks |
|---------|-------------|------------------|-----------------|
| **Follow/Subscribe** | UserProfilePage.tsx: "Subscribe" button | User tracking/watching | Rename to "Subscribe"; style button |
| **Followers Count** | UserProfilePage.tsx: "1.2k Followers" | User stats | Create custom stat display |
| **Tribes Count** | UserProfilePage.tsx: "15 Tribes" | Category memberships | Create custom stat display |
| **Co-Creations Count** | UserProfilePage.tsx: "12 Co-Creations" | N/A | Custom field (Phase 2 feature) |
| **Verification Tiers** | UserProfilePage.tsx: Gold/Silver/Bronze/Blue rings | User badges | Map badges to verification tiers with CSS styling |
| **Cover Image** | UserProfilePage.tsx: Large header image | User profile background | Enable/style profile backgrounds |

### Chat Module
| Feature | Figma Design | Discourse Native | Required Tweaks |
|---------|-------------|------------------|-----------------|
| **Chat Layout** | Custom channel list styling | Chat plugin UI | CSS theming to match FanTribe |
| **Message Styling** | Custom message bubbles | Chat message component | CSS theming |
| **Emoji Picker** | Custom emoji picker styling | Chat emoji picker | CSS theming |

---

## Category 4: Present in Figma but NOT Available in Discourse Native

Features requiring custom development. Categorized by Phase 1 priority.

### P0 - Must Have for Phase 1 Launch

#### Home Feed
| Feature | Figma Component | Development Required | Effort |
|---------|----------------|---------------------|--------|
| **Trending Panel** | RightSidebar (implied) | Custom sidebar widget with trending posts/topics | Medium |
| **Sponsored Content Cards** | SocialFeed.tsx: Sponsored section | Custom ad/sponsored content system | Low-Medium |

> **Note**: Gear Tags on Posts deferred to Phase 2 per stakeholder decision.

#### Post Menu (3-dot menu)
| Feature | Figma Component | Development Required | Effort |
|---------|----------------|---------------------|--------|
| **Pin to Profile** | PostMenu.tsx (own posts) | Custom "pinned posts" on user profile | Medium |
| **Turn Off Comments** | PostMenu.tsx (own posts) | Topic closing by author permission | Low |
| **Follow User from Post** | PostMenu.tsx (other posts) | Quick follow action in menu | Low |
| **Not Interested / Hide Post** | PostMenu.tsx (other posts) | Custom post hiding per user | Medium |
| **Mute User from Post** | PostMenu.tsx (other posts) | Quick mute action in menu | Low |
| **Block User from Post** | PostMenu.tsx (other posts) | Quick block action in menu | Low |

#### Explore Tribes - Missing Features
| Feature | Figma Component | Development Required | Effort |
|---------|----------------|---------------------|--------|
| **Live Badge** | TribeCard.tsx: Red "LIVE" indicator with pulse | Add live stream detection + badge UI | Low |
| **Verified Checkmark** | TribeCard.tsx: Blue checkmark on tribe name | Map category custom field to verified badge | Low |
| **Privacy Indicator** | TribeCard.tsx: Public/Private icon + label | Add privacy display from category permissions | Low |
| **Member Count** | TribeCard.tsx: "12.5K" member count | Display category user count | Low |
| **Load More Button** | ExploreTribes.tsx: Pagination button | Add pagination to explore page | Low |
| **Search Tribes** | ExploreTribes.tsx (implied) | Add search input to filter tribes | Medium |

#### Tribe Detail Page (NEW - Not Yet Implemented)
| Feature | Figma Component | Development Required | Effort |
|---------|----------------|---------------------|--------|
| **Tribe Detail Route** | TribeDetailPage.tsx | Custom route `/explore/:tribeId` | Medium |
| **Cover Image Header** | TribeDetailPage.tsx | Large cover with gradient overlay | Low |
| **Back Navigation** | TribeDetailPage.tsx | Back button to explore page | Low |
| **Live Badge on Detail** | TribeDetailPage.tsx | "LIVE NOW" badge on cover | Low |
| **Sticky Tribe Header** | TribeDetailPage.tsx | Tribe info + join button sticky | Medium |
| **Tabs System** | TribeDetailPage.tsx: Feed/About/Members/Events | Tab navigation component | Medium |
| **Join/Joined Toggle** | TribeDetailPage.tsx | Category membership toggle | Medium |
| **Notification Bell** | TribeDetailPage.tsx | Category notification settings | Low |
| **Non-Member Notice** | TribeDetailPage.tsx | "Join to see all content" banner | Low |
| **Feed Tab** | TribeDetailPage.tsx | Posts from tribe/category | Uses existing feed |
| **About Tab - Description** | TribeDetailPage.tsx | Long description + meta info | Low |
| **About Tab - Rules** | TribeDetailPage.tsx | Numbered rules list | Medium (custom field) |
| **About Tab - Admins** | TribeDetailPage.tsx | Admin/moderator list + message button | Medium |
| **Members Tab** | TribeDetailPage.tsx | Member grid with search | Medium |
| **Members Tab - Tier Badges** | TribeDetailPage.tsx | Gold/Silver/Bronze indicators | Low (uses user badges) |
| **Members Tab - Admin Badge** | TribeDetailPage.tsx | "Admin" tag on moderators | Low |
| **Events Tab** | TribeDetailPage.tsx | Upcoming events list | High (requires events system) |

### Deferred - Phase 2+

| Feature | Figma Component | Development Required | Notes |
|---------|----------------|---------------------|-------|
| **Gear Tags on Posts** | PostCard.tsx: GearPill | Custom post metadata + UI | Deferred per stakeholder |
| **Multi-Emoji Reactions** | ReactionBar.tsx | Reactions plugin | Using single-like for Phase 1 |
| **Gear Collection Tab** | UserProfilePage.tsx | Custom user gear inventory | Deferred |
| **Co-Creations Tab** | UserProfilePage.tsx | Collaboration tracking | Deferred |
| **Shop Tab** | UserProfilePage.tsx | Creator store | Deferred |
| **Live Streaming** | LiveStreamPage.tsx | Video streaming integration | Deferred |
| **Co-Create Collaboration** | CoCreatePage.tsx | Collaboration workflow | Deferred |
| **Revenue Dashboard** | RevenuePage.tsx | Analytics + payments | Deferred |
| **Rewards System** | RewardsPage.tsx | Points/rewards engine | Deferred |
| **Content Studio** | ContentStudioPage.tsx | Content management | Deferred |
| **Fan CRM** | FanCRMPage.tsx | CRM system | Deferred |
| **Partnerships** | PartnershipsPage.tsx | Partnership management | Deferred |
| **Events System** | TribeDetailPage.tsx: Events tab | Full events/calendar system | Deferred |
| **Audio Waveform Display** | PostCard.tsx | Audio visualization | Consider for Phase 1 polish |
| **Video Player Controls** | PostCard.tsx | Custom video player | Consider for Phase 1 polish |

---

## Summary: Tasks for Phase 1 by Module

### Module 1: Home Feed Completion
**Already Done (75%):**
- Feed layout, cards, compose box with category selector
- Media upload buttons, trending panel

**Remaining Tasks (P0):**
1. Style Save/Bookmark button to match Figma (show filled icon when saved)
2. Style native Like button to match Figma heart design
3. Add social sharing to Share modal (Twitter, Facebook, WhatsApp, Email)
4. **Post Menu - Own Posts:**
   - Implement "Pin to Profile"
   - Implement "Turn Off Comments"
5. **Post Menu - Other Posts:**
   - Implement "Follow User" quick action
   - Implement "Hide Post / Not Interested" feature
   - Implement "Mute User" quick action
   - Implement "Block User" quick action
6. Mobile polish for all feed components

**Deferred to Phase 2:**
- Gear Tags UI on posts
- Multi-emoji reactions

### Module 1.2: Chat Enablement
**Remaining Tasks:**
1. Enable Discourse Chat plugin
2. Style chat UI to match FanTribe theme (channel list, messages, emoji picker)
3. Verify DM, group chat, channel functionality
4. Configure chat permissions per category/tribe
5. Mobile chat experience polish

### Module 2: Explore Tribes Completion
**Already Done:**
- Explore page route (`/explore`)
- Category grid with responsive layout
- Tribe card with cover, icon, description, activity indicator
- Filter dropdown by parent category
- Results count display
- Navigation to category page

**Remaining Tasks (P0):**
1. **Tribe Card Enhancements:**
   - Add Live badge indicator (red pulse)
   - Add Verified checkmark on tribe name
   - Add Privacy indicator (Public/Private icon + label)
   - Add Member count display
2. **Explore Page Enhancements:**
   - Add Load More pagination button
   - Add Search input to filter tribes
3. **Tribe Detail Page (NEW):**
   - Create route `/explore/:tribeId`
   - Cover image header with back button
   - Sticky tribe header with join toggle
   - Tabs: Feed, About, Members, Events
   - Non-member notice banner
   - About tab: Description, rules, admins
   - Members tab: Member grid with search + tier badges
   - Events tab: Placeholder/empty state

**Deferred to Phase 2:**
- Events system (full calendar/event management)

### Module 3: User Profile Enhancements
**Styling/Tweaks:**
1. Verification tier styling (Gold/Silver/Bronze/Blue rings)
2. Subscribe button styling
3. Custom stats display (Followers, Tribes)
4. Cover image support

**Deferred:**
- Gear Collection tab
- Co-Creations tab
- Shop tab

---

## Explore Tribes: Implementation Status

### Current Implementation (explore-tribe plugin)
```
plugins/explore-tribe/
├── plugin.rb
├── config/settings.yml
└── assets/
    ├── javascripts/discourse/
    │   ├── explore-tribes-route-map.js
    │   ├── routes/explore.js
    │   ├── templates/explore.gjs
    │   └── components/
    │       ├── fantribe-explore-page.gjs   ✅
    │       └── fantribe-tribe-card.gjs     ✅
    └── stylesheets/common/
        ├── explore-page.scss               ✅
        ├── tribe-grid.scss                 ✅
        ├── tribe-card.scss                 ✅
        └── filter-dropdown.scss            ✅
```

### Missing Components (to be created)
```
└── assets/
    └── javascripts/discourse/
        ├── routes/tribe-detail.js          ❌ NEW
        ├── templates/tribe-detail.gjs      ❌ NEW
        └── components/
            ├── fantribe-tribe-detail.gjs   ❌ NEW
            ├── fantribe-tribe-tabs.gjs     ❌ NEW
            ├── fantribe-tribe-about.gjs    ❌ NEW
            ├── fantribe-tribe-members.gjs  ❌ NEW
            └── fantribe-tribe-events.gjs   ❌ NEW
```

---

## Recommended Discourse Plugins to Evaluate

1. **Follow Plugin** - User following functionality
2. **Bookmark with reminders** - Already native, just needs styling
3. **Social Share** - May have existing plugin for Twitter/FB sharing

---

## Next Steps

1. ~~Confirm feature scope with stakeholder~~ **DONE** - Single-like, all post menu P0, gear tags deferred, marketplace removed
2. Begin Post Menu implementation (Save, Hide, Block, Mute, Follow, Pin, Turn Off Comments)
3. **Explore Tribes completion:**
   - Add missing tribe card features (Live, Verified, Privacy, Member count)
   - Add pagination and search
   - Build Tribe Detail page with tabs
4. Create CSS theming tasks for native features (Like button, Bookmark, Share modal)
5. Chat theming and configuration
6. Set up feature flags for gradual rollout

---

## Output Location

This feature analysis document is saved at:
**`/Users/piyushjain/Documents/fantribe/discourse/docs/plugins/fantribe-feature-analysis.md`**

This provides a reference for the development team to track what features are:
- Direct Discourse native (just enable/style)
- Need tweaks (customize existing)
- Need custom development (build from scratch)
- Deferred (Phase 2+)
