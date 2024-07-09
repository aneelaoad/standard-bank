import { LightningElement, api } from 'lwc';

export default class MallSolutionsModal extends LightningElement {

    _modalHeader;

    @api showModal = false;

    @api disableNextButton = false;

    @api
    get modalHeader() {
      return this._modalHeader;
    }
  
    set modalHeader(value) {
      this._modalHeader = value;
    }

    get nextButtonClass(){
        return this.disableNextButton ? 'slds-button slds-button_brand nextBTN disableBtn' :  'slds-button slds-button_brand nextBTN';
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    confirmAction() {
        this.dispatchEvent(new CustomEvent('confirm'));
    }

    

}