import { LightningElement, api, wire } from 'lwc';
import { MessageContext, subscribe } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/osbMenuEvents__c';
import generateInterestedEmails from '@salesforce/apex/OSB_OD_InterestedJourney_CTRL.generateInterestedEmails';

export default class OsbapiProductInterestedButton extends LightningElement {
    @api labelText;

    productName;
    isDisabled;
    showPopup = false;
    buttonStyle = 'osbapiProductInterestedButton enabled';

    @wire(MessageContext)
    messageContext;

    handleSubscribe() {
        subscribe(this.messageContext, messageChannel, (message) => {
            if (message.ComponentName === 'Product Breadcrumb') {
                this.productName = message.Details.ProductName;
            }
            if (
                message.ComponentName === 'Product Interested Button' &&
                message.Details.Modal === 'close'
            ) {
                this.togglePopup();
            }
        });
    }

    togglePopup() {
        if (this.showPopup) {
            this.showPopup = false;
        } else {
            this.showPopup = true;
        }
    }

    handleOnClick() {
        if (this.isDisabled) return;
        this.togglePopup();
        generateInterestedEmails({ productName: this.productName });
        this.isDisabled = true;
        this.handleButtonStyle();
    }

    handleButtonStyle() {
        this.buttonStyle = (this.isDisabled) ? 'osbapiProductInterestedButton disabled' : 'osbapiProductInterestedButton enabled';
    }

    connectedCallback() {
        this.handleSubscribe();
    }
}