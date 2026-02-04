import Component from "@glimmer/component";

const onlineUsers = [
  {
    id: 1,
    name: "Sarah Chen",
    avatar:
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop",
    status: "Mixing a new track 🎧",
    activity: "In Synth Tribe",
    available: true,
    color: "indigo",
  },
  {
    id: 2,
    name: "Marcus T.",
    avatar:
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop",
    status: "Live in co-creation session",
    activity: "Beta Testing",
    available: false,
    color: "red",
  },
  {
    id: 3,
    name: "Priya K.",
    avatar:
      "https://images.unsplash.com/photo-1519626551145-832f0aa4a368?w=200&h=200&fit=crop",
    status: "Looking for collaborators 🤝",
    activity: "Collab Hub",
    available: true,
    color: "emerald",
  },
  {
    id: 4,
    name: "Alex R.",
    avatar:
      "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=200&h=200&fit=crop",
    status: "Just shared a new preset",
    activity: "Creator Tools",
    available: true,
    color: "purple",
  },
  {
    id: 5,
    name: "Emma W.",
    avatar:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop",
    status: "Hosting Q&A in 10 min",
    activity: "Live Sessions",
    available: false,
    color: "amber",
  },
  {
    id: 6,
    name: "Jordan L.",
    avatar:
      "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=200&h=200&fit=crop",
    status: "Available to chat 💬",
    activity: "Innovation Hub",
    available: true,
    color: "pink",
  },
];

const conversations = [
  {
    id: 1,
    participants: [
      {
        name: "Sarah",
        avatar:
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
      },
      {
        name: "Mike",
        avatar:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop",
      },
    ],
    preview: "Sarah: Have you tried the new reverb preset?",
    typing: "Mike",
    channel: "Synth Tribe",
    timestamp: "Just now",
  },
  {
    id: 2,
    participants: [
      {
        name: "Alex",
        avatar:
          "https://images.unsplash.com/photo-1665396695736-4c1a7eb96597?w=100&h=100&fit=crop",
      },
      {
        name: "Emma",
        avatar:
          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop",
      },
      {
        name: "Jordan",
        avatar:
          "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=100&h=100&fit=crop",
      },
    ],
    preview: "Emma: Let's schedule a collab session!",
    typing: null,
    channel: "Collab Hub",
    timestamp: "2m ago",
    reactions: ["🔥", "✨"],
  },
  {
    id: 3,
    participants: [
      {
        name: "Priya",
        avatar:
          "https://images.unsplash.com/photo-1519626551145-832f0aa4a368?w=100&h=100&fit=crop",
      },
      {
        name: "Carlos",
        avatar:
          "https://images.unsplash.com/photo-1598728637989-9c5de7532584?w=100&h=100&fit=crop",
      },
    ],
    preview: "Carlos: Your feedback really helped shape this 🙏",
    typing: "Priya",
    channel: "Beta Testing",
    timestamp: "5m ago",
  },
];

export default class LiveRightNow extends Component {
  users = onlineUsers;
  conversations = conversations;

  <template>
    <section class="lrn">
      <div class="lrn__container">
        {{! Header }}
        <div class="lrn__header">
          <div class="lrn__badge">
            <span class="lrn__live-dot">
              <span class="lrn__live-ping"></span>
              <span class="lrn__live-solid"></span>
            </span>
            <span>Live Right Now</span>
            <span class="lrn__online-count">2,847 online</span>
          </div>
          <h2 class="lrn__title">
            Real People, Real Conversations,
            <br />
            Happening This Second
          </h2>
          <p class="lrn__subtitle">
            Not screenshots. Not staged. This is what's actually happening right
            now.
          </p>
        </div>

