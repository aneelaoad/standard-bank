/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   05-01-2024   Dayakar   PreApplication CIPC Call Me Back
 */
import { LightningElement,api } from 'lwc';
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
        pageName: " CIPC Call Me Back form",
        dataId: "link_content",
        dataIntent: "Navigational",
        dataScope: "CIPC Call Me Back ",
        cancelButtonText: "mymobiz business account | CIPC Call Me Back  |  back browsing button click",
        siteErrorCode: "",
        application: {
            applicationProduct: "CIPC Call Me Back",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: " CIPC Call Me Back ",
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

        }).catch(error => {

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