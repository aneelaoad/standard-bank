/*
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Created SFP-xxxx  17-11-2022 Gill Lumley   Copied from MVP1 
 * @last modified on  : 26 APRIL 2024
   @last modified by  : Narendra 
   @Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents"; 
import { loadScript } from "lightning/platformResourceLoader";

export default class aob_comp_wfrFailedNoRetry extends LightningElement {
    @api teams = ["Self Assisted"];
    label = {};
    @api applicationId;
    isRendered;
    
    businessAccountURL;

    //Adobe Tagging
    isEventFired;
    adobePageTag = {
        pageName: "idv:identity verification:we could not verify your identity:error",
        dataId: "link_content",
        dataIntent: "navigational",
        dataScope: "identity verification",
        backToBrowsingText: "we could not verify your identity:error | back to browsing button click"
    }; 

    connectedCallback() {
        loadScript(this, FireAdobeEvents).then(() => { 
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
            }
        }); 
    }
    handleResultChange(event) {
        this.label = event.detail;
        this.businessAccountURL= this.label.PBP_ZA_StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts';
    }

    /**
     * @description method to return to  Business Transactional products page
     */
    backToBrowsing(event) {
        window.fireButtonClickEvent(this, event); // SFP-10154 
        window.open(this.businessAccountURL, '_self');
    }

}