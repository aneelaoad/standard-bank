import { LightningElement, track } from 'lwc';
import EVENT_DETAILS_LABEL from '@salesforce/label/c.Eap_EventDetails_Label';

export default class EapEventDetailPage extends LightningElement {
    title = EVENT_DETAILS_LABEL;
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