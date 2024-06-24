/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   19-09-2022   Sharanyya Chanda   PreApplication Error Scenario
 * @last modified on  : 29 APRIL 2024
 *@last modified by  : Narendra 
 *@Modification Description : SFP-38348
 */
import { LightningElement , api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from "lightning/navigation";
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';

export default class Pbp_comp_Unsuccessful_Director_Status extends NavigationMixin(LightningElement) {
    isEventFired;
  @api teams = ["Self Assisted"];
    label = {};
    adobePageTag = {
        pageName: " UnsuccessfulDirector status form",
        dataId: "link_content",
        dataIntent: "Navigational",
        dataScope: "UnsuccessfulDirector status ",
        cancelButtonText: "mymobiz business account |UnsuccessfulDirector status  |  back browsing button click",
        siteErrorCode:"",  
        application:{
            applicationProduct: "UnsuccessfulDirector status",
            applicationMethod: "Online",
            applicationID : "", 
            applicationName : " UnsuccessfulDirector status ", 
            applicationStep : "", 
            applicationStart : true, 
            applicationComplete : false,
        },
    };
    connectedCallback(){
        loadScript(this, FireAdobeEvents).then(() => { 
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
                
                this.adobeAnalyticsPageView();
            }
        }) 
        .catch(error => {
        });
    }
     handleResultChange(event) {
        this.label = event.detail;
    }
    backToHome(event){
        window.fireButtonClickEvent(this, event); 
        this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'our_accounts__c'
                    }
        });
    }
}