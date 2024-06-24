/*
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Created SFP-8831  17-11-2022 Gill Lumley   Copied from MVP1 and removed unused labels and CallMeBack pop-up (not applicable to MVP2) 
 * @last modified on  : 26 APRIL 2024
 *@last modified by  : Narendra 
 *@Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';
import PBP_ZA_StandardBankUrl from "@salesforce/label/c.PBP_ZA_StandardBankUrl";
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents";
//Lightning imports
import { loadScript } from "lightning/platformResourceLoader";

export default class aob_comp_wfrRetriesExceeded extends LightningElement {
    isRendered;
    @api teams = ["Self Assisted"];
    label = {};
    businessAccountURL = PBP_ZA_StandardBankUrl + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts';

    //Adobe Tagging 
    isEventFired;
    adobePageTag = {
        pageName: "idv:identity verification:could not verify your identity",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: "identity verification",
        callMeBackText: "could not verify your identity | call me back button click"
    };



    connectedCallback() {
        loadScript(this, FireAdobeEvents).then(() => { // SFP-10154 Start
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag.pageName);
            }
        });
    }
     handleResultChange(event) {
        this.label = event.detail;
    }


    /**
     * @description method to return to previous page when window is closed
     */
    backToBrowsing(event) {
        window.open(this.businessAccountURL, '_self');
        window.fireButtonClickEvent(this, event);

    }

}