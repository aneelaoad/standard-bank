import { LightningElement, api } from 'lwc';
import THEME_OVERRIDES from '@salesforce/resourceUrl/AOB_ThemeOverrides';

export default class Aob_internal_comp_modal extends LightningElement {
    closeIcon;
    @api hasheader;
    @api header;
    @api aobmodalcontainerlarge;
    get headerClassStyle(){
        return this.hasheader === "true" ? 'aob_modal_header aob_font_size_28_20 aob_text_align_center aob_sm_text_align_left aob_required-actions-sub-title slds-p-vertical_medium bg-gradient-primary' :'aob_header';
    }
    get aob_modal_container(){
        return this.aobmodalcontainerlarge === "true" ? 'aob_modal_container aob_modal_container-large':'aob_modal_container';
    }
    connectedCallback(){
        this.closeIcon = THEME_OVERRIDES + '/assets/images/close_' + (this.hasheader === "true" ? 'white.svg':'button_icon.png');
    }
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    closeModal() {
        this.dispatchEvent(new CustomEvent('closed', {bubbles : true}));
    }
}