# Product Requirements Document (PRD)

## 1. Document Control

| Field | Value |
|-------|-------|
| **Product Name** | Fantribe - Music Community Social Platform |
| **PRD Type** | Feature Specification / To-Be Documentation |
| **Platform Base** | Discourse (Ruby on Rails + Ember.js) |
| **Version** | 1.1 |
| **Last Updated** | January 2026 |

---

## 2. Purpose of Document

This PRD documents the requirements for Fantribe, a social networking platform for music enthusiasts built on top of Discourse. The document maps Fantribe features to Discourse's existing architecture and identifies components requiring custom development via plugins.

**Scope:**
- Social networking features for music communities ("Tribes")
- Content sharing (posts, images, videos, music, gear)
- User engagement and discovery systems
- Mobile-responsive interface

---

## 3. Product Overview

Fantribe is a community-driven social platform that enables music enthusiasts to:
- Join and participate in music-focused communities (Tribes)
- Share content including photos, videos, music playlists, and gear showcases
- Connect with like-minded musicians and fans
- Discover trending topics and recommended connections
- Showcase and discuss music gear with integrated product information

### 3.1 Technology Stack (Inherited from Discourse)

| Layer | Technology |
|-------|------------|
| Backend | Ruby on Rails (REST API) |
| Frontend | Ember.js (Glimmer components) |
| Database | PostgreSQL |
| Cache | Redis |
| Real-time | WebSocket (MessageBus) |

---

## 4. User Roles & Personas

### 4.1 Community Member
- Browse and join Tribes based on interests
- Create posts with various content types
- Interact with content (like, comment, share, bookmark)
- Build profile with mood/status and activity stats
- Connect with other members

### 4.2 Tribe Moderator
- Manage Tribe content and discussions
- Moderate posts and comments
- Pin/feature important content
- Manage Tribe settings and membership

### 4.3 Administrator
- Create and configure Tribes
- Manage site-wide settings
- Configure gear/product integrations
- Monitor platform analytics
- Manage user accounts and permissions

---

## 5. Feature Specifications

### 5.1 Core Modules

#### 5.1.1 Header/Navigation Module

| Feature | Discourse Mapping | Implementation |
|---------|------------------|----------------|
| Logo and branding | Site settings + theme | Configuration |
| Main navigation (Feed, Explore) | Navigation menu | Theme customization |
| Search functionality | `SearchController` | Existing |
| Notifications | `NotificationsController` | Existing + customization |
| Messaging | Chat plugin | Plugin integration |
| User profile access | User menu | Existing |

**Files:** `app/controllers/search_controller.rb`, `app/controllers/notifications_controller.rb`

#### 5.1.2 Mobile Bottom Navigation

| Feature | Discourse Mapping | Implementation |
|---------|------------------|----------------|
| Mobile navigation bar | Theme component | Custom theme |
| Core navigation items | Mobile view | Theme customization |

**Implementation:** Create custom theme component using Discourse's theme system at `app/assets/stylesheets/mobile/`

#### 5.1.3 Sidebar - Left (Tribe Filters)

| Feature | Discourse Mapping | Implementation |
|---------|------------------|----------------|
| Tribe selection | Category sidebar | Existing + customization |
| Active tribe management | `CategoryUser` model | Existing |
| Online member count | Presence system | Plugin enhancement |

**Files:** `app/models/category.rb`, `app/models/category_user.rb`

#### 5.1.4 Sidebar - Right (Widgets)

| Feature | Discourse Mapping | Implementation |
|---------|------------------|----------------|
| Trending topics | Hot topics query | Existing algorithm |
| Suggested connections | **New feature** | Custom plugin |
| Gear recommendations | **New feature** | Custom plugin |

**New Development Required:** `fantribe-widgets` plugin

#### 5.1.5 Main Feed Module

| Feature | Discourse Mapping | Implementation |
|---------|------------------|----------------|
| Post creation interface | Composer | Customization |
| Social feed display | Topic list | Custom scoping |
| Post interactions | `PostAction` model | Existing + reactions plugin |

**Files:** `app/models/topic.rb`, `app/models/post.rb`, `app/models/post_action.rb`

#### 5.1.6 User Profile Widget

| Feature | Discourse Mapping | Implementation |
|---------|------------------|----------------|
| Profile summary | `UserProfile` model | Existing |
| Mood/status updates | User custom fields | Configuration |
| Activity statistics | `UserStat` model | Existing |
| Profile editing | User preferences | Existing |

**Files:** `app/models/user.rb`, `app/models/user_profile.rb`, `app/models/user_stat.rb`

#### 5.1.7 Content Cards

| Feature | Discourse Mapping | Implementation |
|---------|------------------|----------------|
| Text posts | Post model | Existing |
| Image galleries | Upload system | Existing |
| Video sharing | Upload + oneboxing | Existing |
| Music playlists | **New feature** | Custom plugin |
| Gear showcases | **New feature** | Custom plugin |

**New Development Required:** `fantribe-content-types` plugin

---

### 5.2 High-Level Features

#### 5.2.1 Social Networking

| Feature | Discourse Mapping | Status | Notes |
|---------|------------------|--------|-------|
| User profiles with avatars | `User` + `UserProfile` | Existing | Customize fields |
| Friend connections | **New model** | New | `UserConnection` model |
| Mutual connections | **New feature** | New | Query on `UserConnection` |
| Suggested connections | **New feature** | New | Algorithm based on activity |
| Community tribes/groups | `Category` + `Group` | Existing | Rename/rebrand |

**New Models Required:**
```ruby
# UserConnection - tracks friend/follow relationships
class UserConnection < ActiveRecord::Base
  belongs_to :user
  belongs_to :connected_user, class_name: 'User'
  # status: pending, accepted, blocked
end
```

#### 5.2.2 Content Sharing

| Feature | Discourse Mapping | Status | Notes |
|---------|------------------|--------|-------|
| Text posts with rich formatting | `Post` + Markdown | Existing | |
| Photo uploads/galleries | `Upload` model | Existing | Gallery UI enhancement |
| Video sharing | Upload + onebox | Existing | Thumbnail generation |
| Music playlists | **New model** | New | Embed support + custom model |
| Gear showcases | **New model** | New | Product cards |
| Tags/categorization | `Tag` model | Existing | |

**New Models Required:**
```ruby
# MusicPlaylist - embedded playlist references
class MusicPlaylist < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, optional: true
  # platform: spotify, apple_music, soundcloud
  # embed_url, title, artist
end

# GearShowcase - product/gear posts
class GearShowcase < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, optional: true
  # product_name, brand, price, image_url
  # verified: boolean
end
```

#### 5.2.3 Engagement System

