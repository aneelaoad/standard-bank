import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCommunityAssetVersion from '@salesforce/apex/OSB_OD_ProductDetails_CTRL.getCommunityAssetVersion';

export default class OsbapiProductSubscriptionButton extends NavigationMixin(
    LightningElement
) {
    @api labelText;
    @api apiId;
    parentAssetVersion;

    @wire(getCommunityAssetVersion, { assetId: '$apiId' })
    WiredGetParentAssetVersion({ data }) {
        if (data) {
            this.parentAssetVersion = data;
        }
    }

    navigateToSubscibePage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'onedeveloperProductSubscribe__c'
            },
            state: {
                tab: 'OneDeveloper',
                productId: this.parentAssetVersion.acm_pkg__ParentAsset__c,
                versionId: this.parentAssetVersion.Id,
                version: this.parentAssetVersion.acm_pkg__Version__c
            }
        });
    }
}