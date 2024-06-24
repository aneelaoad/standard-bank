import { LightningElement, wire, api } from "lwc";
import Id from "@salesforce/user/Id";
import { refreshApex } from "@salesforce/apex";
import {
  subscribe,
  APPLICATION_SCOPE,
  MessageContext,
} from "lightning/messageService";
import ApplicationRefresh from "@salesforce/messageChannel/osbApplicationRefresh__c";
import {
  interactionSearch,
  pageViewSinglePageApp,
} from "c/osbAdobeAnalyticsWrapperLwc";
import getSolutionShowcaseWithCategory from "@salesforce/apex/OSB_SolutionShowcase_CTRL.getSolutionShowcaseWithCategory";
import getSolutionSearchResultsWithCategory from "@salesforce/apex/OSB_SolutionShowcase_CTRL.getSolutionSearchResultsWithCategory";
import getRegisteredApplicationRT from "@salesforce/apex/OSB_Dashboard_CTRL.getRegisteredApplicationwithRecordType";
import OSB_Images from "@salesforce/resourceUrl/OSB_OnehubDashboard";
import PROVIDER_CHANNEL from '@salesforce/messageChannel/Provider_Channel__c';


const DELAY = 300;
export default class osbApplicationGallerylwc extends LightningElement {
  NoResultsImg = OSB_Images + "/SearchResult.svg";
  userId = Id;
  searchinput;
  categories;
  appSolutions = [];
  appSearchedSolutions = [];
  refreshResult;
  refreshRegisteredResult;
  refreshSearchResults;
  noResults = false;
  regApps = [];
  isLoading = false;
  displayResults = false;
  initialLoad = true;
  showProvider = false;
  providerid;
  subcription = null;
  providerId;
  showPagination = false;
  @api
  get searchInputValue() {
    return this.searchinput;
  }

  set searchInputValue(value) {
    if (value.length >= 2) {
      this.searchinput = value;
    } else {
      this.searchinput = "";
      this.noResults = false;
    }
  }

  @api
  get categoryValue() {
    return this.categories;
  }

  set categoryValue(value) {
    this.categories = value;
  }

  @wire(MessageContext)
  messageContext;

  subscribeToMessageChannel() {
    if (!this.Applicationsubscription) {
      this.Applicationsubscription = subscribe(
        this.messageContext,
        ApplicationRefresh,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE }
      );
    }
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        PROVIDER_CHANNEL,
        (message) => this.handleMessage(message)
      );
    }

  }

  updateRegApps() {
    return refreshApex(this.refreshRegisteredResult);
  }

  updateSearchApplications() {
    return refreshApex(this.refreshSearchResults);
  }

  updateApplications() {
    return refreshApex(this.refreshResult);
  }

  handleMessage(message) {
    this.recordAdded = message.recordAdded;
    this.providerId = message.providerId;  
    this.showProvider = true;
    this.showPagination = false;
    this.updateRegApps();
    this.updateSearchApplications();
    return refreshApex(this.refreshResult);
  }

  connectedCallback() {
    this.subscribeToMessageChannel();
    pageViewSinglePageApp("Application gallery");
  }

  @wire(getRegisteredApplicationRT)
  getRegisteredApplicationRT(result) {
    this.refreshRegisteredResult = result;
    if (result.data) {
      let myapps = JSON.parse(JSON.stringify(result.data));
      this.regApps = myapps;
    }
  }

  @wire(getSolutionShowcaseWithCategory, {
    userId: "$userId",
    categories: "$categories",
  })


  getSolutionShowcaseWithCategory(result) {
    this.refreshResult = result;
    this.noResults = false;
    if (result.data) {
      this.isLoading = true;
      this.displayResults = false;
      let mySolutions = JSON.parse(JSON.stringify(result.data));
      let ApplicationSolutions = [];
      for (let i = 0; i < mySolutions.length; i++) {
        if (!mySolutions[i].Is_coming_soon__c) {
          ApplicationSolutions.push(mySolutions[i]);
        }
      }

      this.isLoading = false;
      if (ApplicationSolutions.length > 0) {
        this.noResults = false;
        this.displayResults = true;
        this.appSolutions = this.arrangeList(ApplicationSolutions);
      } else {
        this.noResults = true;
      }
      if (!this.initialLoad) {
        this.publishToAdobeClickFilter();
      }

      this.initialLoad = false;
    }
    this.updateApplications();
  }

  @wire(getSolutionSearchResultsWithCategory, {
    userId: "$userId",
    searchKeyword: "$searchinput",
    categories: "$categories",
  })
  getSolutionSearchResultsWithCategory(result) {
    this.noResults = false;
    this.refreshSearchResults = result;
    if (result.data) {
      this.isLoading = true;
      this.displayResults = false;
      let mySolutions = JSON.parse(JSON.stringify(result.data));
      let myRegisteredSolutions = JSON.parse(JSON.stringify(this.regApps));
      let ApplicationSolutions = [];
      for (let i = 0; i < mySolutions.length; i++) {
        if (!mySolutions[i].Is_coming_soon__c) {
          let alreadyRegister = false;
          for (let j = 0; j < myRegisteredSolutions.length; j++) {
            if (
              myRegisteredSolutions[j].Solution__r.Title == mySolutions[i].Title
            ) {
              alreadyRegister = true;
            }
          }
          if (!alreadyRegister) {
            ApplicationSolutions.push(mySolutions[i]);
          }
        }
      }
      this.isLoading = false;

      if (ApplicationSolutions.length > 0) {
        this.displayResults = false;
        this.noResults = false;
        this.delayTimeout = setTimeout(() => {
          this.appSearchedSolutions = this.arrangeList(ApplicationSolutions);
          if (!this.initialLoad) {
            this.publishToAdobeClickSearch();
          }
        }, DELAY);
      } else {
        this.noResults = true;
        if (!this.initialLoad) {
          this.publishToAdobeClickSearch();
        }
      }
      this.initialLoad = false;
    }
  }

  arrangeList(unArrangedList) {
    let newList = JSON.parse(JSON.stringify(unArrangedList));
    let ArrangedList = newList.sort(function (a, b) {
      let titleA = a.Title.toLowerCase(),
        titleB = b.Title.toLowerCase();
      if (titleA < titleB) return -1;
      if (titleA > titleB) return 1;
      return 0;
    });

    ArrangedList = [...new Set(ArrangedList)];
    return ArrangedList;
  }

  publishToAdobeClickSearch() {
    let eventData = {
      searchTerm: this.searchinput,
      search: {
        filter: this.categories !== null ? this.categories : "",
        sorting: "default-sorting",
      },
      searchResult: this.appSearchedSolutions.length,
      linkScope: "Application gallery",
    };
    interactionSearch(eventData);
  }

  publishToAdobeClickFilter() {
    let eventData = {
      searchTerm: this.categories,
      search: {
        filter: this.categories !== null ? this.categories : "",
        sorting: "default-sorting",
      },
      searchResult: this.appSolutions.length,
      linkScope: "Application gallery",
    };
    interactionSearch(eventData);
  }
}