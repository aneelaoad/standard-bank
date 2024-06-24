import { LightningElement, api } from 'lwc';
import RESOURCE_BASE_PATH from '@salesforce/resourceUrl/ACM_Assets';

export default class acminfoBox extends LightningElement {
    @api Title;
    @api Description;
    @api SBGInfoBoxIcon;

    get iconImage() {
        return RESOURCE_BASE_PATH + this.SBGInfoBoxIcon;

    }

}