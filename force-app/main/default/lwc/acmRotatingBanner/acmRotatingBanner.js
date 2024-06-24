import { LightningElement, track, wire,api } from "lwc";
import getManagedContentForSite from "@salesforce/apex/ACM_CMSHandler.getManagedContentByContentKeys";
import communityId from "@salesforce/community/Id";
import siteId from '@salesforce/site/Id';
import STATIC_RESOURCE_URL from "@salesforce/resourceUrl/CMN_BentonSansFont";
import { NAVIGATE_TO_URL } from "c/cmnButton";
import basePathName from "@salesforce/community/basePath";
import { prepareEventPayload, getEventPayload, isInBuilder } from "c/cmnUtils";
const CAROUSEL_ADDED_EVENT_NAME = "carouseladded";
const SLIDE_CHANGED_EVENT_NAME = "slidechanged";
const SLIDE_REGISTER_EVENT_NAME = "slideregister";
const CAROUSEL_SLIDES_COUNT_EVENT_NAME = "carouselslidecount";
const CAROUSEL_CAROUSEL_NAME_KEY = "carousel-carousel-name-key";
const CAROUSEL_SLIDE_POSITION_KEY = "carousel-slide-position";
const CAROUSEL_SLIDE_COUNT_KEY = "carousel-slide-count";


export default class ACM_RotatingBanner extends LightningElement {
  cid = communityId;
  sId = siteId;
  @api contentKey;
  @track results = [];
  @api name;
  @api fullWidth;
  @api slideDurationInMilliseconds;
  @track slides = [];
  slidesCount = 0;
  slidesLargestHeight = 0;
  slidesSetHeight = "";
  _currentSlide = 1;
  timeOutId;
  data = [];
  contentDataList = [];
  slideDataList = [];
  isSingleImage = false;
  payload;
  ACM_Slides = [];
  sliderItems = [];
  sliderItem = {};
  navigateToUrl = basePathName + "" + NAVIGATE_TO_URL;
  widthTypeClass = "";
  staticResourceUrlBase = STATIC_RESOURCE_URL.substring(
    0,
    STATIC_RESOURCE_URL.lastIndexOf("/") + 1
  );
  slideHights = [];
  thresholdCount =false;

  @wire(getManagedContentForSite, {
    communityId: "$cid",
    managedContentIds: "$contentKey"
  })
  wiredResults({ data, error }) {
    if (data) {
      this.sliderData = data;
      for (const [key, value] of Object.entries(this.sliderData)) {
        this.payload = { contentKey: key, contentData: value };
        this.payload = this.payload.contentData.contentNodes;
        let i = 0;
        for (const [key2, value2] of Object.entries(this.payload)) {
          if (!key2.includes("header") && key2.includes("image")) {
            this.data[i] = value2.value;
            i++;
          }
        }
        this.formatData(this.data);
      }
    } 
  }

  formatData(dataList) {
    let d = 0;
    getManagedContentForSite({
      communityId: this.cid,
      managedContentIds: dataList
    })
      .then((result) => {
        result.forEach((currentItem) => {
          this.contentDataList[d] = currentItem.contentNodes;
          for (const [key, value] of Object.entries(this.contentDataList[d])) {
            this.sliderItem.position = d + 1;

            if (!key.includes("header") && key.includes("image")) {
              this.sliderItem.image_desktop =
                this.contentDataList[d].image_desktop.contentKey;
              this.sliderItem.image_tablet =
                this.contentDataList[d].image_tablet.contentKey;
              this.sliderItem.image_mobile =
                this.contentDataList[d].image_mobile.contentKey;
            }
            if (key.includes("image_title")) {
              this.sliderItem.title = this.contentDataList[d].image_title.value;
            }
            switch (key) {
              case "content":
                this.sliderItem.content = this.contentDataList[d].content.value;
                break;

              case "buttonLabel":
                if (key.includes("buttonLabel")) {
                  this.sliderItem.buttonLabel =
                    this.contentDataList[d].buttonLabel.value;
                  this.sliderItem.destinationUrl =
                    this.contentDataList[d].destinationUrl.value;
                }
                break;

              default:
                break;
            }
          }
          this.sliderItems[d] = this.sliderItem;
          this.sliderItem = {};
          d++;
        });
        this.initSlider(this.sliderItems);
      })
      .catch((error) => {
      });
  }

  initSlider(arrayList) {
    this.ACM_Slides = arrayList;
    this.slides = this.ACM_Slides;

    if (arrayList.length > 1) {
      this.thresholdCount = true;
      this.startSlideshow();
    }
  }

  get currentSlide() {
    return this._currentSlide;
  }

