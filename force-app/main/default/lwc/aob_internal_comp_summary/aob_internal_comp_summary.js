/**
 * @description       : Displays a summary of products selected.
 * @author            : Sibonelo Ngcobo
 * @last modified on  : 07-20-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-20-2023   Sibonelo Ngcobo   SFP-25089
**/
import {LightningElement,api,track,wire} from 'lwc';
import AOB_Summary_title from '@salesforce/label/c.AOB_ProductsSummary_Title';
import AOB_YesRemoveIt from '@salesforce/label/c.AOB_ZA_YesRemoveit';
import AOB_Summary_subtitle from '@salesforce/label/c.AOB_ProductsSummary_Subtitle';
import availableBundlesData from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.selectedAvailableBundles';
import pocketbizDetails from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.fetchPocketBizDetails';
import mainProductData from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.getMainLineItem';
import removeSummaryProduct from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.removeSummaryProduct';
import {
    getErrorMessage
} from 'c/aob_comp_utils';
import setApplicationStep from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.setApplicationStep';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import productsData from '@salesforce/resourceUrl/PBP_ZA_ProductData';
import {
    loadScript
} from 'lightning/platformResourceLoader';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import PBP_ZA_ProductScreen_Banner_Currency from '@salesforce/label/c.PBP_ZA_ProductScreen_Banner_Currency';
import PBP_ZA_StandardBankUrl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
import AOB_ZA_Currency from '@salesforce/label/c.AOB_ZA_Currency';
import AOB_ZA_viewMymobiz from '@salesforce/label/c.AOB_ZA_View';
import AOB_ZA_viewMarketLink from '@salesforce/label/c.AOB_ZA_ViewMarketLink';
import AOB_ZA_viewPocketBiz from '@salesforce/label/c.AOB_ZA_ViewPocketBiz';
import AOB_ZA_viewSnapscan from '@salesforce/label/c.AOB_ZA_ViewSnapscan';
import AOB_Close from '@salesforce/label/c.AOB_Close';
import { NavigationMixin } from "lightning/navigation";
import AOB_ZA_Removeproduct from '@salesforce/label/c.AOB_ZA_Removeproduct';
import AOB_ZA_Areyou from '@salesforce/label/c.AOB_ZA_Areyou';
import AOB_ZA_NOKEEP from '@salesforce/label/c.AOB_ZA_NOKEEP';
import completeApplication from '@salesforce/apex/AOB_CTRL_InternalCompleteApplication.completeApplicationCallout';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import callContractApi from '@salesforce/apex/AOB_Internal_SRV_CreateContract.callStaffAssistContractAPI';
import updateDeletedBundles from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updateDeletedBundles';
//LMS imports
import { publish, MessageContext } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/progressMessageChannel__c';
import BackmessageChannel from '@salesforce/messageChannel/previousScreenMessageChannel__c';
import setDigitalApi from '@salesforce/apex/AOB_Internal_SRV_SetDigital.callStaffAssistSetDigitalAPI';

export default class Aob_internal_comp_summary extends NavigationMixin(LightningElement) {
    label = {
        PBP_ZA_StandardBankUrl,
        PBP_ZA_ProductScreen_Banner_Currency,
        AOB_ZA_Currency,
        AOB_ZA_viewMarketLink,
        AOB_ZA_viewMymobiz,
        AOB_ZA_viewSnapscan,
        AOB_ZA_viewPocketBiz,
        AOB_Close,
        AOB_ZA_Removeproduct,
        AOB_ZA_Areyou,
        AOB_ZA_NOKEEP,
        AOB_Summary_title,
        AOB_Summary_subtitle,
        AOB_YesRemoveIt
    };
    AOB_ZA_viewMymobizURL = PBP_ZA_StandardBankUrl + '/static_file/South%20Africa/PDF/Business%20Ts%20and%20Cs/Business_Transaction_Accounts_T&Cs.pdf';
    AOB_ZA_viewMarketLinkURL = PBP_ZA_StandardBankUrl + '/static_file/South%20Africa/PDF/Terms%20and%20Conditions/Business/Business_Marketlink_terms_and_conditions.pdf';
    AOB_ZA_viewPocketBizURL = PBP_ZA_StandardBankUrl + '/static_file/South%20Africa/PDF/Terms%20and%20Conditions/Merchant%20Services%20General%20terms%20and%20conditions.pdf';
    AOB_ZA_viewSnapscanURL = PBP_ZA_StandardBankUrl + '/static_file/South%20Africa/PDF/Terms%20and%20Conditions/Snapscan%20terms%20and%20conditions.pdf';

