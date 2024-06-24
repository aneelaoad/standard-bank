import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';

import LEGAL_LABEL from '@salesforce/label/c.Eap_Legal_Label';
import IMPORTANT_NOTICES_LABEL from '@salesforce/label/c.Eap_ImportantNotices_Label';
import PATRIOT_CERTIFICATION_LABEL from '@salesforce/label/c.Eap_USAPatriotActCertification_Label';
import QUESTIONNAIRE_LABEL from '@salesforce/label/c.Eap_WolfsbergQuestionnaire_Label';
import TERMS_CONDITIONS_LABEL from '@salesforce/label/c.Eap_TermsConditions_Label';
import LEGAL_URL from '@salesforce/label/c.Eap_Legal_URL_Label';
import IMPORTANT_NOTICES_URL from '@salesforce/label/c.Eap_ImportantNotices_URL_Label';
import PATRIOT_CERTIFICATION_URL from '@salesforce/label/c.EAP_USAPatriotActCertification_URL_Label';
import QUESTIONNAIRE_URL from '@salesforce/label/c.Eap_WolfsbergQuestionnaire_URL_Label';
import MANAGE_COOKIES from '@salesforce/label/c.Eap_ManageCookies_Label';
import MANAGE_COOKIES_URL from '@salesforce/label/c.Eap_ManageCookies_URL_Label';

export default class EapProfileTermsConditions extends NavigationMixin(LightningElement) {
    labels = {Legal: LEGAL_LABEL, ImportantNotices: IMPORTANT_NOTICES_LABEL, PatriotCertification: PATRIOT_CERTIFICATION_LABEL, Questionnaire: QUESTIONNAIRE_LABEL, TermsConditions: TERMS_CONDITIONS_LABEL,
        LegalURL: LEGAL_URL, ImportantNoticesURL: IMPORTANT_NOTICES_URL, PatriotCertificationURL: PATRIOT_CERTIFICATION_URL, QuestionnaireURL: QUESTIONNAIRE_URL, ManageCookies: MANAGE_COOKIES, ManageCookiesURL: MANAGE_COOKIES_URL};

    @track elements = [
        {
            Id: 1,
            Title: this.labels.Legal,
            IconStart: customIcons+"/iconGlobe.svg",
            IconEnd: "utility:chevronright",
            openFile: function() {
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url: this.labels.LegalURL
                    }
                });
            }
        },
        {
            Id: 2,
            Title: this.labels.ImportantNotices,
            IconStart: customIcons+"/iconGlobe.svg",
            IconEnd: "utility:chevronright",
            openFile: function() {
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url: this.labels.ImportantNoticesURL
                    }
                });
            }
        },
        {
            Id: 3,
            Title: this.labels.PatriotCertification,
            IconStart: customIcons+"/iconGlobe.svg",
            IconEnd: "utility:chevronright",
            openFile: function() {
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url: this.labels.PatriotCertificationURL
                    }
                });
            }
        },
        {
            Id: 4,
            Title: this.labels.Questionnaire,
            IconStart: customIcons+"/iconGlobe.svg",
            IconEnd: "utility:chevronright",
            openFile: function() {
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url: this.labels.QuestionnaireURL
                    }
                });
            }
        },
        {
            Id: 5,
            Title: this.labels.ManageCookies,
            IconStart: customIcons+"/iconGlobe.svg",
            IconEnd: "utility:chevronright",
            openFile: function() { this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url: this.labels.ManageCookiesURL
                    }
                });
            }
        }
    ]

    renderedCallback() {
        const loadedEvent = new CustomEvent('loaded', {});
        this.dispatchEvent(loadedEvent);
    }
}