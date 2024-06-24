import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Pbp_comp_preApplication_RetriesExceeded extends NavigationMixin(LightningElement) {
  @api teams = ["Self Assisted"];
    label = {};
  BACK() {
        this[NavigationMixin.Navigate]({
            "type": "comm__namedPage",
            attributes: {
                name: 'Business_bank_accounts__c'
            }
        });
  }
   handleResultChange(event) {
        this.label = event.detail;
    }
}