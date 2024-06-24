import { api, LightningElement, wire } from 'lwc';
import { MessageContext, publish } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/osbMenuEvents__c';
import { NavigationMixin } from 'lightning/navigation';

export default class OsbapiProductInterestedPopup extends NavigationMixin(LightningElement) {
    @api apiName;

    @wire(MessageContext)
    messageContext;

    closeModal() {
        const payload = {
            ComponentName: 'Product Interested Button',
            Details: {
                Modal: 'close' 
            }
        };
        publish(this.messageContext, messageChannel, payload);
    }

    navigateToTAndC() {
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Terms_and_Conditions__c'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }
}