import Component from "@glimmer/component";

const tribes = [
  {
    id: 1,
    title: "Synth Tribe",
    icon: "music",
    description:
      "Talk directly to the team designing the next generation of synthesizers.",
    badges: ["Fan-Led", "Beta Access"],
    gradient: "indigo-purple",
    leader: {
      name: "Elena K.",
      avatar:
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop",
    },
    members: 1240,
  },
  {
    id: 2,
    title: "Guitar Tribe",
    icon: "zap",
    description:
      "Shape the future of electric strings and submit your custom pedal ideas.",
    badges: ["Music"],
    gradient: "purple-pink",
    leader: {
      name: "Jake M.",
      avatar:
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop",
    },
    members: 856,
  },
  {
    id: 3,
    title: "Creator Tools",
    icon: "wrench",
    description:
      "Join live feedback sessions for our new DAW integration plugins.",
    badges: ["Beta Access", "Dev-Talks"],
    gradient: "pink-rose",
    leader: {
      name: "Dev Collective",
      avatar:
        "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=100&h=100&fit=crop",
    },
    members: 2103,
  },
  {
    id: 4,
    title: "Live Sound",
    icon: "radio",
    description:
      "Empower live performances with fan-requested features for stage gear.",
    badges: ["Fan-Led"],
    gradient: "blue-indigo",
    leader: {
      name: "Maria S.",
      avatar:
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
    },
    members: 634,
  },
  {
    id: 5,
    title: "Vocal Lab",
    icon: "mic",
    description:
      "Experiment with new vocal processing chains and share your presets.",
    badges: ["Community"],
    gradient: "rose-pink",
    leader: {
      name: "Chris T.",
      avatar:
        "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
    },
    members: 945,
  },
  {
    id: 6,
    title: "Innovation Hub",
    icon: "users",
    description:
      "A wildcard space for moonshot ideas and experimental music tech.",
    badges: ["Open-Mic", "Brainstorm"],
    gradient: "amber-orange",
    leader: {
      name: "Taylor R.",
      avatar:
        "https://images.unsplash.com/photo-1519626551145-832f0aa4a368?w=100&h=100&fit=crop",
    },
    members: 1567,
  },
];

export default class Tribes extends Component {
  tribes = tribes;

  <template>
    <section class="tribes">
      {{! Background Decorations }}
      <div class="tribes__bg">
        <div class="tribes__bg-circle tribes__bg-circle--left"></div>
        <div class="tribes__bg-circle tribes__bg-circle--right"></div>
      </div>

      <div class="tribes__container">
        {{! Header }}
        <div class="tribes__header">
          <h2 class="tribes__title">Choose Your Tribe</h2>
          <p class="tribes__subtitle">
            Connect directly with empowered micro-ventures, from instruments to
            innovation labs.
          </p>
        </div>

