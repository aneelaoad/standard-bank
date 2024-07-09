import {
    LightningElement,
    api,
    track
} from 'lwc';

import goBacktoPreviousStep from '@salesforce/apex/AOB_CTRL_FormCreator.goBacktoPreviousStep';
import avaialableBundlesData from '@salesforce/apex/AOB_CTRL_FormCreator.selectedAvaialbleBundles';
import pocketbizDetails from '@salesforce/apex/AOB_CTRL_FormCreator.fetchPocketBizDetails';
import mainProductData from '@salesforce/apex/AOB_CTRL_FormCreator.getMainLineItem';
import removeSummaryProduct from '@salesforce/apex/AOB_CTRL_FormCreator.removeSummaryProduct';
import {
    getErrorMessage
} from 'c/aob_comp_utils';
import setApplicationStep from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationStep';
import createExternalLead from "@salesforce/apex/AOB_API_BusinessLead_CTRL.callBusinessLead";

import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import productsData from '@salesforce/resourceUrl/PBP_ZA_ProductData';
import {
    FlowNavigationNextEvent
} from 'lightning/flowSupport';
import Call_Created_Contract from '@salesforce/apex/AOB_SRV_CreateContract.callContractAPI';
import Cal_Set_Digital_OfferId from '@salesforce/apex/AOB_SRV_SetDigital.callSetDigitalAPI';
import incrementRetryApplication from '@salesforce/apex/AOB_CTRL_FindApplications.incrementRetryApplication';
import {
    loadScript
} from 'lightning/platformResourceLoader';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import { NavigationMixin } from "lightning/navigation";

const RETRY_NUMBER = 1;
import { createLogger } from 'sbgplatform/rflibLogger';
const logger = createLogger('Aob_comp_summary');
export default class Aob_comp_summary extends NavigationMixin(LightningElement) {
    @api teams = ["Self Assisted"];
    label = {};
    AOB_ZA_viewMymobizURL;
    AOB_ZA_viewMarketLinkURL;
    AOB_ZA_viewPocketBizURL;
    AOB_ZA_viewSnapscanURL;

