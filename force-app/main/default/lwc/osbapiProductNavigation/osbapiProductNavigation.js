import { LightningElement, wire } from 'lwc';
import { MessageContext, publish } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/osbMenuEvents__c';

export default class OsbapiProductNavigation extends LightningElement {

    @wire(MessageContext)
    messageContext;

    handleSearch(event) {
        const payload = {
            ComponentName: 'Product Search Bar',
            Details: {
                SearchInput: event.target.value
            }
        };
        publish(this.messageContext, messageChannel, payload);
    }
}