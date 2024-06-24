/*
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Created SFP-8831  17-11-2022 Gill Lumley   Copied from MVP1 and removed unused labels and CallMeBack pop-up (not applicable to MVP2) 
 * @last modified on  : 26 APRIL 2024
 *@last modified by  : Narendra 
 *@Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';
import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents"; 
import { loadScript } from "lightning/platformResourceLoader";

export default class aob_comp_wfrExpired extends LightningElement {
    @api teams = ["Self Assisted"];
    label = {};
    @api applicationId;
    isVisible = true;
    isRendered;
    openWfrExceed = false;
    
    //Adobe Tagging 
    isEventFired;
    adobePageTag = {
        pageName: "idv:identity verification:session expired",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: "identity verification",
        callMeBackText: "session expired | call me back button click",
        retryText: "session expired | retry button click"
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
        window.fireButtonClickEvent(this, event);
        const wfrRetry = new CustomEvent('retry', {});
        this.dispatchEvent(wfrRetry);
    }

    confirmCallback(event) {
        window.fireButtonClickEvent(this, event);
        const confirmed = new CustomEvent('confirm', {});
        this.dispatchEvent(confirmed);
    }

}