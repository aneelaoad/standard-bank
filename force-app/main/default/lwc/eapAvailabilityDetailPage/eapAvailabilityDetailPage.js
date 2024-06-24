import { LightningElement, track } from 'lwc';
import MEETING_AVAILABILITY_LABEL from '@salesforce/label/c.Eap_MeetingAvailability_Label';

export default class EapAvailabilityDetailPage extends LightningElement {
    title = MEETING_AVAILABILITY_LABEL;
    @track loading = true;

    hasLoaded(){
        this.loading = false;
        this.template.querySelector(".content").style.visibility = "visible";
    }

    needToLoad(){
        this.loading = true;
        this.template.querySelector(".content").style.visibility = "hidden";
    }
}