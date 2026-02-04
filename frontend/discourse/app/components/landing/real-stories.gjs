import Component from "@glimmer/component";

const emotionalStories = [
  {
    id: 1,
    name: "Jamie Chen",
    location: "Seattle, WA",
    avatar:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop",
    story:
      "I spent years making music alone in my bedroom, convinced nobody would care. Got my first audio interface and finally had the guts to record something. Then I joined MT Fanverse. Sarah heard my first demo and messaged me at 2am saying it made her cry. We've been collaborating ever since. I'm not alone anymore.",
    emotion: "🥹",
    impact: "Found my first collaborator",
    memberSince: "3 months ago",
  },
  {
    id: 2,
    name: "Maria Rodriguez",
    location: "Austin, TX",
    avatar:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop",
    story:
      "As a woman in audio engineering, I always felt like I had to prove myself. Here? People just... listen. My feedback on the new compressor plugin actually made it into the final product. I cried when I saw my name in the credits. I matter here.",
    emotion: "💜",
    impact: "Changed a real product",
    memberSince: "8 months ago",
  },
  {
    id: 3,
    name: "Kwame Osei",
    location: "Lagos, Nigeria",
    avatar:
      "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=200&h=200&fit=crop",
    story:
      "Internet is expensive here. I can't afford most DAWs. The Dev Tribe built a lightweight plugin JUST for creators in low-bandwidth areas. They asked ME what I needed. First time I've ever felt seen by a tech company.",
    emotion: "🙏",
    impact: "Got tools that actually work for him",
    memberSince: "5 months ago",
  },
  {
    id: 4,
    name: "Alex Kim",
    location: "Toronto, Canada",
    avatar:
      "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=200&h=200&fit=crop",
    story:
      "Depression made me stop creating for 2 years. Joined a live session on a whim. Marcus said 'Hey Alex, glad you're here.' That's it. Five words. But they were real. Bought a cheap interface the next day and started recording again. Sometimes all you need is someone to notice you exist.",
    emotion: "❤️",
    impact: "Found his spark again",
    memberSince: "2 months ago",
  },
  {
    id: 5,
    name: "Sophia Martinez",
    location: "Barcelona, Spain",
    avatar:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop",
    story:
      "My daughter asked why I never pursued music. Didn't have an answer. Found this community, shared my first track at 43 years old. The support was overwhelming. Now she sees me creating every weekend. Teaching her it's never too late to chase dreams.",
    emotion: "✨",
    impact: "Inspiring the next generation",
    memberSince: "6 months ago",
  },
  {
    id: 6,
    name: "Jordan Taylor",
    location: "London, UK",
    avatar:
      "https://images.unsplash.com/photo-1519626551145-832f0aa4a368?w=200&h=200&fit=crop",
    story:
      "Non-binary creator. Constantly misgendered on other platforms. Here, people just... get it. My pronouns are respected. My voice is heard. I can just be myself and make music. That shouldn't be revolutionary, but it feels like it.",
    emotion: "🌈",
    impact: "Found acceptance",
    memberSince: "4 months ago",
  },
];

const creatorTestimonials = [
  {
    name: "Marcus Chen",
    role: "Bedroom Producer",
    image:
      "https://images.unsplash.com/photo-1760780567530-389d8a3fba75?w=600&h=400&fit=crop",
    quote:
      "MT Fanverse gave me the confidence to share my unfinished tracks. Now I'm collaborating with artists I've admired for years. It's not just a platform; it's a family.",
    tags: ["First-Time Creator", "Electronic"],
  },
  {
    name: "Elena Rodriguez",
    role: "Touring DJ",
    image:
      "https://images.unsplash.com/photo-1763630051876-928346788268?w=600&h=400&fit=crop",
    quote:
      "Connecting with fans on a personal level has changed how I perform. I see the faces from the Tribe in the crowd and it fuels my energy.",
    tags: ["Professional", "Live"],
  },
  {
    name: "David Okonjo",
    role: "Music Educator",
    image:
      "https://images.unsplash.com/photo-1691333940510-7286846c5342?w=600&h=400&fit=crop",
    quote:
      "The educational resources and community support here are unmatched. My students are finding their unique sounds faster than ever.",
    tags: ["Mentor", "Community Leader"],
  },
];