| Feature | Discourse Mapping | Status | Notes |
|---------|------------------|--------|-------|
| Like/heart reactions | `discourse-reactions` plugin | Existing | Configure emoji set |
| Comment threads | Post replies | Existing | |
| Share functionality | Share modal | Existing | Enhance for social |
| View counts | Topic views | Existing | |
| Engagement metrics | `UserStat` | Existing | Add custom fields |

**Files:** `plugins/discourse-reactions/`, `app/models/post_action.rb`

#### 5.2.4 Tribe/Community Features

| Feature | Discourse Mapping | Status | Notes |
|---------|------------------|--------|-------|
| Multiple tribe membership | `CategoryUser` | Existing | |
| Tribe filtering | Category scoping | Existing | |
| Favorite tribes | `CategoryUser` watching | Existing | |
| Online member tracking | Presence system | Existing | Per-category enhancement |
| Tribe-specific feeds | Category topic list | Existing | |

**Files:** `app/models/category.rb`, `app/models/category_user.rb`

#### 5.2.5 Discovery & Recommendations

| Feature | Discourse Mapping | Status | Notes |
|---------|------------------|--------|-------|
| Trending topics/hashtags | Hot algorithm | Existing | Tag-based trending |
| Suggested connections | **New feature** | New | ML/rule-based algorithm |
| Gear recommendations | **New feature** | New | Based on tribe activity |
| Popular products | **New feature** | New | Aggregate gear data |

**New Development Required:** `fantribe-discovery` plugin with recommendation engine

#### 5.2.6 Gear/Product Integration

| Feature | Discourse Mapping | Status | Notes |
|---------|------------------|--------|-------|
| Product cards | **New component** | New | Custom post type |
| Verified product badges | Custom field | New | Admin-verified flag |
| Community usage stats | Aggregate queries | New | Count per product |
| Direct product links | Onebox | Existing | Enhance for gear sites |
| Price display | Custom field | New | Currency formatting |

**New Development Required:** `fantribe-gear` plugin

#### 5.2.7 Personalization

| Feature | Discourse Mapping | Status | Notes |
|---------|------------------|--------|-------|
| Customizable mood/status | User custom field | Configuration | |
| Activity tracking | `UserAction` model | Existing | |
| Personalized recommendations | **New feature** | New | Algorithm |
| Location-based features | User field | Configuration | Privacy-aware |

**Files:** `app/models/user_action.rb`, `config/site_settings.yml`

#### 5.2.8 Responsive Design

| Feature | Discourse Mapping | Status | Notes |
|---------|------------------|--------|-------|
| Mobile-optimized interface | Mobile views | Existing | |
| Bottom navigation for mobile | **Theme component** | New | Custom theme |
| Adaptive layouts | CSS breakpoints | Existing | |
| Touch-friendly interactions | Mobile handlers | Existing | |

**Implementation:** Theme customization at `app/assets/stylesheets/`

---

### 5.3 Content Types (Detailed)

Fantribe supports specialized content formats beyond standard text posts. Each content type has unique fields, UI components, and interaction patterns.

#### 5.3.1 Setup Tours (#BedroomStudioTour, #StudioSetup)

Showcase posts for home studios, rehearsal spaces, and performance setups.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Tour title (e.g., "My Bedroom Producer Setup 2024") |
| description | text | Yes | Detailed description of the setup |
| images | array | Yes | Multiple images (min 3, max 20) with captions |
| gear_tags | array | No | Links to GearShowcase items used in setup |
| location_type | enum | Yes | bedroom, garage, professional, mobile, other |
| budget_range | enum | No | budget, mid-range, high-end, mixed |
| featured_image | upload | Yes | Hero/cover image for the tour |

**UI Components:**
- Carousel/gallery view with image captions
- Gear list sidebar linking to tagged products
- Before/after comparison slider (optional)
- Floor plan upload option

**Discourse Mapping:** Topic with `setup_tour` tag + custom fields via `TopicCustomField`

```ruby
# SetupTour - extends Topic with structured data
class SetupTour < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  has_many :setup_tour_images
  has_many :setup_tour_gear_tags
  # location_type, budget_range, featured_image_upload_id
end
```

#### 5.3.2 Gear Talk (#GearTalk, #GearReview)

Discussion-focused posts about specific gear, comparisons, and reviews.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| gear_items | array | Yes | One or more gear items being discussed |
| discussion_type | enum | Yes | review, comparison, question, tip, troubleshooting |
| rating | integer | No | 1-5 star rating (for reviews) |
| pros | array | No | List of positive points |
| cons | array | No | List of negative points |
| owned_duration | string | No | How long user has owned the gear |
| purchase_context | text | No | Where/how they acquired it |

**UI Components:**
- Gear card(s) at top of post
- Star rating display
- Pros/cons comparison layout
- "I own this" indicator for commenters
- Price history chart (if available)

**Discourse Mapping:** Topic with `gear_talk` tag + linked `GearShowcase` records

```ruby
# GearTalkPost - structured gear discussion
class GearTalkPost < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  has_many :gear_talk_items  # links to GearShowcase
  # discussion_type, rating, pros (json), cons (json)
end
```

#### 5.3.3 Concert Experiences (#ConcertExperience, #LiveMusic)

Event-based posts for sharing live music experiences.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| artist_name | string | Yes | Performing artist/band |
| venue_name | string | Yes | Venue name |
| venue_location | string | Yes | City, State/Country |
| event_date | date | Yes | Date of the concert |
| media | array | No | Photos and videos from the event |
| setlist | array | No | Songs performed (ordered list) |
| rating | integer | No | 1-5 star experience rating |
| seat_section | string | No | Seating/standing area |
| highlights | text | No | Best moments description |
| would_see_again | boolean | No | Would attend again? |

**UI Components:**
- Event header with artist, venue, date
- Media gallery with timeline
- Setlist display (collapsible)
- Map showing venue location
- "I was there too" indicator for commenters
- Link to artist's other concert posts

**Discourse Mapping:** Topic with `concert_experience` tag + custom fields

```ruby
# ConcertExperience - live event posts
class ConcertExperience < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  # artist_name, venue_name, venue_location, event_date
  # setlist (json array), rating, seat_section, highlights
end
```

#### 5.3.4 Fan Art (#FanArt, #MusicArt)

Creative works inspired by artists, albums, or music.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Artwork title |
| artwork_image | upload | Yes | Primary artwork image |
| additional_images | array | No | Process shots, variations |
| inspired_by | string | Yes | Artist/album/song that inspired it |
| medium | enum | Yes | digital, traditional, mixed, photography, other |
| tools_used | array | No | Software/materials used |
| time_spent | string | No | Approximate creation time |
| available_for_sale | boolean | No | Is this available for purchase? |
| process_description | text | No | How it was created |

**UI Components:**
- Large artwork display with zoom
- Artist/inspiration attribution card
- Process gallery (if provided)
- Download options (if enabled by creator)
- Commission inquiry button (if available_for_sale)

**Discourse Mapping:** Topic with `fan_art` tag + `Upload` references

