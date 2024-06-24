import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOSBDocumentURL from '@salesforce/apex/OSB_RequestPage_CTRL.getOSBDocumentURL';
import getUserDetails from '@salesforce/apex/OSB_RequestPage_CTRL.getUserDetails';
import CaseCheck from '@salesforce/apex/OSB_RequestPage_CTRL.caseCheck';
import createCaseWithContactId from '@salesforce/apex/OSB_RequestPage_CTRL.createCaseWithContactId';
import sendEmail from '@salesforce/apex/OSB_RequestPage_CTRL.sendEmail';
import { addAnalyticsInteractions, pageViewSinglePageApp } from 'c/osbAdobeAnalyticsWrapperLwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import OPERATING_COUNTRY_FIELD from '@salesforce/schema/Contact.OSB_Operating_Country__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';




export default class osbSolutionSignUp extends LightningElement {

    @api solutionLogo;
    @api solutionName;
    @api termsConditionsDoc;
    @api Email = "true";
    @api Company = "true";
    @api Mobile = "true";
    @api Region = "true";
    @api IdNumber = "true";
    @api sendEmailCheck = "false";
    @api backgroundColor = '#000524';
    @api parentFont = 'Roboto,Brenton,sans-serif';
    RequestNotComplete = true;
    contacts;
    tncDownload;
    Logo;
    email = '';
    RequestButtonAdobe;
    ReturnButtonAdobe;
    TnCAdobeButton;
    regionOptions = [];

    connectedCallback() {
        let pagename = this.solutionName + ' Registration page';
        this.RequestButtonAdobe = pagename + " | request access";
        this.ReturnButtonAdobe = pagename + " | return to Onehub";
        this.TnCAdobeButton = pagename + " | download TnC";
        pageViewSinglePageApp(pagename);
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
        this.Logo = this.solutionLogo;
        getOSBDocumentURL({
            "docName": this.termsConditionsDoc
        }).then(result => {
            const urlRegex = /^((http[s]?|ftp):\/\/)?([^\s\/]+\.)*[^\s\/]+\.[^\s\/]+(\/[^\s\/]*)*$/i;
            if (urlRegex.test(this.termsConditionsDoc)) {
             this.tncDownload = this.termsConditionsDoc;
            } else {
            this.tncDownload = window.location.origin + result;
            }
        })
        this.template.querySelector('[data-id="right-image"]').style.backgroundColor = this.backgroundColor;
        this.template.querySelector('[data-id="SignUpRequestSol"]').style.fontFamily = this.parentFont;
        this.checkForCase();
    }
    get emTSolution() {

        return this.solutionName === 'eMarketTrader';

    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId', fieldApiName: OPERATING_COUNTRY_FIELD })

    wiredDataCountry({ error, data }) {
        if (data) {

            this.regionOptions = data.values.map(objPh => {
                return {
                    name: `${objPh.name}`,
                    value: `${objPh.value}`
                };
            });

        } else if (error) {
            this.error = error;
        }
    }

    @wire(getUserDetails)
    contacts;

    @wire(getUserDetails)
    getContact({ error, data }) {
        if (data) {
            this.email = data[0] ? data[0].Email : '';
        }
    };

    checkForCase() {
        let sub = 'OneHub - ' + this.solutionName;
        CaseCheck({ email: this.email, subject: sub })
            .then((data) => {
                if (data) {
                    if (data[0]) {
                        this.RequestNotComplete = false;
                    }
                    this.error = undefined;
                }
            })
    }

    requestAccess() {
        let fullNameField = this.template.querySelector(`[data-id="Fullname"]`);
        let fullName = fullNameField ? fullNameField.value : "";
        let emailField = this.template.querySelector(`[data-id="EmailAddress"]`);
        let email = emailField ? emailField.value : "";
        let companyNameField = this.template.querySelector(`[data-id="Company"]`);
        let companyName = companyNameField ? companyNameField.value : "";
        let idNumberField = this.template.querySelector('[data-id="IdNumber"]');
        let idNumber = idNumberField ? idNumberField.value : "";
        let cellphoneField = this.template.querySelector(`[data-id="MobileNumber"]`);
        let cellphone = cellphoneField ? cellphoneField.value : "";
        let regionField = this.template.querySelector('[data-id="Region"]');
        let region = regionField ? regionField.value : "";
        if (fullName && email && companyName && this.RequestNotComplete && region) {
            let origin = "Web";
            let status = "New";
            let newCase = {
                Origin: origin,
                Status: status,
                SuppliedEmail: email,
                SuppliedName: fullName,
                SuppliedPhone: cellphone,
                SuppliedIdNumber: idNumber,
                SuppliedCompany: companyName,
                SuppliedRegion: region,
                Description: this.solutionName + ' sign up request',
                Type: 'OneHub ' + this.solutionName + ' Registration',
                Subject: 'OneHub - ' + this.solutionName,
                Case_Country__c: region

            }
            this.createCase(newCase);
            if (this.sendEmailCheck) {
                this.sendEmail();
            }
        }
    }

    sendEmail() {
        sendEmail({ contactRecord: this.contacts, solutionName: this.solutionName });
    }

    createCase(newCase) {
        let regURLName = this.solutionName + '_Registration_URL';

        createCaseWithContactId({ caseRecord: newCase, urlName: regURLName })
        this.RequestNotComplete = false;
    }

    returnToOneHub() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'Home'
            },
        });
    }
}