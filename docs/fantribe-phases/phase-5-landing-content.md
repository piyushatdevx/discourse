# Phase 5: Landing Page & Content

> **Quick Reference:** See [Implementation Guidelines](../FANTRIBE-IMPLEMENTATION-PLAN.md#implementation-guidelines) for design rules.

## Overview
Create a compelling landing page for visitor acquisition, set up about/legal pages, customize onboarding flow, and seed initial content.

## Prerequisites
- [ ] Phase 4 completed and approved
- [ ] Configuration complete

---

## Tasks

### 5.1 Custom Landing Page for Logged-Out Users

**Goal:** Compelling landing page for visitor acquisition

**Option 1: Use Discourse Pages Plugin**
- Install discourse-custom-pages
- Create `/landing` route
- Full control over content

**Option 2: Customize Homepage**
- Modify homepage for logged-out users
- Show different content than logged-in feed

**Landing Page Sections:**

1. **Hero Section**
   ```html
   <div class="fantribe-hero">
     <h1>Connect with Musicians Worldwide</h1>
     <p>Share your music, discover new sounds, and collaborate with artists</p>
     <div class="cta-buttons">
       <a href="/signup" class="btn-primary">Get Started</a>
       <a href="#learn-more" class="btn-secondary">Learn More</a>
     </div>
   </div>
   ```

2. **Featured Tribes Section**
   - Dynamic showcase of top 6 tribes
   - Member counts, recent activity

3. **How It Works**
   - 3-step visual guide
   - Join tribes → Share music → Connect with artists

4. **Testimonials (placeholder)**
   - Social proof section

5. **CTA Footer**
   - Final signup prompt

**Styling:** Use theme SCSS with hero gradients, cards, etc.

---

### 5.2 About & Legal Pages

**Pages to Create:**

1. **About FanTribe** (`/about`)
   - Mission statement
   - What makes FanTribe unique
   - Team info (if applicable)

2. **Terms of Service** (`/tos`)
   - User agreement
   - Content policy
   - Dispute resolution

3. **Privacy Policy** (`/privacy`)
   - Data collection practices
   - Cookie policy
   - GDPR compliance

4. **Community Guidelines** (`/guidelines`)
   - Expected behavior
   - Content rules
   - Consequences for violations

**Create Using:**
- Admin → Customize → Pages
- Or create as static topics in a "Help" category

---

### 5.3 Onboarding Flow Customization

**Goal:** Guide new users through profile setup and first actions

**Onboarding Steps:**

1. **Welcome Modal** (after signup)
   - Brief intro to FanTribe
   - CTA: "Complete Your Profile"

2. **Profile Setup Wizard**
   - Upload avatar
   - Add bio
   - Select instruments & genres (custom fields)
   - Add location

3. **Tribe Suggestions**
   - Recommend 3-5 tribes based on interests
   - "Join your first tribe"

4. **First Post Prompt**
   - Encourage first post
   - Template or prompts: "Introduce yourself" / "Share your latest track"

5. **Feature Tour** (optional)
   - Tooltip walkthrough of key features
   - Can use a library like Shepherd.js

**Implementation:**
- JavaScript in plugin initializer
- Trigger modals based on user state
- Track onboarding completion

---

### 5.4 Default Content & Seed Data

**Goal:** Pre-populate platform so it doesn't look empty

**Content to Create:**

1. **Welcome Post** in General tribe
   - Pinned, from admin/founder
   - "Welcome to FanTribe!"

2. **Sample Posts** in each tribe
   - 3-5 posts per tribe
   - Mix of text, images, discussions
   - Realistic examples

3. **Sample User Accounts**
   - 10-15 fake users with diverse profiles
   - Different instruments, genres
   - Varied activity levels

4. **Badges Created**
   - First Post
   - Welcome
   - 100 Likes Received
   - Active Member (30+ posts)
   - Tribe Founder

**Script:** `scripts/seed_content.rb`
```ruby
# Create sample users
# Create sample posts
# Award initial badges
```

---

## Completion Checklist
- [ ] Landing page implemented and styled
- [ ] About page created
- [ ] Terms of Service published
- [ ] Privacy Policy published
- [ ] Community Guidelines posted
- [ ] Onboarding flow working
- [ ] Welcome post created
- [ ] Sample content seeded
- [ ] Badges configured
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
