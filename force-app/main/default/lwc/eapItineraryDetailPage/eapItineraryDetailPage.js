import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class EapItineraryDetailPage extends LightningElement {
    @track loading = true;
    @track eventId;
    @track travelId;
    @track travelName;

    /* Receive event Id */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.travelId = this.urlStateParameters.travelId || null;
        this.eventId = this.urlStateParameters.eventId || null;
    }

    handleTravelNameChange(){
        this.travelName = this.template.querySelector('c-eap-itinerary-detail-content').travelName;
    }

    hasLoaded(){
        this.loading = false;
        this.template.querySelector(".content").style.visibility = "visible";
    }
}