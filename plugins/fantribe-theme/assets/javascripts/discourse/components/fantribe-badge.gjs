import Component from "@glimmer/component";

export default class FantribeBadge extends Component {
  get variantClass() {
    const variant = this.args.variant || "neutral";
    const variantMap = {
      community: "fantribe-badge--community",
      action: "fantribe-badge--action",
      commerce: "fantribe-badge--commerce",
      neutral: "fantribe-badge--neutral",
    };
    return variantMap[variant];
  }

  <template>
    <span class="fantribe-badge {{this.variantClass}}">
      {{yield}}
    </span>
  </template>
}