```ruby
# FanArtPost - creative work showcase
class FanArtPost < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  belongs_to :artwork_upload, class_name: 'Upload'
  # inspired_by, medium, tools_used (json), time_spent
  # available_for_sale, process_description
end
```

#### 5.3.5 Music Playlists (#Playlist, #NowPlaying)

Curated playlist sharing with embedded players.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Playlist name |
| description | text | No | Playlist description/theme |
| platform | enum | Yes | spotify, apple_music, soundcloud |
| embed_url | url | Yes | Platform embed/share URL |
| track_count | integer | No | Number of tracks |
| total_duration | string | No | Total playlist length |
| cover_image | upload | No | Custom cover (or fetched from platform) |
| genre_tags | array | No | Genre classifications |
| mood_tags | array | No | Mood/vibe tags (chill, workout, focus) |
| context | text | No | When/why to listen |

**UI Components:**
- Embedded player (Spotify/Apple Music/SoundCloud widget)
- Track list preview (first 5-10 tracks)
- Genre and mood tag chips
- "Add to Library" deep links
- Listening stats (if available from API)

**Discourse Mapping:** Topic with `playlist` tag + `MusicPlaylist` model

```ruby
# MusicPlaylist - already defined, extended fields
class MusicPlaylist < ActiveRecord::Base
  belongs_to :topic, optional: true
  belongs_to :post, optional: true
  belongs_to :user
  # platform, embed_url, title, artist/curator
  # track_count, total_duration, genre_tags (json), mood_tags (json)
end
```

#### 5.3.6 Photo Dumps (#PhotoDump, #BTS)

Multi-image casual posts for behind-the-scenes, event photos, or day-in-the-life content.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | No | Optional title |
| images | array | Yes | Multiple images (min 2, max 30) |
| captions | array | No | Per-image captions |
| context | enum | No | backstage, studio_session, tour_life, fan_meetup, other |
| date_taken | date | No | When photos were taken |
| location | string | No | Where photos were taken |

**UI Components:**
- Grid gallery layout (Instagram-style)
- Swipeable carousel on mobile
- Individual image zoom with caption overlay
- Batch download option
- Auto-generated slideshow view

**Discourse Mapping:** Topic with `photo_dump` tag + multiple `Upload` references

```ruby
# PhotoDump - multi-image casual posts
class PhotoDump < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  has_many :photo_dump_images  # ordered, with captions
  # context, date_taken, location
end

class PhotoDumpImage < ActiveRecord::Base
  belongs_to :photo_dump
  belongs_to :upload
  # position (integer), caption (text)
end
```

#### 5.3.7 Video Recordings (#VideoRecording, #Performance)

Video content including performances, tutorials, and recordings.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Video title |
| video | upload/url | Yes | Video file or external URL (YouTube, Vimeo) |
| video_type | enum | Yes | performance, cover, tutorial, vlog, behind_scenes, other |
| duration | integer | No | Length in seconds |
| thumbnail | upload | No | Custom thumbnail |
| description | text | No | Video description |
| song_info | object | No | Song name, original artist (for covers) |
| gear_used | array | No | Equipment used in recording |
| recording_location | string | No | Where it was recorded |
| collaborators | array | No | Tagged users who participated |

**UI Components:**
- Video player with custom thumbnail
- Chapter markers (for tutorials)
- Gear list sidebar
- Collaborator avatars/links
- Related videos from same user
- Quality selector (if multiple resolutions)

**Discourse Mapping:** Topic with `video_recording` tag + `Upload` or onebox

```ruby
# VideoRecording - video content posts
class VideoRecording < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  belongs_to :video_upload, class_name: 'Upload', optional: true
  # external_url (for YouTube/Vimeo), video_type, duration
  # song_info (json), gear_used (json), recording_location
  has_many :video_collaborators  # links to users
end
```

#### Content Type Summary Table

| Content Type | Primary Media | Key Differentiator | Suggested Tags |
|--------------|---------------|-------------------|----------------|
| Setup Tour | Images (gallery) | Gear tagging, floor plans | #BedroomStudioTour, #StudioSetup |
| Gear Talk | Text + gear cards | Reviews, comparisons, ratings | #GearTalk, #GearReview |
| Concert Experience | Images/video | Event data, setlists, venue info | #ConcertExperience, #LiveMusic |
| Fan Art | Single image | Artwork showcase, inspiration credit | #FanArt, #MusicArt |
| Music Playlist | Embedded player | Platform integration, mood tags | #Playlist, #NowPlaying |
| Photo Dump | Multiple images | Casual, grid layout, batch upload | #PhotoDump, #BTS |
| Video Recording | Video | Performance type, collaborators | #VideoRecording, #Performance |

---

### 5.4 Community Engagement (Detailed)

#### 5.4.1 Conversation Threads

Enhanced threading system for deeper discussions within posts.

| Feature | Description | Implementation |
|---------|-------------|----------------|
| Nested replies | Visual indentation for reply chains | Discourse existing + CSS enhancement |
| Reply preview | Quoted content preview on hover | Existing discourse feature |
| Thread collapse | Collapse/expand long threads | Theme component |
| Reply notifications | Notify when someone replies to your comment | Existing notification system |
| Thread subscription | Follow specific threads within a topic | `TopicUser` notification level |
| Mention autocomplete | @username suggestions while typing | Existing + custom styling |
| Rich replies | Images, embeds in replies | Existing post features |

**Threading UX Enhancements:**
- "View full thread" expansion for deep nesting (>3 levels)
- "Jump to parent" navigation
- Thread participant avatars summary
- "Best answer" highlighting for question-type posts
- Real-time reply indicators (typing...)

**Discourse Mapping:** Existing `Post` reply system with `reply_to_post_number`

#### 5.4.2 Community Statistics

Tribe-level and platform-level analytics visible to members.

**Tribe Statistics Widget:**

| Metric | Description | Visibility |
|--------|-------------|------------|
| Member count | Total tribe members | Public |
| Online now | Currently active members | Public |
| Posts today | New posts in last 24h | Public |
| Posts this week | New posts in last 7 days | Public |
| Top contributors | Most active members this month | Public |
| Growth rate | New members this week/month | Moderators |
| Engagement rate | Interactions per post average | Moderators |
| Popular times | Most active hours/days | Moderators |

**User Statistics (Profile):**

| Metric | Description | Visibility |
|--------|-------------|------------|
| Posts created | Total posts by user | Public (configurable) |
| Reactions received | Total likes/reactions | Public |
| Connections | Friend/follower count | Public (configurable) |
| Tribes joined | Number of active tribe memberships | Public |
| Conversations joined | Threads participated in | Public |
| Gear showcased | Number of gear items added | Public |
| Member since | Account creation date | Public |
| Last active | Last activity timestamp | Configurable |

**Implementation:**

