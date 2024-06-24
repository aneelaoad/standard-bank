import { LightningElement, track } from 'lwc';
import ACCOMMODATION_LABEL from '@salesforce/label/c.Eap_Accommodation_Label';

export default class EapAccommodationPage extends LightningElement {
    title = ACCOMMODATION_LABEL;
    @track loading = true;

    hasLoaded(){
        this.loading = false;
        this.template.querySelector(".content").style.visibility = "visible";
    }
}