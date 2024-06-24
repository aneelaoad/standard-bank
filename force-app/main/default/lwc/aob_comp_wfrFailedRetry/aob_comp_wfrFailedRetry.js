/*
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Created SFP-8831  17-11-2022 Gill Lumley   Copied from MVP1 and removed unused labels and CallMeBack pop-up (not applicable to MVP2) 
@last modified on  : 26 APRIL 2024
@last modified by  : Narendra 
@Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';

import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents"; 
//Lightning imports
import { loadScript } from "lightning/platformResourceLoader"; 

export default class aob_comp_wfrFailedRetry extends LightningElement {
    @api teams = ["Self Assisted"];
    label = {};
    @api applicationId;
    isRendered;

    //Adobe Tagging 
    isEventFired;
    adobePageTag = {
        pageName: "idv:identity verification:we could not verify your identity:retry",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: "identity verification",
        callMeBackText: "we could not verify your identity:retry | call me back button click",
        retryText: "we could not verify your identity:retry | retry button click"
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

    confirmCallback() {
        const confirmed = new CustomEvent('confirm', {});
        this.dispatchEvent(confirmed);
    }

}