# Fan Tribe BRD: Discourse Gap Analysis & Timeline

> **Document Type**: Technical Gap Analysis
> **Last Updated**: January 2026
> **Based On**: Fan Tribe Business Requirements Document

## Executive Summary

Based on analysis of the Discourse codebase against the Fan Tribe BRD, approximately **60% of features exist** in Discourse. The major gaps are:
- **Follow/Follower System** - Does not exist
- **Personalized Feed** - Partial (topic lists exist, not user-based feeds)
- **Events/Calendar** - Does not exist
- **Social Media UI** - Discourse is forum-centric, needs theme overhaul

---

## Module-by-Module Analysis

### 3.1 Landing Page & Onboarding

| Feature | Exists in Discourse | Gap | Timeline |
|---------|:------------------:|-----|----------|
| **FR-LND-01**: Public Landing Page | ⚠️ Partial | Discourse has basic landing, needs custom social-style design | 1.5 week |
| **FR-LND-02**: Email Registration | ✅ Yes | Configure validation rules, customize emails | 2 days |
| **FR-LND-03**: Social OAuth | ✅ Yes | Configure Google, Facebook API keys | 1 day |
| **FR-LND-04**: Login | ✅ Yes | Configure rate limiting, session settings | 1 day |
| **FR-LND-05**: Password Reset | ✅ Yes | Customize email templates | 0.5 days |
| **FR-LND-06**: Multi-language Support | ✅ Yes | Add custom translations for Fan Tribe terms | 2 days |

**Module Total**: ~2.5 weeks (including configuration and customization)

---

### 3.2 User Profiles

| Feature | Exists in Discourse | Gap | Timeline |
|---------|:------------------:|-----|----------|
| **FR-PRF-01**: Profile Creation | ✅ Yes | Configure custom user fields, avatar sizes | 2 days |
| **FR-PRF-02**: Profile Display | ⚠️ Partial | Add follower counts, social layout theme | 3 days |
| **FR-PRF-03**: Profile Editing | ✅ Yes | Configure allowed fields, image limits | 1 day |
| **FR-PRF-04**: Privacy Settings | ⚠️ Partial | Add granular visibility controls | 1 week |
| **FR-PRF-05**: Profile Statistics | ⚠️ Partial | Add follower stats display | 2 days |
| **FR-PRF-06**: Follower Management | ❌ No | **Build follower system from scratch** | 2 weeks |
| **FR-PRF-07**: Username Rules | ✅ Yes | Configure validation rules | 0.5 days |

**Module Total**: ~3.5 weeks (follower system + configuration)

---

### 3.3 Feed & Content

| Feature | Exists in Discourse | Gap | Timeline |
|---------|:------------------:|-----|----------|
| **FR-FED-01**: Post Creation | ⚠️ Partial | Customize composer for social-style posts | 2 weeks |
| **FR-FED-02**: Feed Algorithm | ❌ No | **Build personalized feed from scratch** | 3 weeks |
| **FR-FED-03**: Post Display | ⚠️ Partial | Build card-based social UI theme | 2 weeks |
| **FR-FED-04**: Likes | ✅ Yes | Configure like button style, animations | 2 days |
| **FR-FED-05**: Comments | ✅ Yes | Configure threading depth, styling | 2 days |
| **FR-FED-06**: Post Editing | ✅ Yes | Configure edit window, revision display | 1 day |
| **FR-FED-07**: Post Deletion | ✅ Yes | Configure soft delete retention period | 0.5 days |
| **FR-FED-08**: Post Sharing | ⚠️ Partial | Build repost feature | 1 week |
| **FR-FED-09**: Hashtags & Mentions | ✅ Yes | Configure tag styles, autocomplete | 1 day |
| **Image Posts** | ✅ Yes | Configure upload limits, gallery display | 2 days |
| **Audio Posts** | ✅ Yes | Configure audio player, file limits | 1 day |

**Module Total**: ~9 weeks (feed algorithm + UI customization)

---

### 3.4 Connections (Followers)

