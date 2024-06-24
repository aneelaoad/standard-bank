/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   19-09-2022   Devi Ravuri   Aob_comp_mallPreApplication
 */
import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import {
    NavigationMixin
} from "lightning/navigation";
import {
    getErrorMessage
} from 'c/aob_comp_utils';
import {
    loadScript
} from 'lightning/platformResourceLoader';
import {
    CurrentPageReference
} from 'lightning/navigation';
import AOB_PA_Title from '@salesforce/label/c.AOB_PA_Title';
import AOB_PA_SubTitle from '@salesforce/label/c.AOB_PA_SubTitle';
import AOB_PA_Content2 from '@salesforce/label/c.AOB_PA_Content2';
import mallLinkAccount from '@salesforce/apex/AOB_FLOW_LinkAccountToApplicationMall.linkAppWithAccount';
import fetchUserData from '@salesforce/apex/AOB_FLOW_LinkAccountToApplicationMall.fetchUserData';
import findApplication from '@salesforce/apex/AOB_CTRL_FindApplications.findApplication';
import callPreApplication from '@salesforce/apex/AOB_CTRL_FindApplications.callPreApplication';
import incrementRetryApplication from '@salesforce/apex/AOB_CTRL_FindApplications.incrementRetryApplication';
import createExternalLead from "@salesforce/apex/AOB_API_BusinessLead_CTRL.callBusinessLead";
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents";
import productsData from '@salesforce/resourceUrl/PBP_ZA_ProductData';
import APPLICATION from '@salesforce/label/c.AOB_ZA_APPLICATION';
import NAME from '@salesforce/label/c.AOB_ZA_NAME';
import SURNAME from '@salesforce/label/c.AOB_ZA_SURNAME';
import IDNUMBER from '@salesforce/label/c.AOB_ZA_IDNUMBER';
import CELLPHONE from '@salesforce/label/c.AOB_ZA_CELLPHONE';
import EMAILADDRESS from '@salesforce/label/c.AOB_ZA_EMAILADDRESS';
import Companydetails from '@salesforce/label/c.AOB_ZA_Companydetails';
import ofthecompany from '@salesforce/label/c.AOB_ZA_ofthecompany';
import Yes from '@salesforce/label/c.PBP_ZA_Yes';
import No from '@salesforce/label/c.AOB_No';
import AOB_ZA_PleaseCompletethisfield from '@salesforce/label/c.AOB_ZA_PleaseCompletethisfield';
import AOB_ZA_BusinessType from '@salesforce/label/c.AOB_ZA_BusinessType';
import AOB_ZA_Areyouthesole from '@salesforce/label/c.AOB_ZA_Areyouthesole';
import AOB_ZA_GrossAnualTurnover from '@salesforce/label/c.AOB_ZA_GrossAnualTurnover';
import AOB_ZA_RegistrationNumber from '@salesforce/label/c.AOB_ZA_RegistrationNumber';
import AOB_ZA_Province from '@salesforce/label/c.AOB_ZA_Province';
import AOB_ZA_City from '@salesforce/label/c.AOB_ZA_City';
import AOB_ZA_PA_Consent from '@salesforce/label/c.AOB_ZA_PA_Consent';
import PBP_ZA_StandardBankUrl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
import getMymobizManagementSetting from '@salesforce/apex/AOB_CTRL_BackToBCBPlatform.getMymobizManagementSetting';
import AOB_AO_Base_URL from '@salesforce/label/c.AOB_AO_Base_URL';

const CHANNEL_NAME_KEY = "channel";
const CHANNEL_NAME_VALUE_MALL = "mall";

export default class Aob_comp_mallPreApplication extends NavigationMixin(LightningElement) {
    productToOpen = "4648";
    pricingOptToOpen = null;
    productNumber = null;
    pricingOption = null;
    productShortName = null;
    @api channelName;
    @track formDetails = {};
    @track showSS;
    @track error_message = "";
    applicationId;
    showBusinessBlock;
    showRegistration;
    showCity;
    appstatus;
    technicalerror;
    showShareHoldError;
    showOwnerError;
    failing;
    apiRetryNumber = 0;
    errorMessage;
    isMobileDevice = false;
    isLoaded = true;
    spinload = true;
    errorCIPC = false;
    count;
    code;
    businessNameLabel = 'Business Name';
    leadReason = 'PreApplication API retry Limit Exceeded'
    label = {
        AOB_PA_Title,
        AOB_PA_SubTitle,
        AOB_PA_Content2,
        APPLICATION,
        NAME,
        SURNAME,
        IDNUMBER,
        CELLPHONE,
        EMAILADDRESS,
        Companydetails,
        ofthecompany,
        Yes,
        No,
        AOB_ZA_PleaseCompletethisfield,
        AOB_ZA_BusinessType,
        AOB_ZA_Areyouthesole,
        AOB_ZA_PleaseCompletethisfield,
        AOB_ZA_GrossAnualTurnover,
        AOB_ZA_RegistrationNumber,
        AOB_ZA_Province,
        AOB_ZA_City,
        AOB_ZA_PA_Consent
    };

