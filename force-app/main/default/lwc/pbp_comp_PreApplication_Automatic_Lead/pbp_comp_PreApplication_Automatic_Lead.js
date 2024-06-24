/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   19-09-2022   Sharanyya Chanda   PreApplication Error Scenario
 */
import { LightningElement, track, api } from 'lwc';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from "lightning/navigation";
import { loadScript } from 'lightning/platformResourceLoader';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
export default class Pbp_comp_PreApplication_Automatic_Lead extends NavigationMixin(LightningElement) {
    @api teams = ["Self Assisted"];
    label = {};
    businessAccountURL;
    isEventFired;
    adobePageTag = {
        pageName: "AutomaticLead Creation form",
        dataId: "link_content",
        dataIntent: "Navigational",
        dataScope: "preapplication",
        cancelButtonText: "mymobiz business account | AutomaticLead Creation |  back browsing button click",
        siteErrorCode: "",
        application: {
            applicationProduct: "Preapplication",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Preapplication",
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
        this.businessAccountURL = this.label.PBP_ZA_StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts';

    }
    backToHome(event) {
        window.fireButtonClickEvent(this, event);
        window.open(this.businessAccountURL, '_self');
    }
}