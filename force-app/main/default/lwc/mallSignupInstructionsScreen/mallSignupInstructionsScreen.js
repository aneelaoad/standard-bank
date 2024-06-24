import { LightningElement } from "lwc";
import { NAVIGATE_TO_URL } from "c/cmnButton";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";

export default class MallSignupInstructionsScreen extends LightningElement {
  action = NAVIGATE_TO_URL;
  url = "/mall/services/auth/sso/mall_ping_custom";

  get buttonInteractionScope() {
    return this.interactionScope || "mall sign up";
  }

  get buttonInteractionType() {
    return this.interactionType || "click";
  }

  get buttonInteractionText() {
    return this.interactionText || "Continue";
  }

  get buttonInteractionIntent() {
    return this.interactionIntent || "transactional";
  }

  renderedCallback() {
    addAnalyticsInteractions(this.template);
  }

  handleContinue() {
    putCookie("redirectToSignupPage", false);
    window.location.href = "/mall/services/auth/sso/mall_ping_custom";
  }

  handleCloseModal() {
    const closeModalEvent = new CustomEvent("closemodal", {
      detail: false
    });
    this.dispatchEvent(closeModalEvent);
  }
}