    isEventFired;
    adobePageTag = {
        pageName: "business:products and services:bank with us:business bank accounts:",
        dataId: "link_content",
        dataIntent: "informational",
        dataScope: "pre-application",
        cancelButtonText: " ",
        continueButtonText: " ",
        privacyintent: "informational",
        privacyscope: " ",
        formName: "",
        privacylinkclick: "pre application | privacy statement link click",
        siteErrorCode: "",
        application: {
            applicationProduct: "",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Application:",
            applicationStep: "step 1",
            applicationStart: true,
            applicationComplete: false,
        },
        ecommerce: {
            product: [{

            }],
            purchaseID: "",
            currencycode: "ZAR"
        },
    };

    constructor() {
        super();
        this.isMobileDevice = window.matchMedia("only screen and (max-width:576px)").matches;
    }

    privacyclick(event) {
        window.fireButtonClickEvent(this, event);
    }

    connectedCallback() {
        this.readProductsData();
        this.adobePageTag.pageName = this.adobePageTag.pageName + this.productShortName.toLowerCase() + " account origination step 1 pre-application form";
        this.adobePageTag.privacyscope = this.productShortName;
        this.adobePageTag.application.applicationName = this.adobePageTag.application.applicationName + this.productShortName.toLowerCase() + ' business account';
        this.adobePageTag.application.applicationProduct = this.productShortName.toLowerCase() + " business account";
        this.adobePageTag.ecommerce.product[0].productName = this.adobePageTag.application.applicationProduct;
        this.adobePageTag.formName = "apply now business bank account " + this.productShortName.toLowerCase() + " step 1 pre-application form";
        this.adobePageTag.applicationStep = "Step 1"
        loadScript(this, FireAdobeEvents).then(() => {
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
                window.fireApplicationStartEvent(this, this.adobePageTag.application);
                window.fireFormStart(this, this.adobePageTag.formName);

            }
        })
            .catch(error => {
                this.errorMessage = getErrorMessage.call(this, error);
                this.adobePageTag.siteErrorCode = this.errorMessage;


            });
        this.adobePageTag.cancelButtonText = this.adobePageTag.application.applicationProduct + " | pre-application |  cancel button click";
        this.adobePageTag.continueButtonText = this.adobePageTag.application.applicationProduct + " | pre-application | continue button click";
        this.fetchUserData();
    }

    fetchUserData() {
        fetchUserData({}).then(result => {
            this.formDetails = JSON.parse(result);
           
            this.template.querySelectorAll('lightning-input').forEach((element) => {
             
                if (this.formDetails[element.name]) element.value = this.formDetails[element.name];
            });
        }).catch(error => {
            this.isLoading = true;
        });
    }

    renderedCallback() {
        if (this.formDetails.businessType === 'PRIVATE COMPANY' || this.formDetails.businessType === 'CLOSE CORPORATION') {
            this.businessNameLabel = 'Registered Business Name';
        } else {
            this.businessNameLabel = 'Business Name';
        }
      
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

    validateSAID(event) {
        this.checkSumIDNumber(event.target.value);
    }
    checkSumIDNumber(idNumber) {
        let idElement = this.template.querySelector('.validateID');
        idElement.setCustomValidity('');
        idElement.reportValidity();
        if (idNumber.length === 13) {
            var citzenship = parseInt(idNumber.substring(10, 11)) === 0 ? "Yes" : "No";
            var tempTotal = 0;
            var checkSum = 0;
            var multiplier = 1;
            for (var i = 0; i < 13; ++i) {
                tempTotal = parseInt(idNumber.charAt(i)) * multiplier;
                if (tempTotal > 9) {
                    tempTotal = parseInt(tempTotal.toString().charAt(0)) + parseInt(tempTotal.toString().charAt(1));
                }
                checkSum = checkSum + tempTotal;
                multiplier = (multiplier % 2 === 0) ? 1 : 2;
            }
            if ((checkSum % 10) != 0) {
                let idElement = this.template.querySelector('.validateID');
                idElement.setCustomValidity('Invalid ID Number');
                idElement.reportValidity();
            } else {
                if (this.checkApplicantAge(idNumber)) {
                    let idElement = this.template.querySelector('.validateID');
                    idElement.setCustomValidity('Age of applicant must be 18 and older');
                    idElement.reportValidity();
                } else {
                    let idElement = this.template.querySelector('.validateID');
                    idElement.setCustomValidity('');
                    idElement.reportValidity();
                }
            }
        }
    }

    checkApplicantAge(idNumber) {
        var currentYearTwoLastDigits = parseInt(new Date().getFullYear().toString().substring(2));
        var yearTwoDigits = idNumber.substring(0, 2);
        var year = '19';
        if (currentYearTwoLastDigits > parseInt(yearTwoDigits)) {
            var year = '20';
        }
        year = year + yearTwoDigits;
        var applicantYear = new Date(year, idNumber.substring(2, 4) - 1, idNumber.substring(4, 6));
        var diff_ms = Date.now() - applicantYear.getTime();
        var age_dt = new Date(diff_ms);
        var applicantAge = Math.abs(age_dt.getUTCFullYear() - 1970);
        if (applicantAge < 18) {
            return true;
        } else {
            return false;
        }
    }
    adobepagestart(event) {

    }

    genericFieldChange(event) {

        let value = event.target.value;
        let name = event.target.dataset.name;
        this.formDetails[name] = value;
    }

    changeEmailValue(event) {
        let value = event.target.value;
        let name = event.target.dataset.name;
        const sbgEmail = /^\w+([\.-]?\w+)*@(?!sbg)\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(this.formDetails[name]) ? false : true;
        const stanlibEmail = /^\w+([\.-]?\w+)*@(?!stanlib)\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(this.formDetails[name]) ? false : true;
        const stanbicEmail = /^\w+([\.-]?\w+)*@(?!stanbic)\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(this.formDetails[name]) ? false : true;
        const standardbankEmail = /^\w+([\.-]?\w+)*@(?!standardbank)\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(this.formDetails[name]) ? false : true;
        if ((sbgEmail || stanlibEmail || stanbicEmail || standardbankEmail) && (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(this.formDetails[name]))) {
            this.template.querySelectorAll('lightning-input').forEach(ele => {
                if (ele.dataset.name == 'EmailAddress') {
                    ele.setCustomValidity('You are attempting to create a Standard Bank employee as a client contact');
                    ele.reportValidity();
                }
            })
        } else if (!(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(this.formDetails[name]))) {
            this.template.querySelectorAll('lightning-input').forEach(ele => {
                if (ele.dataset.name == 'EmailAddress') {
                    ele.setCustomValidity('Your entry does not match the allowed pattern.');
                    ele.reportValidity();
                }
            })
        } else {
            this.template.querySelectorAll('lightning-input').forEach(ele => {
                if (ele.dataset.name == 'EmailAddress') {
                    ele.setCustomValidity('');
                }
            })
        }
    }

    genericComponentChange(event) {
        let value = event.detail.value;
        let name = event.detail.target;
        this.formDetails[name] = value;
        this.showHiddenField(event);
        this.showBusinessField();
    }
    genericComponentChangeBlur(event) {
        let value = event.detail.value;
        this.selectedPicklistValue = value;
        let name = event.detail.target;
        this.formDetails[name] = value;
    }

    genericRadioChange(event) {
        let name = event.target.dataset.name;
        let value = event.target.dataset.value;
        this.formDetails[name] = value;
        if (name === 'soleOwner') this.showHiddenField(event);
        this.removeFieldErrors(name);
    }

    removeFieldErrors(name) {
        if (name === 'soleOwner') this.showOwnerError = false;
        if (name === 'soleShareholder') this.showShareHoldError = false;
    }

    showHiddenField(event) {
        if (this.formDetails.soleOwner === "true" && this.formDetails.businessType) {
            this.showSS = true;
        } else {
            this.showSS = false;
            delete this.formDetails['soleShareholder'];
        }

    }
    showBusinessField() {
        if (this.formDetails.businessType) {
            if (this.formDetails.businessType === 'SOLE PROPRIETOR' || this.formDetails.businessType === 'OTHER') {
                this.showBusinessBlock = true;
                this.showRegistration = false;
                delete this.formDetails['businessRegistrationNumber'];
            }
            if (this.formDetails.businessType === 'PRIVATE COMPANY' || this.formDetails.businessType === 'CLOSE CORPORATION') {
                this.showBusinessBlock = true;
                this.showRegistration = true;
            }
        } else {
            this.showBusinessBlock = false;
            this.showRegistration = false;
        }
        if (this.formDetails.businessProvince === 'ZAF.GP') {
            this.showCity = true;
        } else {
            this.showCity = false;
        }

    }

    genericCheckboxChange(event) {
        let name = event.target.dataset.name;
        let value = event.target.checked;
        this.formDetails[name] = value;
        this.removeFieldErrors(name);
    }

    backToHome(event) {
        window.fireButtonClickEvent(this, event);
        let channel = sessionStorage.getItem(CHANNEL_NAME_KEY);
        if(channel && channel == CHANNEL_NAME_VALUE_MALL) {
            this.navigateBackToBCBPlatform(channel);
        } else {
            window.open(PBP_ZA_StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts', '_self');
        }
    }
    closemodal(event) {
        this.technicalerror = false;
    }

    continueToNextPage(event) {

        this.formDetails['productNumber'] = this.productNumber;
        this.formDetails['pricingOption'] = this.pricingOption;
        this.formDetails['appName'] = this.productShortName;
        this.formDetails['channelName'] = this.channelName;
        window.fireButtonClickEvent(this, event);
        if (this.checkForm()) { 
            this.isLoaded = false;
            findApplication({
                'customerId': this.formDetails['IdNum'],
                'preAppData': JSON.stringify(this.formDetails)
            }).then(result => {
                var resultData = JSON.parse(result);
                this.appstatus = resultData.appFound;
                this.applicationId = resultData.appId;
                var initiateAPI = resultData.initiateAPI;
                if (this.appstatus === 'EXISTING' && initiateAPI === true) {
                    this.initiatePreApplicationAPI();
                } else if (this.appstatus === 'EXISTING' && initiateAPI === false) {
                    this[NavigationMixin.Navigate]({
                        "type": "standard__webPage",
                        "attributes": {
                            "url":AOB_AO_Base_URL + this.applicationId
                        }
                    });
                    window.fireFormCompleteEvent(this, this.adobePageTag.formName);
                } else if (this.appstatus === 'NEW') {
                    this.initiatePreApplicationAPI();

                }
            }).catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.spinload = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
                window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
            });

        } else {
            this.adobePageTag.siteErrorCode = 'client side | please complete the fields';
            window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
            window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
        }
    }

    retryInitiateAPI(event) {
        this.technicalerror = false;
        this.isLoaded = false;
        incrementRetryApplication({
            'applicationId': this.applicationId
        }).then(response => {

            if (response < 3) {
                this.apiRetryNumber = response;
                this.initiatePreApplicationAPI();
            } else {
                this.createLead();
            }
        }).catch(error => {
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
            window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
        });
    }

    createLead() {
        createExternalLead({
            Applicationid: this.applicationId,
            leadReason: this.leadReason
        }).then((result) => {
            this.isLoading = false;
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Mall_retryExceeded__c'
                }
            });

        }).catch((error) => {
            this.isLoading = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
            window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
        });
    }
    editApplication() {
        this.errorCIPC = false;
        this.isLoaded = true;
    }

    initiatePreApplicationAPI() {
        if (this.apiRetryNumber < 3) {
            callPreApplication({
                'preappData': JSON.stringify(this.formDetails),
                'applicationId': this.applicationId
            }).then(result => {

                let response = JSON.parse(result);
                if (response.responseCode === '52000') {
                    mallLinkAccount({
                        'appIds': this.applicationId
                    }).then(result1 => {
                        this[NavigationMixin.Navigate]({
                            "type": "standard__webPage",
                            "attributes": {
                                "url": AOB_AO_Base_URL + this.applicationId
                            }
                        });
                    }).catch((error) => {
                        this.isLoading = true;
                    })
                    window.fireFormCompleteEvent(this, this.adobePageTag.formName);
                } else if (response.responseCode === '52108' || response.responseCode === '52107' || response.responseCode === '52100' || response.responseCode === '52101' || response.responseCode === '52102' || response.responseCode === '400') { // modal popup -- Technical Error
                    this.technicalerror = true;
                    this.code = response.responseCode;
                    this.adobePageTag.siteErrorCode = 'service error | ' + this.code + '|' + response.responseDesc;
                    this.isLoaded = true;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                } else if (response.responseCode === '52105') { // Exisiting Lead
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + '|' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Mall_Preapplication_Existing_Lead__c'
                        }
                    });
                } else if (response.responseCode === '52109') { // Complaince status
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Mall_UnSuccessful_Compliance_Status__c'
                        }
                    });
                } else if (response.responseCode === '52113' || response.responseCode === '52103' || response.responseCode === '52002' || response.responseCode === '52003' || response.responseCode === '52004' || response.responseCode === '52111') { // Automatic Lead
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Mall_PreApplication_Automatic_Lead__c'
                        }
                    });
                } else if (response.responseCode === '52104') { // Application Cannot Completed 
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc + '| Application Cannot Completed';
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this.errorCIPC = true;
                    this.isLoaded = true;
                } else if (response.responseCode === '52110') { // Director status
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Mall_Unsuccessful_Director_status__c'
                        }
                    });
                } else if (response.responseCode === '52112') { // Company status
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Mall_Unsuccessful_Company_Status__c'
                        }
                    });
                } else {
                    this.technicalerror = true;
                    this.code = response.responseCode;
                    this.isLoaded = true;
                    this.adobePageTag.siteErrorCode = 'service error | ' + response.responseCode + ' | ' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                }
                this.isLoading = false;


            }).catch(error => {
                this.technicalerror = true;
                this.isLoaded = true;
                this.isLoading = false;
                this.errorMessage = getErrorMessage.call(this, error);
                this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
                window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                this.code = error;
            });
        } else {
            this.isLoading = false;
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Mall_retryExceeded__c'
                }
            });
        }
    }

    checkForm() {
        var inputValid;
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        inputValid = allValid;
        this.template.querySelectorAll('c-aob_comp_acpicklist').forEach(currentItem => {
            currentItem.triggerInsideBlur();
        });

        if (this.formDetails.businessType && this.formDetails.businessProvince) {
            if (this.formDetails.businessProvince === 'ZAF.GP' && !this.formDetails.businessCity) inputValid = false;
        } else {
            inputValid = false;
        }

        this.template.querySelectorAll('input').forEach(currentItem => {
            if (!this.formDetails[currentItem.dataset.name]) {
                if (currentItem.dataset.name === 'soleOwner') {
                    this.showOwnerError = true;
                }
                if (currentItem.dataset.name === 'soleShareholder') {
                    this.showShareHoldError = true;
                }
                inputValid = false;
            }
        });
        return inputValid;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.productToOpen = this.urlStateParameters.prodId || this.productToOpen;
            this.pricingOptToOpen = this.urlStateParameters.prOpt;
        }
    }
