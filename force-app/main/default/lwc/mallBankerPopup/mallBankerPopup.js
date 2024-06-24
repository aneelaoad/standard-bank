import { LightningElement, track } from 'lwc';

import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";

const CONTACT_BANKER_BUTTON_TITLE = "Contact Your Banker";

export default class MallBankerPopup extends LightningElement {

    userImage = sbgVisualAssets + "/sbg-people_1.svg";
    bankLogo = sbgVisualAssets + "/SB_Logo_Transparent.png";
    contactBanker = CONTACT_BANKER_BUTTON_TITLE;
    displayPopup = false;
    @track isShowModal = false;
    bankerHeading = "Contact Your Banker";
    bankerText = "For banking-related questions, please submit your query below and your banker will get back to you as soon as possible. By using the form below, you will receive a reference number that you can use to track the progress of your query in the platform.";

    togglePopup() {
        let bankerBtn = this.template.querySelector(".contact-banker-popup-closed");
        let bankerPopup = this.template.querySelector(".contact-banker-popup-open");

        if(this.displayPopup === false){
            bankerBtn.style.display = "none";
            bankerPopup.style.display = "block";
            this.displayPopup = true;
        }else {
            bankerBtn.style.display = "block";
            bankerPopup.style.display = "none";
            this.displayPopup = false;
        }
    }

    openModal() {
        this.isShowModal = true
    }

    hideModalBox() {
        this.isShowModal = false;
      }
}