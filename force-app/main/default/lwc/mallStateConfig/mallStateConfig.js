import { LightningElement, track, wire, api } from "lwc";
import {
  subscribe,
  unsubscribe,
  publish,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { mallStateName, getUserState, setUserState } from "c/sbgUserStateUtils";
import initialization from "@salesforce/apex/MallDataService.initialization";
import USER_LANGUAGE_CHANGED_EVT from "@salesforce/messageChannel/UserLanguageChanged__c";
import USER_MALLSTATE_CHANGED_EVT from "@salesforce/messageChannel/UserMallStateChanged__c";
import IS_GUEST from "@salesforce/user/isGuest";
import DEFAULT_MALL_COUNTRY from "@salesforce/label/c.DEFAULT_MALL_COUNTRY";
import DEFAULT_MALL_LANGUAGE_ISO from "@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO";
import getProductsBySegmentAndCategoryIds from "@salesforce/apex/MallDataService.getProductsBySegmentAndCategoryIds";
import getPromotionsBySegmentAndCategoryIds from "@salesforce/apex/MallDataService.getPromotionsBySegmentAndCategoryIds";
import getEventsBySegmentAndCategoryIds from "@salesforce/apex/MallDataService.getEventsBySegmentAndCategoryIds";
import getSolutionsBySegmentAndCategories from "@salesforce/apex/MallDataService.getSolutionsBySegmentAndCategories";
import { getBaseUrl, navigateToWebPage } from "c/mallNavigation";
import MALL_HOMEPAGE_TRUSTED_PARTNER_TITLE from "@salesforce/label/c.MALL_HOMEPAGE_TRUSTED_PARTNER_TITLE";
import MALL_HOMEPAGE_SERVICES_TITLE from "@salesforce/label/c.MALL_HOMEPAGE_SERVICES_TITLE";
import MALL_HOMEPAGE_SERVICES_COVER_DESCRIPTION from "@salesforce/label/c.MALL_HOMEPAGE_SERVICES_COVER_DESCRIPTION";
import MALL_SOLUTIONS_COVER_DESC from "@salesforce/label/c.MALL_SOLUTIONS_COVER_DESC";
import MALL_HOMEPAGE_GUIDED_SOLUTION_COVER_DESCRIPTION from "@salesforce/label/c.MALL_HOMEPAGE_GUIDED_SOLUTION_COVER_DESCRIPTION";
import MALL_HOMEPAGE_POPULAR_SERVICES_COVER_DESCRIPTION from "@salesforce/label/c.MALL_HOMEPAGE_POPULAR_SERVICES_COVER_DESCRIPTION";
import MALL_HOMEPAGE_BUSINESS_EVENT_COVER_DESCRIPTION from "@salesforce/label/c.MALL_HOMEPAGE_BUSINESS_EVENT_COVER_DESCRIPTION";
import MALL_HOMEPAGE_POPULAR_SERVICES_TITLE from "@salesforce/label/c.MALL_HOMEPAGE_POPULAR_SERVICES_TITLE";
import MALL_HOMEPAGE_GUIDED_SOLUTIONS_TITLE from "@salesforce/label/c.MALL_HOMEPAGE_GUIDED_SOLUTIONS_TITLE";
import MALL_HOMEPAGE_MYDASHBOARD_TITLE from "@salesforce/label/c.MALL_HOMEPAGE_MYDASHBOARD_TITLE";
import MALL_HOMEPAGE_ADDGOAL_TITLE from "@salesforce/label/c.MALL_HOMEPAGE_ADDGOAL_TITLE";
import MALL_SIGN_UP_OR_SIGN_IN from "@salesforce/label/c.MALL_SIGN_UP_OR_SIGN_IN";
import MALL_DEFAULT_BUTTON_TITLE from "@salesforce/label/c.MALL_DEFAULT_BUTTON_TITLE";
import MALL_APPLY_NOW_BUTTON from "@salesforce/label/c.MALL_APPLY_NOW_BUTTON";
import MALL_HOMEPAGE_BUSINESS_EVENT_TITLE from "@salesforce/label/c.MALL_HOMEPAGE_BUSINESS_EVENT_TITLE";
import { MallTranslationService } from "c/mallTranslationService";
import { putCookie } from "c/cmnCookieUtils";
import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";
import mallHomeBanners from "@salesforce/resourceUrl/mallHomeBanners";
import mallHomeGridImages from "@salesforce/resourceUrl/mallHomeGridImages";

const SEGMENT_DEFAULT = "Business";
const DEFAULT_CATEGORY_NAME = "All";
const PAGE_TITLE = "Business banking tailored to your needs";
const PAGE_TITLE_TEXT =
  "Welcome to BCB Platform, an innovative space by Standard Bank, offering diverse business solutions and premium offerings across 'Bank, Borrow, and Grow' categories. Seamlessly connect with trusted brands, configure your dashboard with onboarded offerings, and explore business events and insights. Join us in this era of innovation, unlocking possibilities for your business success.";
const TITLE_FIRST_PARAGRAPH = "Improve your wealth, effortlessly";
const CONTENT_FIRST_PARAGRAPH =
  "Grow your business with our banking, borrowing and growth solutions. Plus, thrive with our shared value insurance model by making use of ways to improve your financial health.";
const TITLE_SECOND_PARAGRAPH = "Partner with other businesses";
const CONTENT_SECOND_PARAGRAPH =
  "Leverage the reputation and network of established professionals to reach new audiences and build trust with potential clients or partners.";
export default class MallStateConfig extends NavigationMixin(LightningElement) {
  pageTitle = PAGE_TITLE;
  pageTitleText = PAGE_TITLE_TEXT;
  titleFirstParagraph = TITLE_FIRST_PARAGRAPH;
  contentFirstParagraph = CONTENT_FIRST_PARAGRAPH;
  imgFirstParagraph = sbgVisualAssets + "/homepage-content-image-1.png";
  titleSecondParagraph = TITLE_SECOND_PARAGRAPH;
  contentSecondParagraph = CONTENT_SECOND_PARAGRAPH;
  imgSecondParagraph = sbgVisualAssets + "/homepage-content-image-2.png";

  //maintains the mall state based on hash fragments
  mallHashState = {
    segment: "",
    category: ""
  };

  //maintains the overall state of the user and application
  mallStateConfig = {
    mallUserSelectedCountry: "",
    mallUserSelectedLanguage: "",
    selectedSegmentNames: [],
    selectedSegmentIds: [],
    selectedCategoriesIds: [],
    selectedCategoryNames: []
  };

  COLLECTION_STRUCT = {
    type: "Title",
    coverImage: {
      imgUrl: "",
      description: "Lorem Ipsum",
      button: {
        url: "/buttonNavigationURL",
        label: this.mallDefaultButtonTitle,
        title: this.mallDefaultButtonTitle,
        readMoreUrl: "",
        hideModal: false
      }
    },
    modal: {
      buttons: [],
      header: ""
    },
    list: []
  };

  trueVal = false;

  segments = [];
  selectedSegment;
  selectedSegmentIds = [];
  categories = [];
  selectedCategoryIds = [];
  @track searchOptions;
  allCategoryIds = [];

  selectedCategoryId = DEFAULT_CATEGORY_NAME;

  allShops;
  @track shopCollection;
  allProducts;
  @track productCollection;
  allPromotions;
  @track promotionCollection;
  @track bannerCollection;
  @track staticBannerRecord;
  @track guidedSolutionCollection;
  @track serviceCollection;
  @track businessEventCollection;
  @track solutionCollection;

  runOnce = false;
  error = undefined;
  connectedCallBackRunOnce = false;
  isLoading = false;
  languageChangeSubscription = null;
  mallStateChangeSubscription = null;
  translationsLoaded = false;
  isGuestBool = IS_GUEST;
  registerDestinationUrl = getBaseUrl() + "/mall/s/sign-up";
  navigateToWebPage = navigateToWebPage.bind(this);
  showSolutionCatalogueLink = true;
  @wire(MessageContext)
  messageContext;

  mallTrustedPartnerTitle = MALL_HOMEPAGE_TRUSTED_PARTNER_TITLE;
  mallServicesTitle = MALL_HOMEPAGE_SERVICES_TITLE;
  mallServicesDescription = MALL_HOMEPAGE_SERVICES_COVER_DESCRIPTION;
  mallPopularServicesDescription =
    MALL_HOMEPAGE_POPULAR_SERVICES_COVER_DESCRIPTION;
  mallGuidedSolutionDescription =
    MALL_HOMEPAGE_GUIDED_SOLUTION_COVER_DESCRIPTION;
  mallBusinessEventDescription = MALL_HOMEPAGE_BUSINESS_EVENT_COVER_DESCRIPTION;
  mallPopularServicesTitle = MALL_HOMEPAGE_POPULAR_SERVICES_TITLE;
  mallGuidedSolutionTitle = MALL_HOMEPAGE_GUIDED_SOLUTIONS_TITLE;
  mallMyDashboardTitle = MALL_HOMEPAGE_MYDASHBOARD_TITLE;
  mallAddGoalTitle = MALL_HOMEPAGE_ADDGOAL_TITLE;
  mallRegisterTitle = MALL_SIGN_UP_OR_SIGN_IN;
  mallDefaultButtonTitle = MALL_DEFAULT_BUTTON_TITLE;
  mallBusinessEventTitle = MALL_HOMEPAGE_BUSINESS_EVENT_TITLE;

  tokenVsLabelsObject = {
    mallTrustedPartnerTitle: "MALL_TRUSTED_PARTNER_TITLE",
    mallServicesTitle: "MALL_SERVICES_TITLE",
    mallServicesDescription: "MALL_SERVICES_DESCRIPTION",
    mallGuidedSolutionDescription: "MALL_GUIDED_SOLUTION_DESC",
    mallBusinessEventDescription: "MALL_BUSINESS_EVENT_DESC",
    mallPopularServicesTitle: "MALL_POPULAR_SERVICES_TITLE",
    mallGuidedSolutionTitle: "MALL_GUIDED_SOLUTIONS_TITLE",
    mallMyDashboardTitle: "MALL_MYDASHBOARD_TITLE",
    mallAddGoalTitle: "MALL_ADDGOAL_TITLE",
    mallRegisterTitle: "MALL_SIGN_UP_OR_SIGN_IN",
    mallDefaultButtonTitle: "MALL_DEFAULT_BUTTON_TITLE",
    mallBusinessEventTitle: "MALL_BUSINESS_EVENT_TITLE"
  };

  //get the translated labels
  async getTranslatedLabels() {
    try {
      const translatedLabelsInstance = MallTranslationService.getInstance();
      const translatedLabels =
        await translatedLabelsInstance.getTranslatedLabels();
      this.setUpTranslatedLabels(translatedLabels);
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

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.pageType = currentPageReference.attributes.name;
    }
  }

  /*Handle Mall State change Event*/
  handleMallStateChange(message) {
    let mallStateConfig = { ...message };
    this.mallStateConfig = { ...mallStateConfig };

    this.refreshMallState();
  }

  /*handleclanguage change event*/
  handleLanguageChange(message) {
    let languageISOCode = message.languageISOCode;
    this.selectedLanguageISOCode = languageISOCode;
    setUserState(
      mallStateName.mallUserSelectedLanguageISOCode,
      this.selectedLanguageISOCode
    );
    this.init();
  }

  /*subscribe for language change event*/
  subscribeToLanguageChangeMessageChannel() {
    if (!this.languageChangeSubscription) {
      this.languageChangeSubscription = subscribe(
        this.messageContext,
        USER_LANGUAGE_CHANGED_EVT,
        (message) => this.handleLanguageChange(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  /*Unsubscribe language change event*/
  unsubscribeToLanguageChangeMessageChannel() {
    unsubscribe(this.languageChangeSubscription);
    this.languageChangeSubscription = null;
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

  connectedCallback() {
    this.subscribeToLanguageChangeMessageChannel();
    this.subscribeToMallStateChangeMessageChannel();
    this.getTranslatedLabels();
    this.init();
  }

  renderedCallback() {}

  disconnectedCallback() {
    this.unsubscribeToLanguageChangeMessageChannel();
    this.unsubscribeToMallStateChangeMessageChannel();
  }

  /*handle Category change*/
  handleCategoryChange(event) {
    if (event.detail.value === DEFAULT_CATEGORY_NAME) {
      this.selectedCategoryId = DEFAULT_CATEGORY_NAME;
      this.selectedCategoryIds = this.allCategoryIds;
    } else {
      this.selectedCategoryId = event.detail.value;
      this.selectedCategoryIds = [this.selectedCategoryId];
    }
    let message = {
      mallUserSelectedCountry: getUserState(
        mallStateName.mallUserSelectedCountry,
        DEFAULT_MALL_COUNTRY
      ),
      mallUserSelectedLanguage: getUserState(
        mallStateName.mallUserSelectedLanguageISOCode,
        DEFAULT_MALL_LANGUAGE_ISO
      ),
      selectedSegmentIds: this.selectedSegmentIds,
      selectedCategoryIds: this.selectedCategoryIds
    };
    publish(this.messageContext, USER_MALLSTATE_CHANGED_EVT, message);
  }

  /* Init function for the mall home page */
  async init() {
    let mallStateConfig = { ...this.mallStateConfig };
    let mallCollection = {};
    try {
      let selectedSegmentName = SEGMENT_DEFAULT.toLocaleLowerCase();
      mallStateConfig.selectedSegmentNames = [selectedSegmentName];
      mallStateConfig.selectedCategoryNames = [
        getUserState(mallStateName.selectedCategoryName)
      ];
      mallStateConfig.mallUserSelectedCountry = getUserState(
        mallStateName.mallUserSelectedCountry,
        DEFAULT_MALL_COUNTRY
      );
      mallStateConfig.mallUserSelectedLanguage = getUserState(
        mallStateName.mallUserSelectedLanguageISOCode,
        DEFAULT_MALL_LANGUAGE_ISO
      );

      this.mallStateConfig = { ...mallStateConfig };
      mallCollection = await initialization({
        mallContext: JSON.stringify(this.mallStateConfig)
      });

      this.processSegmentInfo(mallCollection.segments);
      this.processCategoriesInfo(mallCollection.categories);
      this.processSolutionCollection(mallCollection.solutions);
      this.processPromotionCollection(mallCollection.promotions);
      this.processServiceCollectionInfo(mallCollection.services, null);
      this.processBusinessEventCollection(mallCollection.events, null);
      await this.getSolutionsBySegmentAndCategoryIds(
        JSON.stringify(this.mallStateConfig),
        mallStateConfig
      );
      this.connectedCallBackRunOnce = true;
    } catch (error) {
      this.error = error;
    }
  }

  /*method to refresh mall home state after mallStateChange event*/
  async refreshMallState() {
    try {
      let mallStateConfig = {};
      mallStateConfig.mallUserSelectedCountry =
        this.mallStateConfig.mallUserSelectedCountry;
      mallStateConfig.mallUserSelectedLanguage =
        this.mallStateConfig.mallUserSelectedLanguage;
      mallStateConfig.selectedSegmentIds = [
        ...this.mallStateConfig.selectedSegmentIds
      ];
      mallStateConfig.selectedCategoryIds = [
        ...this.mallStateConfig.selectedCategoryIds
      ];
      mallStateConfig.selectedCategoryNames = [
        ...this.mallStateConfig.selectedCategoryNames
      ];

      let mallContext = JSON.stringify(mallStateConfig);
      await this.getSolutionsBySegmentAndCategoryIds(
        mallContext,
        mallStateConfig
      );
      await this.getPromotionsBySegmentAndCategory(
        mallContext,
        mallStateConfig
      );
      await this.getProductsBySegmentAndCategories(
        mallContext,
        mallStateConfig
      );
      await this.getEventsBySegmentAndCategories(mallContext, mallStateConfig);
    } catch (error) {
      this.error = error;
    }
  }

  getTaggingOptions(tags) {
    return tags.map((DenormalizedTag) => {
      return {
        label: DenormalizedTag.name,
        value: DenormalizedTag.id,
        labeloutput: DenormalizedTag.title
      };
    });
  }

  getSelectedTag(tags, selectedSegmentLabel) {
    let selectedSegment = tags.filter((denormalizedTag) => {
      if (
        denormalizedTag.name.toLowerCase() ===
        selectedSegmentLabel.toLowerCase()
      ) {
        return true;
      } else {
        return false;
      }
    });
    return selectedSegment;
  }

  setTagIds(tags) {
    let tagIds = [];
    tagIds = tags.map((denormalizedTag) => {
      return denormalizedTag.id;
    });
    return tagIds;
  }

  async getProductsBySegmentAndCategories(mallContext, params) {
    try {
      let offerings = await getProductsBySegmentAndCategoryIds({
        mallContext: mallContext,
        segmentIds: params.selectedSegmentIds,
        categoryIds: params.selectedCategoryIds
      });
      let services = [];
      offerings.map((offering) => {
        if (offering.offeringType == "Service") {
          services.push(offering);
        }
      });
      this.processServiceCollectionInfo(services, null);
    } catch (error) {
      this.error = error;
    }
  }

  async getPromotionsBySegmentAndCategory(mallContext, params) {
    try {
      let promotions = await getPromotionsBySegmentAndCategoryIds({
        mallContext: mallContext,
        segmentIds: params.selectedSegmentIds,
        categoryIds: params.selectedCategoryIds
      });
      let selectedCategoryName;
      if (
        params &&
        params.selectedCategoryNames &&
        params.selectedCategoryNames.length
      ) {
        if (params.selectedCategoryNames[0] != DEFAULT_CATEGORY_NAME) {
          selectedCategoryName = params.selectedCategoryNames[0];
        } else {
          selectedCategoryName = "";
        }
      }
      this.processPromotionCollection(promotions, selectedCategoryName);
    } catch (error) {
      this.error = error;
    }
  }

  async getSolutionsBySegmentAndCategoryIds(mallContext, params) {
    try {
      let selectedCategoryName;
      if (
        params &&
        params.selectedCategoryNames &&
        params.selectedCategoryNames.length
      ) {
        if (params.selectedCategoryNames[0] != DEFAULT_CATEGORY_NAME) {
          selectedCategoryName = params.selectedCategoryNames[0];
        } else {
          selectedCategoryName = "";
        }
      }
      let solutionsForSelectedCategory = [];
      let solutionsResponse = await getSolutionsBySegmentAndCategories({
        mallContext: mallContext,
        segmentIds: params.selectedSegmentIds,
        categoryIds: params.selectedCategoryIds
      });

      if (solutionsResponse && solutionsResponse.length > 0) {
        solutionsForSelectedCategory = solutionsResponse[0].solutions;
      }
      this.processSolutionCollection(
        solutionsForSelectedCategory,
        selectedCategoryName
      );
    } catch (error) {
      this.error = error;
    }
  }

  async getEventsBySegmentAndCategories(mallContext, params) {
    try {
      let events = await getEventsBySegmentAndCategoryIds({
        mallContext: mallContext,
        segmentIds: params.selectedSegmentIds,
        categoryIds: params.selectedCategoryIds
      });
      this.processBusinessEventCollection(events);
    } catch (error) {
      this.error = error;
    }
  }

  async getSelectedSegmentName() {
    return SEGMENT_DEFAULT;
  }

  processSegmentInfo(segments) {
    if (!segments) {
      this.segments = [];
      this.selectedCategoryIds = [];
      return;
    }
    this.segments = [...segments];
    this.selectedSegmentIds = this.setTagIds([...segments]);
    this.mallStateConfig.selectedSegmentIds = [...this.selectedSegmentIds];
  }

  processCategoriesInfo(categories) {
    if (!categories) {
      this.categories = [];
      this.searchOptions = [];
      this.selectedCategoryIds = [];
      return;
    }
    this.categories = [...categories];
    this.searchOptions = this.getTaggingOptions([...categories]);
    this.searchOptions.push({
      label: DEFAULT_CATEGORY_NAME,
      value: DEFAULT_CATEGORY_NAME,
      labeloutput: DEFAULT_CATEGORY_NAME
    });
    this.selectedCategoryIds = this.setTagIds([...categories]);
    this.allCategoryIds = this.setTagIds([...categories]);
    this.mallStateConfig.selectedCategoryIds = [...this.selectedCategoryIds];
  }

  processServiceCollectionInfo(services, selectedCategoryName) {
    let serviceCollectionObject = JSON.parse(
      JSON.stringify(this.COLLECTION_STRUCT)
    );
    serviceCollectionObject.type = this.mallServicesTitle;
    serviceCollectionObject.coverImage = {
      description: this.mallPopularServicesDescription
    };
    let serviceCollection = this.processOfferingCollectionInfo(
      services,
      selectedCategoryName,
      serviceCollectionObject
    );
    let baseUrl = getBaseUrl();
    for (let row = 0; row < serviceCollection.list.length; row++) {
      let serviceProcessed = { ...serviceCollection.list[row] };
      serviceProcessed.hideModal = true;
      serviceProcessed.url = serviceProcessed.desktopUrl;
      serviceProcessed.readMoreUrl =
        baseUrl +
        "/mall/s/tag/" +
        serviceProcessed.solutionId +
        "?" +
        "productId=" +
        serviceProcessed.id;
      serviceProcessed.buttonLabel = MALL_APPLY_NOW_BUTTON;
      serviceProcessed.taggingText = serviceProcessed.name + " Service";
      serviceProcessed.taggingTypeId = serviceProcessed.id;
      serviceProcessed.taggingScope = "BCB Platform Services";
      serviceCollection.list[row] = serviceProcessed;
    }
    this.serviceCollection = [serviceCollection];
  }

  processBusinessEventCollection(events, selectedCategoryName) {
    let businessEventCollectionObject = JSON.parse(
      JSON.stringify(this.COLLECTION_STRUCT)
    );
    businessEventCollectionObject.type = this.mallBusinessEventTitle;
    businessEventCollectionObject.coverImage = {
      description: this.mallBusinessEventDescription
    };

    if (!events) {
      businessEventCollectionObject.list = [];
      this.businessEventCollection = [];
      return;
    }

    let businessEventCollection = [];
    if (selectedCategoryName) {
      businessEventCollection = events.filter(
        (promotion) =>
          promotion.tagName.toLowerCase() == selectedCategoryName.toLowerCase()
      );
    } else {
      businessEventCollection = [...events];
    }
    businessEventCollectionObject.list = businessEventCollection;
    businessEventCollectionObject.list = this.sortData(
      "startDate",
      "asc",
      businessEventCollectionObject.list,
      "datetime"
    );
    for (let row = 0; row < businessEventCollectionObject.list.length; row++) {
      let eventProcessed = { ...businessEventCollectionObject.list[row] };
      eventProcessed.hideModal = true;
      eventProcessed.url = null;
      eventProcessed.readMoreUrl = eventProcessed.desktopUrl;
      eventProcessed.taggingText = eventProcessed.name + " business event";
      eventProcessed.taggingTypeId = eventProcessed.id;
      eventProcessed.taggingScope = "BCB Platform business events";
      businessEventCollectionObject.list[row] = eventProcessed;
    }
    this.businessEventCollection = [businessEventCollectionObject];
  }

  processOfferingCollectionInfo(
    offerings,
    selectedCategoryName,
    offeringCollectionObject
  ) {
    if (!offerings) {
      offeringCollectionObject.list = [];
      return [offeringCollectionObject];
    }
    let allOfferings = [...offerings];
    let offeringCollection = [];
    if (selectedCategoryName) {
      offeringCollection = allOfferings.filter(
        (offering) =>
          offering.tagName.toLowerCase() == selectedCategoryName.toLowerCase()
      );
    } else {
      offeringCollection = [...allOfferings];
    }
    offeringCollectionObject.list = [...offeringCollection];
    offeringCollectionObject.list = this.sortData(
      "createdDate",
      "desc",
      offeringCollectionObject.list,
      "datetime"
    );
    return offeringCollectionObject;
  }

  handleSignup() {
    putCookie("userDesiredPage", getBaseUrl() + "/mall/s/");
    putCookie("redirectToUserDesiredPage", "true");
    putCookie("redirectToExternalShopPage", "true");
    //TODO :: GH :: SHould use the navigation mixin here
    let signUpUrl = getBaseUrl() + "/mall/s/sign-up";
    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: signUpUrl
      }
    }).then((generatedUrl) => {
      window.open(generatedUrl, "_self");
    });
  }

  processPromotionCollection(promotions, selectedCategoryName) {
    let promotionCollectionObject = JSON.parse(
      JSON.stringify(this.COLLECTION_STRUCT)
    );
    promotionCollectionObject.type = "Promotions";

    if (!promotions) {
      this.allPromotions = [];
      promotionCollectionObject.list = [];
      this.bannerCollection = [];
      this.promotionCollection = [promotionCollectionObject];
      return;
    }
    this.allPromotions = [...promotions];
    let promotionCollection = [];
    if (selectedCategoryName) {
      promotionCollection = this.allPromotions.filter(
        (promotion) =>
          promotion.tagName.toLowerCase() ==
            selectedCategoryName.toLowerCase() &&
          !promotion.isDefaultCategoryBanner
      );
    } else {
      promotionCollection = this.allPromotions.filter(
        (promotion) => promotion.isDefaultCategoryBanner
      );
    }
    promotionCollectionObject.list = promotionCollection;
    this.bannerCollection = promotionCollection.filter(
      (promotion) => promotion.promotionType === "Banner"
    );
    this.bannerCollection = this.sortData(
      "rank",
      "asc",
      this.bannerCollection,
      "number"
    );
    if (this.bannerCollection.length > 0) {
      this.staticBannerRecord = this.bannerCollection[0];
    }
    this.promotionCollection = promotionCollection.filter(
      (promotion) => promotion.promotionType === "Promotion"
    );
    this.promotionCollection = this.sortData(
      "rank",
      "asc",
      this.promotionCollection,
      "number"
    );
  }

  processSolutionCollection(solutions, selectedCategoryName) {
    let solutionCollectionObject = JSON.parse(
      JSON.stringify(this.COLLECTION_STRUCT)
    );
    solutionCollectionObject.type = "Solutions";
    solutionCollectionObject.coverImage = {
      description: MALL_SOLUTIONS_COVER_DESC
    };

    if (!solutions) {
      solutionCollectionObject.list = [];
      this.solutionCollection = [];
      return;
    }
    solutionCollectionObject.list = [...solutions];
    for (let row = 0; row < solutionCollectionObject.list.length; row++) {
      let solutionProcessed = { ...solutionCollectionObject.list[row] };
      solutionProcessed.url = null;
      solutionProcessed.hideModal = true;
      solutionProcessed.readMoreUrl =
        getBaseUrl() + "/mall/s/tag/" + solutionProcessed.id;
      solutionProcessed.taggingText = solutionProcessed.name + " solutions";
      solutionProcessed.taggingTypeId = solutionProcessed.id;
      solutionProcessed.taggingScope = "BCB Platform solutions";
      solutionCollectionObject.list[row] = solutionProcessed;
    }
    this.solutionCollection = [solutionCollectionObject];
  }

  sortData(fieldName, sortDirection, array, type) {
    let sortResult = [...array];
    let parser = (v) => v;
    if (type === "date" || type === "datetime") {
      parser = (v) => v && new Date(v);
    }
    let sortMult = sortDirection === "asc" ? 1 : -1;
    array = sortResult.sort((a, b) => {
      let a1 = parser(a[fieldName]),
        b1 = parser(b[fieldName]);
      let r1 = a1 < b1,
        r2 = a1 === b1;
      return r2 ? 0 : r1 ? -sortMult : sortMult;
    });
    return array;
  }

  handleModalButtonClick(event) {
    const message = event.detail;
    const buttonName = message.buttonName;
    const record = message.record;
    const callback = message.callback;
    this[callback](record, buttonName);
  }

  handleAddGoal(record) {
    const baseUrl = getBaseUrl();
    const guidedSolutionPage = baseUrl + "/mall/s/" + "guided-solutions";
    const guidedSolutionUrl =
      guidedSolutionPage + "?" + "solutionId=" + record.id;
    this.navigateToWebPage(guidedSolutionUrl);
  }

  handleGoToRegister() {
    const baseUrl = getBaseUrl();
    const signupurl = baseUrl + "/mall/s/" + "sign-up";
    this.navigateToWebPage(signupurl);
  }

  goToSolutionsCatalogue(event) {
    event.preventDefault();
    event.stopPropagation();
    let link = getBaseUrl() + "/mall/s/solutions-catalogue";
    this.navigateToWebPage(link);
  }
  mallHomeBanner1 = mallHomeBanners + "/CombinedBannerImage.png";
  mallHomeBanner2 = mallHomeBanners + "/DesktopView.jpg";
  mallHomeOperationsImage = mallHomeBanners + "/Opperations.png";
  mallGridImage1 = mallHomeGridImages + "/GridImage1.PNG";
  mallGridImage2 = mallHomeGridImages + "/GridImage2.PNG";
  mallHomeSwitch = mallHomeBanners + "/MallSwitchBannerImage.png";
}