        {{! Grid }}
        <div class="tribes__grid">
          {{#each this.tribes as |tribe|}}
            <div class="tribes__card">
              {{! Icon }}
              <div class="tribes__icon tribes__icon--{{tribe.gradient}}">
                {{#if (this.isIcon tribe.icon "music")}}
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <path d="M9 18V5l12-2v13" />
                    <circle cx="6" cy="18" r="3" />
                    <circle cx="18" cy="16" r="3" />
                  </svg>
                {{/if}}
                {{#if (this.isIcon tribe.icon "zap")}}
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
                  </svg>
                {{/if}}
                {{#if (this.isIcon tribe.icon "wrench")}}
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <path
                      d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"
                    />
                  </svg>
                {{/if}}
                {{#if (this.isIcon tribe.icon "radio")}}
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <circle cx="12" cy="12" r="2" />
                    <path
                      d="M16.24 7.76a6 6 0 0 1 0 8.49m-8.48-.01a6 6 0 0 1 0-8.49m11.31-2.82a10 10 0 0 1 0 14.14m-14.14 0a10 10 0 0 1 0-14.14"
                    />
                  </svg>
                {{/if}}
                {{#if (this.isIcon tribe.icon "mic")}}
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <path
                      d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"
                    />
                    <path d="M19 10v2a7 7 0 0 1-14 0v-2" />
                    <line x1="12" y1="19" x2="12" y2="23" />
                    <line x1="8" y1="23" x2="16" y2="23" />
                  </svg>
                {{/if}}
                {{#if (this.isIcon tribe.icon "users")}}
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                    <circle cx="9" cy="7" r="4" />
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                    <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                  </svg>
                {{/if}}
              </div>

              {{! Badges }}
              <div class="tribes__badges">
                {{#each tribe.badges as |badge|}}
                  <span class="tribes__badge">{{badge}}</span>
                {{/each}}
              </div>

              {{! Title }}
              <h3 class="tribes__card-title">{{tribe.title}}</h3>

              {{! Description }}
              <p class="tribes__card-desc">{{tribe.description}}</p>

              {{! Leader }}
              <div class="tribes__leader">
                <img
                  src={{tribe.leader.avatar}}
                  alt={{tribe.leader.name}}
                  class="tribes__leader-avatar"
                />
                <span class="tribes__leader-name">{{tribe.leader.name}}</span>
              </div>

              {{! Members }}
              <div class="tribes__members">{{tribe.members}} members</div>

              {{! Button }}
              <button type="button" class="tribes__btn">
                Enter Hub
                <svg
                  class="tribes__btn-arrow"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                >
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </button>
            </div>
          {{/each}}
        </div>
      </div>
    </section>

    <style>
      .tribes {
        position: relative;
        width: 100%;
        padding: 48px 0;
        background: white;
        overflow: hidden;
      }

      @media (min-width: 768px) {
        .tribes {
          padding: 96px 0;
        }
      }

      /* Background Decorations */
      .tribes__bg {
        position: absolute;
        inset: 0;
        overflow: hidden;
        pointer-events: none;
      }

      .tribes__bg-circle {
        position: absolute;
        border-radius: 50%;
        filter: blur(64px);
      }

      .tribes__bg-circle--left {
        top: 25%;
        left: 0;
        width: 256px;
        height: 256px;
        background: rgba(255, 229, 236, 0.5);
        transform: translateX(-50%);
      }

      .tribes__bg-circle--right {
        bottom: 25%;
        right: 0;
        width: 384px;
        height: 384px;
        background: rgba(255, 245, 247, 0.5);
        transform: translateX(50%);
      }

      .tribes__container {
        position: relative;
        z-index: 10;
        max-width: 1280px;
        margin: 0 auto;
        padding: 0 16px;
      }

      @media (min-width: 640px) {
        .tribes__container {
          padding: 0 24px;
        }
      }

      @media (min-width: 1024px) {
        .tribes__container {
          padding: 0 32px;
        }
      }

      /* Header */
      .tribes__header {
        text-align: center;
        max-width: 48rem;
        margin: 0 auto 32px;
      }

      @media (min-width: 768px) {
        .tribes__header {
          margin-bottom: 64px;
        }
      }

      .tribes__title {
        font-size: 1.5rem;
        font-weight: 400;
        background: linear-gradient(to right, #ff1744, #b91c1c);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin: 0 0 12px;
      }

      @media (min-width: 768px) {
        .tribes__title {
          font-size: 1.875rem;
          margin-bottom: 16px;
        }
      }

      @media (min-width: 1024px) {
        .tribes__title {
          font-size: 2.25rem;
        }
      }

      .tribes__subtitle {
        font-size: 1rem;
        color: #4b5563;
        line-height: 1.6;
        margin: 0;
      }

      @media (min-width: 768px) {
        .tribes__subtitle {
          font-size: 1.125rem;
        }
      }

      /* Grid */
      .tribes__grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 16px;
      }

      @media (min-width: 640px) {
        .tribes__grid {
          grid-template-columns: repeat(2, 1fr);
        }
      }

      @media (min-width: 1024px) {
        .tribes__grid {
          grid-template-columns: repeat(3, 1fr);
          gap: 32px;
        }
      }

      /* Card */
      .tribes__card {
        position: relative;
        background: rgba(255, 255, 255, 0.5);
        backdrop-filter: blur(8px);
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        padding: 24px;
        transition: all 300ms ease;
        overflow: hidden;
      }

      .tribes__card:hover {
        transform: translateY(-4px);
        border-color: rgba(255, 23, 68, 0.4);
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
      }

      /* Icon */
      .tribes__icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 16px;
        transition: transform 300ms ease;
      }

      .tribes__card:hover .tribes__icon {
        transform: scale(1.1);
      }

      .tribes__icon svg {
        width: 24px;
        height: 24px;
      }

      .tribes__icon--indigo-purple {
        background: linear-gradient(135deg, #e0e7ff 0%, #f3e8ff 100%);
        color: #4f46e5;
      }

      .tribes__icon--purple-pink {
        background: linear-gradient(135deg, #f3e8ff 0%, #fce7f3 100%);
        color: #9333ea;
      }

      .tribes__icon--pink-rose {
        background: linear-gradient(135deg, #fce7f3 0%, #ffe4e6 100%);
        color: #ec4899;
      }

      .tribes__icon--blue-indigo {
        background: linear-gradient(135deg, #dbeafe 0%, #e0e7ff 100%);
        color: #2563eb;
      }

      .tribes__icon--rose-pink {
        background: linear-gradient(135deg, #ffe4e6 0%, #fce7f3 100%);
        color: #f43f5e;
      }

      .tribes__icon--amber-orange {
        background: linear-gradient(135deg, #fef3c7 0%, #ffedd5 100%);
        color: #f59e0b;
      }

      /* Badges */
      .tribes__badges {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 8px;
      }

      .tribes__badge {
        padding: 4px 10px;
        background: #f3f4f6;
        color: #4b5563;
        font-size: 0.75rem;
        font-weight: 500;
        border-radius: 9999px;
        transition: background 200ms ease;
      }

      .tribes__badge:hover {
        background: #e5e7eb;
      }

      /* Card Title */
      .tribes__card-title {
        font-size: 1.25rem;
        font-weight: 600;
        color: #111827;
        margin: 0 0 8px !important;
        transition: color 200ms ease;
      }

      .tribes__card:hover .tribes__card-title {
        color: #ff1744;
      }

      /* Description */
      .tribes__card-desc {
        font-size: 1rem;
        color: #6b7280;
        line-height: 1.5;
        margin: 0 0 16px !important;
      }

      /* Leader */
      .tribes__leader {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 8px;
      }

      .tribes__leader-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        object-fit: cover;
      }

      .tribes__leader-name {
        font-size: 0.875rem;
        color: #6b7280;
      }

      /* Members */
      .tribes__members {
        font-size: 0.875rem;
        color: #6b7280;
        margin-bottom: 16px;
      }

      /* Button */
      .tribes__btn {
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 12px 24px;
        background: #ff1744;
        color: white;
        font-size: 0.9375rem;
        font-weight: 500;
        border: none;
        border-radius: 9999px;
        cursor: pointer;
        transition: all 300ms ease;
      }

      @media (min-width: 768px) {
        .tribes__btn {
          opacity: 0;
          transform: translateY(16px);
        }

        .tribes__card:hover .tribes__btn {
          opacity: 1;
          transform: translateY(0);
        }
      }

      .tribes__btn:hover {
        background: #e6143d;
      }

      .tribes__btn-arrow {
        width: 16px;
        height: 16px;
      }
    </style>
  </template>

  isIcon = (icon, name) => icon === name;
}
