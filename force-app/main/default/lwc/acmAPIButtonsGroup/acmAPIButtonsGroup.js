import { LightningElement, api, track } from 'lwc';
import RESOURCE_BASE_PATH from '@salesforce/resourceUrl/ACM_Assets';
export default class AcmAPIButtonsGroup extends LightningElement {
    @api discoverAPIButtonLabel;
    @api discoverAPIUrl;
    @api createAPIButtonLabel;
    @api createAPIUrl;
    @api discoverAccordionHeading;
    @api discoverAccordionText;
    @api createAccordionHeading;
    @api createAccordionText;
    @api SBGMouseIcon;
    @api SBGPcIcon;
    
    get mouseIconImage() {
        return RESOURCE_BASE_PATH + this.SBGMouseIcon;

    }
    get pcIconImage() {
        return RESOURCE_BASE_PATH + this.SBGPcIcon;

    }

    toggleAccordion(event) {

        const accordion = event.target;
        if (accordion) {
            accordion.classList.toggle('expanded');

        }
    }
}