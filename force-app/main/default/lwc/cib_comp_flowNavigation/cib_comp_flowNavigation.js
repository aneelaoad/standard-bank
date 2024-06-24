import { LightningElement, api } from "lwc";

export default class Cib_comp_flowNavigation extends LightningElement {
  @api section;
  @api saveButtonDisable;
  @api isFirstScreen;
  @api submitFirstScreen;
  submitFirstScreenButton;
  saveButtonEnable;
  firstScreens;
  submitText;
  @api acceptTermsText;
  cancelText = "Back";

  onSaveButtonClick() {
    this.dispatchEvent(new CustomEvent("save"));
  }
  onpreviousButtonClick() {
    this.dispatchEvent(new CustomEvent("previous"));
  }
  onsubmitButtonClick() {
    
    this.dispatchEvent(new CustomEvent("submit"));
  }

  connectedCallback() {
    if (this.saveButtonDisable) {
      this.saveButtonEnable = false;
    } else {
      this.saveButtonEnable = true;
    }
    if (this.isFirstScreen) {
      this.firstScreens = true;
      if (this.submitFirstScreen) {
        this.submitFirstScreenButton = true;
        if (this.acceptTermsText) {
          this.submitText = "ACCEPT TERMS & CONDITIONS";
          this.cancelText = "Back";
        } else {
          this.submitText = "Submit";
          this.cancelText = "Cancel";
        }
      } else {
        this.submitFirstScreenButton = false;
      }
    } else {
      this.firstScreens = false;
    }
  }
}