```ruby
# TribeStatistics - cached tribe metrics
class TribeStatistics
  def initialize(category)
    @category = category
  end

  def member_count
    # CategoryUser count with notification_level > muted
  end

  def online_now
    # Users with presence in category channels
  end

  def posts_today
    # Post.where(category: @category).where('created_at > ?', 24.hours.ago).count
  end

  def top_contributors(period: :month)
    # Aggregate post counts by user
  end
end
```

**Discourse Mapping:**
- `CategoryUser` for membership counts
- `UserStat` for user-level stats
- Custom `TribeStatistics` service for aggregations
- Redis caching for performance

#### 5.4.3 Mood Sharing System

User status/mood display and sharing with connections.

**Mood Features:**

| Feature | Description |
|---------|-------------|
| Current mood | Emoji + short text status |
| Mood visibility | Connections only, tribe only, or public |
| Mood history | Optional log of past moods |
| Mood reactions | Others can react to your mood |
| Activity-linked moods | Auto-suggest based on recent activity |
| Mood in feed | Show mood on posts/comments |

**Mood Data Model:**

```ruby
# UserMood - current and historical moods
class UserMood < ActiveRecord::Base
  belongs_to :user
  # emoji (string), text (max 100 chars), visibility (enum)
  # expires_at (optional auto-clear), created_at

  enum visibility: { connections_only: 0, tribe_only: 1, public: 2 }

  scope :current, -> { where('expires_at IS NULL OR expires_at > ?', Time.current).order(created_at: :desc).limit(1) }
end
```

**Predefined Mood Options:**

| Category | Moods |
|----------|-------|
| Creative | 🎵 Making music, 🎸 Jamming, 🎧 In the zone, ✍️ Writing lyrics |
| Listening | 🔊 Discovering new music, 🎶 On repeat, 📻 Live streaming |
| Social | 🎤 At a show, 🎉 Concert tonight, 🤝 Looking to collab |
| Gear | 🛒 GAS alert, 📦 NGD incoming, 🔧 Tweaking my setup |
| General | 😊 Feeling good, 🎯 Focused, 💭 Inspired, 😴 Taking a break |

**UI Components:**
- Mood selector dropdown with emoji picker
- Mood display on profile card
- Mood badge next to username in posts
- "What's your vibe?" prompt on feed
- Mood-based user discovery ("Who's jamming right now?")

#### 5.4.4 Interaction Notifications

Comprehensive notification system for all engagement types.

| Notification Type | Trigger | Priority |
|-------------------|---------|----------|
| connection_request | Someone sends connection request | High |
| connection_accepted | Your request was accepted | High |
| post_liked | Someone liked your post | Normal |
| post_reaction | Someone reacted to your post | Normal |
| comment_reply | Someone replied to your comment | High |
| mention | Someone @mentioned you | High |
| gear_question | Someone asked about your gear | Normal |
| tribe_mention | Your tribe was mentioned | Low |
| milestone | You reached an achievement | Normal |
| mood_reaction | Someone reacted to your mood | Low |
| concert_same | Someone attended same concert | Normal |
| gear_match | Someone has similar gear | Low |

**Notification Preferences:**

```ruby
# User notification settings (stored in UserOption or custom)
{
  connection_requests: { push: true, email: true },
  post_interactions: { push: true, email: :digest },
  mentions: { push: true, email: true },
  tribe_activity: { push: false, email: :weekly },
  gear_related: { push: true, email: false },
  mood_reactions: { push: false, email: false }
}
```

**Discourse Mapping:** Extend `Notification` model with custom notification types

#### 5.4.5 Engagement Actions Summary

| Action | Target | Result | Points (Gamification) |
|--------|--------|--------|----------------------|
| Like | Post/Comment | Heart reaction | +1 giver, +2 receiver |
| React | Post/Comment | Emoji reaction | +1 giver, +2 receiver |
| Comment | Post | New reply | +3 creator |
| Share | Post | Share modal/copy link | +1 sharer, +5 original |
| Bookmark | Post | Save for later | +1 saver |
| Follow | User | Add to connections | +2 both |
| Tag gear | Post | Link to gear item | +2 tagger |
| Verify gear | GearShowcase | Admin verification | +10 owner |

---

## 6. Technical Architecture

### 6.1 Plugin Structure

```
plugins/
├── fantribe-core/              # Core Fantribe functionality
│   ├── plugin.rb
│   ├── config/routes.rb
│   ├── app/
│   │   ├── models/
│   │   │   ├── user_connection.rb
│   │   │   └── user_mood.rb
│   │   ├── controllers/
│   │   │   └── fantribe/connections_controller.rb
│   │   └── serializers/
│   ├── db/migrate/
│   └── assets/javascripts/
│
├── fantribe-content/           # Extended content types
│   ├── plugin.rb
│   ├── app/models/
│   │   ├── music_playlist.rb
│   │   └── gear_showcase.rb
│   └── assets/
│
├── fantribe-discovery/         # Recommendations & trending
│   ├── plugin.rb
│   ├── lib/
│   │   ├── trending_calculator.rb
│   │   └── recommendation_engine.rb
│   └── app/controllers/
│
└── fantribe-theme/             # UI customizations
    ├── about.json
    ├── common/
    ├── desktop/
    └── mobile/
```

### 6.2 Database Schema Extensions

