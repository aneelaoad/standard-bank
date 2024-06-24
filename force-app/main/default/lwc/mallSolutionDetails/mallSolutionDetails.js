import { LightningElement, wire, track } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import getTagsByIds from "@salesforce/apex/MallDataService.getTagsByIdsByContext";
import getOfferingsBySolutionIds from "@salesforce/apex/MallDataService.getOfferingsBySolutionIds";
import IS_GUEST from "@salesforce/user/isGuest";
import {
  publish,
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import USER_LANGUAGE_CHANGED_EVT from "@salesforce/messageChannel/UserLanguageChanged__c";
import MALL_PRE_NAVIGATION_EVT from "@salesforce/messageChannel/PreNavigationModal__c";
import MALL_OFFERING_ITEM_SELECTED from "@salesforce/messageChannel/MallOfferingItemSelected__c";
import { getCookie, putCookie } from "c/cmnCookieUtils";
import { navigateToWebPage } from "c/mallNavigation";
import { mallStateName, getUserState, setUserState } from "c/sbgUserStateUtils";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { createCookie, deleteCookie } from "c/cmnCookieUtils";

const DEFAULT_MALL_COUNTRY = "South Africa";
const DEFAULT_MALL_LANGUAGE_ISO = "en";

export default class MallSolutionDetails extends NavigationMixin(
  LightningElement
) {
  solutionId;
  error;
  products;
  selectedProduct;
  subscription = null;
  subscriptionItemSelected = null;
  navigateToWebPage = navigateToWebPage.bind(this);
  selectedLanguageISOCode = getUserState(
    mallStateName.mallUserSelectedLanguageISOCode,
    DEFAULT_MALL_LANGUAGE_ISO
  );
  userSelectedCountry = getUserState(
    mallStateName.mallUserSelectedCountry,
    DEFAULT_MALL_COUNTRY
  );

  buttonInteractionIntent;
  buttonInteractionScope;
  buttonInteractionType;
  buttonInteractionText;
  buttonInteractionTextBefore;
  @track isShowModal = false;
  productId;

  @track modalConfig = {
    icon: "",
    title: "",
    contentMessage1: "",
    contentMessage2: "",
    buttons: [],
    showCloseButton: true
  };

  cancelNavigation = true;
  solution;
  @track servicesCollection = [];
  trueVal = false;

  setTaggingAttributes(button, type, scope) {
    button.map((item) => {
      this.buttonInteractionIntent = "navigational";
      this.buttonInteractionScope = scope || "test buttonInteractionScope";
      this.buttonInteractionType = "click";
      this.buttonInteractionText =
        item.shopName + " | " + item.title || "test buttonInteractionText";
      this.buttonInteractionTextBefore =
        type || "test buttonInteractionTextBefore";
    });
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    let userSelectedCountry = getUserState(
      mallStateName.mallUserSelectedCountry,
      DEFAULT_MALL_COUNTRY
    );
    let userSelectedLanguageISOCode = getUserState(
      mallStateName.mallUserSelectedLanguageISOCode,
      DEFAULT_MALL_LANGUAGE_ISO
    );
    let params = {};
    params.mallUserSelectedCountry = userSelectedCountry;
    params.mallUserSelectedLanguage = userSelectedLanguageISOCode;
    let mallContext = JSON.stringify(params);

    if (currentPageReference) {
      this.solutionId = currentPageReference?.attributes?.recordId;
      getTagsByIds({ mallContext: mallContext, ids: [this.solutionId] })
        .then((result) => {
          if (result && result.length > 0) {
            this.solution = result[0];
            this.getOfferingsBySolutionIdsProvided(mallContext);
          }
        })
        .catch((error) => {
          this.error = error;
        });
    }
  }

  async getOfferingsBySolutionIdsProvided(mallContext) {
    try {
      let result = await getOfferingsBySolutionIds({
        mallContext: mallContext,
        solutionIds: [this.solutionId],
        recordTypeName: "Service"
      });
      let serviceResult = result.filter(
        (item) => item.offeringType == "Service"
      );
    
      let serviceCollectionObject = {};
      serviceCollectionObject.type = "Offerings";
      serviceCollectionObject.list = [];
      let formattedServices = serviceResult.map((item) => ({
        ...item,
        styleClass:
          item.id == this.productId
            ? "service-item active-service"
            : "service-item",
        url: item.desktopUrl,
        hideModal: true
      }));

      formattedServices = this.sortData("createdDate", "desc", formattedServices, "datetime");
      serviceCollectionObject.list = [...formattedServices];

      this.servicesCollection = [serviceCollectionObject];
      this.products = [...formattedServices];
      if(this.productId) {
        this.selectedProduct = this.products.find((pro) => pro.id == this.productId);
      }
    } catch (error) {
      this.error = error;
    }
  }

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.subscribeToOfferingItemSelectedMessageChannel();
    this.productId = this.getUrlParamValue(window.location.href, "productId");
  }

  renderedCallback() {
    this.publishRedirectModal();
    addAnalyticsInteractions(this.template);
  }

  publishRedirectModal() {
    if (!IS_GUEST && getCookie("navigateToShopAfterLogin") === "true") {
      let navigateToShopUrl = getCookie("navigateToShopUrl");
      deleteCookie("navigateToShopAfterLogin");
      putCookie("navigateToShopUrl", "");
      setTimeout(() => {
        publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {
          targetUrl: navigateToShopUrl,
          storeName: getCookie("shopName")
        });
      }, 4000);
    }
  }

  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }

  setUrlParamValue(url, key, value) {
    return new URL(url).searchParams.set(key, value);
  }

  @wire(MessageContext)
  messageContext;

  handleSelectedOfferingChange(message) {
    let languageISOCode = message.languageISOCode;
    this.selectedLanguageISOCode = languageISOCode;
    setUserState(
      mallStateName.mallUserSelectedLanguageISOCode,
      this.selectedLanguageISOCode
    );
  }

  handleLanguageChange(message) {
    let languageISOCode = message.languageISOCode;
    this.selectedLanguageISOCode = languageISOCode;
    setUserState(
      mallStateName.mallUserSelectedLanguageISOCode,
      this.selectedLanguageISOCode
    );
  }

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        USER_LANGUAGE_CHANGED_EVT,
        (message) => this.handleLanguageChange(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  subscribeToOfferingItemSelectedMessageChannel() {
    if (!this.subscriptionItemSelected) {
      this.subscriptionItemSelected = subscribe(
        this.messageContext,
        MALL_OFFERING_ITEM_SELECTED,
        (message) => this.handleOfferingItemSelected(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  handleOfferingItemSelected(message) {
    this.productSelection(message);
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    unsubscribe(this.subscriptionItemSelected);
    this.subscription = null;
    this.subscriptionItemSelected = null;
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  productSelection(message) {
    this.selectedProduct = this.products.find(
      (pro) => pro.id == message.item.id
    );
    this.products.forEach((prod) => {
      prod.styleClass =
        prod.id == this.selectedProduct.id
          ? "service-item active-service"
          : "service-item";
    });

    this.setUrlParamValue(
      window.location.href,
      "productId",
      this.selectedProduct.id
    );
  }

  sanitizeUrl(url) {
    return url.replace(/[^A-Za-z0-9\/\:\.\-\=\&\#\?\_]/g, "");
  }

  async handleNavigateToProduct(event) {
    event.preventDefault();
    if (IS_GUEST) {
      createCookie("userDesiredPage", window.location.href);
      createCookie("redirectToUserDesiredPage", "true", 3);
      createCookie("shopName", this.selectedProduct.shopName);
      createCookie("redirectToShopPage", "true", 3);
      createCookie("navigateToShopAfterLogin", "true");
      createCookie(
        "navigateToShopUrl",
        this.selectedProduct.desktopUrl,
        3
      );
      publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {});
    } else if (this.selectedProduct && this.selectedProduct.desktopUrl) {
      publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {
        targetUrl: this.selectedProduct.desktopUrl,
        storeName: this.selectedProduct.shopName
      });
    }
  }

  showModalBox() {
    this.isShowModal = true;
  }

  hideModalBox() {
    this.isShowModal = false;
  }

  sortData(fieldName, sortDirection, array, type) {
    let sortResult = [...array];
    let parser = (v) => v;
    if(type==='date' || type==='datetime') {
      parser = (v) => (v && new Date(v));
    }
    let sortMult = sortDirection === 'asc'? 1: -1;
    array = sortResult.sort((a,b) => {
      let a1 = parser(a[fieldName]), b1 = parser(b[fieldName]);
      let r1 = a1 < b1, r2 = a1 === b1;
      return r2? 0: r1? -sortMult: sortMult;
    });
    return array;
  }
}