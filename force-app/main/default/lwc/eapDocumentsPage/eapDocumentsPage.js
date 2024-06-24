import { LightningElement, track } from 'lwc';
import DOCUMENTS_LABEL from '@salesforce/label/c.Eap_Documents_Label';

export default class EapDocumentsPage extends LightningElement {
    title = DOCUMENTS_LABEL;
    @track loading = true;

    hasLoaded(){
        this.loading = false;
        this.template.querySelector(".content").style.visibility = "visible";
    }
}