```sql
-- =============================================
-- CORE SOCIAL TABLES
-- =============================================

-- User Connections (friend/follow system)
CREATE TABLE user_connections (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  connected_user_id INTEGER NOT NULL REFERENCES users(id),
  connection_type VARCHAR(20) DEFAULT 'follow', -- follow, friend
  status VARCHAR(20) DEFAULT 'pending', -- pending, accepted, blocked
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  UNIQUE(user_id, connected_user_id)
);

-- User Moods (status/mood sharing)
CREATE TABLE user_moods (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  emoji VARCHAR(10) NOT NULL,
  text VARCHAR(100),
  visibility INTEGER DEFAULT 2, -- 0: connections, 1: tribe, 2: public
  expires_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL
);

-- =============================================
-- CONTENT TYPE TABLES
-- =============================================

-- Music Playlists
CREATE TABLE music_playlists (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER REFERENCES topics(id),
  post_id INTEGER REFERENCES posts(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  platform VARCHAR(50) NOT NULL, -- spotify, apple_music, soundcloud
  embed_url TEXT NOT NULL,
  title VARCHAR(255),
  artist VARCHAR(255),
  thumbnail_url TEXT,
  track_count INTEGER,
  total_duration INTEGER, -- seconds
  genre_tags JSONB DEFAULT '[]',
  mood_tags JSONB DEFAULT '[]',
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Gear Showcases
CREATE TABLE gear_showcases (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER REFERENCES topics(id),
  post_id INTEGER REFERENCES posts(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  product_name VARCHAR(255) NOT NULL,
  brand VARCHAR(100),
  category VARCHAR(100), -- guitar, amp, pedal, synth, drum, mic, etc.
  price_cents INTEGER,
  currency VARCHAR(3) DEFAULT 'USD',
  product_url TEXT,
  image_url TEXT,
  verified BOOLEAN DEFAULT FALSE,
  verified_by INTEGER REFERENCES users(id),
  verified_at TIMESTAMP,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Setup Tours
CREATE TABLE setup_tours (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER NOT NULL REFERENCES topics(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  location_type VARCHAR(50) NOT NULL, -- bedroom, garage, professional, mobile, other
  budget_range VARCHAR(50), -- budget, mid-range, high-end, mixed
  featured_image_upload_id INTEGER REFERENCES uploads(id),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE TABLE setup_tour_images (
  id SERIAL PRIMARY KEY,
  setup_tour_id INTEGER NOT NULL REFERENCES setup_tours(id) ON DELETE CASCADE,
  upload_id INTEGER NOT NULL REFERENCES uploads(id),
  position INTEGER NOT NULL DEFAULT 0,
  caption TEXT,
  created_at TIMESTAMP NOT NULL
);

CREATE TABLE setup_tour_gear_tags (
  id SERIAL PRIMARY KEY,
  setup_tour_id INTEGER NOT NULL REFERENCES setup_tours(id) ON DELETE CASCADE,
  gear_showcase_id INTEGER NOT NULL REFERENCES gear_showcases(id),
  position_x DECIMAL, -- % position on image for tagging
  position_y DECIMAL,
  image_index INTEGER, -- which image this tag is on
  created_at TIMESTAMP NOT NULL
);

-- Gear Talk Posts
CREATE TABLE gear_talk_posts (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER NOT NULL REFERENCES topics(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  discussion_type VARCHAR(50) NOT NULL, -- review, comparison, question, tip, troubleshooting
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  pros JSONB DEFAULT '[]',
  cons JSONB DEFAULT '[]',
  owned_duration VARCHAR(100),
  purchase_context TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE TABLE gear_talk_items (
  id SERIAL PRIMARY KEY,
  gear_talk_post_id INTEGER NOT NULL REFERENCES gear_talk_posts(id) ON DELETE CASCADE,
  gear_showcase_id INTEGER NOT NULL REFERENCES gear_showcases(id),
  position INTEGER DEFAULT 0,
  created_at TIMESTAMP NOT NULL
);

-- Concert Experiences
CREATE TABLE concert_experiences (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER NOT NULL REFERENCES topics(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  artist_name VARCHAR(255) NOT NULL,
  venue_name VARCHAR(255) NOT NULL,
  venue_location VARCHAR(255) NOT NULL,
  event_date DATE NOT NULL,
  setlist JSONB DEFAULT '[]',
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  seat_section VARCHAR(100),
  highlights TEXT,
  would_see_again BOOLEAN,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- Fan Art Posts
CREATE TABLE fan_art_posts (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER NOT NULL REFERENCES topics(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  artwork_upload_id INTEGER NOT NULL REFERENCES uploads(id),
  inspired_by VARCHAR(255) NOT NULL,
  medium VARCHAR(50) NOT NULL, -- digital, traditional, mixed, photography, other
  tools_used JSONB DEFAULT '[]',
  time_spent VARCHAR(100),
  available_for_sale BOOLEAN DEFAULT FALSE,
  process_description TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE TABLE fan_art_additional_images (
  id SERIAL PRIMARY KEY,
  fan_art_post_id INTEGER NOT NULL REFERENCES fan_art_posts(id) ON DELETE CASCADE,
  upload_id INTEGER NOT NULL REFERENCES uploads(id),
  position INTEGER DEFAULT 0,
  caption TEXT,
  created_at TIMESTAMP NOT NULL
);

-- Photo Dumps
CREATE TABLE photo_dumps (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER NOT NULL REFERENCES topics(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  title VARCHAR(255),
  context VARCHAR(50), -- backstage, studio_session, tour_life, fan_meetup, other
  date_taken DATE,
  location VARCHAR(255),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE TABLE photo_dump_images (
  id SERIAL PRIMARY KEY,
  photo_dump_id INTEGER NOT NULL REFERENCES photo_dumps(id) ON DELETE CASCADE,
  upload_id INTEGER NOT NULL REFERENCES uploads(id),
  position INTEGER NOT NULL DEFAULT 0,
  caption TEXT,
  created_at TIMESTAMP NOT NULL
);

-- Video Recordings
CREATE TABLE video_recordings (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER NOT NULL REFERENCES topics(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  video_upload_id INTEGER REFERENCES uploads(id),
  external_url TEXT, -- YouTube, Vimeo, etc.
  video_type VARCHAR(50) NOT NULL, -- performance, cover, tutorial, vlog, behind_scenes, other
  duration INTEGER, -- seconds
  thumbnail_upload_id INTEGER REFERENCES uploads(id),
  description TEXT,
  song_info JSONB, -- { name, original_artist, album }
  gear_used JSONB DEFAULT '[]',
  recording_location VARCHAR(255),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE TABLE video_collaborators (
  id SERIAL PRIMARY KEY,
  video_recording_id INTEGER NOT NULL REFERENCES video_recordings(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL REFERENCES users(id),
  role VARCHAR(100), -- vocalist, guitarist, producer, etc.
  created_at TIMESTAMP NOT NULL
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- User connections
CREATE INDEX idx_user_connections_user ON user_connections(user_id);
CREATE INDEX idx_user_connections_connected ON user_connections(connected_user_id);
CREATE INDEX idx_user_connections_status ON user_connections(status);

-- User moods
CREATE INDEX idx_user_moods_user ON user_moods(user_id);
CREATE INDEX idx_user_moods_expires ON user_moods(expires_at) WHERE expires_at IS NOT NULL;

-- Gear showcases
CREATE INDEX idx_gear_showcases_category ON gear_showcases(category);
CREATE INDEX idx_gear_showcases_brand ON gear_showcases(brand);
CREATE INDEX idx_gear_showcases_user ON gear_showcases(user_id);
CREATE INDEX idx_gear_showcases_verified ON gear_showcases(verified) WHERE verified = TRUE;

-- Music playlists
CREATE INDEX idx_music_playlists_platform ON music_playlists(platform);
CREATE INDEX idx_music_playlists_user ON music_playlists(user_id);

-- Setup tours
CREATE INDEX idx_setup_tours_user ON setup_tours(user_id);
CREATE INDEX idx_setup_tours_location ON setup_tours(location_type);

-- Concert experiences
CREATE INDEX idx_concert_experiences_artist ON concert_experiences(artist_name);
CREATE INDEX idx_concert_experiences_venue ON concert_experiences(venue_name);
CREATE INDEX idx_concert_experiences_date ON concert_experiences(event_date);
CREATE INDEX idx_concert_experiences_user ON concert_experiences(user_id);

-- Fan art
CREATE INDEX idx_fan_art_posts_user ON fan_art_posts(user_id);
CREATE INDEX idx_fan_art_posts_medium ON fan_art_posts(medium);

-- Photo dumps
CREATE INDEX idx_photo_dumps_user ON photo_dumps(user_id);
CREATE INDEX idx_photo_dumps_context ON photo_dumps(context);

-- Video recordings
CREATE INDEX idx_video_recordings_user ON video_recordings(user_id);
CREATE INDEX idx_video_recordings_type ON video_recordings(video_type);
```

