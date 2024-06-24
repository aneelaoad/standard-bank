import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class OsbapiContactUsButton extends NavigationMixin(LightningElement) {

    @api labelText;

    navigateToContactUsPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'OPTL_Contact_Us__c'
            }
        });
    }
}