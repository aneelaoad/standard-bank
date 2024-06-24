import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPathForBreadCrumb from '@salesforce/apex/OSB_OD_ProductDetails_CTRL.getPathForBreadCrumb';
import { MessageContext, publish } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/osbMenuEvents__c';

export default class OsbapiApiMarketplaceBreadCrumb extends NavigationMixin(
    LightningElement
) {
    @api productId;
    @api showApi;

    productInfo;
    apiInfo;
    productName;
    apiName;

    @wire(MessageContext)
    messageContext;

    handlePublish() {
        const payload = {
            ComponentName: 'Product Breadcrumb',
            Details: {
                ProductName: this.productName
            }
        };
        publish(this.messageContext, messageChannel, payload);
    }

    getBreadCrumbPath() {
        getPathForBreadCrumb({ objectId: this.productId }).then((data) => {
            if (data) {
                this.productInfo = data[0];
                this.productName = data[0].acm_pkg__Name__c;
                if (data.length > 1) {
                    this.apiInfo = data[1];
                    this.apiName = data[1].acm_pkg__Name__c;
                }
                this.handlePublish();
            }
        });
    }

    navigateMarketplace(event) {
        let tabName = event.target.dataset.navigation;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            },
            state: {
                tab: tabName
            }
        });
    }

    navigateToProductPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.productInfo.Id,
                objectApiName: 'CommunityApi__c',
                actionName: 'view'
            },
            state: {
                tab: 'OneDeveloper'
            }
        });
    }

    connectedCallback() {
        this.getBreadCrumbPath();
    }
}