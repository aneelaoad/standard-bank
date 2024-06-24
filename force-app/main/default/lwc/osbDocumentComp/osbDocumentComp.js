import {LightningElement, api} from 'lwc';
import documentLink from '@salesforce/apex/OSB_DocumentWrapper_CTRL.getOSBDocumentURL';

export default class OsbDocumentComp extends LightningElement {
    resourceURL;
    @api documentName;    

    connectedCallback(){
        documentLink({docName: this.documentName})
        .then((result) => {
            if(result){
                this.resourceURL = String(window.location.origin) + result;
            }
        })
    }
}