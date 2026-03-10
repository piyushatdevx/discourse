import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { i18n } from "discourse-i18n";
import ftIcon from "../helpers/ft-icon";

export default class FantribeGearPill extends Component {
  @tracked isHovered = false;

  @action
  handleMouseEnter() {
    this.isHovered = true;
  }

  @action
  handleMouseLeave() {
    this.isHovered = false;
  }

  <template>
    <div class="fantribe-gear-pill">
      <button
        type="button"
        class="fantribe-gear-pill__button"
        {{on "mouseenter" this.handleMouseEnter}}
        {{on "mouseleave" this.handleMouseLeave}}
      >
        {{ftIcon "tag"}}
        <span>{{@gearName}}</span>
      </button>

      {{#if this.isHovered}}
        <div
          class="fantribe-gear-pill__card"
          {{on "mouseenter" this.handleMouseEnter}}
          {{on "mouseleave" this.handleMouseLeave}}
        >
          <div class="fantribe-gear-pill__card-content">
            {{! Product Image }}
            <div class="fantribe-gear-pill__card-image">
              {{#if @gearImage}}
                <img src={{@gearImage}} alt={{@gearName}} />
              {{else}}
                {{ftIcon "tag"}}
              {{/if}}
            </div>

            {{! Product Info }}
            <div class="fantribe-gear-pill__card-info">
              <div class="fantribe-gear-pill__card-header">
                <h4>{{@gearName}}</h4>
                {{ftIcon "external-link"}}
              </div>

              {{#if @gearCategory}}
                <p
                  class="fantribe-gear-pill__card-category"
                >{{@gearCategory}}</p>
              {{/if}}

              {{#if @gearPrice}}
                <p class="fantribe-gear-pill__card-price">{{@gearPrice}}</p>
              {{/if}}

              <button type="button" class="fantribe-gear-pill__card-cta">
                {{i18n "fantribe.gear_pill.view_product"}}
              </button>
            </div>
          </div>

          {{! Quick Stats }}
          <div class="fantribe-gear-pill__card-stats">
            <span>{{i18n "fantribe.gear_pill.used_by_creators"}}</span>
            <span class="fantribe-gear-pill__card-stock">{{i18n
                "fantribe.gear_pill.in_stock"
              }}</span>
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