    @track customFormModal = false;
    @track customFormIDVServiceUnavailable = false;
    @api screenName;
    @api previousScreen;
    @api nextScreen;
    @api applicationId;
    isModalPopUpOpen = false;
    @api availableActions = [];
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    adobeDataScopeApp;
    adobeDataTextBack;
    adobeDataTextContinue;
    adobeDataTextCancelbusiness;
    adobeDataTextCancelpocketbiz;
    adobeDataTextCancelsnapscan;
    noOfPocketbizDevices;
    technicalerror;
    totalPricePck;
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

    mainProductNumber = '4648'; 
    mainProductPrOption = 'ZMMB'; 

    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }
    next1;
    showSummary=true;
    failing = false;
    isLoaded = true;
    isfailing=false;

    @wire(MessageContext)
    MessageContext;

    handleClicks() {
        var progressMessage={currentScreen:this.nextScreen};
        publish(this.MessageContext,messageChannel,progressMessage);
        if(this.screenName==='Summary'){
            this.customShowModalPopup();
        }

        const message= new CustomEvent('buttonclick',
        {detail:this.next1
        });
        this.dispatchEvent(message);
    }
    closeModal() {
        this.isModalPopUpOpen = false;
        this.itemsToDelete.push(this.closedProduct);
        if (this.closedProduct == '4488') this.isBusinessMarketLink = false;
        if (this.closedProduct == 'ZPOB') this.isPocketBiz = false;
        if (this.closedProduct == 'ZPSS') this.isSnapScan = false;
        this.updateLineItems(this.itemsToDelete);
        this.updateBundlesInflightData();
    }
    closeModal1() {
        this.isModalPopUpOpen = false;
    }
    closedModalPopupbusinessmarketlink(event) {
        this.closedProduct = '4488';
        window.fireButtonClickEvent(this, event);
        this.isModalPopUpOpen = true;
    }
    closedModalPopuppocketbiz(event) {
        this.closedProduct = 'ZPOB';
        window.fireButtonClickEvent(this, event);
        this.isModalPopUpOpen = true;
    }
    closedModalPopupsnapscan(event) {
        this.closedProduct = 'ZPSS';
        window.fireButtonClickEvent(this, event);
        this.isModalPopUpOpen = true;
    }

    handleClosepopup() {
        this.customFormModal = false;
    }

    customShowModalPopup(event) {
        this.isLoaded = false;
        this.contractApi();
        window.fireButtonClickEvent(this, event);

    }
    updateBundlesInflightData(){
        if(this.closedProduct){
        updateDeletedBundles({applicationId:this.applicationId,itemToDelete:this.closedProduct})
        .then(result=>{ 
        })
        .catch(errors=>{
        });
    }
    }
    updateLineItems(itemsToDelete) {
        if (itemsToDelete) {
            removeSummaryProduct({
                'appId': this.applicationId,
                'prodToDelete': this.itemsToDelete
            }).then(result => {
            }).catch(errors => {
                this.failing = true;
                this.isLoaded = true;
            });
        }
    }

    customHideModalPopup() {
        this.customFormModal = false;
    }

    customShowIDVServiceUnavailable() {
        this.customFormIDVServiceUnavailable = true;
    }

    customHideIDVServiceUnavailable() {
        this.customFormIDVServiceUnavailable = false;
    }


    listArrow = THEME_OVERRIDES + '/assets/images/list-arrow.svg';
    @api imageLink = THEME_OVERRIDES + "/assets/images/picture.png";
    @api imageLink1 = THEME_OVERRIDES + "/assets/images/picture1.png";
    @api imageLink2 = THEME_OVERRIDES + "/assets/images/pocketBiz.png";
    @api imageLink3 = THEME_OVERRIDES + "/assets/images/snapScan.png";
    @api itemsList = ['A secure card payment solution', 'Free delivery & installation', 'Secure payments', 'Access to free merchant portal', 'Sell airtime and pre-paid electricity, cashback and instant money redemption'];
    @api title = 'MyMoBiz Business Account';
    @api title1 = 'Business MarketLink';
    @api title2 = 'PocketBiz';
    @api title3 = 'SnapScan';

    @api priceList = [{
        'price': '5',
        'currency': 'R',
        'oldPrice': '40',
        'subTitle': 'MONTHLY FEE'
    },
    {
        'price': '198.20',
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
        'price': '4.85%',
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
        'price': '2.60%',
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

    

    connectedCallback() {
        this.callSetDigitalApi();
        this.adobeDataScopeApp = this.adobeDataScope + ' application';
        this.adobeDataScopeApp = this.adobeDataScopeApp.toLowerCase();
        this.adobeDataTextBack = this.adobePageName + ' | Back button click';
        this.adobeDataTextContinue = this.adobePageName + '|  Confirm button click';
        this.adobeDataTextCancelbusiness = this.adobePageName + '| Business marketLink' + '| remove button click';
        this.adobeDataTextCancelpocketbiz = this.adobePageName + '| PocketBiz' + '| remove button click';
        this.adobeDataTextCancelsnapscan = this.adobePageName + '| Snapscan' + '| remove button click';
        this.adobeDatalinkmymobiz = this.adobePageName + '| mymobiz' + '| View mymobiz T&cs link Click';
        this.adobeDatalinkmarket = this.adobePageName + '| marketlink' + '| View marketlink T&cs link Click';
        this.adobeDatalinkpocketbiz = this.adobePageName + '| pocketbiz' + '| View pocketbiz T&cs link Click';
        this.adobeDatalinkssnapscan = this.adobePageName + '| snapscan' + '| View snapscan T&cs link Click';
        this.isLoaded = false;
        this.adobePageTag = 'business application:' + this.adobeDataScopeApp + ':' + this.adobePageName;
        loadScript(this, FireAdobeEvents).then(() => { 
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
            this.failing = false;
        })
            .catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                window.fireErrorCodeEvent(this, this.errorMessage);

            });
        this.availableBundlesData();

        this.getMainProductInfo();
    }

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
    fetchPocketBizDetailsDisplay() {
        pocketbizDetails({
            'applicationId': this.applicationId
        }).then(res => {
            if (res) {
                var pockebizres = JSON.parse(res);
                this.noOfPocketbizDevices = pockebizres.numberOfDevices;
                this.totalPricePck = this.noOfPocketbizDevices * 69;
                this.isLoaded = true;
            }

        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorCodeEvent(this, this.errorMessage);

        });
    }

    backToPreviousPage(event) {
        this.updateProductScreen();
        this.handleBackProgress();  
    }
    handleBackProgress(){
        var progressMessage={currentScreen:this.previousScreen};
        publish(this.MessageContext,messageChannel,progressMessage);
    }
    handleBackClick() {
        var previousScreenMessage={previousScreen:this.previousScreen};
        publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
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
            window.fireErrorCodeEvent(this, this.errorMessage);

        });
    }

    updateMainProductList() {
        let request = new XMLHttpRequest();
        request.open("GET", productsData + '/' + this.mainProductNumber + '.json', false);
        request.send(null);

        let jsonProducts = JSON.parse(request.responseText);

        let price = '';
        let prodName = '';
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

    updateProductScreen(){  
        if(this.isSnapScan==true && this.isPocketBiz==true){
            this.previousScreen='bothProducts';
            var previousScreenMessage={previousScreen:this.previousScreen};
            publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
        }
        else if(!this.isSnapScan && !this.isPocketBiz){
            this.previousScreen='Available Bundles';
            var previousScreenMessage={previousScreen:this.previousScreen};
            publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
        }
        else if(this.isSnapScan){
            this.previousScreen='SnapScan';
            var previousScreenMessage={previousScreen:this.previousScreen};
            publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
        }
        else if(this.isPocketBiz){
            this.previousScreen='PocketBiz';
            var previousScreenMessage={previousScreen:this.previousScreen};
            publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
        }
    }
    completeAppCallout() {
        completeApplication({applicationId:this.applicationId})
            .then(results => {
                this.isLoaded=true;
                let result = JSON.parse(JSON.stringify(results));
                if (result) {
                    if (result == 'Successful') {
                        this.showToast(result,'success');
                    } else {
                        this.showToast(result,'error');
                        setTimeout(()=> {
                            //cancel
                        }
                             ,10000);
                    }
                }
            })
            .catch(errors => {
                this.isLoaded=true;
                const message = 'Some unexpected error,Please contact your administrator';
                let error = JSON.parse(JSON.stringify(errors));
                this.showToast(message,'error');
            })
    }
    contractApi(){
        callContractApi({applicationId:this.applicationId})
        .then(res => {
            this.isLoaded=true;
            this.showSummary=false;
            this.customFormModal = true;
        })
        .catch(error=>{
            const message = 'Some unexpected error,Please contact your administrator';
            this.showToast(message,'error');
        });
    }
    callSetDigitalApi(){
        setDigitalApi({applicationId:this.applicationId})
        .then(result=>{
            const message='Set Digital Offer Created';
            const errorMessage='Set Digital offer failed, Contact your administrator';
            if(JSON.stringify(result) == '200'){
                this.isLoaded=true;
                this.showToast(message,'success');
            }else{
                this.isLoaded=true;
                this.isfailing=true;
                this.showToast(errorMessage,'error');
            }
        })
        .catch(error=>{
            this.isLoaded=true;
            this.showToast(JSON.stringify(error),'error');
        });
    }
    showToast(message,variant) {
        const event = new ShowToastEvent({
            label:'',
            variant:variant,
            message:message,
        });
        this.dispatchEvent(event);
    }
}