const quickTestimonials = [
  {
    name: "Sarah Johnson",
    role: "Music Enthusiast",
    content:
      "FanTribe has completely transformed how I connect with other fans. The community is amazing!",
    rating: 5,
    avatar:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop",
  },
  {
    name: "Michael Chen",
    role: "Audio Engineer",
    content:
      "The real-time updates and collaboration features are incredible. I never miss a moment.",
    rating: 5,
    avatar:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop",
  },
  {
    name: "Emma Davis",
    role: "Community Leader",
    content:
      "Building my own community was so easy. The tools are intuitive and the engagement phenomenal!",
    rating: 5,
    avatar:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop",
  },
];

export default class RealStories extends Component {
  stories = emotionalStories;
  creators = creatorTestimonials;
  testimonials = quickTestimonials;

  <template>
    <section class="stories">
      <div class="stories__container">
        {{! Header }}
        <div class="stories__header">
          <div class="stories__badge">
            <svg
              class="stories__badge-icon"
              viewBox="0 0 24 24"
              fill="currentColor"
            >
              <path
                d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
              />
            </svg>
            <span>Real People, Real Impact</span>
          </div>
          <h2 class="stories__title">
            These Aren't Testimonials—
            <br />
            They're Human Experiences
          </h2>
          <p class="stories__subtitle">
            Unedited, unfiltered, and 100% real. This is what community actually
            feels like.
          </p>
        </div>

