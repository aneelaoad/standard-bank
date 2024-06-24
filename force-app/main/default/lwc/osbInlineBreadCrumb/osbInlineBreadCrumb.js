import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import eventChannel from '@salesforce/messageChannel/osbMenuEvents__c';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class osbInlineBreadCrumb extends LightningElement {
    @api link;
    @api linkLabel;
    @api withOverlay;
    @api baseLabel = 'Dashboard';
    @api baseLink = '/s';
    @api providerLink;
    navLink;
    dataText;

    @wire(MessageContext)
    messageContext;
    handleTabChange(event) {
        const payload = {
            ComponentName: 'Bread crumb',
            Details: {
                tabName: event.target.dataset.id
            }
        };
        publish(this.messageContext, eventChannel, payload);
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
        this.dataText = 'breadcrumb | ' + this.baseLabel;
        if (this.baseLabel == 'Dashboard') {
            this.navLink = '/s';
        } else {
            this.template.querySelector('[data-id="first-item"]').classList.add('adjust');
            this.template.querySelector('[data-id="second-item"]').classList.add('adjust');
            this.template.querySelector('[data-id="container"]').classList.remove('breadLink');
            this.template.querySelector('[data-id="container"]').classList.add('container');
        }
    }
}