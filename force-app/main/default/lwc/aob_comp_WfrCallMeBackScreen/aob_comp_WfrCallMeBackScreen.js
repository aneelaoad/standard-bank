import { LightningElement , api } from 'lwc';

export default class Aob_comp_WfrCallMeBackScreen extends LightningElement {
  @api teams = ["Self Assisted"];
    label = {};

     handleResultChange(event) {
        this.label = event.detail;
    }
    handleBackToBrowsing(event) {
        window.fireButtonClickEvent(this, event);
        window.open(this.label.PBP_ZA_siteURL + "/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts", "__self");
    }
}