| Feature | Exists in Discourse | Gap | Timeline |
|---------|:------------------:|-----|----------|
| **FR-CON-01**: Follow Mechanism | ❌ No | **Build follow model, API, UI** | 2 weeks |
| **FR-CON-02**: Unfollow Mechanism | ❌ No | Part of follow system | included |
| **FR-CON-03**: Follower Lists | ❌ No | Build follower/following list UI | 1 week |
| **FR-CON-04**: Follow Requests | ❌ No | Build request system for private profiles | 1 week |
| **FR-CON-05**: Notifications | ⚠️ Partial | Add follow notification types | 3 days |
| **FR-CON-06**: Mutual Connections | ❌ No | Build query logic, display component | 3 days |
| **FR-CON-07**: Suggested Users | ❌ No | Build recommendation algorithm | 2 weeks |
| **FR-CON-08**: Following Feed Filter | ❌ No | Build filtered feed view | 1 week |

**Module Total**: ~7.5 weeks

---

### 3.5 Tribes (Groups)

| Feature | Exists in Discourse | Gap | Timeline |
|---------|:------------------:|-----|----------|
| **FR-TRB-01**: Tribe Creation | ✅ Yes | Rename "Category" to "Tribe", customize form | 2 days |
| **FR-TRB-02**: Tribe Display Page | ✅ Yes | Theme category page for social look | 3 days |
| **FR-TRB-03**: Joining Tribes | ✅ Yes | Configure join settings, approval flow | 1 day |
| **FR-TRB-04**: Leaving Tribes | ✅ Yes | Configure leave behavior | 0.5 days |
| **FR-TRB-05**: Tribe Posting | ✅ Yes | Configure composer defaults per tribe | 1 day |
| **FR-TRB-06**: Tribe Feed | ✅ Yes | Theme topic list as social feed | 2 days |
| **FR-TRB-07**: Roles & Permissions | ✅ Yes | Configure role permissions | 1 day |
| **FR-TRB-08**: Tribe Administration | ✅ Yes | Customize admin panel labels | 1 day |
| **FR-TRB-09**: Tribe Discovery | ⚠️ Partial | Build browse/search UI | 1 week |
| **FR-TRB-10**: Tribe Notifications | ✅ Yes | Configure notification preferences | 1 day |
| **FR-TRB-11**: Tribe Analytics | ⚠️ Partial | Build analytics dashboard | 1 week |

**Module Total**: ~3 weeks (configuration + UI enhancements)

---

### 3.6 Events & Live Streams

| Feature | Exists in Discourse | Gap | Timeline |
|---------|:------------------:|-----|----------|
| **FR-EVT-01**: Event Creation | ❌ No | **Build event model, form, API** | 2 weeks |
| **FR-EVT-02**: Event Display Page | ❌ No | Build event detail page UI | 1 week |
| **FR-EVT-03**: Following Events | ❌ No | Build RSVP/interested system | 1 week |
| **FR-EVT-04**: Event Discovery | ❌ No | Build browse/search/filter UI | 1 week |
| **FR-EVT-05**: Event Editing | ❌ No | Build edit form, update notifications | included |
| **FR-EVT-06**: Live Stream Integration | ❌ No | Build YouTube/Twitch embed player | 1 week |
| **FR-EVT-07**: Event Notifications | ⚠️ Partial | Add event reminder notification types | 3 days |
| **FR-EVT-08**: Event Calendar | ❌ No | Build calendar view + iCal export | 2 weeks |
| **FR-EVT-09**: Event Analytics | ❌ No | Build event stats dashboard | 1 week |

**Module Total**: ~10 weeks (entirely new system)

---

### 3.7 Chat / Messaging

| Feature | Exists in Discourse | Gap | Timeline |
|---------|:------------------:|-----|----------|
| **FR-CHT-01**: Messaging Access Control | ✅ Yes | Configure who can DM settings | 1 day |
| **FR-CHT-02**: Conversation List | ✅ Yes | Theme conversation list UI | 1 day |
| **FR-CHT-03**: Conversation Thread | ✅ Yes | Theme chat thread UI | 1 day |
| **FR-CHT-04**: Sending Messages | ✅ Yes | Configure message limits | 0.5 days |
| **FR-CHT-05**: Message Actions | ✅ Yes | Configure edit/delete windows | 0.5 days |
| **FR-CHT-06**: Typing Indicators | ✅ Yes | Enable and configure | 0.5 days |
| **FR-CHT-07**: File Sharing | ✅ Yes | Configure file size/type limits | 0.5 days |
| **FR-CHT-08**: Notifications | ✅ Yes | Configure notification preferences | 0.5 days |
| **FR-CHT-09**: Online Status | ✅ Yes | Configure presence settings | 0.5 days |
| **FR-CHT-10**: Blocking in Messages | ✅ Yes | Configure block behavior | 0.5 days |

