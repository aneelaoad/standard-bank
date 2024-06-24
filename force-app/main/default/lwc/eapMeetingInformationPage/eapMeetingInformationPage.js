import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class EapMeetingInformationPage extends LightningElement {
    @track loading = true;
    @track meetingName = "";
    @track meetingId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.meetingId = this.urlStateParameters.meetingId || null;
    }

    handleEventNameChange(){
        this.meetingName = this.template.querySelector('c-eap-meeting-information-content').meetingName;
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