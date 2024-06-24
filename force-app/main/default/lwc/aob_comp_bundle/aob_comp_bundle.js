import { LightningElement, api } from 'lwc';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';

export default class Aob_comp_bundle extends LightningElement {
    @api teams = ["Self Assisted"];
    label = {};
    listArrow = THEME_OVERRIDES + '/assets/images/list-arrow.svg';
    @api imageLink = THEME_OVERRIDES + "/assets/images/pocketBiz.png";
    @api imageLink2 = THEME_OVERRIDES + "/assets/images/snapScan.png";
    @api availableBundleImage;
    @api title = 'PocketBiz';
    @api itemsList = ['A secure card payment solution', 'Free delivery & installation', 'Secure payments', 'Access to free merchant portal', 'Sell airtime and pre-paid electricity, cashback and instant money redemption'];
    @api priceList = [{ 'price': '69', 'currency': 'R', 'oldcurrency': 'R', 'oldPrice': '169', 'subTitle': 'Monthly fee per device' },
    { 'price': 'Zero', 'currency': 'R', 'oldPrice': '590', 'subTitle': 'Once Off sign up fee' }];
    @api percentList = [{ 'percent': '2.60', 'subTitle': 'Transactions fee (EXCL VAT)' }];
    @api applicationId;
    isEventFired;
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    @api productName;
    adobeDataScopeApp;
    dobeDataTextBack;
    adobeDataTextContinue;
    @api productCode;
    @api formDetails = {};
    @api formData;
    isCheck;
    selectedValues={};
    ecommerce={
        product:[{ }],
        purchaseID:"",
        currencycode:"ZAR"
    }
    connectedCallback() {
       this.adobeDataScopeApp = this.productName+' application | available bundles';
        this.adobeDataScopeApp = this.adobeDataScopeApp.toLowerCase();
        this.adobeDataTextContinue = this.title + ' | add to bundle click';
        this.isLoaded = true;
        this.ecommerce.product[0].category='business';
        this.ecommerce.product[0].family='transactional';
        this.ecommerce.product[0].productName= this.productName +' business account';
        this.ecommerce.product[0].price='198';
        this.ecommerce.product[0].quantity='1';
        this.adobePageTag = this.adobeDataScopeApp + ':' + this.adobePageName;
        this.adobePageTag = this.adobePageTag.toLowerCase();
    }

    handleResultChange(event) {
        this.label = event.detail;
    }
   
    get getformData(){
        this.selectedValues = this.formData;
        for(const key in this.selectedValues){
            if(key == this.productCode) return this.selectedValues[key];
        }
    }
    click(event) {
        let name = event.target.name;
        let value = event.target.checked;
        window.fireButtonClickEvent(this, event);
        this.ecommerce.product[0].sku=this.productCode;
        window.cartAddEvent(this, this.ecommerce);
        this.formDetails[name] = value;
        const bundleClick = new CustomEvent('select', { detail: { bundlename: name, bundlevalue: value } });
        this.dispatchEvent(bundleClick);
    }
}