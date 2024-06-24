import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOSBDocumentURL from '@salesforce/apex/OSB_RequestPage_CTRL.getOSBDocumentURL';
import getUserDetails from '@salesforce/apex/OSB_RequestPage_CTRL.getUserDetails';
import CaseCheck from '@salesforce/apex/OSB_RequestPage_CTRL.caseCheck';
import createCaseWithContactId from '@salesforce/apex/OSB_RequestPage_CTRL.createCaseWithContactId';
import sendEmail from '@salesforce/apex/OSB_RequestPage_CTRL.sendEmail';
import getRelatedAccountDetails from '@salesforce/apex/OSB_RequestPage_CTRL.getRelatedAccountDetails';
import {
    addAnalyticsInteractions,
    pageViewSinglePageApp
} from 'c/osbAdobeAnalyticsWrapperLwc';
import getSolutions from '@salesforce/apex/OSB_SolutionShowcase_CTRL.getSolutions';
import JsonUtil from './jsonUtil';

export default class OsbSolutionSignUpVersionTwo extends LightningElement {
    @api solutionLogo;
    @api solutionName;
    @api registrationUrl;
    @api termsConditionsDoc;
   
    @api hasEmail = 'true';
    @api hasCompany = 'true';
    @api hasMobile = 'true';
    @api hasRegion = 'true';
    @api hasIdNumber = 'true';
    @api isInternalSolution = false;
    @api useApiRequest = false;
    @api showOperatingCountry = false;
    @api requiredFields =
        'id, name, lastName, cellNumber, email, pingId, companyIndustry, companyName';
    @api customFields = '';
    @api sendEmailCheck = 'false';
    @api backgroundColor = '#000524';
    @api parentFont;
    RequestNotComplete = true;
    tncDownload;
    Logo;
    email = '';
    RequestButtonAdobe;
    ReturnButtonAdobe;
    TnCAdobeButton;
    displayCountry = [];

    connectedCallback() {
        let pageName = this.solutionName + ' Registration page';
        this.RequestButtonAdobe = pageName + ' | request access';
        this.ReturnButtonAdobe = pageName + ' | return to Onehub';
        this.TnCAdobeButton = pageName + ' | download TnC';
        pageViewSinglePageApp(pageName);
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
        this.Logo = this.solutionLogo;
        getOSBDocumentURL({
            docName: this.termsConditionsDoc
        }).then((result) => {
            const urlRegex =
                /^((http[s]?|ftp):\/\/)?([^\s\/]+\.)*[^\s\/]+\.[^\s\/]+(\/[^\s\/]*)*$/;
            if (urlRegex.test(this.termsConditionsDoc)) {
                this.tncDownload = this.termsConditionsDoc;
            } else {
                this.tncDownload = window.location.origin + result;
            }
        });
        this.template.querySelector(
            '[data-id="right-image"]'
        ).style.backgroundColor = this.backgroundColor;
        this.template.querySelector(
            '[data-id="SignUpRequestSol"]'
        ).style.fontFamily = this.parentFont;
        this.checkForCase();
    }

    @wire(getSolutions)
    solutionShowcaseData({ error, data }) {
        if (data) {
            let solution = JSON.parse(JSON.stringify(data));
            let solutionCountry = [];

            for (let i = 0; i < solution.length; i++) {
                if (solution[i].Title === this.solutionName) {
                    solutionCountry = solution[i].OSB_Country__c.split(';').map(
                        (option) => ({
                            label: option,
                            value: option
                        })
                    );
                }
            }
            this.displayCountry = solutionCountry;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getUserDetails)
    contacts;

    @wire(getUserDetails)
    getContact({ data }) {
        if (data) {
            this.email = data[0] ? data[0].Email : '';
        }
    }

    @wire(getRelatedAccountDetails)
    accounts;

    checkForCase() {
        let sub = 'OneHub - ' + this.solutionName;
        CaseCheck({ email: this.email, subject: sub }).then((data) => {
            if (data) {
                if (data[0]) {
                    this.RequestNotComplete = false;
                }
                this.error = undefined;
            }
        });
    }

    formatRequiredFields() {
        return this.requiredFields.split(',').map((item) => item.trim());
    }

    requestAccess() {
        const getValue = (field) => {
            return field ? field.value : '';
        };

        const fullNameField = this.template.querySelector(
            '[data-id="Fullname"]'
        );
        const emailField = this.template.querySelector(
            '[data-id="EmailAddress"]'
        );
        const companyNameField = this.template.querySelector(
            '[data-id="Company"]'
        );
        const idNumberField = this.template.querySelector(
            '[data-id="IdNumber"]'
        );
        const cellphoneField = this.template.querySelector(
            '[data-id="MobileNumber"]'
        );
        const regionField = this.template.querySelector('[data-id="Region"]');

        const fullName = getValue(fullNameField);
        const email = getValue(emailField);
        const companyName = getValue(companyNameField);
        const idNumber = getValue(idNumberField);
        const cellphone = getValue(cellphoneField);
        const region = getValue(regionField);
        if (!region) {
            const inputFieldContainer = this.template.querySelector('[data-id="inputFieldContainer"]');
            const errorMessage = this.template.querySelector('[data-id="errorMessage"]');
            inputFieldContainer.classList.add('slds-has-error');
            errorMessage.style.display = 'block';
        }

        if (
            fullName &&
            email &&
            companyName &&
            cellphone &&
            region &&
            this.RequestNotComplete
        ) {
            const origin = 'Web';
            const status = 'New';
            const newCase = {
                Origin: origin,
                Status: status,
                SuppliedEmail: email,
                SuppliedName: fullName,
                SuppliedPhone: cellphone,
                SuppliedIdNumber: idNumber,
                SuppliedCompany: companyName,
                Case_Country__c: region,
                Description: this.solutionName + ' sign up request',
                Type: 'OneHub ' + this.solutionName + ' Registration',
                Subject: 'OneHub - ' + this.solutionName
            };
            this.createCase(newCase);

            if (this.sendEmailCheck) {
                this.sendEmail();
            }
        }

        if (this.useApiRequest) {
            const requiredFields = this.formatRequiredFields();
            const payload = new JsonUtil(
                this.contacts.data[0],
                this.accounts.data[0],
                this.isInternalSolution,
                this.customFields
            ).formatJson(requiredFields);
            this.makeRegistrationRequest(payload);
        }
    }

    sendEmail() {
        sendEmail({
            contactRecord: this.contacts,
            solutionName: this.solutionName
        });
    }

    createCase(newCase) {
        let regURLName = this.solutionName + '_Registration_URL';
        createCaseWithContactId({ caseRecord: newCase, urlName: regURLName });
        this.RequestNotComplete = false;
    }

    async makeRegistrationRequest(payload) {
        const requestOptions = {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        };

        await fetch(this.registrationUrl, requestOptions);
    }

    returnToOneHub() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'Home'
            }
        });
    }
}