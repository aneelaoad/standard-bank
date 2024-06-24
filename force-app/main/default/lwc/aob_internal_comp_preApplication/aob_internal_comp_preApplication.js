/**
 * @description       : Displays fields to capture for Pre-Application
 * @author            : Sibonelo Ngcobo
 * @last modified on  : 10-11-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-20-2023   Sibonelo Ngcobo   SFP-25089
**/
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
import findApplication from '@salesforce/apex/AOB_Internal_CTRL_FindApplications.findApplication';
import getProduct from '@salesforce/apex/AOB_Internal_CTRL_FindApplications.getProduct';
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
import preApplicationCallout from '@salesforce/apex/AOB_CTRL_InternalPreApplication.preApplicationCallout';
import {
    deleteRecord
} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createLead from '@salesforce/apex/AOB_Internal_CTRL_FindApplications.createLead';
import accountOrigination from '@salesforce/apex/AOB_CTRL_BusinessAccountOrigination.businessAccOriginationCallout';
import { createLogger } from 'sbgplatform/rflibLogger';


export default class Aob_internal_comp_preApplication extends LightningElement {
    logger = createLogger('Aob_internal_comp_preApplication');
    @api productId;
    @api accountId;
    @api registrationNumber;
    productToOpen;
    pricingOptToOpen = null;
    productNumber = null;
    pricingOption = null;
    productShortName = null;
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
    leadReason = 'PreApplication API retry Limit Exceeded';
    showPreApp=true;
    showProduct=false;
    showDirector=false;
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
        pageName: "business:products and services:bank with us:business bank accounts:mymobiz plus account origination step 1  pre-application form",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: "preapplication",
        cancelButtonText: "mymobiz business account | pre-application |  cancel button click",
        continueButtonText: "mymobiz business account | pre-application | continue button click",
        privacyintent: "informational",
        privacyscope: "mymobiz application",
        privacylinkclick: "pre application | privacy statement link click",
        siteErrorCode: '',
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
    next1;
    @api screenName;
    showModal = false;
    sticky = false;
    timeout = 10000;
    showSearch=false;


    constructor() {
        super();
        this.isMobileDevice = window.matchMedia("only screen and (max-width:576px)").matches;
    }
    

    connectedCallback() {
        loadScript(this, FireAdobeEvents).then(() => {
                if (!this.isEventFired) {
                    this.isEventFired = true;
                    this.adobeAnalyticsPageView();
                }
            })
            .catch(error => {
                this.logger.error('An error occurred while calling loadScript:', error);
                this.error = error;
            });
        this.getProduct();

    }
    getProduct() {
        getProduct({
                productId: this.productId
            })
            .then(result => {
                this.productToOpen = result[0].ProductCode;
                this.readProductsData(result[0].ProductCode);
            })
            .catch(error => {
                this.logger.error('An error occurred while calling getProduct:', error);
                this.error=error;
            })
    }