  set currentSlide(value) {
    if (this.slides && this.slides[this._currentSlide - 1])
      this.slides[this._currentSlide - 1].classList = "indicator";
    this._currentSlide = value;
    if (this.slides && this.slides[this._currentSlide - 1])
      this.slides[this._currentSlide - 1].classList = "indicator current";
  }

  buildSlidesList() {
    this.slides = [];
    for (let i = 1; i <= this.slidesCount; i++) {
      this.slides.push({
        position: i,
        classList: "indicator" + (i == this.currentSlide ? " current" : "")
      });
    }
  }
  currentSlideChange = (event) => {
    const payload = getEventPayload(event);
    if (payload[CAROUSEL_CAROUSEL_NAME_KEY] !== this.name) return;
    this.currentSlide = parseInt(payload[CAROUSEL_SLIDE_POSITION_KEY]);
    this.startSlideshow();
  };

  setSlideHeight(e) {
    let currentLargestHeight = 0;
    this.slideHights[e.detail.slidePosition] = e.detail.slideHeight;

    this.slideHights.forEach((slidH) => {
      if (slidH > currentLargestHeight) {
        currentLargestHeight = slidH;
      }
    });

    this.slidesLargestHeight = currentLargestHeight;
    this.slidesSetHeight = "min-height:" + currentLargestHeight + "px";
  }

  connectedCallback() {
    let targetClass = this;
    // do nothing if in the builder
    if (isInBuilder()) return;
    if (this.fullWidth) {
      this.widthTypeClass = `carousel-wrapper ExtendToFullWidth `;
    } else {
      this.widthTypeClass = `carousel-wrapper`;
    }
    // listens for new added slides
    window.addEventListener(SLIDE_REGISTER_EVENT_NAME, this.registerSlide);

    window.addEventListener("resize", function (e) {

    });

    // Sets the largest height of all slides
    window.addEventListener("SetSlideHight", function (e) {
      targetClass.setSlideHeight(e);
    });

    // register to event to know when slide changed (to unify treatment of time based and user based change)
    window.addEventListener(SLIDE_CHANGED_EVENT_NAME, this.currentSlideChange);

    let payload = {};
    payload[CAROUSEL_CAROUSEL_NAME_KEY] = this.name;

    // tell everyone this carousel is up and running
    window.dispatchEvent(
      new CustomEvent(CAROUSEL_ADDED_EVENT_NAME, {
        detail: prepareEventPayload(payload)
      })
    );
  }

  moveToNextSlide = () => {
    this.moveToSlide((this.currentSlide % this.slidesCount) + 1);
  };

  moveToSlide(slideNumber) {
    let payload = {};
    payload[CAROUSEL_CAROUSEL_NAME_KEY] = this.name;
    // uses local variable, as the proper currentSlide property will be changed be the event
    payload[CAROUSEL_SLIDE_POSITION_KEY] = slideNumber;

    window.dispatchEvent(
      new CustomEvent(SLIDE_CHANGED_EVENT_NAME, {
        detail: prepareEventPayload(payload)
      })
    );
  }

  onSlideIconClick = (event) => {
    event.preventDefault();
    this.moveToSlide(parseInt(event.target.getAttribute("data-position")));
    return false;
  };

  registerSlide = (event) => {
    let payload = getEventPayload(event);

    // is this slide for this carousel?
    if (payload[CAROUSEL_CAROUSEL_NAME_KEY] != this.name) return;

    // since we dispatch an event telling slide N to show, we just need to store the total amount of slides
    this.slidesCount = Math.max(
      payload[CAROUSEL_SLIDE_POSITION_KEY],
      this.slidesCount
    );
    this.buildSlidesList();

    // dispatches the count of slides so that slides can display the dotted line, AND the last one can push the content below
    // (slides are positioned absolutely to stack above each other)
    payload = {};
    payload[CAROUSEL_CAROUSEL_NAME_KEY] = this.name;
    payload[CAROUSEL_SLIDE_COUNT_KEY] = this.slidesCount;
    // tell everyone the count of slides
    window.dispatchEvent(
      new CustomEvent(CAROUSEL_SLIDES_COUNT_EVENT_NAME, {
        detail: prepareEventPayload(payload)
      })
    );
  };

  startSlideshow = () => {
    clearTimeout(this.timeOutId);
    this.timeOutId = setTimeout(
      this.moveToNextSlide,
      this.slideDurationInMilliseconds
    );
  };
}
export {
  CAROUSEL_ADDED_EVENT_NAME,
  CAROUSEL_SLIDES_COUNT_EVENT_NAME,
  SLIDE_CHANGED_EVENT_NAME,
  SLIDE_REGISTER_EVENT_NAME,
  CAROUSEL_CAROUSEL_NAME_KEY,
  CAROUSEL_SLIDE_POSITION_KEY,
  CAROUSEL_SLIDE_COUNT_KEY
}