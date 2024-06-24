/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   19-09-2022   Sharanyya Chanda   PreApplication Error Scenario
 * @last modified on  : 29 APRIL 2024
 *@last modified by  : Narendra 
 *@Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import { NavigationMixin } from "lightning/navigation";
import { loadStyle } from 'lightning/platformResourceLoader';
import { loadScript } from 'lightning/platformResourceLoader';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
export default class Pbp_comp_Unsuccessful_Compliance_Status extends NavigationMixin(LightningElement) {
    isEventFired;
    @api teams = ["Self Assisted"];
    label = {};
    adobePageTag = {
        pageName: " UnsuccessfulCompliance status form",
        dataId: "link_content",
        dataIntent: "Navigational",
        dataScope: "UnsuccessfulCompliance status ",
        cancelButtonText: "mymobiz business account |UnsuccessfulCompliance status  |  back browsing button click",
        siteErrorCode:"",  
        application:{
            applicationProduct: "UnsuccessfulCompliance status",
            applicationMethod: "Online",
            applicationID : "", 
            applicationName : " UnsuccessfulCompliance status ", 
            applicationStep : "", 
            applicationStart : true, 
            applicationComplete : false,
        },
    };
    connectedCallback() {
        loadStyle(this, AOB_ThemeOverrides + '/styleDelta.css')
            .then(() => {
                this.isRendered = true;
                this.isLoaded = true;
            })
            .catch(error => {
            });
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