    @track customFormModal = false;
    @api screenName;
    @api previousScreen;
    @api nextScreen;
    retryValue;
    @api applicationId;
    isModalPopUpOpen = false;
    productToclose;
    @api availableActions = [];
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    @api productName;
    siteErrorCode;
    adobeformName;
    adobeDataScopeApp;
    adobeDataTextBack;
    adobeDataTextContinue;
    adobeDataTextCancelbusiness;
    adobeDataTextCancelpocketbiz;
    adobeDataTextCancelsnapscan;
    noOfPocketbizDevices;
    technicalerror;
    totalPricePck = 'Zero';
    closedProduct;
    application = {
        applicationProduct: "Customer on boarding",
        applicationMethod: "Online",
        applicationID: "",
        applicationName: "",
        applicationStep: "",
        applicationStart: true,
        applicationComplete: false
    }
    itemsToDelete = [];
    isBusinessMarketLink;
    isPocketBiz;
    isSnapScan;
    isDigitalOfferSuccess = false;
    acceptedProducts = [];
    mainProductNumber = '4648'; //MyMoBiz by default
    mainProductPrOption = 'ZMMB'; //MyMoBiz account pricing option by default

    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }

    listArrow = THEME_OVERRIDES + '/assets/images/list-arrow.svg';
    @api imageLink;
    @api imageLink1 = THEME_OVERRIDES + "/assets/images/picture.jpg";
    @api imageLink2 = THEME_OVERRIDES + "/assets/images/pocketBiz.png";
    @api imageLink3 = THEME_OVERRIDES + "/assets/images/snapScan.png";
    @api itemsList = ['A secure card payment solution', 'Free delivery & installation', 'Secure payments', 'Access to free merchant portal', 'Sell airtime and pre-paid electricity, cashback and instant money redemption'];
    @api title = 'MyMoBiz Business Account';
    @api title1 = 'Business MarketLink';
    @api title2 = 'PocketBiz';
    @api title3 = 'SnapScan';

    @api priceList = [{
        'price': '',
        'currency': 'R',
        'oldPrice': '40',
        'subTitle': 'MONTHLY FEE'
    },
    {
        'price': 'Zero', //SFP-38948 Cheque Card Annual Card Fee
        'currency': 'R',
        'oldPrice': '500',
        'subTitle': 'ANNUAL CARD FEES'
    }
    ];
    @api percentList = [{
        'price': '160',
        'currency': 'R',
        'oldPrice': '40',
        'subTitle': 'CARD DELIVERY FEE'
    }];
    @api priceList1 = [{
        'price': 'Zero',
        'currency': 'R',
        'oldPrice': '40',
        'subTitle': 'MONTHLY FEE'
    }];
    @api List2 = [{
        'price': 'Zero',
        'currency': 'R',
        'oldPrice': '500',
        'subTitle': 'OPENING DEPOSIT'
    }];
    @api percentList1 = [{
        'price': '6.50%',
        'oldPrice': '40',
        'subTitle': 'ANNUAL INTEREST OF UP TO'
    }];
    @api priceList2 = [{
        'price': '2',
        'oldPrice': '40',
        'subTitle': 'QTY'
    }];
    @api priceListpck = [{
        'price': '2',
        'oldPrice': '40',
        'currency': 'R',
        'subTitle': 'TOTAL MONTHLLY FEE'
    }];
    @api percentList2 = [{
        'price': '2.75%',
        'oldPrice': '40',
        'subTitle': 'TRANSACTION FEE (EXCL. VAT)'
    }];
    @api priceList3 = [{
        'price': 'Dynamic',
        'currency': 'R',
        'oldPrice': '40',
        'subTitle': 'TRANSACTIONS FEE'
    }];
    @api percentList3 = [{
        'price': 'Zero',
        'currency': 'R',
        'oldPrice': '40',
        'subTitle': 'ONCE-OFF SIGN-UP FEE'
    }];

    failing = false;
    isLoaded = true;


    connectedCallback() {
        this.productName = this.productName.toLowerCase();
        this.adobeDataScopeApp = this.productName + ' application';
        this.adobeDataScopeApp = this.adobeDataScopeApp.toLowerCase();
        this.adobeDataTextBack = this.adobePageName + ' | Back button click';
        this.adobeDataTextContinue = this.adobePageName + '|  Confirm button click';
        this.application.applicationID = this.applicationId;
        this.application.applicationName = 'Application : ' + this.productName + ' business account';
        this.application.applicationProduct = this.productName + ' business account';
        this.application.applicationStep = this.adobeDataScope;
        this.adobeDataTextCancelbusiness = this.adobePageName + '| Business marketLink' + '| remove button click';
        this.adobeDataTextCancelpocketbiz = this.adobePageName + '| PocketBiz' + '| remove button click';
        this.adobeDataTextCancelsnapscan = this.adobePageName + '| Snapscan' + '| remove button click';
        this.adobeDatalinkmymobiz = this.adobePageName + '| mymobiz' + '| View mymobiz T&cs link Click';
        this.adobeDatalinkmarket = this.adobePageName + '| marketlink' + '| View marketlink T&cs link Click';
        this.adobeDatalinkpocketbiz = this.adobePageName + '| pocketbiz' + '| View pocketbiz T&cs link Click';
        this.adobeDatalinkssnapscan = this.adobePageName + '| snapscan' + '| View snapscan T&cs link Click';
        this.adobePageTag = 'business:' + 'products and services:bank with us:business bank accounts: ' + this.productName + " account origination  " + this.adobeDataScope + " " + this.adobePageName;
        this.adobeformName = "apply now " + this.productName + " business account " + this.screenName + "  form";
        loadScript(this, FireAdobeEvents).then(() => { //Adobe tagging start
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
            this.failing = false;
        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorEvent(this, this.errorMessage);
            logger.debug('Error in connectedCallback.setApplicationStep ', error);
        });

        this.availableBundlesData();
        this.getMainProductInfo();
    }
    handleResultChange(event) {
        this.label = event.detail;
        this.AOB_ZA_viewMymobizURL = this.label.PBP_ZA_StandardBankUrl + '/static_file/South%20Africa/PDF/Business%20Ts%20and%20Cs/Business_Transaction_Accounts_T&Cs.pdf';
        this.AOB_ZA_viewMarketLinkURL = this.label.PBP_ZA_StandardBankUrl + '/static_file/South%20Africa/PDF/Terms%20and%20Conditions/Business/Business_Marketlink_terms_and_conditions.pdf';
        this.AOB_ZA_viewPocketBizURL = this.label.PBP_ZA_StandardBankUrl + '/static_file/South%20Africa/PDF/Terms%20and%20Conditions/Merchant%20Services%20General%20terms%20and%20conditions.pdf';
        this.AOB_ZA_viewSnapscanURL = this.label.PBP_ZA_StandardBankUrl + '/static_file/South%20Africa/PDF/Terms%20and%20Conditions/Snapscan%20terms%20and%20conditions.pdf';
    }

    closeModal() {
        this.isModalPopUpOpen = false;
        this.itemsToDelete.push(this.closedProduct);
        if (this.closedProduct == '4488') this.isBusinessMarketLink = false;
        if (this.closedProduct == 'ZPOB') this.isPocketBiz = false;
        if (this.closedProduct == 'ZPSS') this.isSnapScan = false;
        this.updateLineItems();

    }
    keepPopup() {
        this.isModalPopUpOpen = false;
    }
    closeModal1() {
        this.isModalPopUpOpen = false;
    }
    closedModalPopupbusinessmarketlink(event) {
        this.productToclose = this.label.AOB_ZA_Areyou + ' Business Marketlink ' + this.label.AOB_ZA_Areyou2;
        this.closedProduct = '4488';
        window.fireButtonClickEvent(this, event);
        this.isModalPopUpOpen = true;
    }
    closedModalPopuppocketbiz(event) {
        this.productToclose = this.label.AOB_ZA_Areyou + ' Pocketbiz ' + this.label.AOB_ZA_Areyou2;
        this.closedProduct = 'ZPOB';
        window.fireButtonClickEvent(this, event);
        this.isModalPopUpOpen = true;
    }
    closedModalPopupsnapscan(event) {
        this.productToclose = this.label.AOB_ZA_Areyou + ' Snapscan ' + this.label.AOB_ZA_Areyou2;
        this.closedProduct = 'ZPSS';
        window.fireButtonClickEvent(this, event);
        this.isModalPopUpOpen = true;
    }

    handleClosepopup() {
        this.customFormModal = false;
    }
    closePopup() {
        this.isLoaded = true;
    }

    confirmProducts(event) {
        // STEP-1 : Call Contract API
        this.isLoaded = false;
        this.CallSetDigitalOfferId();
        window.fireButtonClickEvent(this, event);

    }
    updateLineItems() {
        if (this.itemsToDelete) {
            removeSummaryProduct({
                'appId': this.applicationId,
                'prodToDelete': this.itemsToDelete
            }).then(result => {
                this.itemsToDelete = [];
                this.isLoaded = true;
            }).catch(error => {
                this.failing = true;
                this.isLoaded = true;
                logger.debug('Error in updateLineItems.removeSummaryProduct ', error);
            });
        }
    }

    customHideModalPopup() {
        this.customFormModal = false;
    }

    availableBundlesData() {
        avaialableBundlesData({
            'appliId': this.applicationId
        }).then(result => {
            var totalRecs = JSON.parse(result);
            for (const key in totalRecs) {
                if (key == '4488') this.isBusinessMarketLink = totalRecs[key];
                if (key == 'ZPOB') this.isPocketBiz = totalRecs[key];
                if (key == 'ZPSS') this.isSnapScan = totalRecs[key];
                if (key == 'chequeCardSelected') {
                    if (totalRecs[key]) {
                        this.imageLink = THEME_OVERRIDES + "/assets/images/picture.png";
                    }
                }
                if (key == 'debitCardSelected') {
                    if (totalRecs[key]) {
                        this.imageLink = THEME_OVERRIDES + "/assets/images/debitCardWithBackground.png";
                        this.priceList = [{
                            'price': '---',
                            'currency': 'R',
                            'oldPrice': '40',
                            'subTitle': 'MONTHLY FEE'
                        },
                        {
                            'price': 'Zero',
                            'currency': 'R',
                            'oldPrice': '500',
                            'subTitle': 'ANNUAL CARD FEES'
                        }
                        ];
                        this.percentList = [{
                            'price': 'Zero',
                            'currency': 'R',
                            'oldPrice': '40',
                            'subTitle': 'CARD DELIVERY FEE'
                        }];
                        this.updateMainProductList();
                    }
                }
            }
            this.fetchPocketBizDetailsDisplay();
        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            logger.debug('Error in availableBundlesData.avaialableBundlesData ', error);
        });
    }
    fetchPocketBizDetailsDisplay() {
        pocketbizDetails({
            'appplicationId': this.applicationId
        }).then(res => {
            if (res) {
                var pockebizres = JSON.parse(res);
                this.noOfPocketbizDevices = pockebizres.numberOfDevices;
                this.isLoaded = true;
            }
            else {
                this.isLoaded = true;
            }

        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorEvent(this, this.errorMessage);
            logger.debug('Error in fetchPocketBizDetailsDisplay.pocketbizDetails ', error);
        });
    }

    /**
     * @description method to move to next screen
     */
    continueToNextPage(event) {
        if (this.availableActions.find(action => action === this.constants.NEXT)) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }



    }
    /**
     * @description method to move to previous screen
     */
    backToPreviousPage(event) {
        window.fireButtonClickEvent(this, event);
        goBacktoPreviousStep({
            'applicationId': this.applicationId
        }).then(result => {
            window.location.reload();

        })
            .catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                window.fireErrorEvent(this, this.errorMessage);
                logger.debug('Error in backToPreviousPage.goBacktoPreviousStep ', error);

            });
    }

    getMainProductInfo() {

        mainProductData({
            'applicationId': this.applicationId
        }).then(result => {
            this.mainProductNumber = result.AOB_ProductCode__c;
            this.mainProductPrOption = result.AOB_Pricing_Option__c;

            this.updateMainProductList();

        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorEvent(this, this.errorMessage);
            logger.debug('Error in getMainProductInfo.mainProductData ', error);

        });
    }

    updateMainProductList() {
        // read product data from json from static resource
        let request = new XMLHttpRequest();
        request.open("GET", productsData + '/' + this.mainProductNumber + '.json', false);
        request.send(null);

        let jsonProducts = JSON.parse(request.responseText);

        let price = '';
        let prodName = '';
        //Go through all products to find the one that we need to display
        for (let i = 0; i < jsonProducts.product.length; i++) {
            if (jsonProducts.product[i].id == this.mainProductNumber && jsonProducts.product[i].pricingOption == this.mainProductPrOption) {
                price = jsonProducts.product[i].price;
                prodName = jsonProducts.product[i].name;
                break;
            }
        }

        this.priceList[0].price = price;
        this.title = prodName;

    }
    mymobizterms(event) {
        window.fireButtonClickEvent(this, event);

    }
    marketlinkterms(event) {
        window.fireButtonClickEvent(this, event);
    }

    pocketbizterms(event) {
        window.fireButtonClickEvent(this, event);
    }
    snapscanterms(event) {
        window.fireButtonClickEvent(this, event);
    }

    createLead(leadReason) {
        createExternalLead({
            applicationId: this.applicationId,
            leadReason: leadReason
        }).then((result) => {
            this.isLoaded = false;
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'PreApplication_Automatic_Lead__c'
                }
            });
        }).catch((error) => {
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
            window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
            logger.debug('Error in createLead.createExternalLead ', error);
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
                if (this.isDigitalOfferSuccess) {
                    this.callCreateContractAPI();
                }
                else {
                    this.CallSetDigitalOfferId();
                }
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
            logger.debug('Error in retryInitiateAPI.incrementRetryApplication ', error);
        });
    }


    CallSetDigitalOfferId() {
        Cal_Set_Digital_OfferId({
            'applicationId': this.applicationId
        }).then(result => {
            if (result == 200) {
                this.isDigitalOfferSuccess = true;
                this.callCreateContractAPI();
            } else {
                if (this.retryValue === RETRY_NUMBER && result != 200) {
                    this.createLead('setdigital offer API failed');
                }
                else {
                    this.technicalerror = true;
                    this.siteErrorCode = 'service error | ' + result;
                    window.fireErrorEvent(this, this.siteErrorCode);
                }

            }
        }).catch(error => {
            this.isLoaded = true;
            if (this.retryValue === RETRY_NUMBER) {
                this.createLead('setdigital offer API failed');
            }
            else {
                this.technicalerror = true;
                this.siteErrorCode = 'service error | ' + error;
                window.fireErrorEvent(this, this.siteErrorCode);
            }
            logger.debug('Error in CallSetDigitalOfferId.Cal_Set_Digital_OfferId ', error);
        });
    }

    callCreateContractAPI() {
        Call_Created_Contract({
            'applicationId': this.applicationId
        }).then(result => {
            if (result == 200) {
                this.isLoaded = true;
                this.customFormModal = true;
            } else {
                if (this.retryValue === RETRY_NUMBER) {
                    this.createLead('CreateContract API failed');
                }
                else {
                    this.failing = true;
                    this.technicalerror = true;
                    this.siteErrorCode = 'service error | ' + result;
                    window.fireErrorEvent(this, this.siteErrorCode);
                }

            }
        }).catch(error => {
            this.isLoaded = true;
            if (this.retryValue === RETRY_NUMBER) {
                this.createLead('CreateContract API failed');
            }
            else {
                this.failing = true;
                this.technicalerror = true;
                this.siteErrorCode = 'service error | ' + error;
                window.fireErrorEvent(this, this.siteErrorCode);
            }
            logger.debug('Error in callCreateContractAPI.Call_Created_Contract ', error);

        });
    }
}