import { LightningElement, api, wire} from 'lwc';
import onboardBulkMangedFund from "@salesforce/apex/OMF_OnboardBulkManagedFundController.onboardBulkMangedFund";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Omf_onboardBulkManagedFund extends NavigationMixin(LightningElement) {
    isLoading;
    _recordId;
    @api set recordId(value) {
        this._recordId = value;
        //this.isLoading = true;
        onboardBulkMangedFund({ accountId: this.recordId })
        .then((result) => {          
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result,
                    objectApiName: "OMF_ManagedFund__c",
                    actionName: "view"
                }
            });      
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'You have successfully started Bulk Managed Fund Onboarding!',
                variant: 'success'
            });
            this.dispatchEvent(event);   
            //this.dispatchEvent(new CloseActionScreenEvent());   
        })
        .catch((error) => {
            this.error = error;
            this.isLoading = false;
        });
    }

    get recordId() {
        return this._recordId;
    }    
}