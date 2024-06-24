import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import ITINERARY_LABEL from '@salesforce/label/c.Eap_TravelItinerary_Label';

export default class EapItineraryPage extends LightningElement {
    title = ITINERARY_LABEL;
    @track loading = true;
    @track eventId;

    /* Receive event Id */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.eventId = this.urlStateParameters.eventId || null;
    }

    hasLoaded(){
        this.loading = false;
        this.template.querySelector(".content").style.visibility = "visible";
        this.template.querySelector('.siteforceSpinnerManager .siteforcePanelsContainer').classList.add('hideEl');
    }

    needToLoad(){
        this.loading = true;
        this.template.querySelector(".content").style.visibility = "hidden";
    }
}