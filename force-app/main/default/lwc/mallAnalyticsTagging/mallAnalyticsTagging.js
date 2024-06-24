import { LightningElement, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { getCookie } from "c/cmnCookieUtils";
import getCurrentUser from "@salesforce/apex/SBGNavigationBarController.getCurrentUser";
import IS_GUEST from "@salesforce/user/isGuest";

/**
 * @description We set data on rendered callback. Expressly for page level tagging.
 * @author Grant Henderson | 26 July 2022
 * @param data The window level data of the component
 **/
export default class MallAnalyticsTagging extends LightningElement {
  currentPageReference;

  // recordId;
  isUserSignedIn;
  userId;
  currentLanguage;
  currentCountry;
  deviceCheck = /Mobile/i.test(navigator.userAgent) ? "Mobile" : "Desktop";
  isUserIdReady = true;
  initDataLayer = {};

  getLanguage() {
    let language = getCookie("MallUserSelectedLanguage")
      ? getCookie("MallUserSelectedLanguage")
      : undefined;
    return (this.currentLanguage = language || "English");
  }

  getCountry() {
    let country = getCookie("MallUserSelectedCountry")
      ? getCookie("MallUserSelectedCountry")
      : undefined;
    return (this.currentCountry = country || "South Africa");
  }

  userLoginCheck() {
    return (this.isUserSignedIn = IS_GUEST ? "guest" : "logged in");
  }

  checkUserId() {
    if (this.userId !== "") {
      this.isUserIdReady = true;
    }

    if (this.isUserIdReady === false) {
      window.setTimeout(
        this.checkUserId,
        100
      ); /* this checks the flag every 100 milliseconds*/
    }
  }

  async getUserId() {
    if (IS_GUEST) return (this.userId = "");
    this.isUserIdReady = false;

    let user = await getCurrentUser();
    if (user !== undefined) {
      this.userId = user.FederationIdentifier;
    }
  }

  /**
   * @description This function will get the page reference data and send it to screenLoadHandler() if chriteria are met.
   * @author Bradley Greenwood | 31-03-2022
   * @param CurrentPageReference current reference data
   **/

  @wire(CurrentPageReference)
  getPageReferenceParameters(currentPageReference) {
    if (!this.siteInPreviewMode()) {
      this.currentPageReference = currentPageReference;
      this.setupAnalytics();
    }
  }

  /**
   * @description This function initializes the Adobe analytics integration
   * @author Bradley Greenwood | 31-03-2022
   **/
  setupAnalytics() {
    //Grab some dynamic values to populate fields for the datalayer
    this.getCountry();
    this.getLanguage();
    this.userLoginCheck();
    this.getUserId();

    while (this.isUserIdReady !== true) {
      this.checkUserId();
    }
    //Now we set up the dataLayer
    this.initDataLayer = {
      articleName: "",
      articleCategory: "",
      application: {
        applicationProduct: "",
        applicationMethod: "",
        applicationID: "",
        applicationName: "",
        applicationStep: "",
        applicationStart: false,
        applicationComplete: false
      },
      customerGUID: this.userId,
      deviceType: this.deviceCheck,
      domainName: window.location.hostname,
      formisSubmitted: false,
      formName: "",
      formStatus: "",
      loginStatus: this.isUserSignedIn,
      numSearchResults: "",
      pageCategory: "",
      pageName: "",
      pageSubSection1: "",
      pageSubSection2: "",
      pageSubSection3: "",
      pageSubSection4: "",
      platformIdentifier: "Salesforce Community",
      search: {
        filter: ""
      },
      searchTerm: "",
      siteCountry: this.currentCountry,
      siteErrorCode: "",
      siteLanguage: this.currentLanguage,
      websiteName: "SBG Mall",
      websiteNameCode: "SBM",
      storeID: "",
      serviceID:"",
      eventID:"",
      guidedSolutionID:"",
      insightID:""
    };

    window.initDataLayer = this.initDataLayer;

    if (typeof window.aaPreviousPage == "undefined") {
      window.aaPreviousPage = "";
    }

    if (
      this.currentPageReference.attributes.name &&
      this.currentPageReference.attributes.name != window.aaPreviousPage
    ) {
      this.screenLoadHandler(this.currentPageReference.attributes.name);
    } else if (
      this.currentPageReference.state.recordName &&
      this.currentPageReference.state.recordName != window.aaPreviousPage
    ) {
      this.screenLoadHandler(this.currentPageReference.state.recordName);
    } else if (
      this.currentPageReference.type &&
      this.currentPageReference.type == "standard__search" &&
      this.currentPageReference.type != window.aaPreviousPage
    ) {
      this.screenLoadHandler(this.currentPageReference.type);
    }
  }

  /**
   * @description This function will initialize the events if the site is not being viewed in the builder.
   * @author Bradley Greenwood | 31-03-2022
   **/
  connectedCallback() {
    if (!this.siteInPreviewMode()) {
      window.addEventListener("AA_buttonClickEvent", this.buttonClickHandler);
      window.addEventListener(
        "AA_searchResultEvent",
        this.searchTaggingHandler
      );
    }
  }

  searchTaggingHandler(e) {
    let pageName = e.detail.currentPageType;
    window.savedDataLayer = Object.assign({}, this.initDataLayer);
    window.savedDataLayer.numSearchResults = e.detail.resultcount;
    window.savedDataLayer.searchTerm = e.detail.term;
    window.savedDataLayer.search.filter = e.detail.filtersApplied;

    window.savedDataLayer.pageName = pageName
      .replace("__c", "")
      .replaceAll("_", " ");
    window.savedDataLayer.pageSubSection1 = pageName
      .replace("__c", "")
      .replaceAll("_", " ");
    window.savedDataLayer.pageUrl = window.location.href;
    window.savedDataLayer.pageCategory = pageName
      .replace("__c", "")
      .replaceAll("_", " ");

    window.dispatchEvent(
      new CustomEvent("adobeTrackLwcListener", {
        detail: {
          trackName: "siteSearch",
          dataLayer: window.savedDataLayer
        }
      })
    );
  }

  /**
   * @description This function tests if the user is in Experience Builder.
   * @author Bradley Greenwood | 31-03-2022
   **/
  siteInPreviewMode() {
    let urlToCheck = window.location.hostname;
    urlToCheck = urlToCheck.toLowerCase();
    return (
      urlToCheck.indexOf("sitepreview") >= 0 ||
      urlToCheck.indexOf("livepreview") >= 0
    );
  }

  /**
   * @description This function formats the current page data and fires the Adobe tracking event containing the page load data.
   * @author Bradley Greenwood | 31-03-2022
   * @param pageName This current page name
   **/
  screenLoadHandler(pageName) {
    window.aaPreviousPage = pageName;
    window.savedDataLayer = Object.assign({}, this.initDataLayer);
    window.aaCurrentPage = pageName.replace("__c", "").replaceAll("_", " ");
    window.savedDataLayer.pageName = window.aaCurrentPage;
    window.savedDataLayer.pageSubSection1 = window.aaCurrentPage;
    window.savedDataLayer.pageUrl = window.location.href;

    window.savedDataLayer.pageCategory = window.aaCurrentPage;

    window.dispatchEvent(
      new CustomEvent("adobeTrackLwcListener", {
        detail: {
          trackName: "globalVirtualPageView",
          dataLayer: window.savedDataLayer
        }
      })
    );
  }

  /**
   * @description This function formats the interaction data and fires the Adobe tracking event.
   * @author Bradley Greenwood | 31-03-2022
   * @param e The click event with relevant data attributes
   **/
  buttonClickHandler(e) {
    let eventDatasets = e.detail.event.currentTarget.dataset;
    let analyticsDataAtributes = ["scope", "text"];
    let linkDataArray = [];
    let linkString = "";

    if (typeof window.savedDataLayer == "undefined") {
      window.savedDataLayer = Object.assign({}, this.initDataLayer);
    }

    //Run through the allowed attribites and add them to an array if they are defined
    analyticsDataAtributes.forEach((value, index) => {
      if (typeof eventDatasets[value] === "string") {
        linkDataArray.push(eventDatasets[value]);
      }
    });

    //Create a string from the defined array values
    linkString = eventDatasets.text;
    //Create the data Layer to be logged
    if (typeof eventDatasets.textBefore === "string") {
      linkString = eventDatasets.textBefore + " | " + linkString;
    }
    if (typeof eventDatasets.textAfter === "string") {
      linkString = linkString + " " + eventDatasets.textAfter;
    }
    //If a type is set then add it to the end of the link string
    if (typeof eventDatasets.type === "string") {
      linkString = linkString + " " + eventDatasets.type;
    }

    if (typeof eventDatasets.scope === "string") {
      linkString = eventDatasets.scope + " | " + linkString;
    }

    //reset attributes
    window.savedDataLayer.serviceID = '';
    window.savedDataLayer.storeID = '';
    window.savedDataLayer.eventID = '';
    window.savedDataLayer.guidedSolutionID = '';
    window.savedDataLayer.insightID = '';

    if (eventDatasets.serviceId) {
      window.savedDataLayer.serviceID = eventDatasets.serviceId;
    }

    if (eventDatasets.storeId) {
      window.savedDataLayer.storeID = eventDatasets.storeId;
    }

    if (eventDatasets.eventId) {
      window.savedDataLayer.eventID = eventDatasets.eventId;
    }

    if (eventDatasets.guidedSolutionId) {
      window.savedDataLayer.guidedSolutionID = eventDatasets.guidedSolutionId;
    }

    if (eventDatasets.insightId) {
      window.savedDataLayer.insightID = eventDatasets.insightId;
    }

    window.savedDataLayer.linkName = `${eventDatasets.intent} | ${linkString}`;
    window.savedDataLayer.linkIntent = eventDatasets.intent;
    window.savedDataLayer.linkScope = eventDatasets.scope;
    window.savedDataLayer.linkId = "link_content";

    window.savedDataLayer.numSearchResults = "";
    window.savedDataLayer.searchTerm = "";
    window.savedDataLayer.search.filter = "";

    if (
      eventDatasets.passSearchDetails &&
      getCookie("searchResults") &&
      getCookie("term") &&
      getCookie("filter")
    ) {
      window.savedDataLayer.numSearchResults = getCookie("searchResults");
      window.savedDataLayer.searchTerm = getCookie("term");
      window.savedDataLayer.search.filter = getCookie("filter");
    }
    document.cookie =
      "searchResults=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/; Secure;httpOnly; SameSite=Strict";
    document.cookie = "term=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/; Secure;httpOnly; SameSite=Strict";
    document.cookie = "filter=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/; Secure;httpOnly; SameSite=Strict";

    window.dispatchEvent(
      new CustomEvent("adobeTrackLwcListener", {
        detail: {
          trackName: "genericUserInteraction",
          dataLayer: window.savedDataLayer
        }
      })
    );
  }
}

/**
 * @description This function searches for the relevant elements and sets the data-scope to the component name.
 * @author Grant Henderson | 26-09-2022
 * @param template The template data of the component
 * @returns String
 **/
function setGenericInteractionScope(template) {
  let component = template;

  return component.host.localName // c-test-component
    .split("-") // ['c', 'test', 'component']
    .slice(1) // removes ns prefix => ['test', 'component']
    .reduce((a, b) => a + b.charAt(0).toUpperCase() + b.slice(1));
}

/**
 * @description This function searches for the relevant elements and creates a listener to send interaction data when clicked.
 * @author Bradley Greenwood | 31-03-2022
 * @param templateP The template data of the component
 **/
export function addAnalyticsInteractions(templateP) {
  //Lightning web security breaks this querySelectorAll
  let interactionElements = templateP.querySelectorAll(
    '[data-id="link_content"]'
  );
  try {
    interactionElements.forEach(function (elem) {
      if (
        elem.dataset.adobeEventAdded !== true &&
        elem.dataset.adobeEventAdded !== "true"
      ) {
        elem.dataset.adobeEventAdded = true;
        elem.addEventListener("click", function (event) {
          window.dispatchEvent(
            new CustomEvent("AA_buttonClickEvent", { detail: { event: event } })
          );
        });
      }
    });
  } catch (error) {
  }
}

export function addSearchAnalyticsInteractions(
  resultsCount,
  filters,
  searchTerm,
  pageType
) {
  window.dispatchEvent(
    new CustomEvent("AA_searchResultEvent", {
      detail: {
        resultcount: resultsCount,
        term: searchTerm,
        filtersApplied: filters,
        currentPageType: pageType
      }
    })
  );
}