**Module Total**: ~1 week (configuration and theming only)

---

### 3.8 Notifications

| Feature | Exists in Discourse | Gap | Timeline |
|---------|:------------------:|-----|----------|
| **FR-NOT-01**: Notification Types | ✅ Yes | Add custom types for follows/events | 2 days |
| **FR-NOT-02**: Notification Center | ✅ Yes | Theme notification dropdown | 1 day |
| **FR-NOT-03**: Unread Badge | ✅ Yes | Style badge, configure max count | 0.5 days |
| **FR-NOT-04**: In-App Notifications | ✅ Yes | Configure toast behavior | 0.5 days |
| **FR-NOT-05**: Push Notifications | ✅ Yes | Configure push service, icons | 1 day |
| **FR-NOT-06**: Notification Preferences | ✅ Yes | Add preferences for new types | 1 day |
| **FR-NOT-07**: Notification Retention | ✅ Yes | Configure retention period | 0.5 days |

**Module Total**: ~1 week (configuration + new notification types)

---

### 4. Admin & Moderation

| Feature | Exists in Discourse | Gap | Timeline |
|---------|:------------------:|-----|----------|
| **FR-ADM-01**: Admin Access | ✅ Yes | Configure admin roles, 2FA requirements | 1 day |
| **FR-ADM-02**: Dashboard Overview | ✅ Yes | Customize dashboard widgets | 2 days |
| **FR-ADM-03**: Content Reporting | ✅ Yes | Configure flag reasons, add custom reasons | 1 day |
| **FR-ADM-04**: Report Review Queue | ✅ Yes | Configure review workflow | 1 day |
| **FR-ADM-05**: User Management | ✅ Yes | Configure suspension rules, user fields | 1 day |
| **FR-ADM-06**: Announcements | ✅ Yes | Configure banner styles | 0.5 days |
| **FR-ADM-07**: Audit Logs | ✅ Yes | Configure retention, export options | 0.5 days |
| **FR-ADM-08**: Analytics | ⚠️ Partial | Build enhanced analytics dashboard | 1 week |

**Module Total**: ~2 weeks (configuration + analytics enhancement)

---

## Summary: What Needs Building

### Features That DON'T Exist in Discourse

| Feature | Complexity | Timeline | Priority |
|---------|------------|----------|----------|
| **Follow/Follower System** | High | 3-4 weeks | P0 - Critical |
| **Personalized Feed Algorithm** | High | 3 weeks | P0 - Critical |
| **Events/Calendar System** | High | 8-10 weeks | P1 - High |
| **Social Media UI/Theme** | Medium | 4-6 weeks | P0 - Critical |
| **User Recommendations** | Medium | 2 weeks | P2 - Medium |
| **Repost/Share to Feed** | Low | 1 week | P2 - Medium |

### Features That Partially Exist

| Feature | Gap | Timeline |
|---------|-----|----------|
| Profile Display | Add follower counts, social layout | 1 week |
| Privacy Settings | Granular visibility controls | 1 week |
| Post Creation | Social-style composer UI | 2 weeks |
| Tribe Discovery | Better browse/search UI | 1 week |

### Features That Fully Exist (No Work Needed)

- Authentication (email, OAuth, 2FA, passkeys)
- Password reset flow
- Multi-language support
- User profiles (core fields)
- Media uploads (images, audio, video)
- Likes and reactions
- Comments/threading
- Tribes/Groups (Categories + Groups)
- Chat/Messaging (full plugin)
- Notifications (27+ types)
- Admin dashboard
- Content moderation
- Audit logging

