import { LightningElement, track } from 'lwc';
import VENUE_LABEL from '@salesforce/label/c.Eap_Venue_Label';

export default class EapVenuePage extends LightningElement {
    title = VENUE_LABEL;
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