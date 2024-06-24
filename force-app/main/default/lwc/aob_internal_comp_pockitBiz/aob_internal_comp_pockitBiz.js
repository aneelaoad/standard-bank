/**
 * @description       : Displays PockitBiz fields to capture.
 * @author            : Sibonelo Ngcobo
 * @last modified on  : 07-20-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-20-2023   Sibonelo Ngcobo   SFP-25089
**/
import {LightningElement,api,wire,track} from 'lwc';
import { getErrorMessage } from 'c/aob_comp_utils';
import { loadScript } from 'lightning/platformResourceLoader';
import setApplicationStep from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.setApplicationStep';
import updateinflight from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updateinflight';
import pocketbizDetails from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.fetchPocketBizDetails';
import AOB_Mymobiz_title from '@salesforce/label/c.AOB_Mymobiz_title';
import AOB_Mymobiz_subTitle from '@salesforce/label/c.AOB_Mymobiz_subTitle';
import AOB_Mymobiz_info_request from '@salesforce/label/c.AOB_Mymobiz_info_request';
import AOB_Number_devices from '@salesforce/label/c.AOB_Number_devices';
import AOB_Select_card from '@salesforce/label/c.AOB_Select_card';
import AOB_Visa from '@salesforce/label/c.AOB_Visa';
import AOB_Diners from '@salesforce/label/c.AOB_Diners';
import AOB_Diners_merchant_number from '@salesforce/label/c.AOB_Diners_merchant_number';
import AOB_Mastercard from '@salesforce/label/c.AOB_Mastercard';
import AOB_American_Express from '@salesforce/label/c.AOB_American_Express';
import AOB_Amex_number from '@salesforce/label/c.AOB_Amex_number';
import AOB_Union_Pay from '@salesforce/label/c.AOB_Union_Pay';
import AOB_RCS from '@salesforce/label/c.AOB_RCS';
import AOB_RCS_merchant_number from '@salesforce/label/c.AOB_RCS_merchant_number';
import AOB_describe_goods from '@salesforce/label/c.AOB_describe_goods';
import AOB_Merchant_Category from '@salesforce/label/c.AOB_Merchant_Category';
import AOB_delivery from '@salesforce/label/c.AOB_delivery';
import AOB_Fee from '@salesforce/label/c.AOB_Fee';
import AOB_R from '@salesforce/label/c.AOB_R';
import AOB_Additional_fee from '@salesforce/label/c.AOB_Additional_fee';
import AOB_Total from '@salesforce/label/c.AOB_Total';
import AOB_Excludes from '@salesforce/label/c.AOB_Excludes';
import AOB_SelectPlaceHolder from '@salesforce/label/c.AOB_SelectPlaceHolder';
import AOB_Example from '@salesforce/label/c.AOB_Example';
import merchantCategory from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.fetchPocketBizMerchant';
import availableBundlesData from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.selectedAvailableBundles';


import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
//LMS imports
import { publish, MessageContext } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/progressMessageChannel__c';
import BackmessageChannel from '@salesforce/messageChannel/previousScreenMessageChannel__c';