### 6.3 API Endpoints

#### Connections API
```
GET    /fantribe/connections                    # List user's connections
POST   /fantribe/connections                    # Create connection request
PUT    /fantribe/connections/:id                # Accept/update connection
DELETE /fantribe/connections/:id                # Remove connection
GET    /fantribe/connections/suggestions        # Get suggested connections
GET    /fantribe/connections/mutual/:user_id    # Get mutual connections with user
GET    /fantribe/users/:id/connections          # Get another user's connections
```

#### Mood API
```
GET    /fantribe/moods/current                  # Get current user's mood
POST   /fantribe/moods                          # Set mood
DELETE /fantribe/moods/current                  # Clear mood
GET    /fantribe/users/:id/mood                 # Get another user's mood
GET    /fantribe/moods/active                   # Get active moods (connections/tribe)
```

#### Music Playlists API
```
GET    /fantribe/playlists                      # List user's playlists
POST   /fantribe/playlists                      # Create playlist post
GET    /fantribe/playlists/:id                  # Get playlist details
PUT    /fantribe/playlists/:id                  # Update playlist
DELETE /fantribe/playlists/:id                  # Delete playlist
GET    /fantribe/playlists/platform/:platform   # Filter by platform
```

#### Gear API
```
GET    /fantribe/gear                           # List user's gear
POST   /fantribe/gear                           # Add gear showcase
GET    /fantribe/gear/:id                       # Get gear details
PUT    /fantribe/gear/:id                       # Update gear
DELETE /fantribe/gear/:id                       # Delete gear
GET    /fantribe/gear/trending                  # Trending gear in community
GET    /fantribe/gear/category/:category        # Filter by category
GET    /fantribe/gear/brand/:brand              # Filter by brand
POST   /fantribe/gear/:id/verify                # Admin: verify gear (admin only)
GET    /fantribe/users/:id/gear                 # Get another user's gear
```

#### Setup Tours API
```
GET    /fantribe/setup-tours                    # List setup tours
POST   /fantribe/setup-tours                    # Create setup tour
GET    /fantribe/setup-tours/:id                # Get tour details
PUT    /fantribe/setup-tours/:id                # Update tour
DELETE /fantribe/setup-tours/:id                # Delete tour
POST   /fantribe/setup-tours/:id/images         # Add images to tour
DELETE /fantribe/setup-tours/:id/images/:img_id # Remove image
POST   /fantribe/setup-tours/:id/gear-tags      # Tag gear in tour
DELETE /fantribe/setup-tours/:id/gear-tags/:tag_id # Remove gear tag
```

#### Gear Talk API
```
GET    /fantribe/gear-talk                      # List gear talk posts
POST   /fantribe/gear-talk                      # Create gear talk post
GET    /fantribe/gear-talk/:id                  # Get post details
PUT    /fantribe/gear-talk/:id                  # Update post
DELETE /fantribe/gear-talk/:id                  # Delete post
GET    /fantribe/gear-talk/type/:type           # Filter by discussion type
GET    /fantribe/gear/:gear_id/discussions      # Get discussions about specific gear
```

#### Concert Experiences API
```
GET    /fantribe/concerts                       # List concert experiences
POST   /fantribe/concerts                       # Create concert experience
GET    /fantribe/concerts/:id                   # Get experience details
PUT    /fantribe/concerts/:id                   # Update experience
DELETE /fantribe/concerts/:id                   # Delete experience
GET    /fantribe/concerts/artist/:name          # Filter by artist
GET    /fantribe/concerts/venue/:name           # Filter by venue
GET    /fantribe/concerts/date/:date            # Filter by date
GET    /fantribe/concerts/:id/attendees         # Users who attended same concert
```

#### Fan Art API
```
GET    /fantribe/fan-art                        # List fan art
POST   /fantribe/fan-art                        # Create fan art post
GET    /fantribe/fan-art/:id                    # Get art details
PUT    /fantribe/fan-art/:id                    # Update art post
DELETE /fantribe/fan-art/:id                    # Delete art post
GET    /fantribe/fan-art/medium/:medium         # Filter by medium
GET    /fantribe/fan-art/inspired-by/:query     # Search by inspiration
POST   /fantribe/fan-art/:id/images             # Add process images
```

#### Photo Dumps API
```
GET    /fantribe/photo-dumps                    # List photo dumps
POST   /fantribe/photo-dumps                    # Create photo dump
GET    /fantribe/photo-dumps/:id                # Get dump details
PUT    /fantribe/photo-dumps/:id                # Update dump
DELETE /fantribe/photo-dumps/:id                # Delete dump
POST   /fantribe/photo-dumps/:id/images         # Add images
PUT    /fantribe/photo-dumps/:id/images/:img_id # Update image caption
DELETE /fantribe/photo-dumps/:id/images/:img_id # Remove image
PUT    /fantribe/photo-dumps/:id/reorder        # Reorder images
```

#### Video Recordings API
```
GET    /fantribe/videos                         # List videos
POST   /fantribe/videos                         # Create video post
GET    /fantribe/videos/:id                     # Get video details
PUT    /fantribe/videos/:id                     # Update video
DELETE /fantribe/videos/:id                     # Delete video
GET    /fantribe/videos/type/:type              # Filter by video type
POST   /fantribe/videos/:id/collaborators       # Add collaborators
DELETE /fantribe/videos/:id/collaborators/:uid  # Remove collaborator
GET    /fantribe/users/:id/videos               # Get user's videos
```

#### Discovery API
```
GET    /fantribe/trending/tags                  # Trending hashtags
GET    /fantribe/trending/tribes                # Active tribes
GET    /fantribe/trending/gear                  # Popular gear this week
GET    /fantribe/trending/content               # Trending posts across types
GET    /fantribe/recommendations/users          # Recommended connections
GET    /fantribe/recommendations/gear           # Recommended gear for you
GET    /fantribe/recommendations/tribes         # Recommended tribes
GET    /fantribe/search/content                 # Search across content types
```

#### Statistics API
```
GET    /fantribe/stats/tribe/:id                # Tribe statistics
GET    /fantribe/stats/user/:id                 # User statistics (public)
GET    /fantribe/stats/user/:id/private         # User statistics (private, self only)
GET    /fantribe/stats/platform                 # Platform-wide statistics
```

---

