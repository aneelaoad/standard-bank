import { LightningElement, wire, api } from 'lwc';
import getParentApiPage from '@salesforce/apex/OSB_OD_ApiDetails_CTRL.getParentApiPage';

export default class OsbapiProductBannerImage extends LightningElement {

    @api recordId;

    imageLink;

    @wire(getParentApiPage, { apiId: '$recordId', pageName: 'Banner Image' })
    WiredGetParentApiPage({ data }) {
        if (data) {
            this.imageLink = this.cleanUpData(data);
        }
    } 

    cleanUpData(data) {
        let tempArr = data.split('(');
        tempArr[1] = tempArr[1].slice(0 , -1);
        return tempArr[1];
    }

}