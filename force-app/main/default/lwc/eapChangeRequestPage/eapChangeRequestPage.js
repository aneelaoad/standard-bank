import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import RESCHEDULE_LABEL from '@salesforce/label/c.Eap_Reschedule_Label';

export default class EapChangeRequestPage extends LightningElement {
    title = RESCHEDULE_LABEL;
    @track loading = true;
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

    hasLoaded(){
        this.loading = false;
        this.template.querySelector(".content").style.visibility = "visible";

        this.template.querySelector('.siteforceSpinnerManager.siteforcePanelsContainer').classList.add('hideEl');
    }

    needToLoad(){
        this.loading = true;
        this.template.querySelector(".content").style.visibility = "hidden";
    }
}