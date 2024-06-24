import { LightningElement, api, wire } from 'lwc';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import fetchInflightData from '@salesforce/apex/AOB_CTRL_FormCreator.fetchApplicationInflightData';
import fetchEmailAddress from '@salesforce/apex/AOB_CTRL_FormCreator.fetchEmailAddressInflightData';
import avaialableBundlesData from '@salesforce/apex/AOB_CTRL_FormCreator.selectedAvaialbleBundles';
import { NavigationMixin } from 'lightning/navigation';

import mainProductData from '@salesforce/apex/AOB_CTRL_FormCreator.getMainLineItem';
import productsData from '@salesforce/resourceUrl/PBP_ZA_ProductData';
import { loadScript } from 'lightning/platformResourceLoader';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import AOB_ZA_weareRecivedAllOFYourINFO from '@salesforce/label/c.AOB_ZA_WeareRecivedAllOFYourINFO';
import AOB_ZA_mainProductTitle from '@salesforce/label/c.AOB_ZA_MainProductTitle';         
import PBP_ZA_pocketBiz from '@salesforce/label/c.PBP_ZA_PocketBiz';
import PBP_ZA_snapScan from '@salesforce/label/c.PBP_ZA_SnapScan';
import AOB_ZA_business_MarketLink from '@salesforce/label/c.AOB_ZA_Business_MarketLink';
import pocketbizDetails from '@salesforce/apex/AOB_CTRL_FormCreator.fetchPocketBizDetails';


export default class Aob_comp_applicationUpdated extends NavigationMixin(LightningElement) {

    label={
        AOB_ZA_weareRecivedAllOFYourINFO,
        AOB_ZA_mainProductTitle,
        PBP_ZA_pocketBiz,
        PBP_ZA_snapScan,
        AOB_ZA_business_MarketLink
    };
    @api imageLink = THEME_OVERRIDES + "/assets/images/picture.png";
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
    adobeDataScopeApp;
    adobeDataTextBack;
    adobeDataTextContinue;
    totalPricePck;
  
    application ={
      applicationProduct: "Customer on boarding",
      applicationMethod: "Online",
      applicationID : "", 
      applicationName : "", 
      applicationStep : "", 
      applicationStart : true, 
      applicationComplete : false 
  }
    emailAddressValue;

    isBusinessMarketLink = true;
    isPocketBiz = true;
    isSnapScan = true;
    isLoaded = true;
    @api mymobizBusinessAcc = [{
        'price': '5',
        'currency': 'R',
        'subTitle': 'MONTHLY FEE'
    }];
    @api businessMarketLink = [{
        'price': '4.85%',
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
        this.adobeDataScopeApp = this.adobeDataScope + ' business application';
        // this.adobeDataScopeApp = this.adobeDataScopeApp.toLowerCase();
        // this.adobeDataTextBack = this.adobePageName + ' back button click';
        // this.adobeDataTextContinue = this.adobePageName + ' continue button click';
        // this.adobeDataTextBack = this.adobePageName + ' | Resend button click';
        this.adobeDataTextContinue = this.adobePageName +'| Back to Browsing button click';
        this.isLoaded = true;
        this.adobePageTag = 'business application:' + this.adobeDataScopeApp + ':' + this.adobePageName;
        loadScript(this, FireAdobeEvents).then(() => { //Adobe tagging start
            if (!this.isEventFired) {
                this.isEventFired = true;
                // window.fireScreenLoadEvent(this, this.adobePageTag);
                //application start event fire
                window.fireScreenLoadEvent(this, this.adobePageTag);
             
                window.fireUserInfoEvent(this,this.event);
                this.adobeAnalyticsPageView();
              }
        });
        
        fetchInflightData({ 'appliId': this.applicationId }).then(result => {
            this.isLoaded=true;
            var cardSelectionData = JSON.parse(result)
            if (cardSelectionData.debitCardselected == true) {
                this.selectedCardImg = THEME_OVERRIDES +'/assets/images/gold-debit-mobile.png';
            } else {
                this.selectedCardImg = THEME_OVERRIDES +'/assets/images/gold-credit-mobile.png';
            }
            // if (cardSelectionData.selectedCard == 'chequeCard') {
            //     console.log('if conditon')
            //     this.selectedCardImg = THEME_OVERRIDES +'/assets/images/gold-credit-mobile.png';
            // } else if (cardSelectionData.selectedCard == 'debitCard') {
            //     this.selectedCardImg = THEME_OVERRIDES +'/assets/images/gold-debit-mobile.png';
            // }
        });
        this.fetchEmailAddress();
        this.availableBundlesData();
        this.getMainProductInfo();
        this.fetchPocketBizDetailsDisplay();
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
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "https://www.standardbank.co.za/southafrica/personal/products-and-services/bank-with-us/bank-accounts/our-accounts"
            }
        });
    }
    fetchEmailAddress() {
        fetchEmailAddress({ 'appliId': this.applicationId }).then(result => {
            var companyDetail = JSON.parse(result);
            // console.log('companydetailscrn',companyDetail['EMAIL ADDRESS']);
            if (companyDetail['EMAIL ADDRESS'] != null) {
                // console.log('if condition');
                this.emailAddressValue = companyDetail['EMAIL ADDRESS'];
            }
        });
    }

    getMainProductInfo(){

        mainProductData({
            'applicationId': this.applicationId
        }).then(result =>{
            this.mainProductNumber = result.AOB_ProductCode__c;
            this.mainProductPrOption = result.AOB_Pricing_Option__c;
            
            this.updateMainProductList();
        
        }).catch(error =>{
             
        });
    }

    updateMainProductList() {
        // read product data from json from static resource
        let request = new XMLHttpRequest();
        request.open("GET", productsData+'/'+this.mainProductNumber+'.json', false);
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
    fetchPocketBizDetailsDisplay(){
        pocketbizDetails({'appplicationId': this.applicationId}).then(res =>{
            var pockebizres = res;
            //console.log(pockebizres.prodDetails.numberOfDevices);
            var noOfPocketbizDevices = pockebizres.prodDetails.numberOfDevices;
            this.totalPricePck = noOfPocketbizDevices*69;
        });
    }

}