/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   19-09-2022   devi ravuri   PreApplication data privacy comp
 * @last modified on  : 19 APRIL 2024
 * @last modified by  : Narendra
 * @Modification Description : SFP-38348
 */
import { LightningElement, api } from 'lwc';
export default class Aob_comp_dataPrivacy extends LightningElement {
    @api productName;
    @api teams = ["Self Assisted"];
    label = {};
    standardbankGroupLink;
    standardbankPrivacyLink;
    isEventFired;
    adobePageTag = {
        dataId: "link_content",
        dataIntent: "navigational",
        seemoreintent: "informational",
        dataScope: " application",
        standardbanklinkclick: "pre application | data privacy | standard bank link click",
        seemorelinkclick: "pre application | data privacy | see more link click",
        standardbankurlclick: "pre application | data privacy | standard bank url click",
    }
    showMoreText(event) {
        window.fireButtonClickEvent(this, event);
        event.preventDefault();
        var dots = this.template.querySelector('.dots');
        var moreText = this.template.querySelector('.moreText');
        var btnText = this.template.querySelector('.moreLess');
        if (dots.style.display === "none") {
            dots.style.display = "inline";
            btnText.innerHTML = "See More";
            moreText.style.display = "none";
        } else {
            dots.style.display = "none";
            btnText.innerHTML = "See Less";
            moreText.style.display = "inline";
        }
    }
    connectedCallback() {
        this.adobePageTag.dataScope = this.productName + ' application';

    }

    handleResultChange(event) {
        this.label = event.detail;
        this.standardbankGroupLink = this.label.PBP_ZA_Standardbankcomurl + '/sbg/standard-bank-group/who-we-are/our-structure';
        this.standardbankPrivacyLink = this.label.PBP_ZA_StandardBankUrl + '/privacy';
    }
    standardbankclick(event) {
        window.fireButtonClickEvent(this, event);
    }

}