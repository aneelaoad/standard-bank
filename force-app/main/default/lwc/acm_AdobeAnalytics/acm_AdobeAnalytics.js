import { LightningElement,track,api,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class Acm_AdobeAnalytics extends LightningElement {
    currentPageReference;
    @api adobeAnalyticsUrl;

    initDataLayer = {
        "domainName": window.location.hostname,
        "platformIdentifier": "Salesforce Community",
        "siteCountry": "South Africa",
        "siteLanguage": "English",
        "websiteName": "API Marketplace",
        "websiteNameCode": "APIMP",
        'deviceType' : /Mobile/i.test(navigator.userAgent) ? "Mobile" : "Desktop",   
    };

    /**
    * @description This function gets the page reference data and saves it before setup begins.
    * @author Bradley Greenwood | 31-03-2022 
    * @param CurrentPageReference current reference data
    **/
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.setupAnalytics();
    }

    /**
    * @description This function will initialize the events if the site is not being viewed in the builder.
    * @author Bradley Greenwood | 31-03-2022 
    **/
    connectedCallback(){
        if(!this.siteInPreviewMode()){
            window.addEventListener("AA_buttonClickEvent", this.buttonClickHandler);
            window.addEventListener("AA_directEvent", this.fireDirectAnalyticsInteraction);
        } 
    }

    /**
    * @description This function initializes the Adobe analytics integration
    * @author Bradley Greenwood | 31-03-2022 
    **/
    setupAnalytics(){
        if(window.location.pathname.indexOf('internalapimarketplace') > 0 || window.location.hostname.indexOf('apicentral') > 0){
            this.initDataLayer.websiteName = 'API Central';
            this.initDataLayer.websiteNameCode = 'APIC';
        }

        if(typeof window.aaPreviousPage == 'undefined'){ 
            window.aaPreviousPage = '';
        }

        if (this.currentPageReference.attributes.name && (this.currentPageReference.attributes.name != window.aaPreviousPage)) {  
            this.screenLoadHandler(this.currentPageReference.attributes.name);
        }else if(this.currentPageReference.state.recordName && (this.currentPageReference.state.recordName != window.aaPreviousPage)){
            this.screenLoadHandler(this.currentPageReference.state.recordName);
        }  
    }

    /**
    * @description This function tests if the user is in Experience Builder.
    * @author Bradley Greenwood | 31-03-2022 
    **/
    siteInPreviewMode(){
        let urlToCheck = window.location.hostname;
        urlToCheck = urlToCheck.toLowerCase();
        return urlToCheck.indexOf('sitepreview') >= 0 || urlToCheck.indexOf('livepreview') >= 0;
    }

    /**
    * @description This function formats the current page data and fires the Adobe tracking event containing the page load data.
    * @author Bradley Greenwood | 31-03-2022 
    * @param pageName This current page name
    **/
    screenLoadHandler(pageName){
        window.aaPreviousPage = pageName;
        window.savedDataLayer = Object.assign({}, this.initDataLayer);
        window.aaCurrentPage = pageName.replace("__c", "").replaceAll("_", " ");
        window.savedDataLayer.pageName = window.aaCurrentPage;
        window.savedDataLayer.pageUrl = window.location.href;
        let urlSegments = window.location.pathname.split("/");
   
        switch (window.aaCurrentPage) {
            case "Forums":  
            case "Corporate": 
            case "Retail": 
                window.savedDataLayer.pageCategory = 'Community';
            break;
            case "Terms and Conditions":  
            case "complaints process": 
                window.savedDataLayer.pageCategory = 'Legal';
            break;
            case "APIs":
                window.savedDataLayer.pageCategory = 'Products';
            break;
            case "Getting Started":
                window.savedDataLayer.pageCategory = 'Guided user journey';
            break;
            case "Application Listing":
                window.savedDataLayer.pageCategory = 'My Applications';
                window.savedDataLayer.pageName =  'My Applications';
            break;
            case "Subscribe":
                window.savedDataLayer.pageCategory = 'Subscribe';
                window.savedDataLayer.pageName =  'Subscribe - ' + this.currentPageReference.state.apiId;
            break;
            default:
                window.savedDataLayer.pageCategory = window.aaCurrentPage;
        } 

        if(urlSegments[3] == "communityapi"){
            window.savedDataLayer.pageCategory = 'Products';
            window.savedDataLayer.pageName =  window.savedDataLayer.pageName + ' - ' + this.currentPageReference.attributes.recordId;
        }else if(urlSegments[3] == "anypointapplications"){
            window.savedDataLayer.pageCategory = 'My Applications';
            window.savedDataLayer.pageName =  'My Application Detail - ' + this.currentPageReference.attributes.recordId;
        }

        window.dispatchEvent(new CustomEvent('adobeTrackLwcListener', {
            detail: {
                trackName:'globalVirtualPageView', 
                dataLayer: window.savedDataLayer
            }
        }));
    }

    /**
    * @description This function formats the interaction data and fires the Adobe tracking event.
    * @author Bradley Greenwood | 31-03-2022 
    * @param e The click event with relevant data attributes
    **/
    buttonClickHandler(e){
        let eventDatasets = e.detail.event.currentTarget.dataset;
        let analyticsDataAtributes = ['scope','text'];      
        let linkDataArray = [];
        let linkString = '';

        if(typeof window.savedDataLayer == 'undefined'){
            window.savedDataLayer = Object.assign({}, this.initDataLayer);
        }

        //Run through the allowed attribites and add them to an array if they are defined
        analyticsDataAtributes.forEach((value,index) => {
            if(typeof eventDatasets[value] === 'string'){
                linkDataArray.push(eventDatasets[value]);
            }
        });

        //Create a string from the defined array values
        linkString = linkDataArray.join(" | ");

        //If a type is set then add it to the end of the link string
        if(typeof eventDatasets.type === 'string'){
            linkString = linkString + ' ' + eventDatasets.type;
        }

        //Create the data Layer to be logged
        window.savedDataLayer.linkName = `${window.aaCurrentPage} | ${linkString}`;
        window.savedDataLayer.linkIntent = eventDatasets.intent;
        window.savedDataLayer.linkScope = eventDatasets.scope;  
        window.savedDataLayer.linkId = "link_content";    

        window.dispatchEvent(new CustomEvent('adobeTrackLwcListener', {
            detail: {
                trackName:'genericUserInteraction', 
                dataLayer: window.savedDataLayer
            }
        }));    
    }

    /**
    * @description This function run an interaction directly when clicked when clicked and passed the dataLayer .
    * @author Pradeep Jangid | 09-06-2022 
    * @param evt The event from the item clicked, @param dataLayerP DataLayer as page load fires before this function can complete
    **/
    @api
    fireDirectAnalyticsInteraction(evt,dataLayerP){   
        let eventDatasets = evt.target.dataset;
        let analyticsDataAtributes = ['scope','text'];      
        let linkDataArray = [];
        let linkString = '';

        //Run through the allowed attribites and add them to an array if they are defined
        analyticsDataAtributes.forEach((value,index) => {
            if(typeof eventDatasets[value] === 'string'){
                linkDataArray.push(eventDatasets[value]);
            }
        });

        //Create a string from the defined array values
        linkString = linkDataArray.join(" | ");

        //If a type is set then add it to the end of the link string
        if(typeof eventDatasets.type === 'string'){
            linkString = linkString + ' ' + eventDatasets.type;
        }

        //Create the data Layer to be logged
        dataLayerP.linkName = `${window.aaCurrentPage} | ${linkString}`;
        dataLayerP.linkIntent = eventDatasets.intent;
        dataLayerP.linkScope = eventDatasets.scope;  
        dataLayerP.linkId = "link_content";    

        window.dispatchEvent(new CustomEvent('adobeTrackLwcListener', {
            detail: {
                trackName:'genericUserInteraction', 
                dataLayer: dataLayerP
            }
        })); 
    }
}

/**
* @description This function searches for the relevant elements and creates a listener to send interaction data when clicked.
* @author Bradley Greenwood | 31-03-2022 
* @param templateP The template data of the component
**/
export function addAnalyticsInteractions(templateP){
    let interactionElements = templateP.querySelectorAll('[data-id="link_content"]');
    
    interactionElements.forEach(function(elem){
        if(elem.dataset.adobeEventAdded != true){
            elem.dataset.adobeEventAdded = true;
            elem.addEventListener("click", function(event){   
                window.dispatchEvent(new CustomEvent('AA_buttonClickEvent', {detail: {event: event}}));
            });                   
        }
    });
}