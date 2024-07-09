import { LightningElement, api, track } from "lwc";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { getBaseUrl } from "c/mallNavigation";
import ContainerQuery from "c/mallContainerQuery";
import { putCookie } from "c/cmnCookieUtils";

const BASE_CLASS_LIST = "bg-aurora";
export default class SbgMidPageBanner extends LightningElement {
  @api heading;
  @api description;
  @api subText;

  @api buttonLabel;
  @api buttonTitle;
  @api destinationUrl;

  @api interactionScope;
  @api interactionType;
  @api interactionIntent;
  @api interactionText;
  @api interactionTextBefore;

  @api action;
  @api variant;
  @api disabled;
  @api wClass;

  @api isCarousel;
  @api isHero;

  @api imagePath;
  @api imagePathTablet;
  @api imagePathDesktop;

  @api fullWidth;
  @api showButton;

  @api customBannerStyles;
  @api applyColourContrastInversion;
  @api customBackgroundColour;
  @api enableTitleGradientUnderline;

  @api containerQueryOutput = "";

  runOnce = false;

  bannerBackgroundClassList = "";

  get buttonInteractionScope() {
    return this.interactionScope || "mid page banner";
  }
  get buttonInteractionType() {
    return this.interactionType || "click";
  }
  get buttonInteractionTextBefore() {
    return this.interactionTextBefore || "";
  }
  get buttonInteractionText() {
    return this.interactionText || this.buttonLabel;
  }
  get buttonInteractionIntent() {
    return this.interactionIntent || "Informational";
  }

  @api handleSignUp(e) {
    window.location.href = getBaseUrl() + "/mall/s/sign-up";
  }

  renderedCallback() {
    if (this.isHero) {
      this.bannerBackgroundClassList = BASE_CLASS_LIST;
    } else {
      this.bannerBackgroundClassList = `${BASE_CLASS_LIST} wave-background`;
    }
    if (
      this.template &&
      this.isCarousel !== "true" &&
      this.isCarousel !== true
    ) {
      if (
        this.containerQueryOutput !=
        ContainerQuery.checkContainerBreakpoint(this.template.host, 1268)
      ) {
        this.containerQueryOutput = ContainerQuery.checkContainerBreakpoint(
          this.template.host,
          1268
        );
      }

      if (!this.runOnce) {
        window.addEventListener("resize", () => {
          setTimeout(() => {
            this.containerQueryOutput = ContainerQuery.checkContainerBreakpoint(
              this.template.host,
              1268
            );
          });
        });
        this.runOnce = true;
      }
    }
    setTimeout(() => {
      addAnalyticsInteractions(this.template);
    }, 1000);
  }
}