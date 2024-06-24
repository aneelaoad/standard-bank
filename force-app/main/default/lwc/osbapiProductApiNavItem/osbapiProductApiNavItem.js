import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getParentAssetVersion from '@salesforce/apex/OSB_OD_ApiDetails_CTRL.getParentAssetVersion';

export default class OsbapiProductApiNavItem extends NavigationMixin(
    LightningElement
) {
    @api apiId;
    @api apiName;
    @api activePageId;

    navItemClass;
    parentId;

    @wire(getParentAssetVersion, { apiId: '$apiId' })
    WiredGetParentAssetVersion({ data }) {
        if (data) {
            this.parentId = data.Id;
        }
    }

    navigateToApi() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.apiId,
                objectApiName: 'acm_pkg__AnypointApplications__x',
                actionName: 'view'
            },
            state: {
                tab: 'OneDeveloper',
                fromAsset: this.apiId,
                fromAssetVersion: this.parentId
            }
        });
    }

    isActivePage() {
        if (this.activePageId === this.apiId) {
            this.setActiveTab();
        } else {
            this.setInactiveTab();
        }
    }

    setActiveTab() {
        this.navItemClass = 'api-nav-item current-api-page';
    }

    setInactiveTab() {
        this.navItemClass = 'api-nav-item';
    }

    connectedCallback() {
        this.isActivePage();
    }
}