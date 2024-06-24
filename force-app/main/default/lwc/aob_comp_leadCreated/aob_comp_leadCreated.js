import { LightningElement,api } from 'lwc';
import createExternalLead from "@salesforce/apex/AOB_API_BusinessLead_CTRL.callBusinessLead";
import { getErrorMessage } from 'c/aob_comp_utils';

export default class Aob_comp_leadCreated extends LightningElement {
    @api applicationId;
    @api leadReason;
    isLoading;
    errorMessage;
    connectedCallback() {
        createExternalLead({
            'applicationId': this.applicationId,
            'leadReason': this.leadReason
        }).then((result) => {
        }).catch((error) => {
            this.isLoading = true;
            this.errorMessage = getErrorMessage.call(this, error);
        });
    }

}