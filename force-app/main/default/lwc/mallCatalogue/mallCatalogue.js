import { LightningElement, track, wire } from "lwc";
import { putCookie } from "c/cmnCookieUtils";
import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { addSearchAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { CurrentPageReference } from "lightning/navigation";
import { MallTranslationService } from "c/mallTranslationService";
import MALL_ALL_OPTIONS from "@salesforce/label/c.MALL_ALL_OPTIONS";
import { navigateToRecordPage } from "c/mallNavigation";
import { NavigationMixin } from "lightning/navigation";
import USER_MALLSTATE_CHANGED_EVT from "@salesforce/messageChannel/UserMallStateChanged__c";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import getSolutionsBySegmentAndCategories from "@salesforce/apex/MallDataService.getSolutionsBySegmentAndCategories";

const SEGMENT_DEFAULT = "Business";

export default class MallCatalogue extends NavigationMixin(LightningElement) {
  pageType;
  isCatalogue = true;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.pageType = currentPageReference.attributes.name;
    }
  }

  get searchPlaceholderText() {
    return "Discover more...";
  }

  backIcon = sbgVisualAssets + "/icn_chevron_left.svg";
  runOnce = false;
  segments;
  categories;
  passSearchData = true;
  mallStateConfig;
  subscription = null;

  @track selectedSegmentName = SEGMENT_DEFAULT;
  @track selectedCategories = [];

  leftDisabled = true;
  rightDisabled = true;
  enableScroll = false;
  navigateToRecordPage = navigateToRecordPage.bind(this);
  mallStateChangeSubscription = null;
  @track solutionCollection = [];

  @wire(MessageContext)
  messageContext;

  /*Handle Mall State change Event*/
  handleMallStateChange(message) {
    let mallStateConfig = { ...message };
    this.mallStateConfig = { ...mallStateConfig };
    this.getSolutionsBySegmentAndCategoryIds(
      JSON.stringify(mallStateConfig),
      mallStateConfig
    );
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

  //Code to setup the translations for the labels
  tokenVsLabelsObject = {
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
        if (property) {
          const value = translatedLabelsInstance.getTranslatedLabelByLabelName(
            this.tokenVsLabelsObject[property],
            translatedLabels
          );
          this[property] = value ? value : this[property];
        }
      }
    }
  }

  async getSolutionsBySegmentAndCategoryIds(mallContext, params) {
    try {
      let mallStateConfig = {};
      mallStateConfig.mallUserSelectedCountry =
        this.mallStateConfig.mallUserSelectedCountry;
      mallStateConfig.mallUserSelectedLanguage =
        this.mallStateConfig.mallUserSelectedLanguage;
      if(this.mallStateConfig.selectedSegmentIds && this.mallStateConfig.selectedSegmentIds.length > 0) {
        mallStateConfig.selectedSegmentIds = [
          ...this.mallStateConfig.selectedSegmentIds
        ];
      }
      mallStateConfig.selectedCategoryIds = [
        ...this.mallStateConfig.selectedCategoryIds
      ];
      mallStateConfig.selectedCategoryNames = [
        ...this.mallStateConfig.selectedCategoryNames
      ];

      let solutionsResponse = await getSolutionsBySegmentAndCategories({
        mallContext: mallContext,
        segmentIds: params.selectedSegmentIds,
        categoryIds: params.selectedCategoryIds
      });

      let solutionResponseCopy = JSON.parse(JSON.stringify(solutionsResponse));
      let solutionResponseCopyNew = [];

      for (let row = 0; row < solutionResponseCopy.length; row++) {
        let recordCopy = { ...solutionResponseCopy[row] };
        for (let k = 0; k < recordCopy.solutions.length; k++) {
          let solutionRec = { ...recordCopy.solutions[k] };
          solutionRec.url = null;
          solutionRec.hideModal = true;
          solutionRec.readMoreUrl =
            window.location.origin +
            "/mall/s/tag/" +
            solutionResponseCopy[row].solutions[k].id;
          recordCopy.solutions[k] = { ...solutionRec };
        }
        solutionResponseCopyNew.push(recordCopy);
      }
      this.solutionCollection = [...solutionResponseCopyNew];
    } catch (error) {
      this.error = error;
    }
  }

  renderedCallback() {
    addAnalyticsInteractions(this.template);
  }

  connectedCallback() {
    this.subscribeToMallStateChangeMessageChannel();
    this.getTranslatedLabels();
  }

  disconnectedCallback() {
    this.unsubscribeToMallStateChangeMessageChannel();
  }

  fireSearchTag() {
    let totalResultCount;
    if (this.activeCategoryName === MALL_ALL_OPTIONS) {
      totalResultCount = this.shopList.length;
    } else {
      totalResultCount = this.filteredCollection.length;
    }
    addSearchAnalyticsInteractions(
      totalResultCount,
      this.activeCategoryName,
      this.selectedSegmentName,
      this.pageType
    );
    putCookie("searchResults", totalResultCount);
    putCookie("term", this.selectedSegmentName);
    putCookie("filter", this.activeCategoryName);
  }

  toggleOpen(event) {
    event.target.classList.toggle("open");
  }

  get isViewAllSelected() {
    return this.activeCategoryName === MALL_ALL_OPTIONS;
  }

  handleSolutionsClick(event) {
    const solutionId = event.currentTarget.dataset.solutionid;
    this.navigateToRecordPage(solutionId);
  }

  updateSelectedCategories(selectedCategories) {
    this.selectedCategories = selectedCategories;
  }

  clearCategory(event) {
    const categoryId = event.currentTarget.dataset.categoryId;
    if (this.selectedCategories && this.selectedCategories.length > 1) {
      this.selectedCategories = this.selectedCategories.filter(
        (category) => category.id !== categoryId
      );
      this.mallStateConfig.selectedCategoryIds = this.selectedCategories.map(
        (category) => category.id
      );
      this.mallStateConfig.selectedCategoryNames = this.selectedCategories.map(
        (category) => category.name
      );
      this.handleMallStateChange(this.mallStateConfig);
    }
  }

  handleFilter(event) {
    this.selectedCategories = event.detail.selectedCategories;
    this.mallStateConfig = event.detail.mallStateConfig;
    this.handleMallStateChange(this.mallStateConfig);
  }
}