export default class Aob_comp_pockitBiz extends LightningElement {
    responseFormDetails = {};
    selGoods;
    merchCat;
    diners;
    amexNumber;
    rcsNumber;
    numOfDevices;
    failing;
    errorMessage;
    selectedPicklistValue;
    isLoaded = true; 
    errorContent = '';
    addErrorMessage;
    goods;
    @track formDetails = { "visaCheck": true, "masterCheck": true, "unionCheck": true, "numberOfDevices": '01',
                           "dinersCheck": false, "dinersNumber":'',"americanCheckbox":false,"americanNumber":'',
                            "rcsCheckbox":false, "rcsNumber":'' };
    @track form;
    isAtScreenLoad = true;
    //Labels
    label = {
        AOB_Mymobiz_title,
        AOB_Mymobiz_subTitle,
        AOB_Mymobiz_info_request,
        AOB_Number_devices,
        AOB_Select_card,
        AOB_Visa,
        AOB_Diners,
        AOB_Diners_merchant_number,
        AOB_Mastercard,
        AOB_American_Express,
        AOB_Amex_number,
        AOB_Union_Pay,
        AOB_RCS,
        AOB_RCS_merchant_number,
        AOB_describe_goods,
        AOB_Merchant_Category,
        AOB_delivery,
        AOB_Fee,
        AOB_R,
        AOB_Additional_fee,
        AOB_Total,
        AOB_Excludes,
        AOB_SelectPlaceHolder,
        AOB_Example
    };
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
    @track deviceTotal = '69,00';
    @api adobeDataScope;
    @track sections;
    @api adobePageName;
    @api productCategory;
    pricePerDevice = '69.00';
    openClosePageModal;
    disableCheck = true;
    disableCheck1 = false;
    disableCheck2 = false;
    disableCheck3 = false;
    showBackButton;
    showNextButton;
    adobeDataScopeApp;
    adobeDataTextBack;
    adobeDataTextContinue;
    showBackB = true;
    isPreApplication = false;
    screenTitle;
    screenSubtitle;
    gridClass;
    totalAmount = '69,00';
    lasttwodigits = ',00';
    dinerscheckbox = false;
    americancheckbox = false;
    rcscheckbox = false;
    application = {
        applicationProduct: "Customer on boarding",
        applicationMethod: "Online",
        applicationID: "",
        applicationName: "",
        applicationStep: "",
        applicationStart: true,
        applicationComplete: false
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
    next1;
    isSnapScan;


    @wire(MessageContext)
    MessageContext;

    availableBundlesData() {
        availableBundlesData({
            'appliId': this.applicationId
        }).then(eachBundle => {
            var totalRecs = JSON.parse(eachBundle);
            if(totalRecs["4488"]){
            this.isBusinessMarketLink = totalRecs["4488"];
            }
            this.isPocketBiz = totalRecs.ZPOB;
            this.isSnapScan = totalRecs.ZPSS;
            this.fetchPocketBizDetailsDisplay();
        });
    }

    handleClicks() {
        var progressMessage={currentScreen:this.nextScreen};
        publish(this.MessageContext,messageChannel,progressMessage);
        if(this.isSnapScan==true){
            this.next1='SnapScan';
            var progressMessage={currentScreen:this.next1};
            publish(this.MessageContext,messageChannel,progressMessage);
        }
        else{
            this.next1='Summary';
            var progressMessage={currentScreen:this.next1};
            publish(this.MessageContext,messageChannel,progressMessage);
        }
    
        const message= new CustomEvent('buttonclick',
        {detail:this.next1
        });
        this.dispatchEvent(message);
    }
    connectedCallback() {
        this.availableBundlesData();
        this.adobeDataScopeApp = this.adobeDataScope + ' business application';
        this.adobeDataScopeApp = this.adobeDataScopeApp.toLowerCase();
        this.adobeDataTextBack = this.adobePageName + ' application ' + ' | Back button click';
        this.adobeDataTextContinue = this.adobePageName + ' application ' + '|  Continue button click';
        this.adobePageTag = 'business application:' + this.adobeDataScopeApp + ':' + this.adobePageName;
        loadScript(this, FireAdobeEvents).then(() => { //Adobe tagging start
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag);
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
                window.fireErrorCodeEvent(this, this.errorMessage);

            });
        this.fetchPocketBizDetailsDisplay();  
    }

    fetchPocketBizDetailsDisplay() {
        pocketbizDetails({
            'applicationId': this.applicationId
        }).then(res => {
            if (res) {  
                this.formDetails = JSON.parse(res);
                this.numberOfDevices = this.formDetails.numberOfDevices;
                this.isDevices = true;
                this.totalAmount = this.numberOfDevices * this.pricePerDevice;
                this.totalAmount = this.totalAmount + ',00';
                this.goods=this.formDetails['goodsdescribe'];
                this.diners=this.formDetails['dinersNumber'];
                this.amexNumber=this.formDetails['americanNumber'];
                this.rcsNumber=this.formDetails['rcsNumber'];
                this.numOfDevices=this.formDetails['numOfDvs'];
                if(this.formDetails.dinersCheck) this.dinerscheckbox = true;
                if(this.formDetails.americanCheckbox) this.americancheckbox = true;
                if(this.formDetails.rcsCheckbox) this.rcscheckbox = true;
                if(this.formDetails.merchantCategory) this.selectedPicklistValue = this.formDetails.merchantCategory;
                this.merchantCategory();
            }
            this.isLoaded = true;
        }).catch(error => {
            this.isLoaded = true;
            window.fireErrorCodeEvent(this, error);

        });
    }
    genericInputOnChange(event) {
        this.numberOfDevices = event.detail.value;
        this.isDevices = true;
        this.totalAmount = this.numberOfDevices * this.pricePerDevice;
        this.totalAmount = this.totalAmount + ',00';
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
        this.disableCheck1 = this.template.querySelector('[data-id="checkbox"]').checked;
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
    continueToNextPage() {
        this.isLoaded = false;
       if (this.validateForm()) {
            this.formDetails['pricePerDevice'] = this.pricePerDevice;
            updateinflight({
                'code': 'ZPOB',
                'json': JSON.stringify(this.formDetails),
                'applicationId': this.applicationId
            }).then(result => {
                this.handleClicks();
            }).catch(error => {
                this.isLoaded = true;
                window.fireErrorCodeEvent(this, error);
            });
            
        }
    }
    merchantCategory(){
        const merchantCode=this.formDetails['merchantCategory'];
        merchantCategory({merchantCode:merchantCode})
        .then(result=>{
        this.isLoaded = true;
        this.merchCat=result;
        })
        .catch(error=>{
        })
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
        this.handleBackClick();  
    }
    handleBackProgress(){
        var progressMessage={currentScreen:this.previousScreen};
        publish(this.MessageContext,messageChannel,progressMessage);
    }
    handleBackClick() {
        this.handleBackProgress();
        var previousScreenMessage={previousScreen:this.previousScreen};
        publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
    }
        
}