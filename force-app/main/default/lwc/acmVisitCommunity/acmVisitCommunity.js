import { LightningElement,api } from 'lwc';
import { addAnalyticsInteractions } from 'c/acm_AdobeAnalytics';

export default class Acm_FooterContent extends LightningElement {

    @api headerText;
    @api subHeaderText;
    
    @api buttonLabel;
    @api destinationUrl;

    renderedCallback(){
       addAnalyticsInteractions(this.template);
      }

    get useHeaderText() {
        return this.headerText;
    }

    get useSubHeaderText() {
        return this.subHeaderText;
    }

    get useButtonText() {
        return this.buttonText;
    }

    get usebuttonLabel() {
        return this.buttonLabel;
    }

    }