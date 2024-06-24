import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedApiList from '@salesforce/apex/OSB_OD_ProductDetails_CTRL.getRelatedApiList';
import getParentAssetVersion from '@salesforce/apex/OSB_OD_ProductDetails_CTRL.getParentAssetVersion';

export default class OsbapiViewDocumentationButton extends NavigationMixin(
    LightningElement
) {
    @api productId;
    @api labelText;

    apiId;
    parentId;

    @wire(getRelatedApiList, { productId: '$productId' })
    WiredGetApiList({ data }) {
        if (data) {
            this.apiId = data[0].Id;
        }
    }

    @wire(getParentAssetVersion, { apiId: '$apiId' })
    WiredGetParentAssetVersion({ data }) {
        if (data) {
            this.parentId = data.Id;
        }
    }

    navigateToDocumentation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.apiId,
                objectApiName: 'CommunityApi__c',
                actionName: 'view'
            },
            state: {
                tab: 'OneDeveloper',
                fromAsset: this.apiId,
                fromAssetVersion: this.parentId
            }
        });
    }
}