import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class EapArchiveDetailPage extends LightningElement {
    @track loading = true;
    @track eventName = "";
    @track eventId;

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

    handleEventNameChange(){
        this.eventName = this.template.querySelector('c-eap-archive-detail-content').eventName;
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