## 7. Discourse Feature Mapping Summary

| Fantribe Concept | Discourse Equivalent | Customization Level |
|------------------|---------------------|---------------------|
| Tribe | Category | Rename + UI theme |
| Post/Content | Topic + Post | Extend with content types |
| Feed | Topic List (filtered) | Custom scoping |
| Likes | PostAction + Reactions | Configure reactions |
| Comments | Post replies | Existing |
| User Profile | User + UserProfile | Add custom fields |
| Notifications | Notification system | Existing + custom types |
| Messaging | Chat plugin | Plugin integration |
| Tags/Hashtags | Tag system | Existing |
| Bookmarks | Bookmark model | Existing |
| Search | Search system | Existing |
| Moderation | Guardian + flags | Existing |

---

## 8. Implementation Phases

### Phase 1: Foundation
- Configure Discourse base installation
- Create `fantribe-theme` with branding and UI customizations
- Rename "Categories" to "Tribes" via localization
- Configure user custom fields (mood, location)
- Enable and configure `discourse-reactions` plugin
- Set up mobile bottom navigation theme component

### Phase 2: Social Features
- Develop `fantribe-core` plugin
- Implement `UserConnection` model and API
- Build suggested connections algorithm
- Add mutual friends display
- Create connection notifications

### Phase 3: Content Types
- Develop `fantribe-content` plugin
- Implement music playlist embeds
- Build gear showcase system
- Create product card components
- Add verified badge system

### Phase 4: Discovery
- Develop `fantribe-discovery` plugin
- Implement trending algorithm
- Build recommendation engine
- Create discovery sidebar widgets
- Add personalized feed sorting

### Phase 5: Polish & Mobile
- Optimize mobile experience
- Performance tuning
- Analytics integration
- Final UI polish

---

## 9. Configuration Requirements

### Site Settings (config/site_settings.yml)
```yaml
fantribe:
  fantribe_enabled:
    default: true
    client: true
  fantribe_max_connections:
    default: 5000
    min: 100
  fantribe_gear_verification_enabled:
    default: true
  fantribe_playlist_platforms:
    default: 'spotify|apple_music|soundcloud'
    type: list
  fantribe_trending_threshold:
    default: 10
    min: 1
  fantribe_mood_enabled:
    default: true
    client: true
```

---

## 10. Success Metrics

| Metric | Measurement | Target |
|--------|-------------|--------|
| User Engagement | Posts per active user/week | 3+ |
| Connection Growth | New connections/user/month | 5+ |
| Tribe Activity | Active tribes with daily posts | 80%+ |
| Content Diversity | Posts with media attachments | 40%+ |
| Mobile Usage | Mobile session percentage | 60%+ |
| Gear Engagement | Gear showcases created/week | Growing |

---

## 11. Security Considerations

- **Authorization**: All new APIs use Guardian pattern for permission checks
- **Rate Limiting**: Connection requests limited to prevent spam
- **Content Validation**: Playlist/gear URLs validated against allowlist
- **Privacy**: Connection visibility respects user privacy settings
- **XSS Prevention**: All user content sanitized through Discourse's cook system

---

## 12. Files to Modify/Create

### Existing Files to Modify
- `config/locales/client.en.yml` - Rename Categories to Tribes
- `config/locales/server.en.yml` - Server-side translations
- `config/site_settings.yml` - Add Fantribe settings

### New Plugin Files to Create

#### fantribe-core (Social Features)
```
plugins/fantribe-core/
├── plugin.rb
├── config/
│   ├── routes.rb
│   └── settings.yml
├── app/
│   ├── models/
│   │   ├── user_connection.rb
│   │   └── user_mood.rb
│   ├── controllers/fantribe/
│   │   ├── connections_controller.rb
│   │   ├── moods_controller.rb
│   │   └── stats_controller.rb
│   ├── serializers/
│   │   ├── user_connection_serializer.rb
│   │   ├── user_mood_serializer.rb
│   │   └── tribe_statistics_serializer.rb
│   └── services/
│       ├── connection_suggester.rb
│       └── tribe_statistics.rb
├── db/migrate/
│   ├── 20240101000001_create_user_connections.rb
│   └── 20240101000002_create_user_moods.rb
├── lib/
│   └── fantribe_core/
│       └── engine.rb
└── spec/
    ├── models/
    ├── controllers/
    └── services/
```

#### fantribe-content (Content Types)
```
plugins/fantribe-content/
├── plugin.rb
├── config/
│   ├── routes.rb
│   └── settings.yml
├── app/
│   ├── models/
│   │   ├── music_playlist.rb
│   │   ├── gear_showcase.rb
│   │   ├── setup_tour.rb
│   │   ├── setup_tour_image.rb
│   │   ├── setup_tour_gear_tag.rb
│   │   ├── gear_talk_post.rb
│   │   ├── gear_talk_item.rb
│   │   ├── concert_experience.rb
│   │   ├── fan_art_post.rb
│   │   ├── fan_art_additional_image.rb
│   │   ├── photo_dump.rb
│   │   ├── photo_dump_image.rb
│   │   ├── video_recording.rb
│   │   └── video_collaborator.rb
│   ├── controllers/fantribe/
│   │   ├── playlists_controller.rb
│   │   ├── gear_controller.rb
│   │   ├── setup_tours_controller.rb
│   │   ├── gear_talk_controller.rb
│   │   ├── concerts_controller.rb
│   │   ├── fan_art_controller.rb
│   │   ├── photo_dumps_controller.rb
│   │   └── videos_controller.rb
│   └── serializers/
│       ├── music_playlist_serializer.rb
│       ├── gear_showcase_serializer.rb
│       ├── setup_tour_serializer.rb
│       ├── gear_talk_post_serializer.rb
│       ├── concert_experience_serializer.rb
│       ├── fan_art_post_serializer.rb
│       ├── photo_dump_serializer.rb
│       └── video_recording_serializer.rb
├── db/migrate/
│   ├── 20240101000010_create_music_playlists.rb
│   ├── 20240101000011_create_gear_showcases.rb
│   ├── 20240101000012_create_setup_tours.rb
│   ├── 20240101000013_create_gear_talk_posts.rb
│   ├── 20240101000014_create_concert_experiences.rb
│   ├── 20240101000015_create_fan_art_posts.rb
│   ├── 20240101000016_create_photo_dumps.rb
│   └── 20240101000017_create_video_recordings.rb
├── lib/
│   └── fantribe_content/
│       ├── engine.rb
│       └── embed_validator.rb
└── spec/
```

#### fantribe-discovery (Recommendations & Trending)
```
plugins/fantribe-discovery/
├── plugin.rb
├── config/
│   ├── routes.rb
│   └── settings.yml
├── app/
│   ├── controllers/fantribe/
│   │   ├── trending_controller.rb
│   │   ├── recommendations_controller.rb
│   │   └── search_controller.rb
│   └── serializers/
│       └── trending_item_serializer.rb
├── lib/
│   └── fantribe_discovery/
│       ├── engine.rb
│       ├── trending_calculator.rb
│       ├── recommendation_engine.rb
│       └── content_search.rb
└── spec/
```

