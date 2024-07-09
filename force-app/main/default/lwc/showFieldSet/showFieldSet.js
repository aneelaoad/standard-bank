import {LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFields from '@salesforce/apex/Ltn_FieldSetController.getFields';

export default class ShowFieldSet extends LightningElement {

    @api recordId;
    @api fieldSetApiName;
    @api sObjectApiName;
    @api sectionTitle;
    @api columns;
    @track fields = [];
    errorMessage = undefined;


    connectedCallback() {
        getFields({recordId: this.recordId, fieldSetName: this.fieldSetApiName})
            .then((response) => {
                let fields = [];
                Object.entries(response.fieldsToQuery).forEach(([key, value]) => {
                    fields.push(value);
                });
                this.fields = fields;
            })
            .catch((error) => {
                this.errorMessage = error;
            });
    }

    handleSuccess() {
        this.showToast('Success', 'The record was updated', 'success', 'pester');
    }

    showToast(title, message, variant, mode) {
        const toast = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(toast);
    }

}