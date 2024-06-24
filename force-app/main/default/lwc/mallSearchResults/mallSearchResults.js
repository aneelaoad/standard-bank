import { LightningElement, api, wire, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from "lightning/navigation";
import getSearchResults from "@salesforce/apex/Mall_CTRL_Search.getSearchResults";
import getCategories from "@salesforce/apex/MallDataService.getActiveRootCategories";
import { navigateToRecordPage } from "c/mallNavigation";
import getProductsByTagIds from "@salesforce/apex/MallDataService.getProductsByTagIds";
import { addSearchAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { getBaseUrl } from "c/mallNavigation";
import IS_GUEST from "@salesforce/user/isGuest";
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import { navigateToWebPage } from "c/mallNavigation";
import { publish, MessageContext } from "lightning/messageService";
import MALL_PRE_NAVIGATION_EVT from "@salesforce/messageChannel/PreNavigationModal__c";
import getSolutionsBySegmentAndCategories from "@salesforce/apex/MallDataService.getSolutionsBySegmentAndCategories";
import DEFAULT_MALL_COUNTRY from "@salesforce/label/c.DEFAULT_MALL_COUNTRY";
import DEFAULT_MALL_LANGUAGE_ISO from "@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO";
import {
  getCookie,
  putCookie,
  createCookie,
  deleteCookie
} from "c/cmnCookieUtils";
import { mallStateName, getUserState } from "c/sbgUserStateUtils";

export default class MallSearchResults extends NavigationMixin(
  LightningElement
) {
  //Heading properties
  @api title;
  @api isPageTitle;
  @api showSubtitle;
  @api subtitle;
  @api alignCenter;
  @api showUnderline;
  @api applyThemeColourToTitle;
  @api applyThemeColourToSubTitle;
  //Used for child components that have boolean property checks
  setFalse = false;
  searchTerm = null;
  selectedTab = undefined;
  navigateToRecordPage = navigateToRecordPage.bind(this);
  @track resultTypeAll = true;
  @track productResultType = true;
  @track solutionsResultType = true;
  @track websiteInfoResultType = true;
  @track results = [];
  @track intialresults = [];
  @track resultscopy = [];
  unfilteredList = [];
  @track searchOptions;
  @track setDefaultChecked = true;
  @track totalResultCount = 0;
  @track showNoResultMessage = false;
  selectedCategories = [];
  @track showMobileCategories = false;
  allSolutions;
  allProducts;
  allOthers;
  allCategoriesProducts;
  allCategoriesSolutions;
  allSolutionResponse;
  redirectToProductWebsite = true;
  pageType;
  resultHeading = "";
  selectedCategory = "";
  isShowModal = false;
  popupIcon = mallIcons + "/avatar_alert_negative.svg";
  navigateToWebPage = navigateToWebPage.bind(this);

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.pageType = currentPageReference.type;
      this.searchTerm = currentPageReference.state.term;
      this.selectedTab = currentPageReference.state.tab;
      this.selectedCategory = currentPageReference.state.category;
    }
  }

  @wire(MessageContext)
  messageContext;

  toggleOpen() {
    this.showMobileCategories = !this.showMobileCategories;
  }

  get categoryTitle() {
    return "Filter by categories";
  }

  get resultCountFeedbackMessage() {
    let number = this.totalResultCount == 0 ? "0 " : this.totalResultCount;
    return number + ' results for "' + this.searchTerm + '"';
  }

  get viewAllLabel() {
    return "View all";
  }

  navigateToSolutionsDetailPage(event) {
    let record = event.currentTarget.dataset.solutionid;
    this.navigateToWebPage(getBaseUrl() + "/mall/s/tag/" + record);
  }

  navigateToSolutionDetailsWithServices(event) {
    let solutionId = event.currentTarget.dataset.solutionid;
    let serviceId = event.currentTarget.dataset.serviceid;
    this.navigateToWebPage(
      getBaseUrl() + "/mall/s/tag/" + solutionId + "?productId=" + serviceId
    );
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

  viewAllResultsByType(evt) {
    if (evt.target.dataset.resultType == "All") {
      this.results = this.intialresults;
    } else {
      this.results = this.resultscopy;
    }
    evt.preventDefault();
    let target = evt.target;
    this.refreshTabResults(target.dataset.resultType);
    this.selectedTab = target.dataset.resultType;
    this.updateTabView();
    //tab focus
    let tabs = this.template.querySelectorAll(".tab-item-checkbox");
    tabs.forEach((element) => {
      if (element.name != target.name) {
        element.checked = false;
      } else {
        element.checked = true;
      }
    });
    this.setDefaultChecked = false;
  }

  updateTabView() {
    this.results.forEach((result) => {
      result.showProducts = false;
      result.showOthers = false;
      if (result.name == "Offerings") {
        result.showProducts =
          this.selectedTab == "All" || this.selectedTab == "Offerings";
      }
      if (result.name == "Solutions") {
        result.showSolutions =
          this.selectedTab == "All" || this.selectedTab == "Solutions";
      } else if (result.name == "Others") {
        result.showOthers =
          this.selectedTab == "All" || this.selectedTab == "Others";
      }
    });
    this.refreshResults();
  }

  refreshTabResults(data) {
    this.resultTypeAll = false;
    this.productResultType = false;
    this.websiteInfoResultType = false;
    this.solutionsResultType = false;
    if (data == "All") {
      this.resultTypeAll = true;
      this.productResultType = true;
      this.websiteInfoResultType = true;
    } else if (data == "Offerings") {
      this.productResultType = true;
    } else if (data == "Solutions") {
      this.solutionsResultType = true;
    } else if (data == "Others") {
      this.websiteInfoResultType = true;
    }
  }

  connectedCallback() {
    this.refreshTabResults(this.selectedTab);
    this.results.push({
      id: "resultType0",
      name: "All",
      all: []
    });
    this.intialresults.push({
      id: "resultType0",
      name: "All",
      all: []
    });
    getSearchResults({
      searchString: this.searchTerm
    })
      .then((result) => {
        let initialProducts = [];
        let initialOthers = [];
        let initialSolutions = [];
        if (this.selectedCategory) {
          result.Products.forEach((item) => {
            if (item.categoryName == this.selectedCategory) {
              initialProducts.push(item);
            }
          });
          result.Others.forEach((item) => {
            if (
              (item.categoryName &&
                item.categoryName == this.selectedCategory) ||
              !item.categoryName
            ) {
              initialOthers.push(item);
            }
          });
          result.Solutions.forEach((item) => {
            initialSolutions.push(item);
          });
        }
        this.results.push({
          id: "resultType1",
          name: "Solutions",
          solutions: result.Solutions,
          count: result.Solutions.length,
          showProducts: false,
          showSolutions: true,
          showOthers: false
        });
        this.intialresults.push({
          id: "resultType1",
          name: "Solutions",
          solutions:
            initialSolutions.length > 0 ? initialSolutions.slice(0, 4) : [],
          count: initialSolutions.length,
          showProducts: false,
          showSolutions: true,
          showOthers: false
        });
        this.results.push({
          id: "resultType2",
          name: "Offerings",
          products: result.Products,
          count: result.Products.length,
          showProducts: true,
          showOthers: false
        });
        this.intialresults.push({
          id: "resultType2",
          name: "Offerings",
          products:
            initialProducts.length > 0 ? initialProducts.slice(0, 4) : [],
          count: initialProducts.length,
          showProducts: true,
          showOthers: false
        });

        this.results.push({
          id: "resultType3",
          name: "Others",
          websiteInfo: result.Others,
          count: result.Others.length,
          showProducts: false,
          showOthers: true
        });
        this.intialresults.push({
          id: "resultType3",
          name: "Others",
          websiteInfo:
            initialOthers.length > 0 ? initialOthers.slice(0, 4) : [],
          count: initialOthers.length,
          showProducts: false,
          showOthers: true
        });
        this.resultscopy = this.results;
        this.results = this.intialresults;
        this.unfilteredList = this.results;
        this.totalResultCount =
          result.Products.length +
          result.Solutions.length +
          result.Others.length;
        addSearchAnalyticsInteractions(
          this.totalResultCount,
          "All",
          this.searchTerm,
          this.pageType
        );
        if (this.totalResultCount == 0) {
          this.showNoResultMessage = true;
        }
        this.allSolutions = result.Solutions;
        this.allProducts = result.Products;
        this.allOthers = result.Others;
        if (this.selectedTab) {
          if (this.selectedTab != "All") {
            this.results = this.resultscopy;
          }
          this.updateTabView();
        }
      })
      .catch((error) => {});

    getCategories()
      .then((result) => {
        let categories = [];
        this.searchOptions = result.map((denormalizedTag) => {
          categories.push(denormalizedTag.id);
          let selected = this.selectedCategory == denormalizedTag.name;
          return {
            value: denormalizedTag.id,
            label: denormalizedTag.name,
            selected: selected
          };
        });
        // Sort
        this.searchOptions.sort((current, next) => {
          let currentName = current.label.toLowerCase();
          let nextName = next.label.toLowerCase();
          if (currentName < nextName) {
            return -1;
          }
          if (currentName > nextName) {
            return 1;
          }
          return 0;
        });
        this.searchOptions.unshift({
          value: "All",
          label: "All",
          selected: !this.selectedCategory ? true : false
        });
        getProductsByTagIds({
          tags: categories
        })
          .then((result) => {
            this.allCategoriesProducts = result.map((denormalizedProduct) => {
              return denormalizedProduct;
            });
          })
          .catch((error) => {});

        this.getSolutionsBySegmentAndCategoryIds(categories);
      })
      .catch((error) => {});
  }

  async getSolutionsBySegmentAndCategoryIds(tagIds) {
    try {
      let mallStateConfig = {};
      mallStateConfig.mallUserSelectedCountry = getUserState(
        mallStateName.mallUserSelectedCountry,
        DEFAULT_MALL_COUNTRY
      );
      mallStateConfig.mallUserSelectedLanguage = getUserState(
        mallStateName.mallUserSelectedLanguageISOCode,
        DEFAULT_MALL_LANGUAGE_ISO
      );
      mallStateConfig.selectedSegmentIds = getUserState(
        mallStateName.selectedSegmentIds,
        []
      );
      mallStateConfig.selectedCategoryIds = [...tagIds];
      let mallContext = JSON.stringify(mallStateConfig);
      let solutionsResponse = await getSolutionsBySegmentAndCategories({
        mallContext: mallContext,
        segmentIds: mallStateConfig.selectedSegmentIds,
        categoryIds: mallStateConfig.selectedCategoryIds
      });

      this.allSolutionResponse = [...solutionsResponse];
      let allSolutions = [];
      let allSolutionIds = [];

      if (solutionsResponse && solutionsResponse.length > 0) {
        for (let row = 0; row < solutionsResponse.length; row++) {
          for (let k = 0; k < solutionsResponse[row].solutions.length; k++) {
            if (
              !allSolutionIds.includes(solutionsResponse[row].solutions[k].id)
            ) {
              allSolutions.push(solutionsResponse[row].solutions[k]);
              allSolutionIds.push(solutionsResponse[row].solutions[k].id);
            }
          }
        }
      }
      this.allCategoriesSolutions = [...allSolutions];
    } catch (error) {
      this.error = error;
    }
  }

  renderedCallback() {
    let tabs = this.template.querySelectorAll(".tab-item-checkbox");
    let selectedResultTab =
      this.selectedTab == undefined ? "All" : this.selectedTab;
    tabs.forEach((element) => {
      if (element.name == selectedResultTab && this.setDefaultChecked)
        element.checked = true;
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

  handleSearchOptionChange(event) {
    this.searchOptions.forEach((option) => {
      if (event.target.value == "All") {
        option.selected = option.value == "All";
      } else {
        if (option.value == "All") {
          option.selected = false;
        } else if (option.value == event.target.value) {
          option.selected = event.target.checked;
        }
      }
    });
    if (event.target.value != "All") {
      if (event.target.checked) {
        this.selectedCategories.push(event.target.value);
      } else {
        for (let i = 0; i < this.selectedCategories.length; i++) {
          if (this.selectedCategories[i] === event.target.value) {
            this.selectedCategories.splice(i, 1);
          }
        }
      }
    } else {
      this.selectedCategories = [];
      this.searchOptions.forEach((option) => {
        option.selected = option.value == "All";
      });
    }
    this.showMobileCategories = false;
    this.refreshResults();
  }

  async refreshResults() {
    this.totalResultCount = 0;
    for (let i = 0; i < this.results.length; i++) {
      if (this.results[i].name == "Offerings") {
        if (this.selectedCategories.length != 0) {
          let tempProducts = this.allCategoriesProducts.filter((product) =>
            this.selectedCategories.includes(product.tagId)
          );
          let temProductIds = tempProducts.map((prod) => {
            return prod.id;
          });
          this.results[i].products = this.allProducts.filter((product) =>
            temProductIds.includes(product.id)
          );
          this.results[i].count = this.allProducts.filter((product) =>
            temProductIds.includes(product.id)
          ).length;
        } else {
          this.results[i].products = this.allProducts;
          this.results[i].count = this.allProducts.length;
        }
        this.totalResultCount = this.totalResultCount + this.results[i].count;
      } else if (this.results[i].name == "Solutions") {
        if (this.selectedCategories.length != 0) {
          this.results[i].solutions = this.allSolutions;
          this.results[i].count = this.allSolutions.length;
        } else {
          this.results[i].solutions = this.allSolutions;
          this.results[i].count = this.allSolutions.length;
        }
        this.totalResultCount = this.totalResultCount + this.results[i].count;
      } else if (this.results[i].name == "Others") {
        if (this.selectedCategories.length != 0) {
          this.results[i].websiteInfo = this.allOthers.filter(
            (other) =>
              !other.categoryId ||
              (other.categoryId &&
                this.selectedCategories.includes(other.categoryId))
          );
          this.results[i].count = this.results[i].websiteInfo.length;
        } else {
          this.results[i].websiteInfo = this.allOthers;
          this.results[i].count = this.allOthers.length;
        }
        this.totalResultCount = this.totalResultCount + this.results[i].count;
      }
    }
    this.totalResultCount = this.totalResultCount ? this.totalResultCount : 0;
    let taggingSearchFilters = "";
    if (this.searchOptions && this.searchOptions.lenght > 0) {
      for (let j = 0; j < this.searchOptions.length; j++) {
        for (let i = 0; i < this.selectedCategories.length; i++) {
          if (this.selectedCategories[i] == this.searchOptions[j].value) {
            if (taggingSearchFilters == "")
              taggingSearchFilters = this.searchOptions[j].label;
            else
              taggingSearchFilters =
                taggingSearchFilters + "," + this.searchOptions[j].label;
          }
        }
      }
      if (taggingSearchFilters == "") {
        taggingSearchFilters = "All";
      }
    }
    addSearchAnalyticsInteractions(
      this.totalResultCount,
      taggingSearchFilters,
      this.searchTerm,
      this.pageType
    );
  }

  get componentWrapper() {
    return this.showNoResultMessage
      ? "search-results-wrapper-no-item"
      : "search-results-wrapper";
  }
}