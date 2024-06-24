/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   19-09-2022   Devi Ravuri   PreApplication
   @last modified on  : 19 APRIL 2024
   @last modified by  : Narendra 
   @Modification Description : SFP-38348
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

import findApplication from '@salesforce/apex/AOB_CTRL_FindApplications.findApplication';
import callPreApplication from '@salesforce/apex/AOB_CTRL_FindApplications.callPreApplication';
import incrementRetryApplication from '@salesforce/apex/AOB_CTRL_FindApplications.incrementRetryApplication';
import createExternalLead from "@salesforce/apex/AOB_API_BusinessLead_CTRL.callBusinessLead";
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents";
import productsData from '@salesforce/resourceUrl/PBP_ZA_ProductData';

const RETRY_NUMBER = 1;
export default class Aob_comp_preApplication extends NavigationMixin(LightningElement) {
    productToOpen = "4648";
    pricingOptToOpen = null;
    productNumber = null;
    pricingOption = null;
    productShortName = null;
    @track formDetails = { "isSFCreateLead": false };
    @track showSS;
    @track error_message = "";
    applicationId;
    showCIPICPage;
    @track regNumberUserAttempts = 0;
    showBusinessBlock;
    showRegistration;
    showCity;
    appstatus;
    technicalerror;
    showShareHoldError;
    showOwnerError;
    showCompanyRegError;
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
    @api teams = ["Self Assisted"];
    label = {};

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
    }

    handleResultChange(event) {
        this.label = event.detail;
    }

    renderedCallback() {
        if (this.formDetails.companyRegistered == "true") {
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

    genericComponentChange(event) {
        let value = event.detail.value;
        let name = event.detail.target;
        this.formDetails[name] = value;
        this.showBusinessCity();
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
        if (name === 'soleOwner' || name === 'companyRegistered') this.showHiddenField(event);
        this.removeFieldErrors(name);
        this.showBusinessField();
    }

    removeFieldErrors(name) {
        if (name === 'soleOwner') this.showOwnerError = false;
        if (name === 'soleShareholder') this.showShareHoldError = false;
        if (name === 'companyRegistered') this.showCompanyRegError = false;
    }

    showHiddenField(event) {
        if (this.formDetails.soleOwner === "true" && this.formDetails.companyRegistered) {
            this.showSS = true;
        } else {
            this.showSS = false;
            delete this.formDetails['soleShareholder'];
        }

    }
    showBusinessField() {
        if (this.formDetails.companyRegistered == "true") {
            this.showBusinessBlock = true;
            this.showRegistration = true;
        } else {
            this.showBusinessBlock = true;
            this.showRegistration = false;
            delete this.formDetails['businessRegistrationNumber'];
        }
    }

    showBusinessCity() {
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
        window.open(this.label.PBP_ZA_ProductSiteBaseURL + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts', '_self');
    }
    closemodal(event) {
        this.technicalerror = false;
    }

    continueToNextPage(event) {
        this.formDetails['productNumber'] = this.productNumber;
        this.formDetails['pricingOption'] = this.pricingOption;
        this.formDetails['appName'] = this.productShortName;
        this.formDetails['channelName'] = 'MyMobiz';
        window.fireButtonClickEvent(this, event);
        if (this.checkForm()) {
            this.isLoaded = false;
            this.findApplication();
        } else {
            this.adobePageTag.siteErrorCode = 'client side | please complete the fields';
            window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
            window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
        }
    }

    setBusinessType() {
        let businessRegNum = this.formDetails['businessRegistrationNumber'];
        if (!businessRegNum) {
            this.formDetails['businessType'] = 'SOLE PROPRIETOR';
            return;
        }
        let regLastTwoDigits = businessRegNum.substring(businessRegNum.length - 2);
        switch (regLastTwoDigits) {
            case "07":
                this.formDetails['businessType'] = 'PRIVATE COMPANY';
                break;
            case "23":
                this.formDetails['businessType'] = 'CLOSE CORPORATION';
                break;
            default:
                this.formDetails['businessType'] = 'OTHER';

        }


    }

    findApplication() {
        this.setBusinessType();
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
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'business_preapplication_verification__c'
                    },
                    state: {
                        status: this.appstatus,
                        appId: this.applicationId,
                        product: this.productShortName
                    }
                });
                window.fireFormCompleteEvent(this, this.adobePageTag.formName);
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
    }

    retryInitiateAPI(event) {
        this.technicalerror = false;
        this.isLoaded = false;
        incrementRetryApplication({
            'applicationId': this.applicationId
        }).then(response => {
            let retryValue = parseInt(response);
            if (retryValue <= RETRY_NUMBER) {
                this.apiRetryNumber = retryValue;
                this.initiatePreApplicationAPI();
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'retryExceeded__c'
                    }
                });
            }
        }).catch(error => {
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
            window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
        });
    }

    createLead(leadReason) {
        createExternalLead({
            applicationId: this.applicationId,
            leadReason: leadReason
        }).then((result) => {
            this.isLoading = false;
            if (this.showCIPICPage) {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'CIPC_Call_Me_Back__c'
                    }
                });
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'PreApplication_Automatic_Lead__c'
                    }
                });
            }

        }).catch((error) => {
            this.isLoading = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
            window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
        });
    }
    editApplication(event) {
        this.formDetails['businessRegistrationNumber'] = event.detail;
        this.template.querySelector('.validateRegNum').value = this.formDetails['businessRegistrationNumber'];
        this.errorCIPC = false;
        this.isLoaded = false;
        this.apiRetryNumber = 0;
        this.findApplication();
        if (this.regNumberUserAttempts == 2) {
            this.formDetails['isSFCreateLead'] = true;
        } else {
            this.formDetails['isSFCreateLead'] = false;
        }

    }
    callMeBackCIPC(event) {
        this.errorCIPC = false;
        this.isLoaded = false;
        this.showCIPICPage = true;
        this.createLead(event.detail);
    }

    initiatePreApplicationAPI() {
      
        if (this.apiRetryNumber <= RETRY_NUMBER) {
            callPreApplication({
                'preappData': JSON.stringify(this.formDetails),
                'applicationId': this.applicationId
            }).then(result => {
                let response = JSON.parse(result);
                
                if (this.apiRetryNumber === RETRY_NUMBER && (response.responseCode === '52108' || response.responseCode === '52107' || response.responseCode === '52100' || response.responseCode === '52101' || response.responseCode === '52102' || response.responseCode === '400')) {
                    this.createLead('PreApplication API failed');
                }
                else if (response.responseCode === '52000') {
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'business_preapplication_verification__c'
                        },
                        state: {
                            status: this.appstatus,
                            appId: this.applicationId,
                            product: this.productShortName
                        }
                    });
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
                            name: 'Preapplication_Existing_Lead__c'
                        }
                    });
                } else if (response.responseCode === '52109') { // Complaince status
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'UnSuccessful_Compliance_Status__c'
                        }
                    });
                } else if (response.responseCode === '52113' || response.responseCode === '52103' || response.responseCode === '52003' || response.responseCode === '52002' || response.responseCode === '52111' || response.responseCode === '52004') { // Automatic Lead
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'PreApplication_Automatic_Lead__c'
                        }
                    });
                } else if (response.responseCode === '52104') { // Application Cannot Completed 
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc + '| Application Cannot Completed';
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this.regNumberUserAttempts++;
                    if (this.regNumberUserAttempts == 3) {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'PreApplication_CIPC__c'
                            }
                        });
                    } else {
                        this.isLoaded = true;
                        this.errorCIPC = true;
                    }

                } else if (response.responseCode === '52110') { // Director status
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Unsuccessful_Director_status__c'
                        }
                    });
                } else if (response.responseCode === '52112') { // Company status
                    this.adobePageTag.siteErrorCode = 'Business error | ' + response.responseCode + ' | ' + response.responseDesc;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Unsuccessful_Company_Status__c'
                        }
                    });
                } else {
                    if (this.apiRetryNumber === RETRY_NUMBER) {
                        this.createLead('PreApplication API failed');
                    }
                    else {
                        this.technicalerror = true;
                        this.code = response.responseCode;
                        this.isLoaded = true;
                        this.adobePageTag.siteErrorCode = 'service error | ' + response.responseCode + ' | ' + response.responseDesc;
                        window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                        window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    }

                }
                this.isLoading = false;
            }).catch(error => {
                if (this.apiRetryNumber === RETRY_NUMBER) {
                    this.createLead('PreApplication API failed');
                }
                else {
                    this.technicalerror = true;
                    this.isLoaded = true;
                    this.isLoading = false;
                    this.errorMessage = getErrorMessage.call(this, error);
                    this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
                    window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
                    window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
                    this.code = error;

                }
            });
        } else {
            this.isLoading = false;
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'retryExceeded__c'
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

        if (this.formDetails.companyRegistered && this.formDetails.businessProvince) {
            if (this.formDetails.businessProvince === 'ZAF.GP' && !this.formDetails.businessCity) inputValid = false;
        } else {
            inputValid = false;
        }

        this.template.querySelectorAll('input').forEach(currentItem => {
            if (!this.formDetails[currentItem.dataset.name]) {
                if (currentItem.dataset.name === 'soleOwner') {
                    this.showOwnerError = true;
                }
                else if (currentItem.dataset.name === 'soleShareholder') {
                    this.showShareHoldError = true;
                }
                else if (currentItem.dataset.name === 'companyRegistered') {
                    this.showCompanyRegError = true;
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


}