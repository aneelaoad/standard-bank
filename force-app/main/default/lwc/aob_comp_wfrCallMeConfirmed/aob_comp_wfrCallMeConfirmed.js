/*
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Created SFP-8831  17-11-2022 Gill Lumley   Copied from MVP1, removed unused labels and commerce site references (old solution)
 * @last modified on  : 26 APRIL 2024
   @last modified by  : Narendra 
   @Modification Description : SFP-38348  
 */
import { LightningElement,api } from 'lwc';
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents"; 
import {NavigationMixin} from "lightning/navigation";
import { loadScript } from "lightning/platformResourceLoader"; 

export default class Aob_comp_wfrCallMeConfirmed extends NavigationMixin(LightningElement) {

    @api teams = ["Self Assisted"];
    label = {};
    businessAccountURL;
    //Adobe Tagging
    isEventFired;
    adobePageTag = {
        pageName: "idv:identity verification:we'll call you back",
        dataId: "link_content",
        dataIntent: "navigational",
        dataScope: "identity verification",
        backToBrowsingText: "we'll call you back | back to browsing button click"
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


    handleBackToBrowsing(event) {
        window.fireButtonClickEvent(this, event);  
        window.open(this.businessAccountURL, '_self');
    }
}