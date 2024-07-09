import {
    LightningElement,
    api,
    track
} from 'lwc';
import { getErrorMessage } from 'c/aob_comp_utils';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { loadScript } from 'lightning/platformResourceLoader';
import setApplicationStep from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationStep';
import goBacktoPreviousStep from '@salesforce/apex/AOB_CTRL_FormCreator.goBacktoPreviousStep';
import updateinfilght from '@salesforce/apex/AOB_CTRL_FormCreator.updateinfilght';
import pocketbizDetails from '@salesforce/apex/AOB_CTRL_FormCreator.fetchPocketBizDetails';
import getApplicantDataForAdobe from '@salesforce/apex/AOB_CTRL_FormCreator.getApplicantDataForAdobe';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';

export default class Aob_comp_pockitBiz extends LightningElement {
    infoIcon = THEME_OVERRIDES + '/assets/images/info_icon.svg';
    responseFormDetails = {};
    selGoods;
    failing;
    errorMessage;
    selectedPicklistValue;
    isLoaded = true;
    errorContent = '';
    addErrorMessage;
    @track formDetails = { "visaCheck": true, "masterCheck": true, "unionCheck": true, "numberOfDevices": '01',
                           "dinersCheck": false, "dinersNumber":'',"americanCheckbox":false,"americanNumber":'',
                            "rcsCheckbox":false, "rcsNumber":'' };
    @track form;
    isAtScreenLoad = true;
   @api teams = ["Self & Staff","Self Assisted"];
    label = {};
    @api applicationId;
    @api screenName;
    @api previousScreen;
    @api nextScreen;
    @api pageName;
    @api isFiringScreenLoad;
    @api isShowingCloseButton;
    isDevices = false;
    @api availableActions = [];
    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }
    @track fieldsMap = {};
    @track numberOfDevices = '01';
    @track deviceTotal = 'Zero';
    @api adobeDataScope;
    @track sections;
    @api adobePageName;
    @api productName;
    @api productCategory;
    pricePerDevice = '69.00';
    openClosePageModal;
    isLoaded = true;
    disableCheck = true;
    disableCheck1 = false;
    disableCheck2 = false;
    disableCheck3 = false;
    showBackButton;
    showNextButton;
    adobeDataScopeApp;
    adobeDataTextBack;
    adobeDataTextContinue;
    adobeformName;
    siteerror;
    showBackB = true;
    isPreApplication = false;
    screenTitle;
    screenSubtitle;
    gridClass;
 
   totalAmount='Zero';
    lasttwodigits = ',00';
    dinerscheckbox = false;
    americancheckbox = false;
    rcscheckbox = false;
    application = {
        applicationProduct: this.adobeDataScope,
        applicationMethod: "Online",
        applicationID: "",
        applicationName: "",
        applicationStep: "",
        applicationStart: true,
        applicationComplete: false
    }
    userInfo = {
        bpguid: "",
        encryptedUsername: ""
    }
    get numberOptions() {
        return [
            { label: '01', value: '01' },
            { label: '02', value: '02' },
            { label: '03', value: '03' },
            { label: '04', value: '04' },
            { label: '05', value: '05' },
            { label: '06', value: '06' },
            { label: '07', value: '07' },
            { label: '08', value: '08' },
            { label: '09', value: '09' },
            { label: '10', value: '10' },
        ];
    }
    connectedCallback() {
        getApplicantDataForAdobe({
            'applicationId': this.applicationId
        }).then(result => {
            let Response = JSON.parse(result);
            this.userInfo.encryptedUsername = Response['customerEmail'];
            this.userInfo.bpguid = Response['customerGUID'];
            this.userInfo.bpguid = this.userInfo.bpguid.split('-').join('');
            this.userInfo.bpguid = this.userInfo.bpguid.toUpperCase();
            window.fireUserInfoEvent(this, this.userInfo);
        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            this.technicalerror = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.siteerror='service error | '+this.errorMessage;
            window.fireErrorEvent(this, this.siteerror);
        });
        this.isLoaded = true;
        this.productName=this.productName.toLowerCase();
        this.adobeDataScopeApp = this.productName + ' application';
        this.adobeDataScopeApp = this.adobeDataScopeApp.toLowerCase();
        this.adobeDataTextBack = this.adobePageName + ' application ' + ' | Back button click';
        this.adobeDataTextContinue = this.adobePageName + ' application ' + '|  Continue button click';

        this.isLoaded = true;
        this.adobePageTag = 'business:'  + 'products and services:bank with us:business bank accounts:'+ this.productName +" account origination "+this.adobeDataScope+" " + this.adobePageName +" form";
        this.application.applicationID = this.applicationId;
        this.application.applicationName = 'Application:' + this.productName +' business account';
        this.application.applicationProduct = this.productName + ' business account';
        this.application.applicationStep = this.adobeDataScope;
        this.adobeformName = "apply now " +'business bank account '+ this.productName + ' account origination '+this.adobeDataScope+' '+ this.screenName.toLowerCase() + " form";
        loadScript(this, FireAdobeEvents).then(() => { //Adobe tagging start
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag);
                window.fireFormStart(this, this.adobeformName);
               window.fireFormStartEvent(this, this.application);

            }
        });
        setApplicationStep({
            'applicationId': this.applicationId,
            'currentScreen': this.screenName,
            'previousScreen': this.previousScreen
        }).then(result => {
        })
            .catch(error => {
                this.failing = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.siteerror='service error | '+this.errorMessage;
               window.fireErrorEvent(this, this.siteerror);
            });
        this.fetchPocketBizDetailsDisplay();
    }
     handleResultChange(event) {
        this.label = event.detail;
    }


    fetchPocketBizDetailsDisplay() {
        pocketbizDetails({
            'appplicationId': this.applicationId
        }).then(res => {
            if (res) {
                this.formDetails = JSON.parse(res);
                this.numberOfDevices = this.formDetails.numberOfDevices;
                this.isLoaded = true;
                if(this.formDetails.dinersCheck) this.dinerscheckbox = true;
                if(this.formDetails.americanCheckbox) this.americancheckbox = true;
                if(this.formDetails.rcsCheckbox) this.rcscheckbox = true;
                if(this.formDetails.merchantCategory) this.selectedPicklistValue = this.formDetails.merchantCategory;
            }

        }).catch(error => {
            this.isLoaded = true;
            this.siteerror='service error | '+error;
            window.fireErrorEvent(this, this.siteerror);
        });
    }
    genericInputOnChange(event) {
        this.numberOfDevices = event.detail.value;
        this.formDetails[event.target.dataset.name] = this.numberOfDevices;
    }
    handleInputChange1(event) {
        if (this.dinerscheckbox == false) {
            this.dinerscheckbox = true;
        }
        else {
            this.dinerscheckbox = false;
            this.formDetails['dinersNumber'] = '';
        }
        this.disableCheck1 = this.template.querySelector('[data-id="checkbox1"]').checked;
        this.formDetails[event.target.dataset.name] = this.disableCheck1;
    }
    handleInputChange2(event) {
        if (this.americancheckbox == false) {
            this.americancheckbox = true;
        } else {
            this.americancheckbox = false;
            this.formDetails['americanNumber'] = '';
        }
        this.disableCheck2 = this.template.querySelector('[data-id="checkbox2"]').checked;
        this.formDetails[event.target.dataset.name] = this.disableCheck2;
    }
    handleInputChange3(event) {
        if (this.rcscheckbox == false) {
            this.rcscheckbox = true;
        } else {
            this.formDetails['rcsNumber'] = '';
            this.rcscheckbox = false
        }
        this.disableCheck3 = this.template.querySelector('[data-id="checkbox3"]').checked;
        this.formDetails[event.target.dataset.name] = this.disableCheck3;
    }
    nameofTheIndividualChange(event) {

        this.formDetails[event.target.dataset.name] = event.detail.value;
    }
    goodsdescribeExampleChange(event) {
        this.selGoods = event.detail.value;
        this.formDetails[event.target.dataset.name] = this.selGoods;
    }
    genericInputOnChangeMerchant(event) {
        let selValue = event.detail.value;
        let name = event.detail.target;
        this.formDetails[name] = selValue;
    }
    continueToNextPage(event) {
        this.isLoaded = false;
        window.fireButtonClickEvent(this, event);
        if (this.validateForm()) {
            this.formDetails['pricePerDevice'] = this.pricePerDevice;
            updateinfilght({
                'code': 'ZPOB',
                'json': JSON.stringify(this.formDetails),
                'applicationId': this.applicationId
            }).then(result => {
                if (this.availableActions.find(action => action === this.constants.NEXT)) {
                    // navigate to the next screen
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                    window.fireFormCompleteEvent(this,this.adobeformName);
                }
            }).catch(error => {
                this.isLoaded = true;
                this.siteerror='service error | '+error;
               window.fireErrorEvent(this, this.siteerror);            });
        }else{
            this.siteerror='client side | please complete the fields';
            window.fireErrorEvent(this, this.siteerror);
        }
    }
    validateForm() {
        var isValid = true;
        this.template.querySelectorAll('[data-id="checkbox"]').forEach(element => {
            this.removeError(element);
            if (element.required && element.checked) {
                element.setCustomValidity(element.dataset.errorMessage);
                element.reportValidity();
                element.focus();
                isValid = false;
            } else if (!element.reportValidity()) {
                isValid = false;
            }
        });
        this.template.querySelectorAll('[data-id="texts"]').forEach(element => {
            this.removeError(element);
            if (element.required && !element.value) {
                element.setCustomValidity(element.dataset.errorMessage);
                //To check the input validity function we have to use reportValidity function.
                element.reportValidity();
                element.focus();
                isValid = false;
            } 
            else if (!element.reportValidity()) {
                isValid = false;
            }
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            this.removeError(element);
            if (element.required && !element.value) {
                element.setCustomValidity(element.dataset.errorMessage);
                element.reportValidity();
                element.focus();
                isValid = false;
            } 
            else if (!element.reportValidity()) {
                isValid = false;
            }
        });
        this.template.querySelectorAll('c-aob_comp_acpicklist').forEach(currentItem => {
            currentItem.triggerInsideBlur();
        });
        if(!this.formDetails['merchantCategory']) isValid = false;
        return isValid;
    }

    checkForm() {
        let isValid = true;
        return isValid;
    }

    removeError(element) {
        element.setCustomValidity("");
        element.reportValidity();
    }

    backToPreviousPage(event) {
        window.fireButtonClickEvent(this, event);
        goBacktoPreviousStep({
            'applicationId': this.applicationId
        }).then(result => {
            window.location.reload();
        }).catch(error => {
            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorEvent(this,  this.errorMessage);

        });
    }
}