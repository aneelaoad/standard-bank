/*
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Created MVP1 Copy 19-11-2022 Gill Lumley   Copied from MVP1 and removed CallMeBack pop-up (not applicable to MVP2) 
 * @last modified on  : 26 APRIL 2024
   @last modified by  : Narendra 
   @Modification Description : SFP-38348
 */
import { LightningElement, api,  } from 'lwc';
//Static Resources
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';

import FireAdobeEvents from "@salesforce/resourceUrl/FireAdobeEvents"; 
import { NavigationMixin } from 'lightning/navigation';
//Lightning imports
import { loadScript } from "lightning/platformResourceLoader"; 

export default class Aob_comp_unverificationModal extends NavigationMixin(LightningElement) {
     @api teams = ["Self Assisted"];
    label = {};
    @api applicationId;
    @api technical;
    isVisible = true;
    model=true;
    openWfrExceed = false;
    isRendered;
   
    //Adobe Tagging 
    isEventFired;
    adobePageTag = {
        pageName: "idv:identity verification:verification unavailable",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: "identity verification",
        callMeBackText: "verification unavailable | call me back button click",
        retryText: "verification unavailable | retry button click"
    };
    listArrow = THEME_OVERRIDES + '/assets/images/list-arrow.svg';
    futureIcon = THEME_OVERRIDES + '/assets/images/icon_future.svg';
    infoCircleIcon = THEME_OVERRIDES + '/assets/images/icon_info_circle.svg';

    closeModal(event) {
        window.fireButtonClickEvent(this, event);
        this.isVisible = false;
    }

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
        this.isVisible = false;
        const wfrRetry = new CustomEvent('retry', {});
        this.dispatchEvent(wfrRetry);
    }

    /**
     * @description method to handle confirmation of Call Me Back
     */
    confirmCallback(event) {
        window.fireButtonClickEvent(this, event);
        this.isVisible = false;
        const confirmed = new CustomEvent('confirm', {});
        this.dispatchEvent(confirmed);
    }

}