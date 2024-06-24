import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class OsbapiApiCatalogueItem extends NavigationMixin(
    LightningElement
) {
    @api title;
    @api description;
    @api icon;
    @api recordId;
    @api showIcon;
    @api parentId;

    navigateToApiDetails() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'CommunityApi__c',
                actionName: 'view'
            },
            state: {
                tab: 'OneDeveloper',
                fromAsset: this.recordId,
                fromAssetVersion: this.parentId
            }
        });
    }
}