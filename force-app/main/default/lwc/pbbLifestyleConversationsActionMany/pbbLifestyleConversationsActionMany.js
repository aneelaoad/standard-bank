import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getInitData from '@salesforce/apex/PBB_Lifestyle_ConversationMassEdit_Ctrl.getInitData';
import getConversations from '@salesforce/apex/PBB_Lifestyle_ConversationMassEdit_Ctrl.getConversations';
import save from '@salesforce/apex/PBB_Lifestyle_ConversationMassEdit_Ctrl.save';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PbbLifestyleConversationsActionMany extends LightningElement {
    @api clientId;
    @track wiredConversations;
    wiredSubcategoryToResponse;
    wiredResponseToReason;
    @track loading = true;

    connectedCallback() {
        getInitData({
                clientId: this.clientId
            })
            .then((result) => {
                this.loading = false;
                this.wiredConversations = result.data;
				this.wiredConversations.forEach(x=>{x.url = '/'+x.Id;});
                this.wiredSubcategoryToResponse = result.subcategoryToResponse;
                this.wiredResponseToReason = result.responseToReason;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
            });
    }
    renderedCallback() {
        if (this.template.querySelectorAll('lightning-combobox[data-type="response"]')) {
            Array.prototype.forEach.call(this.template.querySelectorAll('lightning-combobox[data-type="response"]'), x => {
                let convId = x.getAttribute('data-id');
                let subcategory = this.wiredConversations.find(y => {
                    return y.Id == convId
                }).Subcategory__c;
                let options = this.wiredSubcategoryToResponse[subcategory];
                x.options = options;
            });
        }
    }

    get conversationData() {
        return this.wiredConversations ? this.wiredConversations : [];
    }

	get isConversationsEmpty(){
        return (!Array.isArray(this.wiredConversations) || !this.wiredConversations.length) && !this.loading;
    }

    get isConversationsNotEmpty(){
        return Array.isArray(this.wiredConversations) && this.wiredConversations.length && !this.loading;
    }
    
    handleClick(event) {
        let convId = event.target.dataset.id;
        var record = this.wiredConversations.find(y => {
            return y.Id == convId
        });
        save({
                conversationRecord: record
            })
            .then(response => {
                console.info("Success", response);
                getConversations({
                        clientId: this.clientId
                    })
                    .then((result) => {
                        this.wiredConversations = result;
						this.wiredConversations.forEach(x=>{x.url = '/'+x.Id;});
                        this.error = undefined;
                    })
                    .catch(error => {
                        this.error = error;
                    });
            })
            .catch(error => {
                console.info('error ', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong while saving, system administrator was informed, please come back later or try again.',
                    variant: 'error',
                    mode: 'dismissable'
                }));
            });
    }
    handleResponseChange(event) {
        let response = event.target.value;
        let convId = event.target.dataset.id;
        var record = this.wiredConversations.find(y => {
            return y.Id == convId
        });
        record.Response__c = response;
        record.Reason__c = undefined;
        let options = this.wiredResponseToReason[response];
        this.template.querySelector('lightning-combobox[data-type="reason"][data-id="'+convId+'"]').options = options;
    }

    handleReasonChange(event) {
        let convId = event.target.dataset.id;
        this.wiredConversations.find(y => {
            return y.Id == convId
        }).Reason__c = event.target.value;
    }
    handleCommentsChange(event) {
        let convId = event.target.dataset.id;
        this.wiredConversations.find(y => {
            return y.Id == convId
        }).Comments__c = event.target.value;
    }
    handleFutureContactDateChange(event) {
        let convId = event.target.dataset.id;
        this.wiredConversations.find(y => {
            return y.Id == convId
        }).Future_Contact_Date__c = event.target.value;
    }
}