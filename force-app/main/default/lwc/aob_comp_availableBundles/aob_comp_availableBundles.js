import { LightningElement, track, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { loadScript } from 'lightning/platformResourceLoader';
import { getErrorMessage } from 'c/aob_comp_utils';
import createItems from '@salesforce/apex/AOB_CTRL_FormCreator.createApplicationLineItems';
import setApplicationStep from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationStep';
import goBacktoPreviousStep from '@salesforce/apex/AOB_CTRL_FormCreator.goBacktoPreviousStep';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import setApplicationData from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationData';
import loadInflightData from '@salesforce/apex/AOB_CTRL_FormCreator.setExistingData';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';

export default class Aob_comp_availableBundles extends LightningElement {
    @api imageLink = THEME_OVERRIDES + "/assets/images/pocketBiz.png";
    @api imageLink2 = THEME_OVERRIDES + "/assets/images/snapScan.png";
    @api imageLink3 = THEME_OVERRIDES + '/assets/images/picture.jpg';
    deflistofdata;
    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }
    @track bundleTitle = 'SnapScan';
    @track bundle2ListItems = [' Make and accept contactless mobile payments in store or online', 'Let Standard Bank create your account on behalf of you', 'Generate unlimited number of SnapCodes', 'Option to add SnapCodes to invoices, emails and SMS'];
    @track bundle2ListPrices = [{ 'price': 'Dynamic', 'currency': 'R', 'oldPrice': '', 'subTitle': 'Transactions fee' },
    { 'price': 'Zero', 'currency': 'R', 'oldPrice': '', 'subTitle': 'Once Off sign up fee' }];
    //SFP-8743
    @track bundleTitle3 = 'Business MarketLink';
    @track bundle3ListItems = ['Free savings account linked to your MyMoBiz or MyMoBiz Plus account', 'Unlimited deposits and withdrawals', 'Interest rate is based on account balance', 'Interest is calculated daily and paid monthly', 'Pay-as-you-transact fees applies'];
    @track bundle3ListPrices = [{ 'price': 'Zero', 'currency': 'R', 'oldcurrency': '', 'oldPrice': '', 'subTitle': 'Monthly fee' },
    { 'price': 'Zero', 'currency': 'R', 'oldcurrency': 'R', 'oldPrice': '1000', 'subTitle': 'Once Off sign up fee' }];
    @track bundle3ListPercents = [{ 'percent': '6.50', 'subTitle': 'Annual interest of up to' }];
    @track bundleTitlep = 'PocketBiz';
    @track bundlePListItems = ['A secure card payment solution', 'Free delivery & installation', 'Secure payments', 'Access to free merchant portal', 'Sell airtime and pre-paid electricity, cashback and instant money redemption'];
    @track bundlePListPrices = [{ 'price': 'Zero', 'currency': 'R', 'oldcurrency': 'R', 'oldPrice': '169', 'subTitle': 'Monthly fee per device' },
    { 'price': 'Zero', 'currency': 'R', 'oldcurrency': 'R', 'oldPrice': '590', 'subTitle': 'Once Off sign up fee' }];
    @track bundlePListPercents = [{ 'percent': '2.75', 'subTitle': 'Transaction fee (EXCL VAT)' }];
    @track changeButton = false;
    @track checkCond = 0;
    isLoaded;
    //Adobe Tagging
    isEventFired;
    @api adobePageName;
    @api adobeDataScope;
    @api productCategory;
    adobeformName;
    siteErrorCode;
    adobePageTag = 'apply now business bank account mymobiz plus account origination step 13 available bundles form';
    //Attributes
    @api applicationId;
    @api screenName;
    @api previousScreen;
    @api nextScreen;
    @api productName;
    //Attributes for error handling
    failing;
    errorMessage;
    resultcheck = false;
    @api availableActions = [];
    @track selectedBundles = {};
    adobeDataTextBack;
    adobeDataTextContinue;
    adobeDataTextSkip;
    application = {
        applicationProduct: this.adobeDataScope,
        applicationMethod: "Online",
        applicationID: "",
        applicationName: "",
        applicationStep: "",
        applicationStart: true,
        applicationComplete: false
    }



    /**
     * @description connectedcallback to set inital config and update current/previous screen on application
     */

    connectedCallback() {
        this.adobeDataScopeApp = this.productName + ' application ';
        this.adobeDataScopeApp = this.adobeDataScopeApp
        this.adobeDataTextBack = this.adobePageName + ' | back button click';
        this.adobeDataTextContinue = this.adobePageName + ' | continue button click';
        this.adobeDataTextSkip = this.adobePageName + ' | skip button click';
        this.isLoaded = true;
        this.adobePageTag = 'business:' + 'products and services:bank with us:business bank accounts: ' + this.productName + " account origination  " + this.adobeDataScope + " " + this.adobePageName + " form";
        this.application.applicationID = this.applicationId;
        this.application.applicationName = 'Applcation : ' + this.productName;
        this.application.applicationProduct = this.productName + ' business account';
        this.application.applicationStep = this.adobeDataScope;
        this.adobeformName = "apply now " + this.productName + " business account " + this.screenName + "  form";
        this.adobePageTag = this.adobePageTag.toLowerCase();
        loadScript(this, FireAdobeEvents).then(() => { //Adobe tagging start
            if (!this.isEventFired) {
                this.isEventFired = true;
                //application start event fire
                window.fireScreenLoadEvent(this, this.adobePageTag);

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

                window.fireErrorEvent(this, this.errorMessage);
            });
        this.prepopulateExistingData();
    }

    /**
     * @description handles to fetch inflight data of the application based on current screen
     */
    prepopulateExistingData() {
        loadInflightData({
            'appId': this.applicationId,
            'screenName': this.screenName
        })
            .then(result => {
                if (result) {
                    this.selectedBundles = JSON.parse(result);
                    this.setButtonName();
                }
            }).catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.siteErrorCode='service error | '+this.errorMessage;
                window.fireErrorEvent(this, this.siteErrorCode);
            });
    }

    /**
     * @description method to move to previous screen
     */
    backToPreviousPage(event) {
        window.fireButtonClickEvent(this, event);
        window.fireScreenLoadEvent(this, this.adobePageTag);
        goBacktoPreviousStep({
            'applicationId': this.applicationId
        }).then(result => {
            window.location.reload();

        })
            .catch(error => {
                this.failing = true;
                this.errorMessage = getErrorMessage.call(this, error);
                 this.siteErrorCode='service error | '+this.errorMessage;
                window.fireErrorEvent(this, this.siteErrorCode);

            });
    }

    /**
    * @description method to move to next screen
    */
    continueToNextPage(event) {
        window.fireButtonClickEvent(this, event);
        //in select bundle if every product is false then then call the formdetails1 else call the selectBundle
        createItems({
            'applicationId': this.applicationId,
            'items': JSON.stringify(this.selectedBundles)
        }).then(result => {
            setApplicationData({
                'applicationId': this.applicationId,
                'appData': JSON.stringify(this.selectedBundles)
            }).then(result => {
                // check if NEXT is allowed on this screen
                if (this.availableActions.find(action => action === this.constants.NEXT)) {
                    // navigate to the next screen
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);

                }
            }).catch(error => {
                this.failing = true;
            });
        })
            .catch(error => {
                this.failing = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.siteErrorCode='service error | '+this.errorMessage;
                window.fireErrorEvent(this, this.siteErrorCode);
            });
    }

    /**
    * @description method to handle click event from child
    */
    handleClick(event) {
        var selectedItem = event.detail;
        var name = selectedItem.bundlename;
        var value = selectedItem.bundlevalue;
        this.selectedBundles[name] = value;
        this.setButtonName();

    }

    setButtonName() {
        var selectedKeys = Object.keys(this.selectedBundles);
        for (const item of selectedKeys) {
            this.changeButton = false;
            if (this.selectedBundles[item] == true) {
                this.changeButton = true;
                break;
            }
        }
    }

}