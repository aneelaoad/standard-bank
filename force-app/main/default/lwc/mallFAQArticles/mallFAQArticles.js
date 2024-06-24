import { LightningElement, wire, track } from "lwc";
import getFAQsInfo from "@salesforce/apex/MallFAQArticlesController.getFAQsInfo";
import { mallStateName, getUserState } from "c/sbgUserStateUtils";
import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext
} from "lightning/messageService";
import USER_LANGUAGE_CHANGED_EVT from "@salesforce/messageChannel/UserLanguageChanged__c";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";

const DEFAULT_MALL_COUNTRY = "South Africa";

export default class MallFAQArticles extends NavigationMixin(LightningElement) {
  error;
  tabs;
  @track selectedTab = {};
  @track accordionData;
  subscription = null;
  currentPageReference;
  @wire(MessageContext)
  messageContext;
  tabsLoaded = false;
  tabsMeta = {};
  @track faqData;

  audienceMap = {
    'Client' : 'For shoppers',
    'Staff' : 'For tenants'
  }

  connectedCallback() {
    this.subscribeToMessageChannel();
    this.getFAQData();
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

  handleLanguageChange(message) {
    if (!this.selectedTab.tabName) {
      for (const property in this.tabsMeta) {
        if (this.tabsMeta[property] == this.selectedTab.value) {
          this.selectedTab.tabName = property;
        }
      }
    }
    if (this.selectedTab.tabName) {
      this.fetchForSelectedFAQSAudience(this.selectedTab.tabName);
    }
  }

  async fetchFAQTabs() {
    try {
        let tabs = [];
        let tabsMeta = this.tabsMeta;
        for (const key in tabsMeta) {
          tabs.push({ tabName: this.audienceMap[key], value: this.audienceMap[key] });
        }
        tabs.sort(function(a,b){return a.value-b.value});
        this.tabsLoaded = true;
        this.tabs = [...tabs];
    } catch (error) {
      this.error = error;
    }
  }

  async getFAQsTabs() {
    try {
      let tabsMeta = {};
      for (const key in this.faqData) {
        if (this.faqData.hasOwnProperty(key)) {
          tabsMeta[key] = this.audienceMap[key] ? this.audienceMap[key] : key;
        }
      }
      this.tabsMeta = tabsMeta;
    } catch (error) {
      this.error = error;
    }
  }

  async fetchForSelectedFAQSAudience(selectedTab) {
    try{
      this.accordionData = JSON.stringify(this.faqData[selectedTab]);
    }
    catch (error) {
      this.error = error;
    }
  }

  async getFAQData() {
      try {
        let userSelectedCountry = getUserState(
          mallStateName.mallUserSelectedCountry,
          DEFAULT_MALL_COUNTRY
        );
        let result = await getFAQsInfo({
          country: userSelectedCountry,
          category: 'FAQ'
        });
        this.faqData = JSON.parse(result);
        if (this.objectIsEmpty(this.tabsMeta));
        {
          this.getFAQsTabs();
          this.fetchFAQTabs();
        }
        if (!this.objectIsEmpty(this.tabsMeta) && !this.accordionData) {
          for (const property in this.tabsMeta) {
            if (this.tabsMeta[property] == this.selectedTab.value) {
              this.fetchForSelectedFAQSAudience(property);
            }
          }
        }
      } catch (error) {
        this.error = error;
      }

  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    this.currentPageReference = currentPageReference;
    if (this.objectIsEmpty(this.tabsMeta));
    {
      this.getFAQsTabs();
      this.fetchFAQTabs();
    }
    if (currentPageReference) {
      let tabValue = currentPageReference.state["tab"];
      this.selectedTab.value = tabValue;
      if (tabValue) {
        for (const property in this.tabsMeta) {
          if (tabValue && this.tabsMeta[property] == tabValue) {
            this.selectedTab = { tabName: property, value: tabValue };
            this.fetchForSelectedFAQSAudience(this.selectedTab.tabName);
            break;
          }
        }
      }
    }
  }

  handleTabChange(event) {
    event.preventDefault();
    event.stopPropagation();
    let selectedTab = event.target.value;
    this.handleStateChange(selectedTab);
  }

  handleStateChange(selectedTabValue) {
    let updatedPageReference = this.getUpdatedPageReference({
      tab: selectedTabValue
    });
    this[NavigationMixin.Navigate](updatedPageReference, true);
  }

  renderedCallback() {
    addAnalyticsInteractions(this.template);
  }

  getUpdatedPageReference(stateChanges) {
    return Object.assign({}, this.currentPageReference, {
      state: Object.assign({}, this.currentPageReference.state, stateChanges)
    });
  }

  objectIsEmpty(object) {
    return Object.keys(object).length === 0;
  }
}