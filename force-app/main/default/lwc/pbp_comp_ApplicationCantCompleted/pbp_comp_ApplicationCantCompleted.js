/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   03-01-2024   Devi Ravuri  Application Cant Completed
 * @last modified on  : 29 APRIL 2024
 *@last modified by  : Narendra 
 *@Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import { NavigationMixin } from "lightning/navigation";
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import info from '@salesforce/resourceUrl/AOB_ThemeOverrides';


import triangle from '@salesforce/resourceUrl/PBP_ThemeOverrides';
export default class Pbp_comp_ApplicationCantCompleted extends NavigationMixin(LightningElement) {

    @api teams = ["Self Assisted"];
    label = {};
    @api capturedRegNumber;
    regNumber;
    regAttemptsMessage;
    @api userAttempts;
    info = info + '/assets/images/orange_info.svg';
    triangle = triangle + '/assets/images/triangle.png';
    isEventFired;
    adobePageTag = {
        pageName: " Application Can't be completed form",
        dataId: "link_content",
        dataIntent: "Navigational",
        dataScope: "Application Can't be completed ",
        cancelButtonText: "mymobiz business account | Application Can't be completed  |  back browsing button click",
        continueButtonText: "mymobiz business account | Application Can't be completed  | Retry button click",
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
        if (this.userAttempts == 1) {
            this.regAttemptsMessage = `You have 1 attempt left to try again `;
        } else if (this.userAttempts == 2) {
            this.regAttemptsMessage = `This is your last attempt to try again before we call you back`;
        }
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
    
    addSlashForNumber(event) {
        if (event.target.name === 'businessRegistrationNumber' && event.keyCode != 8) {
            if (event.target.value.length === 4 || event.target.value.length === 11) {
                event.target.value = event.target.value + '/';
            }
            if (event.target.value.length >= 12 && !event.target.value.includes('/')) {
                event.target.value = event.target.value.substring(0, 4) + '/' + event.target.value.substring(4, 10) + '/' + event.target.value.substring(10, 12);
            }
        }

    }

      validateRegistrationNumber(event) {
        let value = event.target.value;
        let regNumberElement = this.template.querySelector('.validateRegNum');

        if ((/^(\d{4}\/\d{2}){2}$/.test(value))) {
            regNumberElement.setCustomValidity('');
            regNumberElement.reportValidity();
            let currentYear = new Date().getFullYear();
            let year = value.substring(0, 4);
            let validYear = /^(19|20)[0-9]{2}$/.test(year) ? false : true;
            let currentYearValid = (parseInt(year) <= currentYear) ? false : true;
            if (validYear || currentYearValid) {
                regNumberElement.setCustomValidity('Enter a valid Registration Number');
                regNumberElement.reportValidity();
            }

        } else {
            regNumberElement.setCustomValidity('Your entry does not match the allowed pattern.');
            regNumberElement.reportValidity();
        }
    }

    genericFieldChange(event) {
        let value = event.target.value;
        this.regNumber = value;
    }

    retryAPI(event) {
        if (this.checkForm()) {
            if (this.capturedRegNumber == this.regNumber) {
                let regElement = this.template.querySelector('lightning-input');
                regElement.setCustomValidity('You have entered the same invalid Registration Number, please capture the correct Registration Number');
                regElement.reportValidity();
            } else {
                const selectedEvent = new CustomEvent("recapture", {
                    detail: this.regNumber
                });
                this.dispatchEvent(selectedEvent);
                this.showSpinner = true;
            }
        }

    }

    checkForm() {
        let regElement = this.template.querySelector('lightning-input');
        regElement.setCustomValidity('');
        regElement.reportValidity();
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;

    }
    callMeBack(event) {
        const selectedEvent = new CustomEvent("callmeback", {
            detail: 'Customer clicked call me back for CIPC'
        });
        this.dispatchEvent(selectedEvent);
    }

}