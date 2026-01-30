import Component from "@glimmer/component";

export default class TribeCta extends Component {
  <template>
    <section class="cta">
      <div class="cta__container">
        <div class="cta__box">
          {{! Background Pattern }}
          <div class="cta__pattern"></div>

          {{! Content }}
          <div class="cta__content">
            <div class="cta__badge">
              <span class="cta__badge-emoji">🎉</span>
              <span>Join 241,532 tribe members</span>
            </div>

            <h2 class="cta__title">Your Tribe is Waiting</h2>

            <p class="cta__text">
              Real people. Real conversations. No algorithms deciding what you
              see. Just human connection and co-creation.
            </p>

            <div class="cta__buttons">
              <button type="button" class="cta__btn cta__btn--primary">
                Join the Tribe
                <svg
                  class="cta__btn-arrow"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                >
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </button>
              <button type="button" class="cta__btn cta__btn--secondary">
                Take a Tour First
              </button>
            </div>

            <p class="cta__footer">
              Free to join. No credit card required. Always human-first.
            </p>
          </div>
        </div>
      </div>
    </section>

    <style>
      .cta {
        width: 100%;
        padding: 48px 0;
        background: white;
      }

      @media (min-width: 768px) {
        .cta {
          padding: 96px 0;
        }
      }

      .cta__container {
        max-width: 1280px;
        margin: 0 auto;
        padding: 0 16px;
      }

      @media (min-width: 640px) {
        .cta__container {
          padding: 0 24px;
        }
      }

      @media (min-width: 1024px) {
        .cta__container {
          padding: 0 32px;
        }
      }

      .cta__box {
        position: relative;
        overflow: hidden;
        border-radius: 24px;
        background: linear-gradient(
          135deg,
          #ff1744 0%,
          #dc2626 50%,
          #f97316 100%
        );
        box-shadow:
          0 25px 50px -12px rgba(0, 0, 0, 0.25),
          0 0 0 1px rgba(255, 255, 255, 0.1) inset;
      }

      .cta__pattern {
        position: absolute;
        inset: 0;
        opacity: 0.1;
        background-image: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
        background-size: 30px 30px;
      }

      .cta__content {
        position: relative;
        z-index: 10;
        padding: 48px 24px;
        text-align: center;
        color: white;
      }

      @media (min-width: 768px) {
        .cta__content {
          padding: 80px 64px;
        }
      }

      .cta__badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 8px 16px;
        background: rgba(255, 255, 255, 0.2);
        backdrop-filter: blur(8px);
        border: 1px solid rgba(255, 255, 255, 0.3);
        border-radius: 9999px;
        margin-bottom: 16px;
      }

      @media (min-width: 768px) {
        .cta__badge {
          margin-bottom: 24px;
        }
      }

      .cta__badge-emoji {
        font-size: 1rem;
      }

      .cta__badge span:last-child {
        font-size: 0.875rem;
        font-weight: 500;
      }

      .cta__title {
        font-size: 1.875rem;
        font-weight: 700;
        margin: 0 0 16px;
        line-height: 1.2;
      }

      @media (min-width: 640px) {
        .cta__title {
          font-size: 2.25rem;
        }
      }

      @media (min-width: 768px) {
        .cta__title {
          font-size: 3rem;
          margin-bottom: 24px;
        }
      }

      .cta__text {
        font-size: 1.125rem;
        max-width: 42rem;
        margin: 0 auto 24px !important;
        line-height: 1.6;
        opacity: 0.9;
        color: white !important;
      }

      @media (min-width: 768px) {
        .cta__text {
          font-size: 1.25rem;
          margin-bottom: 32px;
        }
      }

      .cta__buttons {
        display: flex;
        flex-direction: column;
        gap: 12px;
        justify-content: center;
        align-items: center;
      }

      @media (min-width: 640px) {
        .cta__buttons {
          flex-direction: row;
          gap: 16px;
        }
      }

      .cta__btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 12px 24px;
        font-size: 1rem;
        font-weight: 500;
        border-radius: 9999px;
        cursor: pointer;
        transition: all 300ms ease;
        width: 100%;
      }

      @media (min-width: 640px) {
        .cta__btn {
          width: auto;
          padding: 16px 32px;
          font-size: 1.125rem;
        }
      }

      .cta__btn--primary {
        background: white;
        color: #ff1744;
        border: none;
      }

      .cta__btn--primary:hover {
        background: #fefcfb;
        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.2);
        transform: translateY(-2px);
      }

      .cta__btn--secondary {
        background: transparent;
        color: white;
        border: 2px solid white;
        backdrop-filter: blur(4px);
      }

      .cta__btn--secondary:hover {
        background: rgba(255, 255, 255, 0.1);
      }

      .cta__btn-arrow {
        width: 20px;
        height: 20px;
        transition: transform 200ms ease;
      }

      .cta__btn--primary:hover .cta__btn-arrow {
        transform: translateX(4px);
      }

      .cta__footer {
        margin: 24px 0 0 !important;
        font-size: 0.75rem;
        opacity: 0.7;
        color: white !important;
      }

      @media (min-width: 768px) {
        .cta__footer {
          margin-top: 32px;
          font-size: 0.875rem;
        }
      }
    </style>
  </template>
}
