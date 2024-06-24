import { LightningElement, api } from 'lwc';
import STATIC_RESOURCE_URL from '@salesforce/resourceUrl/CMN_BentonSansFont';
import { NAVIGATE_TO_URL } from 'c/cmnButton';
import {
  CAROUSEL_ADDED_EVENT_NAME,
  CAROUSEL_SLIDES_COUNT_EVENT_NAME,
  SLIDE_CHANGED_EVENT_NAME,
  SLIDE_REGISTER_EVENT_NAME,
  CAROUSEL_CAROUSEL_NAME_KEY,
  CAROUSEL_SLIDE_POSITION_KEY,
  CAROUSEL_SLIDE_COUNT_KEY
} from 'c/cmnCarousel';
import { prepareEventPayload, getEventPayload, isInBuilder } from 'c/cmnUtils';

const BASE_CLASS_LIST = "CarouseldSlide ";

export default class ACM_Banner extends LightningElement {
  @api carouselName;
  @api carouselSlidePosition;
  @api buttonLabel;
  @api buttonTitle;
  @api showButton;
  @api variant;
  @api wClass;
  @api content;
  @api heightInPixelsForDesktop;
  @api heightForDesktop;
  @api imagePath;
  @api imagePathTablet;
  @api imagePathMobile;
  @api destinationUrl;
  @api title;
  @api slidesLargestHeight;

  backgroundImage;
  backgroundImageMobile;
  backgroundImageTablet;
  classList;
  currentSlide = 1;
  firstRender = true;
  navigateToUrl = NAVIGATE_TO_URL;
  slidesCount;
  style;
  zIndex;
  show = false;
  isLastSlide = false;
  showBtn = false;
  staticResourceUrlBase = STATIC_RESOURCE_URL.substring(
    0,
    STATIC_RESOURCE_URL.lastIndexOf("/") + 1
  );
  imagesExist=false;
  contentClasses =
    "content-section slds-col slds-size_1-of-1 slds-medium-size_6-of-12 slds-large-size_5-of-12 slds-order_2 slds-medium-order_1 slds-large-order_1 ";

  connectedCallback() {
    // do nothing if in the builder
    if (isInBuilder()) return;

    this.backgroundImage = `/cms/delivery/media/${this.imagePath}`;
    this.backgroundImageTablet = `/cms/delivery/media/${this.imagePathTablet}`;
    this.backgroundImageMobile = `/cms/delivery/media/${this.imagePathMobile}`;

    if (this.buttonLabel) {
      this.showBtn = true;
    }

    // if no carousel show myself and that's it
    if (!this.carouselName) {
      this.showMyself();
      return;
    }

    if (
      this.backgroundImage &&
      this.backgroundImageTablet &&
      this.backgroundImageMobile
    ) {
      this.imagesExist = true;
    }

    // if first slide of a carousel, show thyself
    if (this.carouselSlidePosition === 1) this.showMyself();
    else this.hideMyself();

    // listens to get the slides count
    window.addEventListener(CAROUSEL_SLIDES_COUNT_EVENT_NAME, (event) => {
      const payload = getEventPayload(event);
      if (payload[CAROUSEL_CAROUSEL_NAME_KEY] !== this.carouselName) return;

      this.slidesCount = payload[CAROUSEL_SLIDE_COUNT_KEY];
      // special class to push content after the carousel
      if (this.carouselSlidePosition == this.slidesCount)
        this.isLastSlide = true;
      else this.isLastSlide = false;
    });

    // then ready to self register to the carousel if need be. Custom name to avoid conflicts
    window.addEventListener(CAROUSEL_ADDED_EVENT_NAME, (event) => {
      const payload = getEventPayload(event);
      if (payload[CAROUSEL_CAROUSEL_NAME_KEY] === this.carouselName)
        this.registerToCarousel();
    });

    // register to event to know when to hide or show
    window.addEventListener(SLIDE_CHANGED_EVENT_NAME, (event) => {
      // a bit overkill for a simple value, but kind of a best practice for more complex paylods
      const payload = getEventPayload(event);
      if (payload[CAROUSEL_CAROUSEL_NAME_KEY] !== this.carouselName) return;
      // if the previous current slide was me, I have to move myself behing
      if (this.currentSlide === this.carouselSlidePosition)
        this.moveMyselfBehind();
      this.currentSlide = payload[CAROUSEL_SLIDE_POSITION_KEY];
      // if the new slide to show is me, show myself
      if (this.currentSlide === this.carouselSlidePosition) this.showMyself();
    });

    // in case it was loaded after the carousel sent its event for registration, say it's working
    this.registerToCarousel();
  }

  hideMyself = () => {
    this.classList = BASE_CLASS_LIST + "hidden";
  };

  moveMyselfBehind() {
    // first, just put the slide behind, making the new one fading in nicer
    this.classList = BASE_CLASS_LIST + "behind";
    // then, after the fade is done, hide it properly so that next fade in works
    setTimeout(this.hideMyself, 1000);
  }

  registerToCarousel() {
    let payload = {};
    payload[CAROUSEL_CAROUSEL_NAME_KEY] = this.carouselName;
    payload[CAROUSEL_SLIDE_POSITION_KEY] = this.carouselSlidePosition;

    window.dispatchEvent(
      new CustomEvent(SLIDE_REGISTER_EVENT_NAME, {
        detail: prepareEventPayload(payload)
      })
    );
  }

  setSlideHeights() {
    let height;

    this.template.querySelector(".content-section").classList.add('inTransition');
    height = this.template.querySelector(".Inner-wrapper").offsetHeight;
    this.template.querySelector(".content-section").classList.remove('inTransition');

    window.dispatchEvent(
      new CustomEvent("SetSlideHight", {
        detail: {
          slidePosition: this.carouselSlidePosition,
          slideHeight: height
        }
      })
    );
  }

  renderedCallback() {
    let targetCont = this;

    if (this.firstRender) {
      this.initCSSVariables();
      this.setSlideHeights();

      window.addEventListener("resize", function (e) {
        targetCont.setSlideHeights();
      });

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

  onSlideIconClick = (event) => {
    event.preventDefault();
    this.moveToSlide(parseInt(event.target.getAttribute("data-position")));
    return false;
  };
}