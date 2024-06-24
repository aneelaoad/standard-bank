import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import ALL_EVENTS_LABEL from '@salesforce/label/c.Eap_AllEvents_Label';
import ARCHIVE_LABEL from '@salesforce/label/c.Eap_Archive_Label';


export default class EapEventsListPage extends LightningElement {
    labels = {AllEvents: ALL_EVENTS_LABEL, Archive: ARCHIVE_LABEL };
    @track loading = true;
    @track title;
    @track allEventsSelected;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        let allEvents = this.urlStateParameters.allEvents || null;
        if (allEvents)
        {
            this.title = this.labels.AllEvents;
            this.allEventsSelected = true;

        }else{
            this.title = this.labels.Archive;
            this.allEventsSelected = false;
        }
    }

    hasLoaded(){
        this.loading = false;
        this.template.querySelector(".content").style.visibility = "visible";
    }

    needToLoad(){
        this.loading = true;
        this.template.querySelector(".content").style.visibility = "hidden";
    }
}