/*
     *@desc  gets readProductsData
     */
    readProductsData() {
        let request = new XMLHttpRequest();
        request.open("GET", productsData + '/' + this.productToOpen + '.json', false);
        request.send(null);
        let jsonProducts = JSON.parse(request.responseText);
        for (let i = 0; i < jsonProducts.product.length; i++) {
            if (jsonProducts.product[i].id == this.productToOpen) {
                if (this.pricingOptToOpen == null) {
                    this.productShortName = jsonProducts.product[i].shortName.toUpperCase();
                    this.pricingOption = jsonProducts.product[i].pricingOption;
                    this.productNumber = jsonProducts.product[i].productNumber;
                    break;
                } else {
                    if (jsonProducts.product[i].pricingOption === this.pricingOptToOpen) {
                        this.productShortName = jsonProducts.product[i].shortName.toUpperCase();
                        this.pricingOption = jsonProducts.product[i].pricingOption;
                        this.productNumber = jsonProducts.product[i].productNumber;
                        break;
                    }
                }
            }
        }
    }

    async navigateBackToBCBPlatform(channelName) {
        try{
            const mymobizManagementSettingByChannel = await getMymobizManagementSetting({channelName : channelName});
            if(mymobizManagementSettingByChannel) {
                let channelSetting = {...mymobizManagementSettingByChannel};
                sessionStorage.setItem(CHANNEL_NAME_KEY, "");
                if(channelSetting && channelSetting.Channel_URL__c) {
                    window.open(channelSetting.Channel_URL__c, "_self"); 
                }
            }
        } catch(error) {
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorCodeEvent(this, this.errorMessage);
        }
    }
}