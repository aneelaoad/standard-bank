import { LightningElement, wire, api } from 'lwc';
import getProduct from '@salesforce/apex/OSB_OD_ApiDetails_CTRL.getParentProduct';
import { NavigationMixin } from 'lightning/navigation';

export default class OsbapiDocumentDownloadButton extends NavigationMixin(
    LightningElement
) {
    @api recordId;
    product;
    name;
    resourceURL;

    @wire(getProduct, { apiId: '$recordId' })
    WiredGetProduct({ data }) {
        if (data) {
            this.product =
                this.createSearchString(data.acm_pkg__Name__c) +
                '_integration_guide';
        }
    }

    createSearchString(productName) {
        return productName
            .replace(/-/g, '')
            .replace(/[^a-zA-Z0-9\s]/g, '')
            .replace(/\s+/g, ' ')
            .toLowerCase()
            .replace(/\s/g, '_');
    }

    navigateToDocumentPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__namedPage',
            attributes: {
                name: 'api_integration_guide_view__c'
            },
            state: {
                product: this.product
            }
        }).then((url) => {
            window.open(url);
        });
    }
}