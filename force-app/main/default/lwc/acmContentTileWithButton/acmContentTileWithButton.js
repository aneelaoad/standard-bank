import { LightningElement, api } from 'lwc';
import HOMEPAGEICONS from '@salesforce/resourceUrl/sbgVisualAssets';
import { addAnalyticsInteractions } from 'c/acm_AdobeAnalytics';

export default class AcmContentTileWithButton extends LightningElement {
    
    @api ACMHelperimage;
    @api supportText;
    @api subHeaderText;
    @api emailId;
    @api buttonLabel;
    @api weekdayHours;
    @api weekendHours;

    get sectionImage() {
        return HOMEPAGEICONS + this.ACMHelperimage;
       
    }

    get useSupportText(){

        return this.supportText;
    }

    get useSubHeaderText(){

        return this.subHeaderText;
    }

    get useEmailId(){

        return this.emailId;
    }

    get destinationUrl(){

        return 'mailto:' + this.emailId;
    }

    get useWeekdayHours(){

        return this.weekdayHours;
    }

    get useWeekendHours(){

        return this.weekendHours;
    }

    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }
}