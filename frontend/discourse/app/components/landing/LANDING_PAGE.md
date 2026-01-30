# FanTribe Landing Page

Documentation for the landing page implementation to help set context for future development.

## Overview

The landing page (`/landing`) is a marketing page designed to showcase the FanTribe community platform. It uses full-width sections to create an immersive experience.

## Section Structure

| # | Section | Component | Data Source | Status |
|---|---------|-----------|-------------|--------|
| 1 | Hero | `hero.gjs` | `heroSlides`, `heroAvatars` | Done |
| 2 | Live Right Now | `live-right-now.gjs` | `onlineUsers`, `conversations` | Done |
| 3 | Tribes | `tribes.gjs` | `tribes` | Done |
| 4 | Live Sessions | - | - | Skipped |
| 5 | Real Stories | `real-stories.gjs` | `emotionalStories`, `creatorTestimonials`, `quickTestimonials` | Done |
| 6 | Community Heroes | `community-heroes.gjs` | `topContributors`, `recentStories` | Done |
| 7 | Tribe CTA | `tribe-cta.gjs` | - | Done |
| 8 | Your Adventure | - | - | Skipped |
| 9 | Community Resources | - | - | Skipped |
| 10 | Footer | - | - | Skipped |

## File Structure

```
frontend/discourse/app/
├── components/landing/
│   ├── hero.gjs              # Section 1: Hero carousel
│   ├── live-right-now.gjs    # Section 2: Online activity
│   ├── tribes.gjs            # Section 3: Choose Your Tribe
│   ├── real-stories.gjs      # Section 5: Testimonials & Stories
│   ├── community-heroes.gjs  # Section 6: Meet the People Shaping MT Fanverse
│   ├── tribe-cta.gjs         # Section 7: Your Tribe is Waiting CTA
│   └── LANDING_PAGE.md       # This documentation
├── templates/
│   └── landing.gjs           # Main template
├── routes/
│   └── landing.js            # Route definition
└── lib/
    └── landing-data.js       # Static data for all sections
```

## Styling Conventions

### Full-Width Approach

The landing page uses full-width sections that break out of Discourse's default container constraints:

1. **Template overrides** (`landing.gjs`):
   - `body.landing-page #main-outlet-wrapper { display: block !important; }`
   - `body.landing-page #main-outlet { padding: 0; max-width: none; }`

2. **Theme exclusion** (`themes/horizon/scss/main.scss`):
   - `.landing-page-wrapper` is added to the `:not()` selector to exclude it from `max-width: 1000px`

3. **Section pattern**:
   ```css
   .section-name {
     width: 100%;           /* Full viewport width */
     padding: 64px 0;       /* Vertical spacing */
   }

   .section-name__container {
     max-width: 1280px;     /* Content constraint */
     margin: 0 auto;        /* Center content */
     padding: 0 16px;       /* Horizontal padding */
   }
   ```

### Design System Colors

From `landing-page.scss`:

| Variable | Value | Usage |
|----------|-------|-------|
| `$ft-vibrant-red` | #ff1744 | Primary CTA, accents |
| `$ft-warm-white` | #fefcfb | Background |
| `$ft-soft-stone` | #faf9f8 | Alternate background |
| `$ft-deep-charcoal` | #1a1a1a | Headings |
| `$ft-charcoal-600` | #4a4a4a | Body text |
| `$ft-charcoal-400` | #6b6b6b | Muted text |
| `$ft-pearl-gray` | #e8e6e3 | Borders |
| `$ft-mint` | #10b981 | Online/success indicators |

### Component Naming (BEM)

- Block: `.live-right-now`
- Element: `.live-right-now__container`, `.live-right-now__header`
- Modifier: `.live-right-now__user-card--active`

## Adding New Sections

1. Create component in `frontend/discourse/app/components/landing/`
2. Import data from `landing-data.js`
3. Follow the full-width styling pattern above
4. Add to `landing.gjs` template
5. Update this documentation

## Related Files

- **Route**: `config/routes.rb` - `/landing` route
- **App Route Map**: `frontend/discourse/app/routes/app-route-map.js`
- **Theme Styles**: `themes/horizon/scss/main.scss`
- **Design System**: `app/assets/stylesheets/common/base/landing-page.scss`
