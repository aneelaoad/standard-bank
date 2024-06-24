/*
  @Name of the Class  :Unknown
  @Description        :Unknown
  @Author             :Unknown
  @Created Date       :Unknown
  ***************************************************************************************
  @Last Modified By         : Emmanuel Mulea
  @Last Modified On         : 09 May 2024
  @Modification description : SFP-38411 Hero Banner for marketplace site 
  ***************************************************************************************  
*/
import { LightningElement, api } from "lwc";
import { NAVIGATE_TO_URL } from "c/cmnButton";

const BASE_CLASS_LIST = "hero-banner ";

export default class SbgHeroBanner extends LightningElement {
  @api carouselName;
  @api carouselSlidePosition;
  @api heading;
  @api subText;

  @api buttonLabel;
  @api buttonTitle;
  @api destinationUrl;

  @api action = NAVIGATE_TO_URL;
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
  backgroundImage;
  classList;
  currentSlide = 1;
  firstRender = true;
  navigateToUrl = NAVIGATE_TO_URL;
  slidesCount;
  style;
  zIndex;

  show = false;
  isLastSlide = false;

  connectedCallback() {
    // do nothing if in the builder
    this.backgroundImage = `background-image: url(${this.staticResourceUrlBase}${this.imagePath});`;

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

  get getWidth(){
    if (this.fullWidth) {
      return `hero-banner ExtendToFullWidth`;
    }
    return `hero-banner`;
  }

}