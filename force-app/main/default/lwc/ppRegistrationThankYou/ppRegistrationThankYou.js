/**
* @description  : Partner Portal Regisrtaion Form Sub Component
* User Story : SFP-5159
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
import { LightningElement, api } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import { NavigationMixin } from 'lightning/navigation'
import { trackLink } from 'c/ppEventUtils'

export default class PPThankYou extends NavigationMixin(LightningElement){

    @api pageIndex;
    icon;

    connectedCallback() {
        this.icon = Assets + '/Icons/trackerCompleteIcon.png';
    }
    
    get renderFlag() {
        return this.pageIndex == 6 ? true : false;
    }
    
    navigateToHome(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

    tracker(event) {
        trackLink(event);
    }

}