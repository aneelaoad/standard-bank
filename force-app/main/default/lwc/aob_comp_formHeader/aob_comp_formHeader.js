import { LightningElement, api } from 'lwc';
export default class Aob_comp_formHeader extends LightningElement {
     @api teams = ["Self Assisted"];
    label = {};

    @api title;
    @api subTitle;
    @api currentScreen;
    showBlock = false;

    connectedCallback() {
        if (this.currentScreen == 'PreApplication') this.showBlock = true;
    }
      handleResultChange(event) {
        this.label = event.detail;
    }
}