    adobeAnalyticsPageView() {
        document.dispatchEvent(new CustomEvent('screenload', {
            'detail': {
                formName: "Registration"
            }
        }));
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
   

    genericFieldChange(event) {

        let value = event.target.value;
        let name = event.target.dataset.name;
        this.formDetails[name] = value;
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
            if (this.formDetails.businessType === 'SOLE PROPRIETORSHIP' || this.formDetails.businessType === 'OTHER') {
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
        this[NavigationMixin.Navigate]({
            "type": "comm__namedPage",
            attributes: {
                name: 'our_accounts__c'
            }
        });
    }
    closemodal(event) {
        this.technicalerror = false;
    }
    continueToNextPage() {
        this.formDetails['productNumber'] = this.productNumber;
        this.formDetails['pricingOption'] = this.pricingOption;
        this.formDetails['appName'] = this.productShortName;
        this.formDetails['soleOwner'] = false;
        this.formDetails['consentForStaffAttestation']=true;
        if (this.checkForm()) {
            this.isLoaded = false;
            findApplication({
                'customerId': this.formDetails['IdNum'],
                'preAppData': JSON.stringify(this.formDetails),
                'productCode': this.productToOpen,
                'accountId': this.accountId
            }).then(result => {
                var resultData = JSON.parse(result);
                this.appstatus = resultData.appFound;
                this.applicationId = resultData.appId;
                this.adobePageTag.application.applicationID = this.applicationId;
                this.preAppCallout(this.applicationId);

            }).catch(error => {
                this.logger.error('An error occurred while calling findApplication:', error);
                this.failing = true;
                this.isLoaded = true;
                this.spinload = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.adobePageTag.siteErrorCode = this.errorMessage;
            });
            this.adobePageTag.application.applicationStart = false;
            this.adobePageTag.application.applicationComplete = true;
        }
    }
    editApplication() {
        this.errorCIPC = false;
        this.isLoaded = true;
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

    readProductsData(productToOpen) {
        let request = new XMLHttpRequest();
        request.open("GET", productsData + '/' + productToOpen + '.json', false);
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
    preAppCallout(applicationId) {
        let idNumber=this.formDetails['IdNum'];
        this.registrationNumber = this.formDetails['businessRegistrationNumber'];
        if(this.registrationNumber==null){
            this.registrationNumber=idNumber;
        }
        preApplicationCallout({
                preApplicationId:applicationId,
                registrationNumber: this.registrationNumber
            })
            .then(results => {
                let result = JSON.parse(JSON.stringify(results));
                if (result) {
                    if (result == 'Successful') {
                        this.accountOrigination();
                    } else {
                        this.showToast(result,'error');
                        this.removeApplicationRecord();
                        setTimeout(()=> {
                            this.showPreApp=false;
                            this.showProduct=true;
                        }
                             ,10000);
                         this.createLead();
                    }
                }
            })
            .catch(error => {
                this.logger.error('An error occurred while calling preApplicationCallout API:', error);
                const message = 'Some unexpected error,Please contact your administrator';
                this.showToast(message,'error');
                this.removeApplicationRecord();
                setTimeout(()=> {
                    this.showPreApp=false;
                    this.showProduct=true;
                }
                     ,10000);
                this.createLead();
            })
    }
    accountOrigination(){
        accountOrigination({applicationId:this.applicationId})
        .then(result=>{
        let results = JSON.parse(JSON.stringify(result));
        if (result == 'Successful') {
        this.showPreApp=false;
        this.showDirector=true;
        this.showToast(results,'success');
        
        }else {
            let results = JSON.parse(JSON.stringify(result));
            this.showToast(results,'error');
            this.removeApplicationRecord();
            setTimeout(()=> {
            this.showPreApp=false;
            this.showProduct=true;
        }
            ,10000);
            this.createLead();
        }
        })
        .catch(error=>{
            this.logger.error('An error occurred while calling accountOrigination API:', error);
            let errors = JSON.stringify(error);
            this.showToast(errors,'error');
            this.removeApplicationRecord();
            setTimeout(()=> {
            this.showPreApp=false;    
            this.showProduct=true;                    
        }
             ,10000);
             this.createLead();
        })
    }
    createLead(){
        createLead({
            'preAppData': JSON.stringify(this.formDetails),
            'productCode': this.productToOpen,
            'accountId': this.accountId
        }).then(result => {
        })
            .catch((error) => {
                this.logger.error('An error occurred while calling createLead:', error);
                this.error = error;
            });
    }
    showToast(message,variant) {
        const event = new ShowToastEvent({
            variant:variant,
            message:message,
        });
        this.dispatchEvent(event);
    }
    removeApplicationRecord() {
        deleteRecord(this.applicationId)
            .then((result) => {
                this.applicationId = null;
            })
            .catch((error) => {
                this.logger.error('An error occurred while calling deleteRecord:', error);
                this.error = error;
            });

    }
    handleModalClick() {
        this.productId = null;
        this.showPreApp=false; 
        this.showSearch=true;
    }

}