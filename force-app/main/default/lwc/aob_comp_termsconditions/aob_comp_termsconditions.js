import {
    LightningElement,
    api
} from 'lwc';
import {
    NavigationMixin
} from "lightning/navigation";
import {
    FlowNavigationNextEvent
} from 'lightning/flowSupport';

import callGetDocumentAPI from '@salesforce/apex/AOB_SRV_CreateContract.callGetDocumentAPI';
import getAcceptedLineItems from '@salesforce/apex/AOB_CTRL_FormCreator.getAcceptedLineItems';

export default class Aob_comp_termsconditions extends NavigationMixin(LightningElement) {
    @api closePopup;
    @api applicationId;
    @api businessmarketlink;
    @api pckbiz;
    @api snapscan;
    @api availableActions = [];
    @api screenName;
    @api appid;
    @api previousScreen;
    @api nextScreen;
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    @api acceptedItems;
    @api productName;
    adobeformName;
     scope;
    adobedatatextapp;
    mymoBizId;
    marketLinkId;
    pocketBizId;
    snapScanId;
    link;
    isLoaded;
    acceptedProducts;
    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }
     @api teams = ["Self & Staff","Self Assisted"];
    label = {};
   
    connectedCallback() {
        this.adobeDataTextBack = 'Sign in' + ' Close button click';
        this.scope=this.productName +' application';
        this.adobeDataTextContinue = 'sign Legal agreements | sign in button click';

        this.adobeformName = "ZA | apply now  business bank account  summary form";
        this.fetchAcceptedLineItems();
    }
    handleResultChange(event) {
        this.label = event.detail;
        this.adobedatatextappGeneralTermsandconditions = 'sign in legal agreements | ' + this.label.AOB_GeneralTermsAndConditions + ' link click';
        this.adobedatatextappMymobizbusinessaccounttermsandconditions = 'sign in legal agreements | ' + this.label.AOB_MymobizBusinessAccountTermsAndC + ' link click';
        this.adobedatatextappMarketlinkTermsAndconditions = 'sign in legal agreements | ' + this.label.AOB_MarketlinkTermsAndConditions + ' link click';
        this.adobedatatextappPocketbiztermandconditions = 'sign in legal agreements | ' + this.label.AOB_PocketbizTermsAndConditions + ' link click';
        this.adobedatatextappSnapscantermandconditions = 'sign in legal agreements | ' + this.label.AOB_SnapscanTermAndConditions + ' link click';
        this.adobedatatextappShareHolderCertificate = 'sign in legal agreements | ' + this.label.AOB_ShareHolder + ' link click';

    }

    fetchAcceptedLineItems() {
        getAcceptedLineItems({
            'appId': this.applicationId
        }).then(result => {
            let response = result;
            if (response) {
                this.acceptedProducts = response;
                response.forEach(item => {
                    if (item.AOB_ProductCode__c == '4648') this.mymoBizId = item.SalesObjectItemId__c;
                    if (item.AOB_ProductCode__c == '4488') this.marketLinkId = item.SalesObjectItemId__c;
                    if (item.AOB_ProductCode__c == 'ZPOB') this.pocketBizId = item.SalesObjectItemId__c;
                    if (item.AOB_ProductCode__c == 'ZPSS') this.snapScanId = item.SalesObjectItemId__c;
                });
            }
            this.isLoaded = true;
        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
        });
    }

    fetchDocument(event) {
        this.isLoaded = false;
        let docCode = event.target.dataset.code;
        callGetDocumentAPI({
            'applicationId': this.applicationId,
            'docName': docCode
        }).then(result => {
            const binaryString = window.atob(result);
            const binaryLen = binaryString.length;
            const bytes = new Uint8Array(binaryLen);
            for (let i = 0; i < binaryLen; i++) {
                bytes[i] = binaryString.charCodeAt(i);
            }
            let blob = new Blob([bytes.buffer], { type: 'application/pdf' });
            let url = URL.createObjectURL(blob);
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url":url
                }
            });
            this.isLoaded = true;
        }).catch(error => {
           
            this.failing = true;
            this.isLoaded = true;
        });
        window.fireButtonClickEvent(this, event);

    }

    handleClosePoup(event) {
        this.closePopup = false;
        window.fireButtonClickEvent(this, event);
        const closeModal = new CustomEvent("closepopwindow", {
            detail: this.closePopup
        });
        this.dispatchEvent(closeModal);
    }
    customHideModalPopup() {
        this.isModalOpen = false;
    }

    handleSignMethod(event) {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
        window.fireButtonClickEvent(this, event);

    }


}