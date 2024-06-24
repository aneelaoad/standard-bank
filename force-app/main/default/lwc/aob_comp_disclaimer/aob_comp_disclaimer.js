import { LightningElement,api } from 'lwc';
import SBG_LOCK from '@salesforce/resourceUrl/AOB_ThemeOverrides';
export default class Aob_comp_disclaimer extends LightningElement {
    @api teams = ["Self Assisted"];
    label = {};
    lockIMG = SBG_LOCK + '/assets/images/SBG_Lock.png';
    

    handleResultChange(event) {
        this.label = event.detail;
    }
}