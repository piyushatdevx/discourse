<!-- AI_INSTRUCTIONS_START
This file is the central tracker for FanTribe implementation.

HOW TO USE THIS FILE:
1. Read CURRENT_PHASE marker to know which phase to work on
2. Open the linked phase file for detailed implementation steps
3. Follow the Implementation Guidelines below for ALL phases
4. After completing a phase:
   - Update phase status from 'in_progress' → 'completed' in the tracker table
   - Update CURRENT_PHASE to next phase number
   - Add entry to Progress Log with date and summary
   - Request user review before proceeding

CURRENT_PHASE tells you where to start/continue.
Always read the full Implementation Guidelines before any phase work.
AI_INSTRUCTIONS_END -->

# FanTribe MVP Implementation Plan

**Quick MVP: Transform Discourse into Social Media Platform (4-6 weeks)**

## Overview

Transform the existing Discourse forum into a social-media-style music community platform by creating a custom theme plugin that reskins the interface, renames terminology (Categories → Tribes), and configures native features for social interaction.

**Strategy:** Leverage 80% of Discourse's native functionality, focus development on UI/UX transformation and social media aesthetics.

---

<!-- CURRENT_PHASE: 2 -->
<!-- CURRENT_SUB_PHASE: 2.1 -->

## Phase Tracker

| # | Phase | Status | Sub-Progress | File |
|---|-------|--------|--------------|------|
| 1 | Foundation Setup | ✅ completed | - | [phase-1-foundation.md](./fantribe-phases/phase-1-foundation.md) |
| 2 | UI Transformation | 🔄 in_progress | 2/9 sub-phases | [phase-2-ui-transformation.md](./fantribe-phases/phase-2-ui-transformation.md) |
| 3 | Terminology | ⏳ pending | - | [phase-3-terminology.md](./fantribe-phases/phase-3-terminology.md) |
| 4 | Configuration | ⏳ pending | - | [phase-4-configuration.md](./fantribe-phases/phase-4-configuration.md) |
| 5 | Landing & Content | ⏳ pending | - | [phase-5-landing-content.md](./fantribe-phases/phase-5-landing-content.md) |
| 6 | Testing & Launch | ⏳ pending | - | [phase-6-testing-launch.md](./fantribe-phases/phase-6-testing-launch.md) |
| 7 | Post-MVP | ⏳ pending | - | [phase-7-post-mvp.md](./fantribe-phases/phase-7-post-mvp.md) |

**Status Legend:** ⏳ pending | 🔄 in_progress | ✅ completed | ⏸️ blocked

---

## Progress Log

| Date | Phase | Action | Notes |
|------|-------|--------|-------|
| - | - | Plan restructured | Split into phase files with tracking |
| 2026-01-29 | 1 | Completed | Foundation setup with design tokens and base styles |
| 2026-01-29 | 2.1 | Completed | Custom Header Component - awaiting review |
| 2026-01-29 | 2.2 | Completed | Feed View - Three-column layout with sidebars |

---

## Implementation Guidelines (CRITICAL - MUST FOLLOW)

### Design Decision Rule: PASTEL COLORS FOR SOOTHING EXPERIENCE

**IMPORTANT:** When making ANY design decision where specific colors are NOT mentioned:

