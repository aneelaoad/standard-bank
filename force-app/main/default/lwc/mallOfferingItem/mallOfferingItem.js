import { LightningElement, api, wire } from "lwc";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import MALL_PRE_NAVIGATION_EVT from "@salesforce/messageChannel/PreNavigationModal__c";
import MALL_OFFERING_ITEM_SELECTED from "@salesforce/messageChannel/MallOfferingItemSelected__c";

import {
  publish,
  MessageContext
} from "lightning/messageService";
import { createCookie } from "c/cmnCookieUtils";
import IS_GUEST from "@salesforce/user/isGuest";
import { NavigationMixin } from "lightning/navigation";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";

const DEFAULT_LABEL = "Apply now";
const NAVIGATE_TO_URL = "navigateToUrl";

export default class MallOfferingItem extends NavigationMixin(LightningElement) {
  @api set item(item) {
    this.itemRecord = item;
    this.buttonLabel = item.buttonLabel ? item.buttonLabel : DEFAULT_LABEL;
  }

  get item() {
    return this.itemRecord;
  }
  itemRecord;
  @api offeringType;
  @api interactionScope;
  @api isBusinessEventItem = false;
  @api isSuccessStory;
  @api isOfferingDetail = false;
  action = NAVIGATE_TO_URL;
  todayDate = new Date();
  currentItemDate;
  showLogoImg = false;
  showPriceBanner = false;

  buttonInteractionIntent;
  buttonInteractionScope;
  buttonInteractionType;
  buttonInteractionText;
  buttonInteractionTextBefore;
  buttonLabel = DEFAULT_LABEL;
  buttonTitle = DEFAULT_LABEL;
  navigateToWebPage = navigateToWebPage.bind(this);

  setTaggingAttributes() {
    let typeVsTaggingAttribute = {
      "Guided Solutions": "data-guided-solution-id",
      "Popular services": "data-service-id",
      "Business Events": "data-event-id",
      Services: "data-service-id"
    };
    let elements = this.template.querySelectorAll('[data-id="link_content"]');
    elements.forEach((item) => {
      let tempElement = item.setAttribute(
        typeVsTaggingAttribute[this.offeringType],
        this.item.taggingTypeId
      );
    });
  }

  @wire(MessageContext)
  messageContext;

  renderedCallback() {
    const productDescriptionsList = this.template.querySelectorAll(
      ".product-description"
    );
    if (this.item && this.isBusinessEventItem) {
      let eventDate = this.item.startDate
        ? new Date(this.item.startDate)
        : this.todayDate;
      this.currentItemDate = `${("0" + eventDate.getDate()).slice(-2)}/${(
        "0" +
        (eventDate.getMonth() + 1)
      ).slice(-2)}/${eventDate.getFullYear()}`;
    }

    if (this.item && this.offeringType && (this.offeringType.toLowerCase().includes("offerings"))) {
      this.showLogoImg = true;
      this.showPriceBanner = true;
    }

    productDescriptionsList.forEach((description) => {
      if (description.scrollHeight > description.offsetHeight) {
        description.style.setProperty("--opacity", 1);
      } else {
        description.style.setProperty("--opacity", 0);
      }
    });
    this.setTaggingAttributes();
    addAnalyticsInteractions(this.template);
  }

  handleItemNavigationApplyNow(event) {
    this.handleItemNavigation(event,"apply-now");
  }

  handleItemNavigationReadMore(event) {
    let targetClick = event.currentTarget.dataset.tile ? event.currentTarget.dataset.tile : "read-more"
    this.handleItemNavigation(event, targetClick);
  }

  handleItemNavigation(event, buttonType) {
    if(this.item && this.offeringType && (this.offeringType.toLowerCase().includes("offerings")) && buttonType == "apply-now" || (this.offeringType && this.offeringType.toLowerCase() == "business events")) {
      event.preventDefault();
      event.stopPropagation();
      if (IS_GUEST) {
        createCookie("userDesiredPage",window.location.href);
        createCookie("redirectToUserDesiredPage",'true',3);
        createCookie("shopName", this.item.shopName);
        createCookie('redirectToShopPage','true',3);
        createCookie("navigateToShopAfterLogin", "true");
        createCookie("navigateToShopUrl", this.item.desktopUrl,3);
        publish(this.messageContext, MALL_PRE_NAVIGATION_EVT,{});
      } else if(this.item && this.item.desktopUrl) {
          publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {"targetUrl" : this.item.desktopUrl , "storeName" : this.item.shopName});
        }
    }
    if(this.offeringType && (this.offeringType.toLowerCase().includes("offerings")) && buttonType == "service") {
      publish(this.messageContext, MALL_OFFERING_ITEM_SELECTED, {"item" : this.item});
      if(!this.isOfferingDetail) {
        this.navigateToWebPage(this.item.readMoreUrl);
      }
    } 
    if((this.item && this.offeringType == "Solutions" ||  this.offeringType == "Success stories") && buttonType == "service") {
      this.navigateToWebPage(this.item.readMoreUrl);
    }
  }

  showModalBox() {
    let paramData = { selectedItem: this.item };
    let ev = new CustomEvent("popup", { detail: paramData });
    this.dispatchEvent(ev);
  }
}