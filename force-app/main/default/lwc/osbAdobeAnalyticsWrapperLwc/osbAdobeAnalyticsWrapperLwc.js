import { LightningElement} from 'lwc';
import Id from '@salesforce/user/Id';

export default class osbAdobeAnalyticsWrapperLwc extends LightningElement {

  /**
   * @description sets up the event listeners handlers
   * @author Wayde Fagan | 17-06-2022
   */
  connectedCallback() {
    this.screenLoadHandler();
    window.addEventListener("AA_buttonClickEvent", this.buttonClickHandler);
    window.addEventListener("AA_tabEvent", this.screenLoadHandlerTab);
    window.addEventListener("AA_searchEvent", this.searchInteraction);
    window.addEventListener("AA_formEvent", this.formInteraction);
    window.addEventListener("AA_specificButtonClickEvent", this.clickHandler)
  }

  /**
   * @description This function formats the current page data and fires the Adobe tracking event containing the page load data.
   * @author Wayde Fagan | 17-06-2022
   **/
  screenLoadHandler() {
    let loginSuccess = document.referrer.includes('/apex/CommunitiesLanding')  ? "true" : "false";
        let today = new Date();
        let date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        let time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        let dateTime = date+' '+time;
        document.dispatchEvent(new CustomEvent('triggerInteraction', {
            'detail': {
                eventName: 'globalVirtualPageView',
                websiteName:'Onehub',
                websiteCode:'OPTL',
                siteCountry : "South Africa",
                siteErrorCode : "",
                siteLanguage : "English",
                pageName : "Dashboard",
                pageCategory : "Dashboard",
                pageSubSection1 : "Dashboard",
                pageSubSection2 : "",
                pageSubSection3 : "",
                pageSubSection4 : "",
                userLogin: {
                    loginTime: dateTime, 
                    loginSuccess: loginSuccess,
                    loginSuccessPersist: "true",
                    userID: Id
                }
            }
          }));
  }

  /**
   * @description This function is used to send a new page view when using a SPA
   * @author Wayde Fagan | 17-06-2022
   * @param e The click event with relevant data attributes
   **/
  screenLoadHandlerTab(event){
    setTimeout(() => {
      document.dispatchEvent(new CustomEvent('triggerInteraction', {
          'detail': {
              eventName: 'globalVirtualPageView',
              pageName : event.detail.event,
              pageCategory : event.detail.event,
              pageSubSection1 : event.detail.event,
          }
      }));
    },1000);
  }

  /**
   * @description This function sends data to Adobe based on the search used by the user
   * @author Wayde Fagan | 17-06-2022
   * @param e The click event with relevant data attributes
   **/
  searchInteraction(event){
    document.dispatchEvent(new CustomEvent('triggerInteraction', {
      'detail': {
          eventName: 'userSearch',
          search:{
            filter: event.detail.event.search.filter
          },
          searchTerm: event.detail.event.searchTerm,
          searchResult: event.detail.event.searchResult,
          linkScope: event.detail.event.linkScope
      }
    }));
  }

  /**
   * @description This function is called when a form is completed
   * @author Wayde Fagan | 17-06-2022
   * @param e The click event with relevant data attributes
   **/
  formInteraction(event){
    setTimeout(() => {
    document.dispatchEvent(new CustomEvent('triggerInteraction', {
      'detail': {
          eventName: event.detail.event.name,
          formName : event.detail.event.formName,
          formStatus : event.detail.event.formStatus,
          formisSubmitted : event.detail.event.formisSubmitted
      }
    }))},2000);
  }

  /**
   * @description This function formats the interaction data and fires the Adobe tracking event.
   * @author Wayde Fagan | 17-06-2022
   * @param e The click event with relevant data attributes
   **/
  buttonClickHandler(e) {
    let eventDatasets = e.detail.event.currentTarget.dataset;
    let analyticsDataAtributes = ["scope", "text", "id", "intent","type"];
    let linkDataArray = [];
    analyticsDataAtributes.forEach((value, index) => {
      if (typeof eventDatasets[value] === "string") {
        linkDataArray.push(eventDatasets[value]);
      }
    });
    document.dispatchEvent(new CustomEvent('triggerInteraction', {
      'detail': {
          eventName: 'flexiLinkTracking',
          'data-id':'link_content',
          linkIntent: linkDataArray[3] ? linkDataArray[3] : '',
          linkName: linkDataArray[1] ? linkDataArray[1] : '' + linkDataArray[2] ? linkDataArray[2] : '' + 'link click',
          linkScope: linkDataArray[0] ? linkDataArray[0] : ''
      }
    }));
  }

  /**
   * @description This function formats the interaction data and fires the Adobe tracking event when required for specific clicks.
   * @author Milica Milicevic | 26-10-2022
   * @param e The click event with relevant data attributes
   **/
  clickHandler(event) {
    document.dispatchEvent(new CustomEvent('triggerInteraction', {
      'detail': {
          eventName: 'flexiLinkTracking',
          'data-id':'link_content',
          linkIntent: event.detail.event.intent,
          linkName: event.detail.event.name + ' click',
          linkScope: event.detail.event.scope
      }
    }));
  }

}



/**
* @description This function searches for the relevant elements and creates a listener to send interaction data when clicked.
* @author Wayde Fagan | 17-06-2022 
* @param templateP The template data of the component
**/
export function addAnalyticsInteractions(templateP){
    let interactionElements = templateP.querySelectorAll('[data-intent]');
    interactionElements.forEach(function(elem){
        if(elem.dataset.adobeEventAdded != 'true'){
            elem.dataset.adobeEventAdded = true;
            elem.addEventListener("click", function(event){
                window.dispatchEvent(new CustomEvent('AA_buttonClickEvent', {detail: {event: event}}));
            });                   
        }
    });
}

/**
* @description This function searches for the relevant elements and creates a listener to send interaction data when clicked.
* @author Wayde Fagan | 17-06-2022 
* @param event The click event with relevant data attributes
**/
export function pageViewSinglePageApp(event){
  window.dispatchEvent(new CustomEvent('AA_tabEvent', {detail: {event: event}}));
}

/**
* @description This function searches for the relevant elements and creates a listener to send interaction data when clicked.
* @author Wayde Fagan | 17-06-2022 
* @param event The click event with relevant data attributes
**/
export function interactionSearch(event){
  window.dispatchEvent(new CustomEvent('AA_searchEvent', {detail: {event: event}}));
}

/**
* @description This function searches for the relevant elements and creates a listener to send interaction data when clicked.
* @author Wayde Fagan | 17-06-2022 
* @param event The click event with relevant data attributes
**/
export function interactionForm(event){
  window.dispatchEvent(new CustomEvent('AA_formEvent', {detail: {event: event}}));
}

/**
* @description This function searches for the relevant elements and creates a listener to send interaction data when clicked.
* @author Milica Milicevuc | 26-10-2022 
* @param event The click event with relevant data attributes
**/
export function interactionClick(event){
  window.dispatchEvent(new CustomEvent('AA_specificButtonClickEvent', {detail: {event: event}}));
}