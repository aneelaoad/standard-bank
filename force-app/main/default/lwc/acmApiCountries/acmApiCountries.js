import { LightningElement } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { addAnalyticsInteractions } from 'c/acm_AdobeAnalytics';

export default class AcmApiCountries extends NavigationMixin(LightningElement) {
    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }

    handleClickSouthAfrica(){

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'API_South_Africa__c',
            },
        });
    }
    handleClickKenya(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'API_Kenya__c',
            },
        });
    }
    handleClickUganda(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'API_Uganda__c',
            },
        });
    }

}