        <div class="lrn__content">
          {{! Who's Here Right Now }}
          <div class="lrn__section">
            <h3 class="lrn__section-title">
              <svg
                class="lrn__section-icon"
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
              Who's Here Right Now
            </h3>

            <div class="lrn__users-grid">
              {{#each this.users as |user|}}
                <div class="lrn__user-card">
                  <div
                    class="lrn__user-indicator lrn__user-indicator--{{user.color}}"
                  >
                    <span class="lrn__user-indicator-ping"></span>
                  </div>

                  <div class="lrn__user-top">
                    <div class="lrn__user-avatar-wrap">
                      <img
                        src={{user.avatar}}
                        alt={{user.name}}
                        class="lrn__user-avatar"
                      />
                    </div>
                    <div class="lrn__user-info">
                      <h4 class="lrn__user-name">{{user.name}}</h4>
                      <p class="lrn__user-status">{{user.status}}</p>
                    </div>
                  </div>

                  {{#if user.available}}
                    <button
                      type="button"
                      class="lrn__user-btn lrn__user-btn--available"
                    >
                      <svg
                        class="lrn__btn-icon"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                      >
                        <path
                          d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
                        />
                      </svg>
                      Say Hi 👋
                    </button>
                  {{else}}
                    <button
                      type="button"
                      class="lrn__user-btn lrn__user-btn--busy"
                      disabled
                    >
                      Busy right now
                    </button>
                  {{/if}}
                </div>
              {{/each}}
            </div>

            <p class="lrn__more-users">
              <strong>2,841 more</strong>
              people are online. Join to see them all!
            </p>
          </div>

          {{! Conversations Happening Now }}
          <div class="lrn__section">
            <h3 class="lrn__section-title">
              <svg
                class="lrn__section-icon"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path
                  d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
                />
              </svg>
              Conversations Happening Now
            </h3>

            <div class="lrn__convos">
              {{#each this.conversations as |convo|}}
                <div class="lrn__convo-card">
                  <div class="lrn__convo-avatars">
                    {{#each convo.participants as |participant|}}
                      <img
                        src={{participant.avatar}}
                        alt={{participant.name}}
                        class="lrn__convo-avatar"
                      />
                    {{/each}}
                    <span class="lrn__convo-live-dot"></span>
                  </div>

                  <div class="lrn__convo-content">
                    <div class="lrn__convo-meta">
                      <span class="lrn__convo-channel">#{{convo.channel}}</span>
                      <span class="lrn__convo-time">{{convo.timestamp}}</span>
                      {{#if convo.reactions}}
                        <div class="lrn__convo-reactions">
                          {{#each convo.reactions as |reaction|}}
                            <span
                              class="lrn__convo-reaction"
                            >{{reaction}}</span>
                          {{/each}}
                        </div>
                      {{/if}}
                    </div>

                    <p class="lrn__convo-preview">{{convo.preview}}</p>

                    {{#if convo.typing}}
                      <div class="lrn__convo-typing">
                        <span class="lrn__typing-dots">
                          <span class="lrn__typing-dot"></span>
                          <span class="lrn__typing-dot"></span>
                          <span class="lrn__typing-dot"></span>
                        </span>
                        <span class="lrn__typing-text">
                          <strong>{{convo.typing}}</strong>
                          is typing...
                        </span>
                      </div>
                    {{/if}}

                    <div class="lrn__convo-participants">
                      <svg
                        class="lrn__participants-icon"
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
                      {{#each convo.participants as |p index|}}
                        {{#if index}},{{/if}}
                        {{p.name}}
                      {{/each}}
                    </div>
                  </div>
                </div>
              {{/each}}
            </div>

            <p class="lrn__join-text">
              Join the conversation—real people are waiting to meet you 💬
            </p>
          </div>
        </div>
      </div>
    </section>

    <style>
      .lrn {
        width: 100%;
        padding: 48px 0 96px;
        background: linear-gradient(
          135deg,
          #ffffff 0%,
          rgba(99, 102, 241, 0.03) 50%,
          rgba(168, 85, 247, 0.03) 100%
        );
      }

      @media (min-width: 768px) {
        .lrn {
          padding: 96px 0;
        }
      }

      .lrn__container {
        max-width: 1280px;
        margin: 0 auto;
        padding: 0 16px;
      }

      @media (min-width: 640px) {
        .lrn__container {
          padding: 0 24px;
        }
      }

      @media (min-width: 1024px) {
        .lrn__container {
          padding: 0 32px;
        }
      }

      /* Header */
      .lrn__header {
        text-align: center;
        margin-bottom: 32px;
      }

      @media (min-width: 768px) {
        .lrn__header {
          margin-bottom: 64px;
        }
      }

      .lrn__badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 6px 16px;
        background: white;
        border: 1px solid rgba(99, 102, 241, 0.2);
        border-radius: 9999px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        margin-bottom: 12px;
      }

      @media (min-width: 768px) {
        .lrn__badge {
          padding: 8px 16px;
          margin-bottom: 16px;
        }
      }

      .lrn__live-dot {
        position: relative;
        display: flex;
        width: 8px;
        height: 8px;
      }

      .lrn__live-ping {
        position: absolute;
        inset: 0;
        border-radius: 50%;
        background: #10b981;
        animation: lrn-ping 1.5s cubic-bezier(0, 0, 0.2, 1) infinite;
      }

      .lrn__live-solid {
        position: relative;
        width: 100%;
        height: 100%;
        border-radius: 50%;
        background: #10b981;
      }

      @keyframes lrn-ping {
        75%,
        100% {
          transform: scale(2);
          opacity: 0;
        }
      }

      .lrn__badge > span:nth-child(2) {
        font-size: 0.75rem;
        font-weight: 500;
        color: #312e81;
      }

      @media (min-width: 768px) {
        .lrn__badge > span:nth-child(2) {
          font-size: 0.875rem;
        }
      }

      .lrn__online-count {
        padding: 2px 8px;
        background: #d1fae5;
        color: #047857;
        font-size: 0.75rem;
        font-weight: 500;
        border-radius: 9999px;
      }

      .lrn__title {
        font-size: 1.5rem;
        font-weight: 400;
        color: #111827;
        line-height: 1.3;
        margin: 0 0 12px;
      }

      @media (min-width: 768px) {
        .lrn__title {
          font-size: 1.875rem;
          margin-bottom: 16px;
        }
      }

      @media (min-width: 1024px) {
        .lrn__title {
          font-size: 2.25rem;
        }
      }

      .lrn__title br {
        display: none;
      }

      @media (min-width: 768px) {
        .lrn__title br {
          display: block;
        }
      }

      .lrn__subtitle {
        display: block;
        width: 100%;
        max-width: 42rem;
        margin: 8px auto !important;
        font-size: 1rem;
        color: #4b5563;
        line-height: 1.6;
        text-align: center;
      }

      @media (min-width: 768px) {
        .lrn__subtitle {
          font-size: 1.125rem;
        }
      }

      /* Content */
      .lrn__content {
        max-width: 72rem;
        margin: 0 auto;
      }

      .lrn__section {
        margin-bottom: 48px;
      }

      @media (min-width: 768px) {
        .lrn__section {
          margin-bottom: 64px;
        }
      }

      .lrn__section:last-child {
        margin-bottom: 0;
      }

      .lrn__section-title {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 1.25rem;
        font-weight: 400;
        color: #111827;
        margin: 0 0 16px !important;
      }

      @media (min-width: 768px) {
        .lrn__section-title {
          font-size: 1.5rem;
          margin-bottom: 24px;
        }
      }

      .lrn__section-icon {
        width: 20px;
        height: 20px;
        color: #6366f1;
      }

      @media (min-width: 768px) {
        .lrn__section-icon {
          width: 24px;
          height: 24px;
        }
      }

      /* Users Grid */
      .lrn__users-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 12px;
      }

      @media (min-width: 640px) {
        .lrn__users-grid {
          grid-template-columns: repeat(2, 1fr);
          gap: 16px;
        }
      }

      @media (min-width: 1024px) {
        .lrn__users-grid {
          grid-template-columns: repeat(3, 1fr);
        }
      }

      .lrn__user-card {
        position: relative;
        background: white;
        border: 1px solid #e5e7eb;
        border-radius: 12px;
        padding: 16px;
        transition: all 200ms ease;
      }

      .lrn__user-card:hover {
        border-color: rgba(255, 23, 68, 0.4);
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
      }

      .lrn__user-indicator {
        position: absolute;
        top: 12px;
        right: 12px;
        width: 12px;
        height: 12px;
        border-radius: 50%;
        box-shadow: 0 0 0 2px white;
      }

      .lrn__user-indicator--indigo {
        background: #6366f1;
      }
      .lrn__user-indicator--red {
        background: #ef4444;
      }
      .lrn__user-indicator--emerald {
        background: #10b981;
      }
      .lrn__user-indicator--purple {
        background: #a855f7;
      }
      .lrn__user-indicator--amber {
        background: #f59e0b;
      }
      .lrn__user-indicator--pink {
        background: #ec4899;
      }

      .lrn__user-indicator-ping {
        position: absolute;
        inset: 0;
        border-radius: 50%;
        background: inherit;
        animation: lrn-ping 1.5s cubic-bezier(0, 0, 0.2, 1) infinite;
      }

      .lrn__user-top {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        margin-bottom: 12px;
      }

      .lrn__user-avatar-wrap {
        flex-shrink: 0;
      }

      .lrn__user-avatar {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        object-fit: cover;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        border: 2px solid white;
      }

      .lrn__user-info {
        flex: 1;
        min-width: 0;
      }

      .lrn__user-name {
        font-size: 0.9375rem;
        font-weight: 600;
        color: #111827;
        margin: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .lrn__user-status {
        font-size: 0.875rem;
        color: #4b5563;
        margin: 2px 0 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .lrn__user-activity {
        display: flex;
        align-items: center;
        gap: 6px;
        margin-bottom: 12px;
      }

      .lrn__activity-icon {
        width: 12px;
        height: 12px;
        color: #6366f1;
      }

      .lrn__user-activity span {
        font-size: 0.75rem;
        color: #6b7280;
      }

      .lrn__user-btn {
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 8px 16px;
        border-radius: 9999px;
        font-size: 0.875rem;
        font-weight: 500;
        cursor: pointer;
        transition: all 200ms ease;
      }

      .lrn__user-btn--available {
        background: transparent;
        color: #ff1744;
        border: 1px solid rgba(255, 23, 68, 0.2);
      }

      .lrn__user-card:hover .lrn__user-btn--available {
        border-color: rgba(255, 23, 68, 0.4);
      }

      .lrn__user-btn--available:hover {
        background: #ff1744;
        color: white;
        border-color: #ff1744;
      }

      .lrn__user-btn--busy {
        background: #f3f4f6;
        color: #9ca3af;
        border: 1px solid transparent;
        cursor: not-allowed;
      }

      .lrn__btn-icon {
        width: 16px;
        height: 16px;
      }

      .lrn__more-users {
        text-align: center;
        font-size: 0.875rem;
        color: #6b7280;
        margin: 24px 0 0 !important;
      }

      .lrn__more-users strong {
        color: #111827;
      }

      /* Conversations */
      .lrn__convos {
        display: flex;
        flex-direction: column;
        gap: 12px;
      }

      @media (min-width: 768px) {
        .lrn__convos {
          gap: 16px;
        }
      }

      .lrn__convo-card {
        display: flex;
        gap: 12px;
        padding: 16px;
        background: linear-gradient(
          135deg,
          white 0%,
          rgba(249, 250, 251, 0.3) 100%
        );
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        transition: all 300ms ease;
      }

      @media (min-width: 768px) {
        .lrn__convo-card {
          gap: 16px;
          padding: 20px;
        }
      }

      .lrn__convo-card:hover {
        border-color: rgba(255, 23, 68, 0.4);
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
        transform: translateY(-4px);
      }

      .lrn__convo-avatars {
        position: relative;
        display: flex;
        flex-shrink: 0;
      }

      .lrn__convo-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        border: 2px solid white;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        margin-left: -8px;
        object-fit: cover;
      }

      @media (min-width: 768px) {
        .lrn__convo-avatar {
          width: 48px;
          height: 48px;
          margin-left: -12px;
        }
      }

      .lrn__convo-avatar:first-child {
        margin-left: 0;
      }

      .lrn__convo-live-dot {
        position: absolute;
        right: -4px;
        width: 14px;
        height: 14px;
        background: #10b981;
        border: 2px solid white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      @media (min-width: 768px) {
        .lrn__convo-live-dot {
          width: 16px;
          height: 16px;
        }
      }

      .lrn__convo-live-dot::after {
        content: "";
        width: 6px;
        height: 6px;
        background: white;
        border-radius: 50%;
        animation: lrn-pulse 2s ease-in-out infinite;
      }

      @keyframes lrn-pulse {
        0%,
        100% {
          opacity: 1;
        }
        50% {
          opacity: 0.5;
        }
      }

      .lrn__convo-content {
        flex: 1;
        min-width: 0;
      }

      .lrn__convo-meta {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
        margin-bottom: 8px;
      }

      .lrn__convo-channel {
        font-size: 0.625rem;
        font-weight: 600;
        color: #6366f1;
        background: rgba(99, 102, 241, 0.1);
        padding: 4px 8px;
        border-radius: 6px;
      }

      @media (min-width: 768px) {
        .lrn__convo-channel {
          font-size: 0.75rem;
        }
      }

      .lrn__convo-time {
        font-size: 0.625rem;
        color: #9ca3af;
      }

      @media (min-width: 768px) {
        .lrn__convo-time {
          font-size: 0.75rem;
        }
      }

      .lrn__convo-reactions {
        display: flex;
        gap: 4px;
        margin-left: auto;
      }

      .lrn__convo-reaction {
        font-size: 0.75rem;
      }

      @media (min-width: 768px) {
        .lrn__convo-reaction {
          font-size: 0.875rem;
        }
      }

      .lrn__convo-preview {
        font-size: 0.875rem;
        color: #374151;
        line-height: 1.5;
        margin: 0 0 8px;
      }

      @media (min-width: 768px) {
        .lrn__convo-preview {
          font-size: 1rem;
        }
      }

      .lrn__convo-typing {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.75rem;
        color: #6b7280;
        margin-bottom: 8px;
      }

      @media (min-width: 768px) {
        .lrn__convo-typing {
          font-size: 0.875rem;
        }
      }

      .lrn__typing-dots {
        display: flex;
        gap: 3px;
      }

      .lrn__typing-dot {
        width: 6px;
        height: 6px;
        background: #818cf8;
        border-radius: 50%;
        animation: lrn-typing 1s ease-in-out infinite;
      }

      @media (min-width: 768px) {
        .lrn__typing-dot {
          width: 8px;
          height: 8px;
        }
      }

      .lrn__typing-dot:nth-child(2) {
        animation-delay: 0.2s;
      }

      .lrn__typing-dot:nth-child(3) {
        animation-delay: 0.4s;
      }

      @keyframes lrn-typing {
        0%,
        100% {
          transform: scale(1);
        }
        50% {
          transform: scale(1.2);
        }
      }

      .lrn__typing-text strong {
        font-weight: 500;
      }

      .lrn__convo-participants {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 0.625rem;
        color: #9ca3af;
      }

      @media (min-width: 768px) {
        .lrn__convo-participants {
          font-size: 0.75rem;
        }
      }

      .lrn__participants-icon {
        width: 12px;
        height: 12px;
      }

      .lrn__join-text {
        text-align: center;
        font-size: 0.75rem;
        font-style: italic;
        color: #6b7280;
        margin: 24px 0 0 !important;
      }

      @media (min-width: 768px) {
        .lrn__join-text {
          font-size: 0.875rem;
          margin-top: 32px;
        }
      }
    </style>
  </template>
}
