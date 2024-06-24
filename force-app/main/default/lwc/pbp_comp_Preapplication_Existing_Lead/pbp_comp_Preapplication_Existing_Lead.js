/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   19-09-2022   Sharanyya Chanda   PreApplication Error Scenario
 * @last modified on  : 29 APRIL 2024
   @last modified by  : Narendra 
   @Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from "lightning/navigation";
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
export default class Pbp_comp_Preapplication_Existing_Lead extends NavigationMixin(LightningElement) {

    @api teams = ["Self Assisted"];
    label = {};
    businessAccountURL;
    isEventFired;
    adobePageTag = {
        pageName: "Existing Lead form",
        dataId: "link_content",
        dataIntent: "Navigational",
        dataScope: "Existing Lead ",
        cancelButtonText: "mymobiz business account | Existing Lead  |  back browsing button click",
        siteErrorCode: "",
        application: {
            applicationProduct: "Existing Lead ",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Existing Lead ",
            applicationStep: "",
            applicationStart: true,
            applicationComplete: false,
        },
    };
    connectedCallback() {
        loadStyle(this, AOB_ThemeOverrides + '/styleDelta.css')
            .then(() => {
                this.isRendered = true;
                this.isLoaded = true;
            })
            .catch(error => { });
        loadScript(this, FireAdobeEvents).then(() => {
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
                this.adobeAnalyticsPageView();
            }
        }).catch(error => {
            this.isLoaded = true;
        });

    }

    handleResultChange(event) {
        this.label = event.detail;
        this.businessAccountURL = this.label.PBP_ZA_StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts';
        
    }

    backToHome(event) {
        window.fireButtonClickEvent(this, event);
        window.open(this.businessAccountURL, '_self');
    }
}