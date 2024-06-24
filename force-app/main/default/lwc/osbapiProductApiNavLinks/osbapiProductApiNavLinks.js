import { LightningElement, api, wire } from 'lwc';
import getSiblingApis from '@salesforce/apex/OSB_OD_ApiDetails_CTRL.getSiblingApis';

export default class OsbapiProductApiNavLinks extends LightningElement {

    @api recordId

    apiList;

    @wire(getSiblingApis, { apiId: '$recordId' })
    WiredGetSiblingApis({ data }) {
        if (data) {
            this.apiList = data;
        }
    }

}