### Theme Files
```
plugins/fantribe-theme/
├── about.json
├── common/
│   ├── common.scss
│   ├── header.scss
│   ├── sidebar.scss
│   ├── feed.scss
│   ├── profile.scss
│   └── content-cards/
│       ├── base.scss
│       ├── setup-tour.scss
│       ├── gear-card.scss
│       ├── concert.scss
│       ├── fan-art.scss
│       ├── photo-dump.scss
│       ├── video.scss
│       └── playlist.scss
├── desktop/
│   └── desktop.scss
├── mobile/
│   ├── mobile.scss
│   └── bottom-nav.scss
└── javascripts/
    ├── discourse/
    │   ├── components/
    │   │   ├── fantribe-mood-selector.gjs
    │   │   ├── fantribe-connection-button.gjs
    │   │   ├── fantribe-gear-card.gjs
    │   │   ├── fantribe-playlist-embed.gjs
    │   │   ├── fantribe-photo-gallery.gjs
    │   │   ├── fantribe-video-player.gjs
    │   │   └── fantribe-stats-widget.gjs
    │   └── initializers/
    │       └── fantribe-setup.js
    └── select-kit/
        └── components/
            └── mood-dropdown.gjs
```

---

## 13. Verification Plan

### 13.1 Unit Tests (RSpec)

| Component | Test Coverage |
|-----------|---------------|
| `UserConnection` | Create, accept, reject, block, mutual query |
| `UserMood` | Set, clear, expire, visibility scopes |
| `MusicPlaylist` | CRUD, platform validation, embed URL parsing |
| `GearShowcase` | CRUD, verification workflow, usage counting |
| `SetupTour` | CRUD, image ordering, gear tagging |
| `GearTalkPost` | CRUD, rating validation, pros/cons |
| `ConcertExperience` | CRUD, setlist parsing, date filtering |
| `FanArtPost` | CRUD, image handling, medium validation |
| `PhotoDump` | CRUD, image batch operations, reordering |
| `VideoRecording` | CRUD, external URL validation, collaborators |
| `ConnectionSuggester` | Algorithm accuracy, performance |
| `TribeStatistics` | Aggregation accuracy, caching |
| `TrendingCalculator` | Ranking algorithm, time decay |

### 13.2 Integration Tests (API)

```ruby
# Example test structure for each endpoint group
describe "Fantribe::ConnectionsController" do
  it "lists user connections with pagination"
  it "creates connection request and notifies user"
  it "accepts connection request and updates both users"
  it "rejects connection request"
  it "blocks user and hides from suggestions"
  it "returns mutual connections"
  it "returns suggested connections based on activity"
end

describe "Fantribe::ContentController" do
  context "setup tours" do
    it "creates tour with images and gear tags"
    it "updates image order"
    it "validates minimum image count"
  end

  context "gear talk" do
    it "creates review with rating"
    it "links multiple gear items"
    it "validates discussion type"
  end

  # ... similar for all content types
end
```

### 13.3 System Tests (Page Objects)

```
spec/system/page_objects/
├── pages/
│   ├── fantribe_feed.rb
│   ├── fantribe_profile.rb
│   ├── fantribe_tribe.rb
│   └── fantribe_composer.rb
└── components/
    ├── mood_selector.rb
    ├── connection_button.rb
    ├── gear_card.rb
    ├── photo_gallery.rb
    └── video_player.rb
```

**Critical User Flows:**

| Flow | Test Scenario |
|------|---------------|
| Connection Flow | User A sends request → User B receives notification → User B accepts → Both see each other in connections |
| Setup Tour Creation | Upload images → Add captions → Tag gear → Publish → Verify display |
| Concert Experience | Fill event details → Add photos → Submit setlist → Find "I was there" users |
| Gear Review | Select gear → Rate → Add pros/cons → Publish → Verify on gear page |
| Mood Sharing | Set mood → Verify visibility to connections → Expire mood |

### 13.4 Manual Testing Checklist

#### Social Features
- [ ] Create account and complete profile
- [ ] Set mood and verify visibility settings
- [ ] Send connection request to another user
- [ ] Accept/reject incoming connection requests
- [ ] View mutual connections
- [ ] Check suggested connections algorithm
- [ ] Block a user and verify hidden from feed

#### Content Types
- [ ] **Setup Tour**: Create with 5+ images, tag 3+ gear items, publish
- [ ] **Gear Talk**: Create review with rating, pros/cons, owned duration
- [ ] **Concert Experience**: Add event with setlist, find other attendees
- [ ] **Fan Art**: Upload artwork, set inspiration, mark for sale
- [ ] **Music Playlist**: Embed Spotify/Apple Music/SoundCloud playlist
- [ ] **Photo Dump**: Upload 10+ images, add captions, reorder
- [ ] **Video Recording**: Upload video, tag collaborators, add gear used

#### Tribe Features
- [ ] Join multiple tribes
- [ ] View tribe statistics (members, posts, activity)
- [ ] Filter feed by tribe
- [ ] Set tribe as favorite
- [ ] View online members in tribe

#### Discovery
- [ ] Browse trending tags
- [ ] View recommended connections
- [ ] Search across content types
- [ ] View trending gear

#### Mobile
- [ ] Bottom navigation works correctly
- [ ] Photo gallery is swipeable
- [ ] Mood selector is touch-friendly
- [ ] All content types render correctly
- [ ] Connection requests work on mobile

### 13.5 Performance Testing

| Scenario | Target |
|----------|--------|
| Feed load (100 posts) | < 500ms |
| Connection suggestions (1000 users) | < 200ms |
| Tribe statistics | < 100ms (cached) |
| Image gallery load (20 images) | < 1s |
| Search results | < 300ms |

### 13.6 Security Testing

- [ ] Verify Guardian checks on all new endpoints
- [ ] Test connection visibility respects privacy settings
- [ ] Validate gear URLs against allowlist
- [ ] Test rate limiting on connection requests
- [ ] Verify mood visibility scopes
- [ ] Test XSS prevention in user-generated content

---

## 14. Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Music Platforms** | Spotify, Apple Music, SoundCloud | Most popular platforms with reliable embed APIs |
| **Gear Database** | User-submitted with verification | Enables community contributions while maintaining quality via admin verification |
| **Phase 1 Focus** | Social features (connections, feed) | Prioritizes user relationships and engagement foundation |

---

## 15. Remaining Questions

1. **Monetization**: Are there plans for premium features or gear affiliate links?
2. **Moderation**: Should Tribes have dedicated moderators or rely on community flagging?
3. **Analytics**: What specific user activity metrics should be tracked?