        {{! Emotional Stories Grid }}
        <div class="stories__grid">
          {{#each this.stories as |story|}}
            <div class="stories__card">
              <div class="stories__card-header">
                <div class="stories__avatar-wrap">
                  <img
                    src={{story.avatar}}
                    alt={{story.name}}
                    class="stories__avatar"
                  />
                  <span class="stories__emotion">{{story.emotion}}</span>
                </div>
                <div class="stories__meta">
                  <h3 class="stories__name">{{story.name}}</h3>
                  <div class="stories__location">
                    <svg
                      class="stories__location-icon"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                    >
                      <path
                        d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"
                      />
                      <circle cx="12" cy="10" r="3" />
                    </svg>
                    {{story.location}}
                  </div>
                  <p class="stories__member-since">
                    Member since
                    {{story.memberSince}}
                  </p>
                </div>
                <svg
                  class="stories__quote-icon"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path
                    d="M6 17h3l2-4V7H5v6h3zm8 0h3l2-4V7h-6v6h3z"
                    opacity="0.3"
                  />
                </svg>
              </div>

              <div class="stories__story">
                <p>"{{story.story}}"</p>
              </div>

              <div class="stories__impact">
                <span class="stories__impact-badge">
                  💫
                  {{story.impact}}
                </span>
              </div>
            </div>
          {{/each}}
        </div>

        {{! Creator Testimonials }}
        <div class="stories__creators">
          <h3 class="stories__section-title">From the Creator Community</h3>
          <div class="stories__creators-grid">
            {{#each this.creators as |creator|}}
              <div class="stories__creator-card">
                <div class="stories__creator-image">
                  <img src={{creator.image}} alt={{creator.name}} />
                  <div class="stories__creator-overlay"></div>
                  <div class="stories__creator-info">
                    <h4>{{creator.name}}</h4>
                    <p>{{creator.role}}</p>
                  </div>
                </div>
                <div class="stories__creator-content">
                  <svg
                    class="stories__creator-quote"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                  >
                    <path
                      d="M6 17h3l2-4V7H5v6h3zm8 0h3l2-4V7h-6v6h3z"
                      opacity="0.2"
                    />
                  </svg>
                  <p>"{{creator.quote}}"</p>
                  <div class="stories__creator-tags">
                    {{#each creator.tags as |tag|}}
                      <span class="stories__tag">{{tag}}</span>
                    {{/each}}
                  </div>
                </div>
              </div>
            {{/each}}
          </div>
        </div>

        {{! Quick Testimonials }}
        <div class="stories__testimonials">
          <div class="stories__community-image">
            <img
              src="https://images.unsplash.com/photo-1543069752-7148d755b347?w=1200&h=600&fit=crop"
              alt="Community gathering"
            />
          </div>

          <div class="stories__testimonials-grid">
            {{#each this.testimonials as |testimonial|}}
              <div class="stories__testimonial-card">
                <div class="stories__stars">
                  {{#each (Array 5) as |_|}}
                    <svg
                      class="stories__star"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path
                        d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                      />
                    </svg>
                  {{/each}}
                </div>
                <p class="stories__testimonial-text">{{testimonial.content}}</p>
                <div class="stories__testimonial-author">
                  <img
                    src={{testimonial.avatar}}
                    alt={{testimonial.name}}
                    class="stories__testimonial-avatar"
                  />
                  <div>
                    <div class="stories__testimonial-name">
                      {{testimonial.name}}
                    </div>
                    <div class="stories__testimonial-role">
                      {{testimonial.role}}
                    </div>
                  </div>
                </div>
              </div>
            {{/each}}
          </div>
        </div>

        {{! Bottom CTA }}
        <div class="stories__cta">
          <div class="stories__cta-box">
            <p class="stories__cta-title">Your story could be next.</p>
            <p class="stories__cta-text">
              Real people. Real connections. Real impact. This is what we're
              building together.
            </p>
            <div class="stories__cta-stat">
              <svg
                class="stories__cta-heart"
                viewBox="0 0 24 24"
                fill="currentColor"
              >
                <path
                  d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
                />
              </svg>
              <span>241,532 people have found their tribe</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <style>
      .stories {
        width: 100%;
        padding: 48px 0;
        background: #f9fafb;
      }

      @media (min-width: 768px) {
        .stories {
          padding: 96px 0;
        }
      }

      .stories__container {
        max-width: 1280px;
        margin: 0 auto;
        padding: 0 16px;
      }

      @media (min-width: 640px) {
        .stories__container {
          padding: 0 24px;
        }
      }

      @media (min-width: 1024px) {
        .stories__container {
          padding: 0 32px;
        }
      }

      /* Header */
      .stories__header {
        text-align: center;
        max-width: 48rem;
        margin: 0 auto 64px;
      }

      .stories__badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: white;
        border: 1px solid #e5e7eb;
        border-radius: 9999px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        margin-bottom: 16px;
      }

      .stories__badge-icon {
        width: 16px;
        height: 16px;
        color: #f43f5e;
      }

      .stories__badge span {
        font-size: 0.875rem;
        font-weight: 500;
        color: #111827;
      }

      .stories__title {
        font-size: 1.875rem;
        font-weight: 700;
        color: #111827;
        line-height: 1.2;
        margin: 0 0 16px;
      }

      @media (min-width: 640px) {
        .stories__title {
          font-size: 2.25rem;
        }
      }

      .stories__title br {
        display: none;
      }

      @media (min-width: 640px) {
        .stories__title br {
          display: block;
        }
      }

      .stories__subtitle {
        font-size: 1.125rem;
        color: #4b5563;
        line-height: 1.6;
        margin: 0;
      }

      /* Stories Grid */
      .stories__grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 32px;
        max-width: 72rem;
        margin: 0 auto 80px;
      }

      @media (min-width: 768px) {
        .stories__grid {
          grid-template-columns: repeat(2, 1fr);
        }
      }

      .stories__card {
        display: flex;
        flex-direction: column;
        height: 100%;
        background: white;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        padding: 24px;
        transition: all 300ms ease;
      }

      @media (min-width: 640px) {
        .stories__card {
          padding: 32px;
        }
      }

      .stories__card:hover {
        border-color: rgba(255, 23, 68, 0.4);
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
      }

      .stories__card-header {
        display: flex;
        align-items: flex-start;
        gap: 16px;
        margin-bottom: 16px;
      }

      .stories__avatar-wrap {
        position: relative;
        flex-shrink: 0;
      }

      .stories__avatar {
        width: 56px;
        height: 56px;
        border-radius: 50%;
        object-fit: cover;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }

      .stories__emotion {
        position: absolute;
        bottom: -4px;
        right: -4px;
        font-size: 1.5rem;
      }

      .stories__meta {
        flex: 1;
        min-width: 0;
      }

      .stories__name {
        font-size: 1.125rem;
        font-weight: 600;
        color: #111827;
        margin: 0 0 4px;
      }

      .stories__location {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 0.875rem;
        color: #6b7280;
      }

      .stories__location-icon {
        width: 12px;
        height: 12px;
      }

      .stories__member-since {
        font-size: 0.75rem;
        color: #9ca3af;
        margin: 4px 0 0;
      }

      .stories__quote-icon {
        width: 32px;
        height: 32px;
        color: #e5e7eb;
        flex-shrink: 0;
      }

      .stories__story {
        flex: 1;
        margin-bottom: 16px;
      }

      .stories__story p {
        font-size: 1rem;
        font-style: italic;
        color: #374151;
        line-height: 1.7;
        margin: 0;
      }

      .stories__impact {
        padding-top: 16px;
        border-top: 1px solid #f3f4f6;
        margin-top: auto;
      }

      .stories__impact-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 12px;
        background: #f9fafb;
        border-radius: 8px;
        font-size: 0.75rem;
        font-weight: 600;
        color: #374151;
      }

      /* Creator Testimonials */
      .stories__creators {
        margin-bottom: 80px;
      }

      .stories__section-title {
        font-size: 1.5rem;
        font-weight: 400;
        color: #111827;
        text-align: center;
        margin: 0 0 40px !important;
      }

      .stories__creators-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 24px;
        max-width: 72rem;
        margin: 0 auto;
      }

      @media (min-width: 768px) {
        .stories__creators-grid {
          grid-template-columns: repeat(3, 1fr);
        }
      }

      .stories__creator-card {
        background: white;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        overflow: hidden;
        transition: all 300ms ease;
      }

      .stories__creator-card:hover {
        border-color: rgba(255, 23, 68, 0.4);
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
        transform: translateY(-4px);
      }

      .stories__creator-image {
        position: relative;
        height: 192px;
        overflow: hidden;
      }

      .stories__creator-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }

      .stories__creator-overlay {
        position: absolute;
        inset: 0;
        background: linear-gradient(to top, rgba(0, 0, 0, 0.6), transparent);
      }

      .stories__creator-info {
        position: absolute;
        bottom: 12px;
        left: 12px;
        right: 12px;
      }

      .stories__creator-info h4 {
        font-size: 1rem;
        font-weight: 600;
        color: white;
        margin: 0;
      }

      .stories__creator-info p {
        font-size: 0.875rem;
        color: #d1d5db;
        margin: 0;
      }

      .stories__creator-content {
        padding: 24px;
      }

      .stories__creator-quote {
        width: 24px;
        height: 24px;
        color: #e5e7eb;
        margin-bottom: 12px;
      }

      .stories__creator-content > p {
        font-size: 1rem;
        font-style: italic;
        color: #374151;
        line-height: 1.6;
        margin: 0 0 16px;
      }

      .stories__creator-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
      }

      .stories__tag {
        padding: 4px 10px;
        background: #f3f4f6;
        color: #374151;
        font-size: 0.75rem;
        font-weight: 500;
        border-radius: 9999px;
      }

      /* Quick Testimonials */
      .stories__testimonials {
        margin-bottom: 64px;
      }

      .stories__community-image {
        max-width: 56rem;
        margin: 0 auto 48px;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
      }

      .stories__community-image img {
        width: 100%;
        height: 400px;
        object-fit: cover;
      }

      .stories__testimonials-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 24px;
        max-width: 72rem;
        margin: 0 auto;
      }

      @media (min-width: 768px) {
        .stories__testimonials-grid {
          grid-template-columns: repeat(3, 1fr);
        }
      }

      .stories__testimonial-card {
        background: white;
        border: 1px solid #f3f4f6;
        border-radius: 12px;
        padding: 32px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        transition: all 200ms ease;
      }

      .stories__testimonial-card:hover {
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
      }

      .stories__stars {
        display: flex;
        gap: 4px;
        margin-bottom: 16px;
      }

      .stories__star {
        width: 16px;
        height: 16px;
        color: #fbbf24;
      }

      .stories__testimonial-text {
        font-size: 1rem;
        color: #374151;
        line-height: 1.6;
        margin: 0 0 24px !important;
      }

      .stories__testimonial-author {
        display: flex;
        align-items: center;
        gap: 12px;
      }

      .stories__testimonial-avatar {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        object-fit: cover;
      }

      .stories__testimonial-name {
        font-size: 0.9375rem;
        font-weight: 600;
        color: #111827;
      }

      .stories__testimonial-role {
        font-size: 0.875rem;
        color: #6b7280;
      }

      /* CTA */
      .stories__cta {
        text-align: center;
        margin-top: 64px;
      }

      .stories__cta-box {
        display: inline-block;
        max-width: 32rem;
        padding: 24px;
        background: white;
        border: 2px solid #e0e7ff;
        border-radius: 16px;
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
      }

      .stories__cta-title {
        font-size: 1.25rem;
        font-weight: 700;
        color: #111827;
        margin: 0 0 8px;
      }

      .stories__cta-text {
        font-size: 1rem;
        color: #4b5563;
        margin: 0 0 16px;
      }

      .stories__cta-stat {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        font-size: 0.875rem;
        color: #6b7280;
      }

      .stories__cta-heart {
        width: 16px;
        height: 16px;
        color: #f43f5e;
      }
    </style>
  </template>
}
