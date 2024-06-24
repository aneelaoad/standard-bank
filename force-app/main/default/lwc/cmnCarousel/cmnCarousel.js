import { LightningElement, api, track } from 'lwc';
import { prepareEventPayload, getEventPayload, isInBuilder } from 'c/cmnUtils';

const CAROUSEL_ADDED_EVENT_NAME = 'carouseladded';
const SLIDE_CHANGED_EVENT_NAME = 'slidechanged';
const SLIDE_REGISTER_EVENT_NAME = 'slideregister';
const CAROUSEL_SLIDES_COUNT_EVENT_NAME = 'carouselslidecount';
const CAROUSEL_CAROUSEL_NAME_KEY = 'carousel-carousel-name-key';
const CAROUSEL_SLIDE_POSITION_KEY = 'carousel-slide-position';
const CAROUSEL_SLIDE_COUNT_KEY = 'carousel-slide-count';

export default class CmnCarousel extends LightningElement {
  @api name;
  @api slideDurationInMilliseconds;

  slidesCount = 0;
  _currentSlide = 1;
  timeOutId;
  @track slides;

  get currentSlide() {
    return this._currentSlide;
  }

  set currentSlide(value) {
    if(this.slides && this.slides[this._currentSlide - 1]) this.slides[this._currentSlide - 1].classList = "indicator";
    this._currentSlide = value;
    if(this.slides && this.slides[this._currentSlide - 1]) this.slides[this._currentSlide - 1].classList = "indicator current";
  }

  buildSlidesList() {
    this.slides = [];
    for(let i = 1; i <= this.slidesCount; i++) {
      this.slides.push({
        'position': i,
        'classList': "indicator" + ((i == this.currentSlide)?" current":"")
      });
    }
  }
  

  currentSlideChange = (event) => {
    const payload = getEventPayload(event);
    if(payload[CAROUSEL_CAROUSEL_NAME_KEY] !== this.name) return;
    this.currentSlide = parseInt(payload[CAROUSEL_SLIDE_POSITION_KEY]);
    this.startSlideshow();
  }

	connectedCallback() {
    // do nothing if in the builder
    if(isInBuilder()) return;

    // listens for new added slides
    window.addEventListener(SLIDE_REGISTER_EVENT_NAME, this.registerSlide);

    // register to event to know when slide changed (to unify treatment of time based and user based change)
    window.addEventListener(SLIDE_CHANGED_EVENT_NAME, this.currentSlideChange);

    let payload = {};
    payload[CAROUSEL_CAROUSEL_NAME_KEY] = this.name;
    // tell everyone this carousel is up and running
    window.dispatchEvent(new CustomEvent(CAROUSEL_ADDED_EVENT_NAME, { detail: prepareEventPayload(payload) }));

    this.startSlideshow();

  }

  moveToNextSlide = () => {
    this.moveToSlide((this.currentSlide % this.slidesCount) + 1);
  }

  moveToSlide(slideNumber) {
    let payload = {};
    payload[CAROUSEL_CAROUSEL_NAME_KEY] = this.name;
    // uses local variable, as the proper currentSlide property will be changed be the event
    payload[CAROUSEL_SLIDE_POSITION_KEY] = slideNumber;
    window.dispatchEvent(new CustomEvent(SLIDE_CHANGED_EVENT_NAME, { detail: prepareEventPayload(payload) }));
  }

  onSlideIconClick = (event) => {
    event.preventDefault();
    this.moveToSlide(parseInt(event.target.getAttribute('data-position')));
    return false;
  }

  registerSlide = (event) => {
    let payload = getEventPayload(event);
    // is this slide for this carousel?
    if(payload[CAROUSEL_CAROUSEL_NAME_KEY] != this.name) return;

    // since we dispatch an event telling slide N to show, we just need to store the total amount of slides
    this.slidesCount = Math.max(payload[CAROUSEL_SLIDE_POSITION_KEY], this.slidesCount);
    this.buildSlidesList();

    // dispatches the count of slides so that slides can display the dotted line, AND the last one can push the content below
    // (slides are positioned absolutely to stack above each other)
    payload = {};
    payload[CAROUSEL_CAROUSEL_NAME_KEY] = this.name;
    payload[CAROUSEL_SLIDE_COUNT_KEY] = this.slidesCount;
    // tell everyone the count of slides
    window.dispatchEvent(new CustomEvent(CAROUSEL_SLIDES_COUNT_EVENT_NAME, { detail: prepareEventPayload(payload) }));

  }

  startSlideshow = () => {
    clearTimeout(this.timeOutId);
    this.timeOutId = setTimeout(this.moveToNextSlide, this.slideDurationInMilliseconds);
  }

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