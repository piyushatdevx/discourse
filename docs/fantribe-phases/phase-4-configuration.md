# Phase 4: Feature Configuration & Setup

> **Quick Reference:** See [Implementation Guidelines](../FANTRIBE-IMPLEMENTATION-PLAN.md#implementation-guidelines) for design rules.

## Overview
Enable and configure essential plugins, create default tribes (categories), set up custom user profile fields, configure OAuth providers, and set up email templates.

## Prerequisites
- [ ] Phase 3 completed and approved
- [ ] Terminology transformation in place

---

## Tasks

### 4.1 Enable & Configure Essential Plugins

**Plugins to Enable:**

1. **discourse-chat** (for messaging)
   ```bash
   # Enable in admin panel or config/discourse.conf
   DISCOURSE_ENABLE_CHAT_PLUGIN=true
   ```

2. **discourse-reactions** (for emoji reactions beyond likes)
   - Install from: https://github.com/discourse/discourse-reactions
   - Configure available reactions in admin panel

3. **discourse-follow** (if available, or build minimal version)
   - Enables user following functionality
   - If not available, defer to Phase 7 custom development

**Configuration Steps:**
- Admin Panel → Plugins → Enable selected plugins
- Configure plugin settings per social media use case
- Test plugin functionality

---

### 4.2 Create Default Tribes (Categories)

**Goal:** Set up initial tribes for music community

**Default Tribes to Create:**
1. **General** (default, all users)
2. **Music Gear** (for gear discussions)
3. **Studio Setup** (for setup showcases)
4. **Collaborations** (for finding collaborators)
5. **Events & Meetups** (for concerts, jam sessions)
6. **Music Production** (tips, techniques)
7. **Newbie Zone** (for beginners)

**For Each Tribe:**
- Name, description, color scheme
- Custom logo/icon
- Banner image (gradient or photo)
- Permissions (public/private)
- Tags configuration

**Script:** `scripts/create_default_tribes.rb`
```ruby
# Create default tribes
tribes = [
  {
    name: "General",
    description: "General discussions about music, life, and everything in between",
    color: "FF1844",
    permissions: { everyone: :full }
  },
  {
    name: "Music Gear",
    description: "Discuss instruments, equipment, pedals, and all your music gear",
    color: "FF6B4A",
    permissions: { everyone: :full }
  },
  # ... more tribes
]

tribes.each do |tribe_data|
  Category.create!(
    name: tribe_data[:name],
    description: tribe_data[:description],
    color: tribe_data[:color],
    # ... other settings
  )
end
```

---

### 4.3 Configure User Profile Fields

**Goal:** Add custom user fields for music community

**Custom Fields to Add (Admin → Users → Custom User Fields):**

1. **Instruments Played**
   - Type: Multi-select dropdown
   - Options: Guitar, Bass, Drums, Keys, Vocals, Production, DJ, etc.

2. **Music Genres**
   - Type: Multi-select
   - Options: Rock, Pop, Electronic, Jazz, Hip-Hop, Metal, etc.

3. **Experience Level**
   - Type: Dropdown
   - Options: Beginner, Intermediate, Advanced, Professional

4. **Location (City)**
   - Type: Text
   - For finding local musicians

5. **Available for Collaboration**
   - Type: Checkbox

6. **Website/Portfolio**
   - Type: URL

7. **Spotify/SoundCloud/Bandcamp**
   - Type: Text (for profile links)

**Display on Profile:**
- Add these fields to user profile display template
- Style as badges or info cards

---

### 4.4 OAuth Provider Setup

**Goal:** Enable social login (Google, Facebook)

**Google OAuth Setup:**
1. Create project in Google Cloud Console
2. Enable Google+ API
3. Create OAuth 2.0 credentials
4. Configure in Discourse:
   - Admin → Settings → Login
   - `google_oauth2_client_id`: [your-client-id]
   - `google_oauth2_client_secret`: [your-client-secret]

**Facebook OAuth Setup:**
1. Create app in Facebook Developers
2. Add Facebook Login product
3. Configure in Discourse:
   - Admin → Settings → Login
   - `facebook_app_id`: [your-app-id]
   - `facebook_app_secret`: [your-app-secret]

**Testing:**
- Test login flow for each provider
- Ensure profile info is imported correctly
- Test account linking

---

### 4.5 Email Configuration & Templates

**Goal:** Professional email notifications with FanTribe branding

**SMTP Settings (Admin → Settings → Email):**
```yaml
notification_email: noreply@fantribe.com
reply_by_email_address: replies+%{reply_key}@fantribe.com
smtp_address: smtp.sendgrid.net  # or your provider
smtp_port: 587
smtp_user_name: apikey
smtp_password: [your-api-key]
```

**Customize Email Templates:**
- Admin → Customize → Email Templates
- Update logo, colors, footer
- Customize text for:
  - Welcome email
  - Email verification
  - Password reset
  - Notification digest
  - Mention notifications
  - Like notifications

**Email Branding:**
- Add FanTribe logo
- Use brand colors (#FF1844)
- Include social links in footer

---

### 4.6 Notification Preferences Setup

**Goal:** Configure smart notification defaults

**Default Settings (Admin → Settings → Notifications):**
```yaml
# Notification Defaults
default_email_digest_frequency: weekly
default_email_level: always  # or only_when_away
default_email_messages_level: always
default_email_mailing_list_mode: false

# Notification Types
enable_mentions: true
enable_likes_notifications: true
enable_linked_notifications: true

# Digests
enable_digest_emails: true
digest_min_excerpt_length: 100
```

**User-Configurable Preferences:**
- Each user can customize in Settings → Notifications
- Per-tribe notification levels
- In-app vs email vs push
- Quiet hours

---

## Completion Checklist
- [ ] Essential plugins enabled and configured
- [ ] Default tribes created with proper settings
- [ ] Custom user fields configured
- [ ] Google OAuth working
- [ ] Facebook OAuth working
- [ ] SMTP email configured and tested
- [ ] Email templates branded
- [ ] Notification defaults set
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
