import { LightningElement, api, track } from "lwc";
import { RETURN_LABEL_WHEN_CLICKED } from "c/cmnButton";
import { getBaseUrl } from "c/mallNavigation";
let BASE_CLASS_LIST = "hero-banner ";
import { MallTranslationService } from 'c/mallTranslationService';

export default class BcbPlatformHeroBanner extends LightningElement {
  @api carouselName;
  @api carouselSlidePosition;
  @api heading;
  @api subText;

  @api buttonLabel;
  @api buttonTitle;
  @api destinationUrl;

  @api action = RETURN_LABEL_WHEN_CLICKED;
  @api variant;
  @api disabled;
  // buttons seem to come in various predefined widths
  @api wClass;
  @api imagePath;
  @api heroBannerClassConfig;
  @api isImage;
  @api imagePathDesktop;
  @api imagePathTablet;
  @api fullWidth;
  @api showButton;

  @api customBannerStyles;
  @track showSignupInstructions = false;

  backgroundImage;
  classList;
  currentSlide = 1;
  firstRender = true;
  slidesCount;
  style;
  zIndex;

  show = false;
  isLastSlide = false;

  get applyBannerCssClass() {
    if (this.customBannerStyles === true) {
      BASE_CLASS_LIST += " custom-hero-banner";
    }

    if (this.fullWidth) {
      return (BASE_CLASS_LIST += ` ExtendToFullWidth`);
    }

    return BASE_CLASS_LIST;
  }

  //Code to setup the translations for the labels
  tokenVsLabelsObject = {
    "heading": "SBG_HERO_BANNER_HEADING",
    "subText": "SBG_HERO_BANNER_SUBTEXT",
    "buttonLabel": "SIGN_UP_BUTTON_LABEL",
    "buttonTitle": "SIGN_UP_BUTTON_TITLE"
  }

  //get the translated labels
  async getTranslatedLabels() {
    try {
      const translatedLabelsInstance = MallTranslationService.getInstance();
      const translatedLabels = await translatedLabelsInstance.getTranslatedLabels();
      this.setUpTranslatedLabels(translatedLabelsInstance);
    } catch (error) {
        this.error = error;
    }
  }

  // Method to create and setting up labels as properties
  setUpTranslatedLabels(translatedLabelsInstance, translatedLabels) {
    //Add translation for defined tokenVsLabelsObject 
    if(this.tokenVsLabelsObject) {
      for (let property in this.tokenVsLabelsObject) {
        const value = translatedLabelsInstance.getTranslatedLabelByLabelName(this.tokenVsLabelsObject[property], translatedLabels)
        this[property] = value ? value : this[property];
      }
    }
  }


  connectedCallback() {
    // do nothing if in the builder
    this.backgroundImage = `background-image: url(${this.staticResourceUrlBase}${this.imagePath});`;
    this.getTranslatedLabels();
    // if no carousel show myself and that's it
    if (!this.carouselName) {
      this.showMyself();
      return;
    }

    // if first slide of a carousel, show thyself
    if (this.carouselSlidePosition === 1) this.showMyself();
    else this.hideMyself();
  }

  hideMyself = () => {
    this.classList = BASE_CLASS_LIST + "hidden";
  };

  moveMyselfBehind() {
    // move back at the back of the pack
    // first, just put the slide behind, making the new one fading in nicer
    this.classList = BASE_CLASS_LIST + "behind";
    // then, after the fade is done, hide it properly so that next fade in works
  }

  renderedCallback() {
    if (this.firstRender) {
      this.initCSSVariables();
      this.firstRender = false;
    }
  }

  initCSSVariables() {
    let css = document.body.style;
    css.setProperty("--height-in-pixels-for-desktop", this.heightForDesktop);
  }

  showMyself() {
    this.classList = BASE_CLASS_LIST + "visible";
  }

  updateZIndex() {
    this.style = "z-index: " + this.zIndex;
  }

  handleSignup() {
    window.location.href = getBaseUrl() + "/mall/s/sign-up";
  }

  handleCloseSignupInstructions() {
    this.showSignupInstructions = false;
    putCookie("redirectToSignupPage", false);
  }
}