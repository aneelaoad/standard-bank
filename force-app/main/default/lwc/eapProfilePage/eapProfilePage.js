import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import PROFILE_LABEL from '@salesforce/label/c.Eap_Profile_Label';

export default class EapProfilePage extends LightningElement {
    title = PROFILE_LABEL;
    @track loading = true;
    @track viewPage = 0; //Number of the tab that the viewer wants to open

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        let openContact = this.urlStateParameters.openContact || null;
        let openTermsConditions = this.urlStateParameters.openTermsConditions || null;

        if (openContact !== null) {
            this.viewPage = 1; //See EapProfileContent for reference
        }
        if (openTermsConditions !== null) {
            this.viewPage = 2; //See EapProfileContent for reference
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