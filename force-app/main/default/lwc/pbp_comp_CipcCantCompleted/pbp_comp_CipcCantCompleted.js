/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   19-09-2022   Sharanyya Chanda   PreApplication Error Scenario
 * @last modified on  : 29 APRIL 2024
 *@last modified by  : Narendra 
 *@Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from "lightning/navigation";
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';

export default class Pbp_comp_CipcCantCompleted extends NavigationMixin(LightningElement) {

    @api teams = ["Self Assisted"];
    label = {};
    isEventFired;
    adobePageTag = {
        pageName: " Application Can't be completed form",
        dataId: "link_content",
        dataIntent: "Navigational",
        dataScope: "Application Can't be completed ",
        cancelButtonText: "mymobiz business account | Application Can't be completed  |  back browsing button click",
        siteErrorCode: "",
        application: {
            applicationProduct: "Application Can't be completed",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: " Application Can't be completed ",
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
                this.isLoaded = true;
            });
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
    }

    backToHome(event) {
        window.fireButtonClickEvent(this, event);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'our_accounts__c'
            }
        });
    }
}