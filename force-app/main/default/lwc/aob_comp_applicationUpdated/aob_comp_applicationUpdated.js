import { LightningElement, api, wire } from 'lwc';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import fetchInflightData from '@salesforce/apex/AOB_CTRL_FormCreator.fetchApplicationInflightData';
import fetchEmailAddress from '@salesforce/apex/AOB_CTRL_FormCreator.fetchEmailAddressInflightData';
import avaialableBundlesData from '@salesforce/apex/AOB_CTRL_FormCreator.selectedAvaialbleBundles';
import { NavigationMixin } from 'lightning/navigation';
import updateApplicationStatus from '@salesforce/apex/AOB_CTRL_FormCreator.updateApplicationStatus';
import mainProductData from '@salesforce/apex/AOB_CTRL_FormCreator.getMainLineItem';
import productsData from '@salesforce/resourceUrl/PBP_ZA_ProductData';
import { loadScript } from 'lightning/platformResourceLoader';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import getApplicantDataForAdobe from '@salesforce/apex/AOB_CTRL_FormCreator.getApplicantDataForAdobe';
import getMymobizManagementSetting from '@salesforce/apex/AOB_CTRL_BackToBCBPlatform.getMymobizManagementSetting';

const CHANNEL_NAME_KEY = "channel";
const CHANNEL_NAME_VALUE_MALL = "mall";

export default class Aob_comp_applicationUpdated extends NavigationMixin(LightningElement) {
    @api teams = ["Self Assisted"];
    label = {};
    @api imageLink = THEME_OVERRIDES + "/assets/images/picture.jpg";
    @api imageLink1 = THEME_OVERRIDES + "/assets/images/picture1.png";
    @api imageLink2 = THEME_OVERRIDES + "/assets/images/pocketBiz.png";
    @api imageLink3 = THEME_OVERRIDES + "/assets/images/snapScan.png";

    @api debitCard = THEME_OVERRIDES + '/assets/images/gold-debit-mobile.png';
    @api chequeCard = THEME_OVERRIDES + '/assets/images/gold-credit-mobile.png';

    mainProductNumber = '4648'; //MyMoBiz by default
    mainProductPrOption = 'ZMMB'; //MyMoBiz account pricing option by default
    @api mainProductTitle = 'MyMoBiz Business Account';

    @api selectedCard;
    @api screenName;
    @api applicationId;
    @api previousScreen;
    @api nextScreen;
    @api selectedCardImg;
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    @api productName;
    adobeDataScopeApp;
    adobeDataTextBack;
    adobeDataTextContinue;
    totalPricePck='Zero';
    adobeformName;

    application = {
        applicationProduct: " ",
        applicationMethod: "Online",
        applicationID: "",
        applicationName: "",
        applicationStep: "",
        applicationStart: false,
        applicationComplete: true
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
    emailAddressValue;

    isBusinessMarketLink;
    isPocketBiz;
    isSnapScan;
    isLoaded;
    @api mymobizBusinessAcc = [{
        'price': '',
        'currency': 'R',
        'subTitle': 'MONTHLY FEE'
    }];
    @api businessMarketLink = [{
        'price': '6.25%',
        'subTitle': 'ANNUAL INTEREST OF UP TO'
    }];
    @api pocketbiz = [{
        'price': '138',
        'currency': 'R',
        'subTitle': 'Total Monthlly fee'
    }];
    @api snapscan = [{
        'price': 'Dynamic',
        'subTitle': 'TRANSACTIONS FEE'
    }];

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
            window.fireErrorCodeEvent(this, this.errorMessage);
        });
        this.productName = this.productName.toLowerCase();
        this.adobeDataScopeApp = this.productName + ' application';
        this.adobeDataTextContinue = this.adobePageName + '| Back to Browsing button click';
        this.isLoaded = true;
        this.adobePageTag = 'business:' + 'products and services:bank with us:business bank accounts: ' + this.productName + " account origination  " + this.adobeDataScope + " application complete";
        this.application.applicationID = this.applicationId;
        this.application.applicationName = 'Application: ' + this.productName + ' business account';
        this.application.applicationProduct = this.productName + ' business account';
        this.application.applicationStep = this.adobeDataScope;
        this.ecommerce.product[0].category = 'business';
        this.ecommerce.product[0].family = 'transactional';
        this.ecommerce.product[0].quantity = '1';
        this.ecommerce.product[0].sku = '4648';
        this.ecommerce.purchaseID = this.applicationId;
         if(this.productName == 'mymobiz plus'){
            this.ecommerce.product[0].price = '155';
         }else{
           this.ecommerce.product[0].price = '7';  
         }
     
        this.ecommerce.product[0].productName = this.application.applicationProduct;
        this.ecommerce.product[0].revenueType = 'final';
        loadScript(this, FireAdobeEvents).then(() => {
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag);
                window.fireApplicationCompleteEvent(this, this.application);
                window.purchase(this, this.ecommerce);

            }
        });
        updateApplicationStatus({
            'appId': this.applicationId,
            'screenName': this.screenName,
            'previousScreen': this.previousScreen
        }).then(result => {
            this.failing = false;
        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            window.fireErrorCodeEvent(this, this.errorMessage);
        });

        fetchInflightData({ 'appliId': this.applicationId }).then(result => {
            this.isLoaded = true;
            var cardSelectionData = JSON.parse(result)
            if (cardSelectionData.debitCardSelected == true) {
                this.selectedCardImg = THEME_OVERRIDES + '/assets/images/debitCardWithBackground.png';
            } else {
                this.selectedCardImg = THEME_OVERRIDES + '/assets/images/picture.png';
            }
        });
        this.fetchEmailAddress();
        this.availableBundlesData();
        this.getMainProductInfo();
    }
        handleResultChange(event) {
        this.label = event.detail;
    }
    availableBundlesData() {
        avaialableBundlesData({ 'appliId': this.applicationId }).then(eachBundle => {
            var totalRecs = JSON.parse(eachBundle);
            this.isBusinessMarketLink = totalRecs["4488"];
            this.isPocketBiz = totalRecs.ZPOB;
            this.isSnapScan = totalRecs.ZPSS;
        });
    }
    backToPreviousPage(event) {
        window.fireButtonClickEvent(this, event);
        let channel = sessionStorage.getItem(CHANNEL_NAME_KEY);
        if(channel && channel == CHANNEL_NAME_VALUE_MALL) {
            this.navigateBackToBCBPlatform(channel);
        } else {
            window.open(this.label.PBP_ZA_StandardBankUrl + "/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts", "_self");
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

    fetchEmailAddress() {
        fetchEmailAddress({ 'appliId': this.applicationId }).then(result => {
            var companyDetail = JSON.parse(result);
            if (companyDetail['EMAIL ADDRESS'] != null) {
                this.emailAddressValue = companyDetail['EMAIL ADDRESS'];
            }
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
        });
    }

    updateMainProductList() {
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

        this.mymobizBusinessAcc[0].price = price;
        this.mainProductTitle = prodName;

    }

}