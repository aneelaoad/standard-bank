import { LightningElement, api } from 'lwc';
export default class Aob_comp_taxError extends LightningElement {
     @api teams = ["Self Assisted"];
    label = {};
    @api errorLabel;
   
    @api content;
    @api customerError;
    showModal = true;
    isVisible = true;
    @api applicationId;
    businessAccountURL;

    adobePageTag = {
        pageName: "business:products and services:bank with us:business bank accounts:mymobiz plus account origination step 1  pre-application form",
        dataId: "link_content",
        dataIntent: "transactional",
        dataScope: "preapplication",
        cancelButtonText: "mymobiz business account | pre-application |  cancel button click",
        continueButtonText: "mymobiz business account | pre-application | continue button click",
        privacyintent: "informational",
        privacyscope: "mymobiz application",
        privacylinkclick: "pre application | privacy statement link click",
        siteErrorCode: "",
        application: {
            applicationProduct: "Preapplication",
            applicationMethod: "Online",
            applicationID: "",
            applicationName: "Preapplication",
            applicationStep: "",
            applicationStart: true,
            applicationComplete: false,
        },
    };

    closeModal(event) {
        window.fireButtonClickEvent(this, event);
        this.technical = false;
        const selectedEvent = new CustomEvent("cancel", {
            detail: 'cancelled'
        });
        this.dispatchEvent(selectedEvent);
    }
     handleResultChange(event) {
        this.label = event.detail;
        this.businessAccountURL=this.label.PBP_ZA_siteURL + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts';
    }

    backhome(event) {
        this.customerError = false;
        const selectedEvent = new CustomEvent("cancel", {
            detail: 'cancel'
        });
        this.dispatchEvent(selectedEvent);
    }
}