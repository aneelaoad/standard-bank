import { LightningElement, api } from 'lwc';
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbHeaderBannerMessageLwc extends LightningElement {
    @api externallink;
    @api standardbanklink;
    
    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }
}