import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getSearchResults from "@salesforce/apex/Mall_CTRL_Search.getSearchResults";
import getCategories from "@salesforce/apex/MallDataService.getActiveRootCategories";
import { getBaseUrl } from "c/mallNavigation";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { MallTranslationService } from "c/mallTranslationService";
import USER_MALLSTATE_CHANGED_EVT from "@salesforce/messageChannel/UserMallStateChanged__c";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext,
  publish
} from "lightning/messageService";
import { addSearchAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { CurrentPageReference } from "lightning/navigation";
import IS_GUEST from "@salesforce/user/isGuest";
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import { navigateToWebPage } from "c/mallNavigation";
import MALL_PRE_NAVIGATION_EVT from "@salesforce/messageChannel/PreNavigationModal__c";
import {
  getCookie,
  putCookie,
  createCookie,
  deleteCookie
} from "c/cmnCookieUtils";

export default class MallSearch extends NavigationMixin(LightningElement) {
  @api placeholderText;
  searchTerm = "";
  openFlyOut = false;
  categoryName;

  get productLabel() {
    return "Offerings";
  }

  get solutionsLabel() {
    return "Solutions";
  }

  get otherLabel() {
    return "Other";
  }

  get viewAllLabel() {
    return "View all";
  }

  get checkboxMessageCategory() {
    return this.categoryName;
  }

  set checkboxMessageCategory(value) {
    this.categoryName = value;
  }

  mallStateConfig;
  mallStateChangeSubscription = null;

  backText = "Back";
  checkboxMessage = "Include only items in category ";

  productCount = 0;
  solutionsCount = 0;
  otherCount = 0;
  loadingSearch = false;
  skeletonProduct = [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }];
  skeletonSolutions = [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }];
  @track products = undefined;
  @track solutions = undefined;
  @track others = undefined;
  @track allProducts;
  @track allSolutions;
  @track allSuggestion;
  termSuggestions = [];
  showViewAllProducts = false;
  showViewAllSolutions = false;
  showViewAllOthers = false;
  isCategoryFilterActive = false;
  showCategorySelection = false;
  isShowModal = false;
  popupIcon = mallIcons + "/avatar_alert_negative.svg";
  navigateToWebPage = navigateToWebPage.bind(this);

  @api showMobileSearch = false;
  screenWidth = 0;
  pageType;
  error;

  get searchPlaceholderText() {
    return this.placeholderText || "Discover more...";
  }

  @wire(MessageContext)
  messageContext;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.pageType = currentPageReference.type;
    }
  }

  connectedCallback() {
    this.getTranslatedLabels();
    this.subscribeToMallStateChangeMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMallStateChangeMessageChannel();
  }

  /*subscribe for mall state change event*/
  subscribeToMallStateChangeMessageChannel() {
    if (!this.mallStateChangeSubscription) {
      this.mallStateChangeSubscription = subscribe(
        this.messageContext,
        USER_MALLSTATE_CHANGED_EVT,
        (message) => this.handleMallStateChange(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  /*unsubscribe mall state change event*/
  unsubscribeToMallStateChangeMessageChannel() {
    unsubscribe(this.mallStateChangeSubscription);
    this.mallStateChangeSubscription = null;
  }

  /*Handle Mall State change Event*/
  handleMallStateChange(message) {
    let mallStateConfig = { ...message };
    this.mallStateConfig = { ...mallStateConfig };
    if (this.mallStateConfig.selectedCategoryIds.length == 1) {
      this.checkboxMessageCategory = this.mallStateConfig.selectedCategoryNames;
      this.showCategorySelection = true;
      if (this.isCategoryFilterActive) {
        this.isCategoryFilterActive = !this.isCategoryFilterActive;
        this.generateCategoryResults();
      } else {
        this.isCategoryFilterActive = !this.isCategoryFilterActive;
        this.removeCategoryFilter();
      }
    } else {
      this.showCategorySelection = false;
      this.checkboxMessageCategory = undefined;
      this.isCategoryFilterActive = !this.isCategoryFilterActive;
      this.removeCategoryFilter();
    }
  }

  //Code to setup the translations for the labels
  tokenVsLabelsObject = {
    placeholderText: "MALL_SEARCH_PLACEHOLDER"
  };

  //get the translated labels
  async getTranslatedLabels() {
    try {
      const translatedLabelsInstance = MallTranslationService.getInstance();
      const translatedLabels =
        await translatedLabelsInstance.getTranslatedLabels();
      this.setUpTranslatedLabels(translatedLabelsInstance);
    } catch (error) {
      this.error = error;
    }
  }

  // Method to create and setting up labels as properties
  setUpTranslatedLabels(translatedLabelsInstance, translatedLabels) {
    //Add translation for defined tokenVsLabelsObject
    if (this.tokenVsLabelsObject) {
      for (let property in this.tokenVsLabelsObject) {
        const value = translatedLabelsInstance.getTranslatedLabelByLabelName(
          this.tokenVsLabelsObject[property],
          translatedLabels
        );
        this[property] = value ? value : this[property];
      }
    }
  }

  /**
   * On inputing search keyphrase, we fire this method for showing flyout with preview terms and suggested results
   * @param {*} event
   * @returns
   */
  searchKeyphraseChange(evt) {
    this.loadingSearch = true;
    this.products = [];
    this.productCount = 0;
    this.solutions = [];
    this.solutionsCount = 0;
    //Checks if user presses enter key
    const isEnterKey = evt.keyCode === 13;

    this.searchTerm = evt.target.value;

    if (isEnterKey) {
      return this.submitSearchPhrase(this.searchTerm);
    }

    if (!this.searchTerm) return (this.openFlyOut = false);

    this.openFlyOut = true;
    //Will close any dropdowns open on the header
    window.dispatchEvent(new CustomEvent("closeDropdowns"));

    if (this.searchTerm.length > 1) {
      this.initFlyOut(this.searchTerm);
    }
  }

  /**
   * we submit the search term to the search page as a url paramaeter
   * @param {*} event
   * @returns
   */
  submitSearchPhrase(evt, term) {
    if (evt) {
      evt.preventDefault();
    }

    let result = term || this.searchTerm;

    if (!this.result) {
      this.error = error;
    }

    return this.navigateToSearchResults(result);
  }

  submitSearchPhraseOnEnter(evt) {
    if (evt.key === "Enter") {
      return this.navigateToSearchResults(this.searchTerm);
    }
  }

  onClickProduct(event) {
    event.preventDefault();
    if (IS_GUEST) {
      createCookie("userDesiredPage", window.location.href);
      createCookie("redirectToUserDesiredPage", "true", 3);
      createCookie("shopName", event.currentTarget.dataset.shopname, 3);
      createCookie("redirectToShopPage", "true", 3);
      createCookie("navigateToShopAfterLogin", "true");
      createCookie("navigateToShopUrl", event.currentTarget.dataset.url, 3);
      publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {});
    } else {
      publish(this.messageContext, MALL_PRE_NAVIGATION_EVT, {
        targetUrl: event.currentTarget.dataset.url,
        storeName: event.currentTarget.dataset.shopname
      });
    }
  }

  sanitizeUrl(url) {
    return url.replace(/[^A-Za-z0-9\/\:\.\-\=\&\#\?\_]/g, "");
  }

  initFlyOut(term) {
    getCategories().then((result) => {
      result.forEach((denormalizedTag) => {
        if (denormalizedTag.name.startsWith(this.searchTerm)) {
          this.termSuggestions.push({
            id: denormalizedTag.id,
            name: denormalizedTag.name
          });
        }
      });
    });
    //Do some stuff to get previews and what not
    getSearchResults({ searchString: this.searchTerm })
      .then((result) => {
        this.termSuggestions = [];
        if (result.Solutions.length != 0) {
          this.solutions = result.Solutions.slice(0, 4);
          this.solutionsCount = result.Solutions.length;
          this.allSolutions = result.Solutions;
        } else {
          this.solutions = undefined;
          this.allSolutions = undefined;
        }
        if (result.Products.length != 0) {
          this.products = result.Products.slice(0, 4);
          this.productCount = this.products.length;
          this.allProducts = result.Products;
        } else {
          this.products = undefined;
          this.allProducts = undefined;
        }
        this.generateSuggestions(false);
        this.otherCount = result.Others.length;
        this.others = result.Others;

        this.showViewAllProducts =
          this.screenWidth > 768
            ? this.productCount > 4
            : this.productCount > 1;
        this.showViewAllSolutions =
          this.screenWidth > 768
            ? this.solutionsCount > 4
            : this.solutionsCount > 1;
        this.showViewAllOthers =
          this.screenWidth > 768 ? this.otherCount > 0 : this.otherCount > 0;
        this.loadingSearch = false;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  generateSuggestions(includeCategoryFilter) {
    this.termSuggestions = [];
    let suggessionlength = 0;
    this.allProducts =
      this.allProducts && this.allProducts.length > 0 ? this.allProducts : [];
    for (let i = 0; i < this.allProducts.length; i++) {
      if (suggessionlength <= 2 && !includeCategoryFilter) {
        this.termSuggestions.push({
          id: this.allProducts[i].id,
          name: this.allProducts[i].title
        });
        suggessionlength = suggessionlength + 1;
      } else if (
        suggessionlength <= 2 &&
        includeCategoryFilter &&
        this.allProducts[i].categoryName == this.checkboxMessageCategory
      ) {
        this.termSuggestions.push({
          id: this.allProducts[i].id,
          name: this.allProducts[i].title
        });
        suggessionlength = suggessionlength + 1;
      }
    }
  }

  navigateToSearchResults(term) {
    let searchUrl =
      window.location.origin +
      "/mall/s/search-results/" +
      term +
      "?tab=All" +
      (this.categoryName ? "&category=" + this.categoryName : "");
    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: searchUrl
      }
    }).then((generatedUrl) => {
      window.open(generatedUrl, "_self");
    });
  }

  navigateToResults(event) {
    let term = event.currentTarget.dataset.term;
    let searchUrl =
      window.location.origin +
      "/mall/s/search-results/" +
      term +
      "?tab=All" +
      (this.categoryName ? "&category=" + this.categoryName : "");
    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: searchUrl
      }
    }).then((generatedUrl) => {
      window.open(generatedUrl, "_self");
    });
  }

  navigateToSolutionDetailPage(event) {
    let recordid = event.currentTarget.dataset.solutionid;
    let solutionUrl = window.location.origin + "/mall/s/tag/" + recordid;
    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: solutionUrl
      }
    }).then((generatedUrl) => {
      window.open(generatedUrl, "_self");
    });
  }

  viewAllResultsByType(event) {
    let viewAllurl =
      window.location.origin + "/mall/s/search-results/" + this.searchTerm;
    if (event.currentTarget.dataset.resultType == "PRODUCTS") {
      viewAllurl = viewAllurl + "?tab=Offerings";
    } else if (event.currentTarget.dataset.resultType == "SOLUTIONS") {
      viewAllurl = viewAllurl + "?tab=Solutions";
    } else if (event.currentTarget.dataset.resultType == "OTHERS") {
      viewAllurl = viewAllurl + "?tab=Others";
    }
    viewAllurl += this.categoryName ? "&category=" + this.categoryName : "";
    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: viewAllurl
      }
    }).then((generatedUrl) => {
      window.open(generatedUrl, "_self");
    });
  }

  showSearchWindow() {
    this.showMobileSearch = true;
    document.body.style.overflow = "hidden";
  }

  removeSearchText() {
    this.searchTerm = null;
    this.termSuggestions = null;
    this.products = null;
    this.openFlyOut = false;
  }

  hideSearchWindow() {
    this.showMobileSearch = false;
    document.body.style.overflow = "auto";
  }

  get searchResultURLProducts() {
    return (
      getBaseUrl() +
      "/mall/s/search-results/" +
      this.searchTerm +
      "?tab=Offerings" +
      (this.categoryName ? "&category=" + this.categoryName : "")
    );
  }

  get searchResultURLSolutions() {
    return (
      getBaseUrl() +
      "/mall/s/search-results/" +
      this.searchTerm +
      "?tab=Solutions" +
      (this.categoryName ? "&category=" + this.categoryName : "")
    );
  }

  get searchResultURLOthers() {
    return (
      getBaseUrl() +
      "/mall/s/search-results/" +
      this.searchTerm +
      "?tab=Others" +
      (this.categoryName ? "&category=" + this.categoryName : "")
    );
  }

  applyCategoryFilter(event) {
    if (event.target.checked) {
      this.generateCategoryResults();
    } else {
      this.removeCategoryFilter();
    }
  }

  generateCategoryResults() {
    this.isCategoryFilterActive = !this.isCategoryFilterActive;
    this.products = [];
    this.solutions = [];
    this.productCount = 0;
    this.solutionsCount = 0;
    this.otherCount = 0;
    this.allSolutions.forEach((item) => {
      if (item.categoryName == this.checkboxMessageCategory) {
        this.solutionsCount++;
        if (this.solutions.length < 5) {
          this.solutions.push(item);
        }
      }
    });
    this.allProducts.forEach((item) => {
      if (item.categoryName == this.checkboxMessageCategory) {
        this.productCount++;
        if (this.products.length < 5) {
          this.products.push(item);
        }
      }
    });

    this.others.forEach((item) => {
      if (
        (item.categoryName &&
          item.categoryName == this.checkboxMessageCategory) ||
        !item.categoryName
      ) {
        this.otherCount++;
      }
    });

    this.generateSuggestions(true);
    this.showViewAllProducts =
      this.screenWidth > 768 ? this.productCount > 4 : this.productCount > 0;
    this.showViewAllSolutions =
      this.screenWidth > 768
        ? this.solutionsCount > 4
        : this.solutionsCount > 0;
    this.showViewAllOthers =
      this.screenWidth > 768 ? this.otherCount > 0 : this.otherCount > 0;

    addSearchAnalyticsInteractions(
      this.productCount + this.solutionsCount + this.otherCount,
      this.checkboxMessageCategory,
      this.searchTerm,
      this.pageType
    );
  }

  get noResultMessage() {
    return (
      'we could not find any results for "' +
      this.searchTerm +
      '" , try a different term or browse our categories'
    );
  }

  get showNoResultMessage() {
    return this.productCount + this.solutionsCount + this.otherCount == 0;
  }

  removeCategoryFilter() {
    this.isCategoryFilterActive = !this.isCategoryFilterActive;
    if (this.allProducts) {
      this.products =
        this.allProducts.length > 4
          ? this.allProducts.slice(0, 4)
          : [...this.allProducts];
    }
    this.generateSuggestions(false);
    this.otherCount = this.others ? this.others.length : 0;
    this.productCount = this.allProducts ? this.allProducts.length : 0;
    this.solutionsCount = this.allSolutions ? this.allSolutions.length : 0;
    this.showViewAllProducts =
      this.screenWidth > 768 ? this.productCount > 4 : this.productCount > 0;
    this.showViewAllOthers =
      this.screenWidth > 768 ? this.otherCount > 0 : this.otherCount > 0;
  }

  renderedCallback() {
    this.screenWidth = screen.width;
    window.addEventListener("resize", () => {
      this.screenWidth = screen.width;
    });
    addAnalyticsInteractions(this.template);
    this.publishRedirectModal();
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
}