---

## Timeline Estimate by Module

| Module | Build New | Configure Existing | Total | Notes |
|--------|-----------|-------------------|-------|-------|
| 3.1 Landing & Onboarding | 1 week | 1 week | **2 weeks** | Landing page + auth config |
| 3.2 User Profiles | 2 weeks | 1.5 weeks | **3.5 weeks** | Follower system + profile config |
| 3.3 Feed & Content | 6 weeks | 3 weeks | **9 weeks** | Feed algorithm + content config |
| 3.4 Connections (Followers) | 7 weeks | 0.5 weeks | **7.5 weeks** | Core new feature |
| 3.5 Tribes (Groups) | 2 weeks | 1 week | **3 weeks** | Discovery UI + tribe config |
| 3.6 Events & Live Streams | 10 weeks | 0 weeks | **10 weeks** | Entirely new system |
| 3.7 Chat / Messaging | 0 weeks | 1 week | **1 week** | Configuration only |
| 3.8 Notifications | 0.5 weeks | 0.5 weeks | **1 week** | New types + config |
| 4. Admin & Moderation | 1 week | 1 week | **2 weeks** | Analytics + config |
| **Theme/UI Overhaul** | 4 weeks | 2 weeks | **6 weeks** | Social media look & feel |

---

## Recommended Implementation Phases

### Phase 1: Social Foundation (10-12 weeks)
1. Follow/Follower system plugin
2. Personalized feed based on follows
3. Social media theme (card-based posts, profile layout)
4. Profile enhancements (follower counts, privacy)

### Phase 2: Events & Discovery (10-12 weeks)
1. Events/Calendar plugin
2. Event notifications and reminders
3. User recommendations algorithm
4. Tribe discovery improvements

### Phase 3: Polish & Advanced Features (4-6 weeks)
1. Repost/share functionality
2. Live stream integration
3. Advanced analytics
4. Mobile optimization

---

## Total Estimated Timeline

| Category | Effort |
|----------|--------|
| Build New Features | ~33.5 weeks |
| Configure Existing Features | ~11.5 weeks |
| **Gross Total** | **~45 weeks** |
| **With Parallel Work (-30%)** | **~32 weeks** |

| Phase | Duration | Details |
|-------|----------|---------|
| Phase 1: Social Foundation | 12-14 weeks | Follow system, feed, theme, profiles |
| Phase 2: Events & Discovery | 12-14 weeks | Events, calendar, recommendations |
| Phase 3: Polish & Config | 6-8 weeks | Admin, notifications, testing |
| **Total MVP** | **30-36 weeks** | (~7-9 months) |

---

## Key Plugins to Build

1. **fantribe-social** - Follow system, feed algorithm, user recommendations
2. **fantribe-events** - Event creation, calendar, RSVP, reminders
3. **fantribe-theme** - Social media UI overhaul

---

## Technical Reference

### Existing Discourse Files (Leverage As-Is)

| File | Purpose |
|------|---------|
| `app/models/user.rb` | Core user model with profile fields |
| `app/models/user_profile.rb` | Extended profile (bio, location, etc.) |
| `app/models/notification.rb` | 27+ notification types |
| `plugins/chat/` | Full chat implementation (683 files) |
| `app/models/upload.rb` | Media handling with optimization |
| `app/models/category.rb` | Tribes base (rename categories) |
| `app/models/group.rb` | Group membership and permissions |
| `app/models/post.rb` | Post creation, editing, likes |
| `app/models/topic.rb` | Topic/thread management |
| `lib/auth/` | OAuth authenticators |

### New Plugin Structure

