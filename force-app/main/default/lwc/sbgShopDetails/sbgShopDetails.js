import { LightningElement, wire, track } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import getShopsByIds from "@salesforce/apex/MallDataService.getShopsByIds";
import getProductsByShopIds from "@salesforce/apex/MallDataService.getProductsByShopIds";
import CLIENT_FORM_FACTOR from "@salesforce/client/formFactor";
import IS_GUEST from "@salesforce/user/isGuest";
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import setSessionVars from "@salesforce/apex/MallProductRangeItemController.setSessionVariables";
import Mall_Ping_Provider_SSO_URL from "@salesforce/label/c.Mall_Ping_Provider_SSO_URL";
import {
  publish,
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import USER_LANGUAGE_CHANGED_EVT from "@salesforce/messageChannel/UserLanguageChanged__c";
import MALL_PRE_NAVIGATION_EVT from "@salesforce/messageChannel/PreNavigationModal__c";
import { getCookie, putCookie } from "c/cmnCookieUtils";
import { navigateToWebPage } from "c/mallNavigation";
import { mallStateName, getUserState, setUserState } from "c/sbgUserStateUtils";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { getBaseUrl } from "c/mallNavigation";


const DEFAULT_MALL_COUNTRY = "South Africa";
const DEFAULT_MALL_LANGUAGE_ISO = "en";

export default class SbgShopDetails extends NavigationMixin(LightningElement) {
  shop;
  @track shopLink;
  shopId;
  error;
  products;
  showScroller;
  selectedProduct;
  subscription = null;
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
  buttonLabel = 'Go to Store';
  buttonTitle = 'Go To Store';
  @track isShowModal = false;
  productId;

  popupIcon = mallIcons + "/avatar_alert_negative.svg";
  
  setTaggingAttributes(button, type, scope){
      button.map((item) => {
          this.buttonInteractionIntent = "navigational";
          this.buttonInteractionScope = scope || "test buttonInteractionScope";
          this.buttonInteractionType = "click";
          this.buttonInteractionText = item.shopName + " | " + item.title || "test buttonInteractionText";
          this.buttonInteractionTextBefore = type || "test buttonInteractionTextBefore" ;            
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
      this.shopId = currentPageReference?.attributes?.recordId;
      getShopsByIds({ mallContext: mallContext, shopIds: [this.shopId] })
        .then((result) => {
          if (result && result.length > 0) {
            this.shop = result[0];
            this.shopLink =
              CLIENT_FORM_FACTOR === "Small"
                ? this.shop.mobileUrl
                : this.shop.desktopUrl;
          }
        })
        .catch((error) => {
          this.error = error;
          console.log(this.error);
        });

      getProductsByShopIds({ mallContext: mallContext, shopIds: [this.shopId] })
        .then((result) => {
          let serviceResult = result.filter(item => (item.offeringType == "Service"));
          this.products = serviceResult.map((item) => ({
            ...item,
            styleClass:  item.id == this.productId ? 'service-item active-service' : 'service-item',
            serviceUrl: getBaseUrl() + '/mall/s/account/' + this.shopId + '/' + this.shop.name + '?productId=' + item.id
          }));
          this.showScroller = this.products.length > 5;
          this.selectedProduct = this.products.find(prod => prod.id == this.productId);
        })
        .catch((error) => {
          this.error = error;
        });
    }
  }

  connectedCallback() {
    this.productId = this.getUrlParamValue(window.location.href, 'productId'); 
  }

  renderedCallback() {
    this.publishRedirectModal();
    addAnalyticsInteractions(this.template);
  }

  publishRedirectModal(){
    if(!IS_GUEST && getCookie("navigateToShopAfterLogin")==="true"){
      let navigateToShopUrl = getCookie("navigateToShopUrl");
        this.deleteCookie('navigateToShopAfterLogin');
        putCookie("navigateToShopUrl", "");
        setTimeout(() => {
          publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {"targetUrl" : navigateToShopUrl, "storeName" : getCookie('shopName')});
        }, 4000);
    }

  }



  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  } 

  setUrlParamValue(url, key, value) {
    return new URL(url).searchParams.put(key, value);
  } 

  @wire(MessageContext)
  messageContext;

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

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  productSelection(event) {
    this.selectedProduct = this.products.find(pro => pro.id == event.currentTarget.dataset.serviceid);
    this.products.forEach(prod =>  {
      prod.styleClass = prod.id == this.selectedProduct.id ? 'product-item active-product' : 'product-item';
    })
    
    this.setUrlParamValue(window.location.href, 'productId', this.selectedProduct.id);
  }

  async handleNavigateToShop(event) {
    event.preventDefault();
    this.createCookie("shopName",this.shop.name);
    this.createCookie("navigateToShopUrl", this.sanitizeUrl(this.shopLink),3);
    if (IS_GUEST) {
      this.createCookie("userDesiredPage",window.location.href);
      this.createCookie("redirectToUserDesiredPage",'true',3);
      this.createCookie("shopName",this.shop.name);
      this.createCookie('redirectToShopPage','true',3);
      this.createCookie("navigateToShopAfterLogin", "true");
      this.createCookie("navigateToShopUrl", this.sanitizeUrl(this.shopLink),3);
      publish(this.messageContext, MALL_PRE_NAVIGATION_EVT,{});
    } else {
      publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {"targetUrl" : this.sanitizeUrl(this.shopLink), "storeName" : this.shop.name});
    }
  }

  createCookie(name, value, days) {
    var expires;

    if (days) {
        const date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toGMTString();
    } else {
        expires = "";
    }

    document.cookie = name + "=" + escape(value) + expires + "; path=/";
  }

  deleteCookie(name){
     document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
  }

  sanitizeUrl(url){
     return url.replace(/[^A-Za-z0-9\/\:\.\-\=\&\#\?\_]/g, '');	
  }

  async navigateToTargetRecord(record) {
    const currentPageUrl = decodeURIComponent(document.location.href);
    const recordUrl = (CLIENT_FORM_FACTOR === "Small") ? record.mobileUrl : record.desktopUrl;
    const redirectUrl = recordUrl;
    try {
      //log session variables
      await setSessionVars({ pageUrl: currentPageUrl });
      if (redirectUrl && !redirectUrl.includes("http")) {
        redirectUrl = "https://" + redirectUrl;
      }
      if (redirectUrl) {
        this.navigateToWebPage(redirectUrl);
      }
    } catch(error) {
      this.error = error;
    }
  }

  async handleNavigateToProduct(event) {
    event.preventDefault();
    if (IS_GUEST) {
      this.createCookie("userDesiredPage",window.location.href);
      this.createCookie("redirectToUserDesiredPage",'true',3);
      this.createCookie("shopName",this.shop.name);
      this.createCookie('redirectToShopPage','true',3);
      this.createCookie("navigateToShopAfterLogin", "true");
      this.createCookie("navigateToShopUrl", this.selectedProduct.desktopUrl,3);
      publish(this.messageContext, MALL_PRE_NAVIGATION_EVT,{});
    } else if(this.selectedProduct && this.selectedProduct.desktopUrl) {
            publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {"targetUrl" : this.selectedProduct.desktopUrl , "storeName" : this.shop.name});
      }
  }

  shopSliderScroll(event) {
    let maxScrollLeft = 0;
    let content = this.template.querySelector('[data-id="menuShopSlider"]');
    let filterCategoryContainer = this.template.querySelectorAll(
      ".products-list"
    );
    filterCategoryContainer.forEach((filter) => {
      maxScrollLeft += filter.scrollLeft;
    });
    if (event.type === "mousedown") {
      if (
        event.target.classList.contains("scroll-button_next-ss") ||
        event.target
          .closest('[class*="scroll-button"]')
          .classList.contains("scroll-button_next-ss")
      ) {
        this.leftDisabled = false;
        content.scrollLeft += 120;
        this.enableScroll = true;

        if (content.scrollLeft == maxScrollLeft) {
          this.rightDisabled = true;
        }
        event.preventDefault();
      }
      if (
        event.target.classList.contains("scroll-button_prev-ss") ||
        event.target
          .closest('[class*="scroll-button"]')
          .classList.contains("scroll-button_prev-ss")
      ) {
        content.scrollLeft -= 120;
        this.rightDisabled = false;
        if (content.scrollLeft == 0) {
          this.leftDisabled = true;
        }
        this.enableScroll = true;
        event.preventDefault();
      }
    }
  }
}