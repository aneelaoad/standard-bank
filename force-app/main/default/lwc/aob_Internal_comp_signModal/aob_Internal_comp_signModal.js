import { LightningElement, api } from 'lwc';
import utils from 'c/aob_comp_utils';
//Adobe imports
import { loadScript } from 'lightning/platformResourceLoader';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';

export default class Aob_Internal_comp_signModal extends LightningElement {
    @api applicationId;
    @api contractId;
    @api hasInsurance;
    @api productName;
    isRendered;
    label = {
        AOB_FinalOffer_Modal_Title,
        AOB_FinalOffer_Modal_Text,
        AOB_FinalOffer_Modal_Text2,
        AOB_FinalOffer_Modal_Link,
        AOB_FinalOffer_Modal_Confirm1,
        AOB_FinalOffer_Modal_Confirm2,
        AOB_Button_Close,
        AOB_Button_Sign,
        AOB_FinalOffer_Modal_Link_WithoutInsurance,
        AOB_FinalOffer_Modal_Confirm1_WithoutInsurance
    };
    documentBlob;
    BlobUrl;
    link;
    adobeTag = {
        'dataId':'link_content',
        'dataIntent':'confirmational',
        'dataScope':'contract sign',
        'dataTextSign':'sign legal agreement | sign button clicked',
        'dataTextClose':'sign legal agreement | close button clicked'
    };
    connectedCallback() {
        
    }

    renderedCallback() {
        if (!this.isRendered) {
            loadScript(this, FireAdobeEvents)
                .then(() => {
                    this.isRendered = true;
                })
                .catch();
        }
    }
    @api isSigned = false;

    handleChange() {
        this.isSigned = !this.isSigned;
    }
    get disableButton() {
        return !this.isSigned;
    }
    closeModal(event) {
        window.fireButtonClickEvent(this, event);
        const storeEvent = new CustomEvent('closedmodal', {});
        this.dispatchEvent(storeEvent);
        
    }
    handleSign(event) {
        if (!this.isSigned) return;
        window.fireButtonClickEvent(this, event);
        const selectedEvent = new CustomEvent("signed", {
            detail: this.isSigned
        });
        this.dispatchEvent(selectedEvent);
        deleteAttachedDocs({'applicationId':this.applicationId })
            .catch(error => {
                utils.showToast.call(this, error);
            });
    }


    get AOB_FinalOffer_Modal_Link() {
        return this.hasInsurance ? utils.format(this.label.AOB_FinalOffer_Modal_Link, this.productName) : this.label.AOB_FinalOffer_Modal_Link_WithoutInsurance;
    }
    get AOB_FinalOffer_Modal_Confirm1() {
        return this.hasInsurance ? utils.format(this.label.AOB_FinalOffer_Modal_Confirm1, this.productName) : this.label.AOB_FinalOffer_Modal_Confirm1_WithoutInsurance;
    }
    get AOB_FinalOffer_Modal_Confirm2() {
        return this.hasInsurance ? utils.format(this.label.AOB_FinalOffer_Modal_Confirm2, this.productName) : null;
    }

    get disabledURL() {
        return this.BlobUrl ? '' : "isDisabled";
    }
}