```
plugins/fantribe-social/
├── plugin.rb                    # Plugin entry point
├── config/
│   ├── routes.rb               # API routes
│   └── settings.yml            # Plugin settings
├── app/
│   ├── models/
│   │   ├── user_follow.rb      # Follow relationships
│   │   ├── follow_request.rb   # Pending requests (private profiles)
│   │   └── user_recommendation.rb
│   ├── controllers/fantribe/
│   │   ├── follows_controller.rb
│   │   ├── feed_controller.rb
│   │   └── recommendations_controller.rb
│   ├── serializers/
│   │   ├── user_follow_serializer.rb
│   │   └── feed_item_serializer.rb
│   └── services/
│       ├── feed_builder.rb     # Personalized feed algorithm
│       └── recommendation_engine.rb
├── db/migrate/
│   ├── 001_create_user_follows.rb
│   └── 002_create_follow_requests.rb
├── lib/
│   └── fantribe_social/
│       └── engine.rb
└── spec/
    ├── models/
    └── services/

plugins/fantribe-events/
├── plugin.rb
├── config/
│   ├── routes.rb
│   └── settings.yml
├── app/
│   ├── models/
│   │   ├── event.rb
│   │   ├── event_rsvp.rb
│   │   └── event_reminder.rb
│   ├── controllers/fantribe/
│   │   └── events_controller.rb
│   ├── serializers/
│   │   └── event_serializer.rb
│   └── jobs/
│       └── send_event_reminder.rb
├── db/migrate/
│   ├── 001_create_events.rb
│   ├── 002_create_event_rsvps.rb
│   └── 003_create_event_reminders.rb
└── spec/

plugins/fantribe-theme/
├── about.json
├── common/
│   ├── common.scss             # Shared styles
│   ├── feed.scss               # Card-based feed
│   ├── profile.scss            # Social profile layout
│   └── components/
├── desktop/
│   └── desktop.scss
├── mobile/
│   └── mobile.scss
└── javascripts/
    └── discourse/
        ├── components/
        │   ├── follow-button.gjs
        │   ├── feed-card.gjs
        │   └── event-card.gjs
        └── initializers/
```

---

## Database Schema (New Tables)

```sql
-- User Follows
CREATE TABLE user_follows (
  id SERIAL PRIMARY KEY,
  follower_id INTEGER NOT NULL REFERENCES users(id),
  followed_id INTEGER NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL,
  UNIQUE(follower_id, followed_id)
);

CREATE INDEX idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX idx_user_follows_followed ON user_follows(followed_id);

-- Follow Requests (for private profiles)
CREATE TABLE follow_requests (
  id SERIAL PRIMARY KEY,
  requester_id INTEGER NOT NULL REFERENCES users(id),
  target_id INTEGER NOT NULL REFERENCES users(id),
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL,
  responded_at TIMESTAMP,
  UNIQUE(requester_id, target_id)
);

-- Events
CREATE TABLE events (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  category_id INTEGER REFERENCES categories(id),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  event_type VARCHAR(50) NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  timezone VARCHAR(50),
  location VARCHAR(255),
  external_url TEXT,
  cover_image_upload_id INTEGER REFERENCES uploads(id),
  privacy VARCHAR(20) DEFAULT 'public',
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Event RSVPs
CREATE TABLE event_rsvps (
  id SERIAL PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  status VARCHAR(20) DEFAULT 'interested',
  created_at TIMESTAMP NOT NULL,
  UNIQUE(event_id, user_id)
);

-- Event Reminders
CREATE TABLE event_reminders (
  id SERIAL PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  remind_at TIMESTAMP NOT NULL,
  sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL
);
```

---

## API Endpoints (New)

### Follow System
```
POST   /fantribe/follows/:user_id       # Follow user
DELETE /fantribe/follows/:user_id       # Unfollow user
GET    /fantribe/followers/:user_id     # Get user's followers
GET    /fantribe/following/:user_id     # Get who user follows
GET    /fantribe/follows/suggestions    # Get suggested users
POST   /fantribe/follow-requests/:id/accept
POST   /fantribe/follow-requests/:id/reject
```

### Feed
```
GET    /fantribe/feed                   # Personalized feed
GET    /fantribe/feed/following         # Posts from followed users only
```

### Events
```
GET    /fantribe/events                 # List events
POST   /fantribe/events                 # Create event
GET    /fantribe/events/:id             # Get event
PUT    /fantribe/events/:id             # Update event
DELETE /fantribe/events/:id             # Delete event
POST   /fantribe/events/:id/rsvp        # RSVP to event
DELETE /fantribe/events/:id/rsvp        # Remove RSVP
GET    /fantribe/events/calendar        # Calendar view data
```
