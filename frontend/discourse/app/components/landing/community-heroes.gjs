import Component from "@glimmer/component";

const topContributors = [
  {
    id: 1,
    name: "Maya Rodriguez",
    role: "Community Champion",
    avatar:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop",
    contributions: 247,
    impact: "Led 12 Topics",
    badge: "Top Contributor",
    gradient: "red-coral",
  },
  {
    id: 2,
    name: "Jordan Kim",
    role: "Beta Tester",
    avatar:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop",
    contributions: 189,
    impact: "Tested 23 new features",
    badge: "Early Adopter",
    gradient: "charcoal",
  },
  {
    id: 3,
    name: "Sophia Chen",
    role: "Content Creator",
    avatar:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop",
    contributions: 156,
    impact: "Created 8 tutorials",
    badge: "Creator",
    gradient: "amber-coral",
  },
];

const recentStories = [
  {
    id: 1,
    name: "Alex T.",
    avatar:
      "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
    story:
      "Just finished my first collaboration with the Synth Tribe! Never thought my feedback would make it into the final product. This community is incredible! 🎹",
    timestamp: "2 hours ago",
    likes: 42,
  },
  {
    id: 2,
    name: "Priya M.",
    avatar:
      "https://images.unsplash.com/photo-1519626551145-832f0aa4a368?w=100&h=100&fit=crop",
    story:
      "The live session today with Sarah was amazing. Love how our ideas are actually being heard and implemented. This is what real co-creation looks like!",
    timestamp: "5 hours ago",
    likes: 67,
  },
  {
    id: 3,
    name: "Carlos D.",
    avatar:
      "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=100&h=100&fit=crop",
    story:
      "Earned my first 500 points! The gamification here is fun, but what really keeps me coming back is the genuine connections I've made.",
    timestamp: "1 day ago",
    likes: 38,
  },
];

export default class CommunityHeroes extends Component {
  contributors = topContributors;
  stories = recentStories;

  <template>
    <section class="heroes">
      <div class="heroes__container">
        {{! Header }}
        <div class="heroes__header">
          <div class="heroes__badge">
            <svg
              class="heroes__badge-icon"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            >
              <circle cx="12" cy="8" r="7" />
              <polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88" />
            </svg>
            <span>Community Heroes</span>
          </div>
          <h2 class="heroes__title">Meet the People Shaping MT Fanverse</h2>
          <p class="heroes__subtitle">
            These community members are leading the way. Their contributions
            make this platform what it is.
          </p>
        </div>

