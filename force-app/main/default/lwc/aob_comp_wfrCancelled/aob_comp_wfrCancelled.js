/*
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Created SFP-8831  17-11-2022 Gill Lumley   Copied from MVP1 and removed unused labels and CallMeBack pop-up (not applicable to MVP2) 
 * @last modified on  : 26 APRIL 2024
   @last modified by  : Narendra 
   @Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents"; 
import { loadScript } from "lightning/platformResourceLoader"; 

export default class aob_comp_wfrCancelled extends LightningElement {
    @api applicationId;
    isRendered;
 @api teams = ["Self Assisted"];
    label = {};

    //Adobe Tagging
    isEventFired;
    adobePageTag = {
        pageName: "idv:identity verification:cancelled",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: "identity verification",
        callMeBackText: "cancelled | call me back button click",
        retryText: "cancelled | retry button click"
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
    }

    /**
     * @description method to process retry
     */
    retryCallback(event) {
        window.fireButtonClickEvent(this, event); // SFP-10154 
        const wfrRetry = new CustomEvent('retry', {});
        this.dispatchEvent(wfrRetry);
    }

    /**
     * @description method to confirm callback
     */
    confirmCallback() {
        const confirmed = new CustomEvent('confirm', {});
        this.dispatchEvent(confirmed);
    }
}