import { LightningElement, api, wire } from 'lwc';
import {
    subscribe,
    MessageContext
} from 'lightning/messageService';
import OSB_Logo from '@salesforce/resourceUrl/OSB_logoBadge';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';
import PROVIDER_CHANNEL from '@salesforce/messageChannel/Provider_Channel__c';
import Id from '@salesforce/user/Id';
import getApplicationByContactIdAndSolutionId from '@salesforce/apex/OSB_Dashboard_CTRL.getApplicationByContactIdAndSolutionId';

export default class OsbProviderSpacesProductCardLwc extends LightningElement {

    userId = Id;
    SBLogo = OSB_Logo;
    subscription = null;
    tileClick;
    tileLinkName;
    iconImage;
    @api title;
    @api solutionid;
    @api largelogo;
    @api dashboard;
    @api modalissolution;
    @api solutionsiteurl;
    @api isOnShowcase;
    @api isOpen = false;
    @api applicationowner;
    @api ssoredirecturl;
    @api urlname;
    @api introduction;
    @api modalcontent;
    @api providername;
    @api isproviderexit = false;
    @api providertitle;
    @api stopduplicate;
    @api link;

    @wire(MessageContext)
    messageContext;

    renderedCallback() {
        addAnalyticsInteractions(this.template);

        this.tileClick = this.title + ' selected';
        this.tileLinkName = 'Solution | ' + this.title + ' Clicked';
    }

    createmodalwindow() {
        this.isOpen = true;
        this.isproviderexit = true;

        getApplicationByContactIdAndSolutionId({ solutionId: this.solutionid })
            .then((result) => {
                this.subscribeSolutions = result;

                if (this.subscribeSolutions.length) {

                    this.stopduplicate = false;
                } else {                    
                    this.stopduplicate = true;
                }
            })
            .catch((error) => {
                this.error = error;
              
            });

    }

    modalCloseHandler() {
        this.isOpen = false;
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                PROVIDER_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        this.providerId = message.providerId;
        this.providertitle = message.providerTitle;
        this.modalfirstbuttonurl = message.modalfirstbuttonurl;
     

    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

}