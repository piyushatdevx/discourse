import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";
import { concat } from "@ember/helper";

export default class FantribeTribeButton extends Component {
  get buttonClasses() {
    const classes = ["fantribe-tribe-button"];
    if (this.args.isSelected) {
      classes.push("fantribe-tribe-button--active");
    }
    return classes.join(" ");
  }

  get topicCount() {
    return this.args.category?.topic_count || 0;
  }

  get topicLabel() {
    return this.topicCount === 1 ? "topic" : "topics";
  }

  <template>
    <button type="button" class={{this.buttonClasses}} {{on "click" @onToggle}}>
      <div class="fantribe-tribe-button__icon">
        {{#if @category.uploaded_logo}}
          <img
            src={{@category.uploaded_logo.url}}
            alt={{@category.name}}
            class="fantribe-tribe-button__icon-img"
          />
        {{else}}
          <span
            class="fantribe-tribe-button__icon-dot"
            style={{concat "background-color: #" @category.color}}
          ></span>
        {{/if}}
      </div>

      <div class="fantribe-tribe-button__info">
        <span class="fantribe-tribe-button__name">{{@category.name}}</span>
        <span class="fantribe-tribe-button__topic-count">
          {{this.topicCount}}
          {{this.topicLabel}}
        </span>
      </div>

      {{#if @category.is_favorite}}
        <span
          class="fantribe-tribe-button__favorite fantribe-tribe-button__favorite--filled"
        >
          {{icon "heart"}}
        </span>
      {{/if}}
    </button>
  </template>
}
