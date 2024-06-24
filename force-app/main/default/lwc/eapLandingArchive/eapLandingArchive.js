import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import ARCHIVE_LABEL from '@salesforce/label/c.Eap_ArchivedFiles_Label';

export default class EapLandingArchive extends NavigationMixin(LightningElement) {
    title = ARCHIVE_LABEL;

    showArchivedEvents(){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Events_List__c'
            },
            state: {
                allEvents: false
            }
        });
    }
}