        {{! Contributors Grid }}
        <div class="heroes__contributors">
          {{#each this.contributors as |contributor|}}
            <div class="heroes__card">
              <div
                class="heroes__card-banner heroes__card-banner--{{contributor.gradient}}"
              ></div>
              <div class="heroes__card-content">
                <div class="heroes__avatar-wrap">
                  <img
                    src={{contributor.avatar}}
                    alt={{contributor.name}}
                    class="heroes__avatar"
                  />
                </div>
                <span
                  class="heroes__contributor-badge"
                >{{contributor.badge}}</span>
                <h3 class="heroes__name">{{contributor.name}}</h3>
                <p class="heroes__role">{{contributor.role}}</p>

                <div class="heroes__stats">
                  <div class="heroes__stat">
                    <span
                      class="heroes__stat-value"
                    >{{contributor.contributions}}</span>
                    <span class="heroes__stat-label">Contributions</span>
                  </div>
                </div>

                <p class="heroes__impact">
                  <svg
                    class="heroes__impact-icon"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                  >
                    <path
                      d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z"
                    />
                  </svg>
                  {{contributor.impact}}
                </p>
              </div>
            </div>
          {{/each}}
        </div>

        {{! Recent Highlights }}
        <div class="heroes__highlights">
          <h3 class="heroes__section-title">Recent Highlights from the Tribe</h3>
          <div class="heroes__stories">
            {{#each this.stories as |story|}}
              <div class="heroes__story-card">
                <img
                  src={{story.avatar}}
                  alt={{story.name}}
                  class="heroes__story-avatar"
                />
                <div class="heroes__story-content">
                  <div class="heroes__story-header">
                    <span class="heroes__story-name">{{story.name}}</span>
                    <span class="heroes__story-time">{{story.timestamp}}</span>
                  </div>
                  <p class="heroes__story-text">{{story.story}}</p>
                  <div class="heroes__story-likes">
                    <svg
                      class="heroes__heart-icon"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path
                        d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
                      />
                    </svg>
                    <span>{{story.likes}} people resonated with this</span>
                  </div>
                </div>
              </div>
            {{/each}}
          </div>
        </div>
      </div>
    </section>

    <style>
      .heroes {
        width: 100%;
        padding: 48px 0;
        background: linear-gradient(to bottom, #fefcfb, #f8f7f6);
      }

      @media (min-width: 768px) {
        .heroes {
          padding: 96px 0;
        }
      }

      .heroes__container {
        max-width: 1280px;
        margin: 0 auto;
        padding: 0 16px;
      }

      @media (min-width: 640px) {
        .heroes__container {
          padding: 0 24px;
        }
      }

      @media (min-width: 1024px) {
        .heroes__container {
          padding: 0 32px;
        }
      }

      /* Header */
      .heroes__header {
        text-align: center;
        max-width: 48rem;
        margin: 0 auto 64px;
      }

      .heroes__badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: white;
        border: 1px solid #fcd34d;
        border-radius: 9999px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        margin-bottom: 16px;
      }

      .heroes__badge-icon {
        width: 16px;
        height: 16px;
        color: #d97706;
      }

      .heroes__badge span {
        font-size: 0.875rem;
        font-weight: 500;
        color: #78350f;
      }

      .heroes__title {
        font-size: 1.875rem;
        font-weight: 700;
        color: #111827;
        line-height: 1.2;
        margin: 0 0 16px;
      }

      @media (min-width: 640px) {
        .heroes__title {
          font-size: 2.25rem;
        }
      }

      .heroes__subtitle {
        font-size: 1.125rem;
        color: #4b5563;
        line-height: 1.6;
        margin: 0;
      }

      /* Contributors Grid */
      .heroes__contributors {
        display: grid;
        grid-template-columns: 1fr;
        gap: 24px;
        max-width: 56rem;
        margin: 0 auto 64px;
      }

      @media (min-width: 768px) {
        .heroes__contributors {
          grid-template-columns: repeat(3, 1fr);
        }
      }

      .heroes__card {
        position: relative;
        background: white;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        overflow: hidden;
        transition: all 300ms ease;
      }

      .heroes__card:hover {
        border-color: rgba(255, 23, 68, 0.4);
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
      }

      .heroes__card-banner {
        height: 96px;
      }

      .heroes__card-banner--red-coral {
        background: linear-gradient(135deg, #ff1744 0%, #f97316 100%);
      }

      .heroes__card-banner--charcoal {
        background: linear-gradient(135deg, #1a1a1a 0%, #4a4a4a 100%);
      }

      .heroes__card-banner--amber-coral {
        background: linear-gradient(135deg, #f59e0b 0%, #f97316 100%);
      }

      .heroes__card-content {
        padding: 0 24px 24px;
        text-align: center;
        margin-top: -40px;
        position: relative;
      }

      .heroes__avatar-wrap {
        margin-bottom: 12px;
      }

      .heroes__avatar {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        border: 4px solid white;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        object-fit: cover;
      }

      .heroes__contributor-badge {
        display: inline-block;
        padding: 4px 12px;
        background: white;
        border: 1px solid #e8e6e3;
        border-radius: 9999px;
        font-size: 0.75rem;
        font-weight: 500;
        color: #1a1a1a;
        margin-bottom: 8px;
      }

      .heroes__name {
        font-size: 1.125rem;
        font-weight: 700;
        color: #111827;
        margin: 0 0 4px;
      }

      .heroes__role {
        font-size: 0.875rem;
        color: #6b7280;
        margin: 0 0 16px;
      }

      .heroes__stats {
        display: flex;
        justify-content: center;
        padding-top: 12px;
        border-top: 1px solid #e8e6e3;
      }

      .heroes__stat {
        text-align: center;
      }

      .heroes__stat-value {
        display: block;
        font-size: 1.5rem;
        font-weight: 700;
        color: #ff1744;
      }

      .heroes__stat-label {
        font-size: 0.75rem;
        color: #6b7280;
      }

      .heroes__impact {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        font-size: 0.875rem;
        color: #4b5563;
        margin: 12px 0 0;
      }

      .heroes__impact-icon {
        width: 16px;
        height: 16px;
        color: #f59e0b;
      }

      /* Recent Highlights */
      .heroes__highlights {
        max-width: 48rem;
        margin: 0 auto;
      }

      .heroes__section-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: #111827;
        text-align: center;
        margin: 0 0 32px;
      }

      .heroes__stories {
        display: flex;
        flex-direction: column;
        gap: 16px;
      }

      .heroes__story-card {
        display: flex;
        gap: 16px;
        background: white;
        border: 1px solid #e5e7eb;
        border-radius: 12px;
        padding: 20px;
        transition: all 200ms ease;
      }

      .heroes__story-card:hover {
        border-color: rgba(255, 23, 68, 0.4);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
      }

      .heroes__story-avatar {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        object-fit: cover;
        flex-shrink: 0;
      }

      .heroes__story-content {
        flex: 1;
        min-width: 0;
      }

      .heroes__story-header {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 8px;
      }

      .heroes__story-name {
        font-size: 0.9375rem;
        font-weight: 600;
        color: #111827;
      }

      .heroes__story-time {
        font-size: 0.875rem;
        color: #9ca3af;
      }

      .heroes__story-text {
        font-size: 1rem;
        color: #374151;
        line-height: 1.6;
        margin: 0 0 12px !important;
      }

      .heroes__story-likes {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 0.875rem;
        color: #6b7280;
      }

      .heroes__heart-icon {
        width: 16px;
        height: 16px;
        color: #f97316;
      }
    </style>
  </template>
}
