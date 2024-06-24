import { LightningElement, api } from "lwc";
import basePath from "@salesforce/community/basePath";
import { NavigationMixin } from "lightning/navigation";
import { FlowNavigationNextEvent } from "lightning/flowSupport";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { navigateToWebPage } from "c/mallNavigation";

const NAVIGATE_TO_URL = "navigateToUrl";
const RETURN_LABEL_WHEN_CLICKED = "returnLabelWhenClicked";
const FLOW_NEXT_BUTTON = "flowNextButton";

export default class CmnButton extends NavigationMixin(LightningElement) {
  /* we don't want to let flow devs to select another action than the flow one  so we need a way to detect we are in a flow, which we do thanks to availableActions */
  @api availableActions = [];

  @api action = NAVIGATE_TO_URL;
  @api variant;
  @api destinationUrl;
  @api label = "label";
  @api title = "button";
  @api buttonType = "button";
  @api disabled;
  // buttons seem to come in various predefined widths
  @api wClass;
  @api icon;
  @api responsiveIconState;

  //Adobe tracking attribute variables
  @api interactionIntent;
  @api interactionScope;
  @api interactionType;
  @api interactionText;
  @api interactionTextBefore;
  navigateToWebPage = navigateToWebPage.bind(this);

  get buttonInteractionText() {
    return this.interactionText || this.label;
  }

  get iconStyle() {
    return this.icon ? `background-image: url('${this.icon}');` : "";
  }

  classList = "slds-button slds-button_";

  renderedCallback() {
    addAnalyticsInteractions(this.template);
  }

  connectedCallback() {
    this.classList += this.variant + " " + this.wClass;
    this.icon && this.responsiveIconState
      ? (this.classList += " responsive-icon-button")
      : "";
    // auto-detect flow (if there is not next screen, what's the purpose of a button anyway??)
    if (this.availableActions.find((action) => action === "NEXT"))
      this.action = FLOW_NEXT_BUTTON;
  }

  onClick(event) {
        // window.location.href = window.location.origin + "/mall/s/sign-up";

    switch (this.action) {
      case NAVIGATE_TO_URL:
        if (this.destinationUrl.startsWith("http"))
          this.navigateToWebPage(this.destinationUrl);
        else if (this.destinationUrl.startsWith("/"))
          this.navigateToWebPage(
            document.location.protocol +
              "//" +
              document.location.hostname +
              basePath +
              this.destinationUrl
          );
        else document.location.href = `${basePath}/${this.destinationUrl}`;
        break;
      case RETURN_LABEL_WHEN_CLICKED:
        this.dispatchEvent(new CustomEvent("clicked", { detail: this.label }));
        break;
      case FLOW_NEXT_BUTTON:
        event.preventDefault();
        this.dispatchEvent(new FlowNavigationNextEvent());
        break;
      default:
        break;
    }
  }
  
}

export { NAVIGATE_TO_URL, RETURN_LABEL_WHEN_CLICKED, FLOW_NEXT_BUTTON };