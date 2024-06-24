/**
 * @description       : Displays available bundles to add to an application
 * @author            : Mahlatse Tjale
 * @last modified on  : 09-13-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/
import { LightningElement, track, api,wire} from 'lwc';
import { getErrorMessage } from 'c/aob_comp_utils';
import createItems from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.createApplicationLineItems';
import setApplicationStep from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.setApplicationStep';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import loadInflightData from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.setExistingData';
import updateScreen from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updateScreen';
import { publish, MessageContext } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/progressMessageChannel__c';
import BackmessageChannel from '@salesforce/messageChannel/previousScreenMessageChannel__c';
import updatePreviousScreen from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updatePreviousScreen';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateAvailableBundles from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updateAvailableBundles';

export default class aob_internal_comp_available_bundles extends LightningElement {
    @api imageLink = THEME_OVERRIDES + "/assets/images/pocketBiz.png";
    @api imageLink2 = THEME_OVERRIDES + "/assets/images/snapScan.png";
    @api imageLink3 = THEME_OVERRIDES + '/assets/images/snapScan.png';
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
    @track bundle3ListPercents = [{ 'percent': '4.85', 'subTitle': 'Annual interest of up to' }];
    @track bundleTitlep = 'PocketBiz';
    @track bundlePListItems = ['A secure card payment solution', 'Free delivery & installation', 'Secure payments', 'Access to free merchant portal', 'Sell airtime and pre-paid electricity, cashback and instant money redemption'];
    @track bundlePListPrices = [{ 'price': '69', 'currency': 'R', 'oldcurrency': 'R', 'oldPrice': '169', 'subTitle': 'Monthly fee per device' },
    { 'price': 'Zero', 'currency': 'R', 'oldcurrency': 'R', 'oldPrice': '590', 'subTitle': 'Once Off sign up fee' }];
    @track bundlePListPercents = [{ 'percent': '2.60', 'subTitle': 'Transaction fee (EXCL VAT)' }];
    @track changeButton = false;
    @track checkCond = 0;
    isLoaded;
    //Adobe Tagging
    isEventFired;
    @api adobePageName;
    @api adobeDataScope;
    @api productCategory;
    adobePageTag = 'apply now business bank account mymobiz plus account origination step 13 available bundles form';
    //Attributes
    @api applicationId;
    @api screenName;
    @api previousScreen;
    @api nextScreen;
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
        applicationProduct: "Customer on boarding",
        applicationMethod: "Online",
        applicationID: "",
        applicationName: "",
        applicationStep: "",
        applicationStart: true,
        applicationComplete: false
    }
    hasSnapScan=false;
    hasPocketBiz=false;
    bothProducts=false;

    @wire(MessageContext)
    MessageContext;

    
    handleClicks() {
        if(this.screenName==='Available Bundles'){
            this.next1='PocketBiz';
        }

        const message= new CustomEvent('buttonclick',
        {detail:this.next1
        });
        this.dispatchEvent(message);
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


    /**
     * @description connectedcallback to set inital config and update current/previous screen on application
     */
    connectedCallback() {
        this.adobeDataScopeApp = this.adobeDataScope + ' application';
        this.adobeDataScopeApp = this.adobeDataScopeApp.toLowerCase();
        this.adobeDataTextBack = this.adobePageName + ' | back button click';
        this.adobeDataTextContinue = this.adobePageName + ' | continue button click';
        this.adobeDataTextSkip = this.adobePageName + ' | skip button click';
        this.isLoaded = true;
        this.adobePageTag = this.adobeDataScopeApp + ':' + this.adobePageName;
        this.application.applicationID = this.applicationId;
        this.application.applicationName = this.adobeDataScopeApp;
        this.adobePageTag = this.adobePageTag.toLowerCase();
        
        setApplicationStep({
            'applicationId': this.applicationId,
            'currentScreen': this.screenName,
            'previousScreen': this.previousScreen
        }).then(result => {
        })
        .catch(error => {
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
            });
    }

    /**
     * @description method to move to previous screen
     */
    backToPreviousPage(event) {
        this.handleBackClick();

        this.updatePreviousScreen();
    }

    /**
    * @description method to move to next screen
    */
    continueToNextPage(event) {
        this.createItems();
        
    }
    setApplicationData(){
        updateAvailableBundles({
            'applicationId': this.applicationId,
            'appData': JSON.stringify(this.selectedBundles)
        }).then(result => {
            this.updateProductScreen();
            this.showToast('Bundles added Successfuly','success');
        }).catch(error => {
            this.showToast('Please refresh and select again, '+JSON.stringify(error),'error');
        });
    }
    createItems(){
        createItems({
            'applicationId': this.applicationId,
            'items': JSON.stringify(this.selectedBundles)
        }).then(result => {
            this.setApplicationData();
        })
        .catch(error => {
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
    updatePreviousScreen(){
        updatePreviousScreen({
            'applicationId': this.applicationId,
            'currentScreen': this.screenName,
            'previousScreen': this.previousScreen
        }).then(result => {
        })
        .catch(error => {
        });
    }
    updateProductScreen(){
            if (this.selectedBundles.ZPSS) {
                this.hasSnapScan= this.selectedBundles.ZPSS;
            }  
            if (this.selectedBundles.ZPOB) {
                this.hasPocketBiz = this.selectedBundles.ZPOB;
            }
        
        if(this.hasSnapScan==true && this.hasPocketBiz==true){
            this.nextScreen='bothProducts'
            const message= new CustomEvent('buttonclick',
            {detail:this.nextScreen
            });
            this.dispatchEvent(message);
            this.updateScreen('PocketBiz');
        }
        if(this.hasSnapScan==false && this.hasPocketBiz==false){
            this.nextScreen='Summary'
            const message= new CustomEvent('buttonclick',
            {detail:this.nextScreen
            });
            this.dispatchEvent(message);
            this.updateScreen(this.nextScreen);
        }
        if(this.hasSnapScan && this.hasPocketBiz==false){
            this.nextScreen='SnapScan';
            
            const message= new CustomEvent('buttonclick',
            {detail:this.nextScreen
            });
            this.dispatchEvent(message);
            this.updateScreen(this.nextScreen);
        }
        if(this.hasPocketBiz && this.hasSnapScan==false){
            this.nextScreen='PocketBiz';
        const message= new CustomEvent('buttonclick',
        {detail:this.nextScreen
        });
        this.dispatchEvent(message);
        this.updateScreen(this.nextScreen);
        }
    }
    updateScreen(nextScreen){
        updateScreen({
            'applicationId': this.applicationId,
            'currentScreen': nextScreen,
            'previousScreen': this.previousScreen
        }).then(result => {
        })
        .catch(error => {
            });
    }
    showToast(message,variant) {
        const event = new ShowToastEvent({
            variant:variant,
            message:message,
        });
        this.dispatchEvent(event);
    }
}