1. **ALWAYS prefer pastel/soft colors** over harsh or saturated colors
2. **Reserve primary red (#FF1844)** ONLY for:
   - Primary CTAs (Sign Up, Post, Join Tribe)
   - Critical actions
   - Brand logo elements
3. **Use pastel palette** for:
   - Background colors and hover states
   - Card accents and borders
   - Badge and tag backgrounds
   - Success/warning/info states
   - Secondary UI elements
   - Tribe category colors

**Goal:** Create a calming, soothing visual experience that doesn't overwhelm users. The interface should feel soft and inviting, not aggressive or harsh.

**Example Decisions:**
- Notification badge background? → Use `$fantribe-pastel-pink` not bright red
- Hover state on card? → Use `$fantribe-pastel-cream` not gray
- Success message? → Use `$fantribe-pastel-mint` background with soft green text
- Tag/label colors? → Use pastels (lavender, peach, sky) not saturated colors
- Empty state illustration? → Use soft pastel tones

---

### Phase-by-Phase Implementation with Review Checkpoints

**IMPORTANT:** Do NOT implement all phases at once. Follow this iterative process:

#### Implementation Flow:
```
Phase N → Implement → Stop → Request Review → Get Approval → Phase N+1
```

#### After Completing Each Phase:

1. **STOP implementation** and notify the user
2. **Summarize what was built:**
   - Files created/modified (with paths)
   - Components implemented
   - Functionality added
   - Any deviations from plan (and why)

3. **Request review of:**
   - **UI Review:** Visual appearance, styling, responsiveness
   - **Functionality Review:** Does it work as expected?
   - **Code Quality:** Clean code, follows conventions
   - **Documentation:** Was it documented properly?

4. **Provide testing instructions:**
   - How to view/test the changes
   - URLs to visit
   - Actions to take
   - Expected behavior

5. **Wait for explicit approval** before proceeding to next phase

#### Review Checkpoint Template:

```markdown
## Phase [N] Complete - Ready for Review

### What Was Built:
- [Component 1]: [Brief description]
- [Component 2]: [Brief description]

### Files Created/Modified:
- `path/to/file1.scss` - [Purpose]
- `path/to/file2.gjs` - [Purpose]

### How to Test:
1. Start the development server: `bin/ember-cli` and `bin/rails s`
2. Visit: http://localhost:4200
3. [Specific testing steps]

### Screenshots/Previews:
[If applicable, describe what should be visible]

### Questions/Decisions Needed:
- [Any decisions that need user input]

### Ready for:
- [ ] UI Review
- [ ] Functionality Review
- [ ] Code Review

**Please review and confirm before I proceed to Phase [N+1].**
```

#### Phase Review Checklist:

| Phase | Key Review Items |
|-------|-----------------|
| **Phase 1: Foundation** | Plugin loads, variables defined, no errors in console |
| **Phase 2.1: Custom Header** | Header displays, navigation works, mobile nav shows on small screens |
| **Phase 2.2: Feed** | Posts display as cards, layout is correct, responsive |
| **Phase 2.3: Post Cards** | Individual posts styled correctly, actions work |
| **Phase 2.4: User Profiles** | Profile page styled, cover photo area, stats display |
| **Phase 2.5: Tribe Pages** | Category pages styled as tribes, header/feed/members tabs |
| **Phase 2.6-2.8: Polish** | Buttons, mobile responsive, glassmorphism effects |
| **Phase 3: Terminology** | All text changed (Categories→Tribes, etc.) |
| **Phase 4: Configuration** | OAuth works, tribes created, profile fields added |
| **Phase 5: Content** | Landing page, legal pages, onboarding flow |
| **Phase 6: Launch Prep** | All tests pass, performance good, security checked |

#### Sub-Phase Reviews (For Complex Phases):

For **Phase 2 (UI Transformation)**, break into sub-reviews:

1. **2.1 Custom Header** → STOP → Review → Approve
2. **2.2 Feed View** → STOP → Review → Approve
3. **2.3 Post Cards** → STOP → Review → Approve
4. **2.4 User Profiles** → STOP → Review → Approve
5. **2.5 Tribe Pages** → STOP → Review → Approve
6. **2.6-2.8 Polish** → STOP → Review → Approve

This ensures each major UI component is reviewed individually.

#### How to Request Changes:

After review, user can respond with:
- **"Approved, proceed to next phase"** → Continue to next phase
- **"Changes needed: [specific feedback]"** → Make changes, then re-request review
- **"Hold, I have questions"** → Answer questions before proceeding

### Error Handling During Implementation:

If errors occur during implementation:
1. Document the error clearly
2. Explain what was attempted
3. Propose solutions
4. Ask for guidance if blocked

**Do NOT silently skip features or make major deviations without user approval.**

---

## Critical Files Reference

**Theme Plugin Core:**
- `plugins/fantribe-theme/plugin.rb` - Main registration
- `plugins/fantribe-theme/config/settings.yml` - Theme settings
- `plugins/fantribe-theme/config/locales/client.en.yml` - Terminology overrides
- `plugins/fantribe-theme/assets/stylesheets/common/variables.scss` - Design system
- `plugins/fantribe-theme/assets/stylesheets/common/base.scss` - Global styles

**Component Styles:**
- `plugins/fantribe-theme/assets/stylesheets/common/components/header.scss`
- `plugins/fantribe-theme/assets/stylesheets/common/components/feed.scss`
- `plugins/fantribe-theme/assets/stylesheets/common/components/post-card.scss`
- `plugins/fantribe-theme/assets/stylesheets/common/components/user-profile.scss`
- `plugins/fantribe-theme/assets/stylesheets/common/components/tribe-page.scss`
- `plugins/fantribe-theme/assets/stylesheets/common/components/buttons.scss`

**JavaScript Customizations:**
- `plugins/fantribe-theme/assets/javascripts/discourse/initializers/fantribe-customizations.js`
- `plugins/fantribe-theme/assets/javascripts/discourse/initializers/fantribe-terminology.js`

**Mobile:**
- `plugins/fantribe-theme/assets/stylesheets/mobile/mobile-overrides.scss`

---

## Verification & Testing

**How to Test Each Phase:**

**Phase 1-2 (Theme):**
```bash
# Start development server
bin/rails server

# Compile assets in dev
bin/ember-cli

# Visit in browser
open http://localhost:3000

# Check:
# - Brand colors visible
# - Outfit font loading
# - Card layouts applied
# - Mobile responsive
```

**Phase 3 (Terminology):**
```bash
# Check translation keys loaded
# Visit various pages and verify:
# - "Categories" → "Tribes"
# - "Topics" → "Posts"
# - "Reply" → "Comment"
```

**Phase 4 (Configuration):**
```bash
# Test OAuth login flows
# Create test tribes
# Test user profile fields
# Send test emails
```

**Phase 5 (Content):**
```bash
# Verify landing page loads
# Check legal pages exist
# Test onboarding flow with new user
```

**Phase 6 (Launch):**
```bash
# Run linting
bin/lint --fix plugins/fantribe-theme/

# Run tests (if written)
bundle exec rspec plugins/fantribe-theme/

# Performance audit
# Run Lighthouse on key pages

# Security scan
bundle audit check
pnpm audit
```

---

## Timeline Summary

| Phase | Duration | Key Deliverable |
|-------|----------|----------------|
| **Phase 1: Foundation** | Week 1 (Days 1-3) | Plugin structure, design system |
| **Phase 2: UI Transformation** | Weeks 1-3 | Social media interface |
| **Phase 3: Terminology** | Weeks 2-3 | Tribes, Posts, Comments |
| **Phase 4: Configuration** | Weeks 3-4 | OAuth, tribes, settings |
| **Phase 5: Content** | Weeks 4-5 | Landing page, legal, seed data |
| **Phase 6: Testing & Launch** | Weeks 5-6 | QA, optimization, launch |
| **Total MVP** | **6 weeks** | Production-ready social platform |

---

## Success Metrics for MVP

**Launch Goals (First 30 Days):**
- 500+ registered users
- 1000+ posts created
- 50+ active tribes
- 80%+ mobile traffic served correctly
- <3s page load time
- >4.5 accessibility score

**Quality Metrics:**
- 0 critical bugs
- <5 support tickets per day
- >90% positive user feedback
- >70% user activation (complete profile + join tribe + make post)

---

## Notes & Considerations

1. **Discourse Version:** Ensure running latest stable (v3.2+)
2. **Ruby Version:** 3.2+
3. **Node Version:** 18+
4. **Database:** PostgreSQL 13+
5. **Redis:** Required for caching
6. **Email Provider:** SendGrid, AWS SES, or similar
7. **Hosting:** DigitalOcean, AWS, or Discourse-managed hosting

**Dependencies:**
- Discourse core (already installed)
- discourse-chat plugin (for messaging)
- discourse-reactions plugin (optional, for emoji reactions)

**Development Conventions (from CLAUDE.md):**
- Use `pnpm` for JavaScript packages
- Use `bundle` for Ruby gems
- Lint all changes: `bin/lint --fix`
- FormKit for forms
- No JSDoc on new code
- Guardian for authorization
- Services for business logic
