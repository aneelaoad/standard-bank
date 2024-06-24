import { LightningElement, track, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { getErrorMessage } from 'c/aob_comp_utils';
import { NavigationMixin } from "lightning/navigation";
import { loadScript } from 'lightning/platformResourceLoader';
import createExternalLead from "@salesforce/apex/AOB_API_BusinessLead_CTRL.callBusinessLead";
import setApplicationStep from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationStep';
import setApplicationData from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationData';
import goBacktoPreviousStep from '@salesforce/apex/AOB_CTRL_FormCreator.goBacktoPreviousStep';
import clearChequeCardInflight from '@salesforce/apex/AOB_CTRL_FormCreator.clearChequeCardInflight';
import getCustomer from '@salesforce/apex/AOB_CTRL_GetCustomer.getCustomer';
import incrementRetryApplication from '@salesforce/apex/AOB_CTRL_FindApplications.incrementRetryApplication';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import getApplicantDataForAdobe from '@salesforce/apex/AOB_CTRL_FormCreator.getApplicantDataForAdobe';
const RETRY_NUMBER = 1;
export default class Aob_comp_selectCard extends NavigationMixin(LightningElement) {
    @api teams = ["Self Assisted"];
    label = {};
    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }
    isLoaded = true;
    debitCard = AOB_ThemeOverrides + '/assets/images/gold-debit-mobile.png';
    chequeCard = AOB_ThemeOverrides + '/assets/images/gold-credit-mobile.png';
    defaultImg = AOB_ThemeOverrides + '/assets/images/defaultTag.png';
    upgradeImg = AOB_ThemeOverrides + '/assets/images/upgradeTag.png';
    @api applicationId;
    @api productName;
    @api screenName;
    retryValue;
    @api previousScreen;
    @api nextScreen;
    @track customFormModal = false;
    isEventFired;
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    adobeformName;
    adobeDataScopeApp;
    adobeDataTextBack;
    siteerror;
    technicalerror;
    adobeDataTextContinue;
    @track cardDetails = {};
    screenName;
    isNewToBank;
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
    ecommerce = {
        product: [{}],
        purchaseID: "",
        currencycode: "ZAR"
    }
    failing;
    errorMessage;
    isOpenCardDelivery = false;
    @api availableActions = [];

    connectedCallback() {
        this.productName = this.productName.toLowerCase();
        this.adobeDataScopeApp = this.productName + ' application';
        this.adobeDataScopeApp = this.adobeDataScopeApp;
        this.adobeDataTextBack = this.adobePageName + '| ' + this.label.PBP_ZA_MYMOBizDebitCard + ' | Select button click';
        this.adobeDataTextContinue = this.adobePageName + ' | ' + this.label.PBP_MYMOBizChequeCard + ' | select button click';
        this.isLoaded = true;
        this.adobePageTag = 'business:' + 'products and services:bank with us:business bank accounts:' + this.productName + " account origination " + this.adobeDataScope + " choose product form ";
        this.application.applicationID = this.applicationId;
        this.application.applicationName = 'Application:' + this.productName + ' business account';
        this.application.applicationProduct = this.productName + ' business account';
        this.application.applicationStep = this.adobeDataScope;
        this.ecommerce.product[0].category = 'business';
        this.ecommerce.product[0].family = 'transactional';
        this.ecommerce.product[0].quantity = '1';
        this.ecommerce.product[0].productName = this.application.applicationProduct;
        this.adobeformName = "apply now " + 'business bank account ' + this.productName + ' account origination ' + this.adobeDataScope + ' ' + "card delivery form";
        this.adobePageTag = this.adobePageTag.toLowerCase();
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
            window.fireErrorEvent(this, this.errorMessage);
        });
        loadScript(this, FireAdobeEvents).then(() => {
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag);
                window.fireFormStartEvent(this, this.application);
            }
        });

        setApplicationStep({
            'applicationId': this.applicationId,
            'currentScreen': this.screenName,
            'previousScreen': this.previousScreen
        }).then(result => {
        }).catch(error => {
            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorEvent(this, this.errorMessage);
        });
    }
      handleResultChange(event) {
        this.label = event.detail;
    }

    ModalPopUp(event) {
        let name = event.target.dataset.name;
        let value = event.target.dataset.id;
        if (value == 'chequeCard') {
            this.cardDetails[name] = true;
            this.cardDetails["debitCardSelected"] = false;
        }
        setApplicationData({
            'applicationId': this.applicationId,
            'appData': JSON.stringify(this.cardDetails)
        }).then(result => {
        }).catch(error => {
            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorEvent(this, this.errorMessage);
        });
    }

    continueToNextPage(event) {
        let name = event.target.dataset.name
        window.fireButtonClickEvent(this, event);
        this.ecommerce.product[0].price = '0';
        window.cartAddEvent(this, this.ecommerce);

        if (name == 'debitCard') {
            this.cardDetails['debitCardSelected'] = true;
            this.cardDetails["chequeCardSelected"] = false;
        }
        setApplicationData({
            'applicationId': this.applicationId,
            'appData': JSON.stringify(this.cardDetails)
        }).then(result => {

            this.clearChequeCardData();
        }).catch(error => {

            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.siteerror = 'service error | ' + this.errorMessage;
            window.fireErrorEvent(this, this.siteerror);
        });
    }

    clearChequeCardData() {
        clearChequeCardInflight({
            'applicationId': this.applicationId,
        }).then(result => {
            this.continueToNextScreen();
        }).catch(error => {
            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.siteerror = 'service error | ' + this.errorMessage;
            window.fireErrorEvent(this, this.siteerror);
        });
    }

    continueToNextScreen() {
        if (this.availableActions.find(action => action === this.constants.NEXT)) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
    closePopup(event) {
        this.isLoaded = true;
        this.isOpenCardDelivery = false;
    }

    initiateGetCustomerAPI(event) {
        this.isLoaded = false;
        window.fireButtonClickEvent(this, event);
        this.ecommerce.purchaseID = '';
        this.ecommerce.product[0].sku = '4108';
        this.ecommerce.product[0].price = '198.20';
        window.cartAddEvent(this, this.ecommerce);
        let name = event.target.dataset.name
        if (name == 'chequeCard') {
            this.cardDetails['chequeCardSelected'] = true;
            this.cardDetails["debitCardSelected"] = false;
        }
        setApplicationData({
            'applicationId': this.applicationId,
            'appData': JSON.stringify(this.cardDetails)
        }).then(result => {
            this.callGetCustomerAPI();
        }).catch(error => {
            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.siteerror = 'service error | ' + this.errorMessage;
            window.fireErrorEvent(this, this.siteerror);
        });
    }

    createLead(leadReason) {
        createExternalLead({
            applicationId: this.applicationId,
            leadReason: leadReason
        }).then((result) => {
            this.isLoading = false;
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'PreApplication_Automatic_Lead__c'
                }
            });
        }).catch((error) => {
            this.isLoading = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
            window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
        });
    }

    callGetCustomerAPI() {
        getCustomer({
            'applicationID': this.applicationId
        }).then(response => {
            if (response.customer['customerRole']) {
                var result = response.customer['customerRole'].find(item => item.role === 'BUP014');
                if (result != undefined) {
                    if (result.roleX === 'CUSTOMER') {
                        let currentDate = new Date().toJSON().slice(0, 10);
                        let months = this.getMonthDifference(new Date(result.startDate), new Date(currentDate));
                        if (months < 6) {
                            this.screenName = 'Card delivery New';
                            this.isOpenCardDelivery = true;
                            this.isLoaded = true;
                            window.fireFormStart(this, this.adobeformName);
                        } else {
                            this.screenName = 'Card delivery';
                            this.isOpenCardDelivery = true;
                            this.isLoaded = true;
                            window.fireFormStart(this, this.adobeformName);
                        }
                    } else {
                        this.screenName = 'Card delivery New';
                        this.isOpenCardDelivery = true;
                        this.isLoaded = true;
                        window.fireFormStart(this, this.adobeformName);
                    }
                }
                else {
                    this.screenName = 'Card delivery New';
                    this.isOpenCardDelivery = true;
                    this.isLoaded = true;
                    window.fireFormStart(this, this.adobeformName);
                }
            }
            else {
                this.screenName = 'Card delivery New';
                this.isOpenCardDelivery = true;
                this.isLoaded = true;
                window.fireFormStart(this, this.adobeformName);
            }
        }).catch(error => {
            this.failing = true;
            if (this.retryValue === RETRY_NUMBER) {
                this.createLead('GetCustomer API failed');
            }
            this.technicalerror = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.isLoaded = true;
            this.siteerror = 'service error | ' + this.errorMessage;
            window.fireErrorEvent(this, this.siteerror);
        });
    }


    retryInitiateAPI(event) {
        this.technicalerror = false;
        this.isLoaded = false;
        incrementRetryApplication({
            'applicationId': this.applicationId
        }).then(response => {
            this.retryValue = parseInt(response);
            if (this.retryValue <= RETRY_NUMBER) {
                this.callGetCustomerAPI();
            }
            else {
                this[NavigationMixin.Navigate]({
                    "type": "comm__namedPage",
                    attributes: {
                        name: 'retryExceeded__c'
                    }
                });
            }
        }).catch(error => {
            this.isLoaded = true;
        });
    }

    backToPreviousPage(event) {
        goBacktoPreviousStep({
            'applicationId': this.applicationId
        }).then(result => {
            eval("$A.get('e.force:refreshView').fire();");

        }).catch(error => {

            this.failing = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.siteerror = 'service error | ' + this.errorMessage;
            window.fireErrorCodeEvent(this, this.siteerror);
        });
        window.fireButtonClickEvent(this, event);

    }



    getMonthDifference(startDate, currentDate) {
        return currentDate.getMonth() - startDate.getMonth() +
            (12 * (currentDate.getFullYear() - startDate.getFullYear()))
    }
}