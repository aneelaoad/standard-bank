/*
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Created SFP-9125  19-11-2022 Gill Lumley   Copied from MVP1. Lead processing commented out (to be replaced by MVP2 lead process). References to FunFacts removed
 * @last modified on  : 19 APRIL 2024
 * @last modified by  : Narendra
 * @Modification Description : SFP-38348
 */
import { LightningElement, api, wire } from 'lwc';
export default class Aob_comp_cameraMissing extends LightningElement {

    isLoading;
    isVisible = true;
    wfrStatus;
    idNumber;
    correlationId;
    failing;
    errorContent;
    wfrFailReason;
    showVerificationUnavailablePopup;
    showErrorPopup;
    showCallMeBackConfirmedPopup;
    showRetriesExceededScreen;
    wiredRecords;

    //Labels
     @api teams = ["Self Assisted"];
    label = {};

    //Adobe Tagging 
    isEventFired;
    adobePageTag = {
        //pageName: "idv:identity verification:no camera found",
        dataId: "link_content",
        dataIntent: "navigational",
        dataScope: "identity verification",
        continueText: "no camera found | continue button click"
    };
   
    connectedCallback() {
    }
    handleResultChange(event) {
        this.label = event.detail;
    }

    /**
     * @description method to send event to parent to start OrchestrateIDV
     */
    callIDV(event) {
        window.fireButtonClickEvent(this, event);
        this.isVisible = false;
        const startIDV = new CustomEvent('callidv', {});
        this.dispatchEvent(startIDV);
    }

    /**
     * @description method to send event to parent to close popup
     */
    closeCameraPopup(){
        const closepopup = new CustomEvent('closed', {});
        this.dispatchEvent(closepopup);
    }

}