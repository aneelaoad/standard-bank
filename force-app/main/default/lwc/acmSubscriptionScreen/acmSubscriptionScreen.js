import { LightningElement, api, wire,track } from 'lwc';
import getApiProducts from '@salesforce/apex/ACM_SubscriptionScreenController.getApiProducts';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import networkId from '@salesforce/community/Id';

export default class AcmSubscriptionScreen extends NavigationMixin(LightningElement) {
    @api recordId;
    @api buttonLabel;
    @track communityApiList;
    @track error;
    communityApiListHasvalue = true;
    currentcommunityId;

    connectedCallback() {
        this.currentcommunityId = networkId;
    }    

    @wire(getApiProducts, { apiId: '$recordId', communityId: '$currentcommunityId' })
    wiredCommunityApiList({ error, data }) {
        if (data) {
            this.communityApiList = data;
            if(this.communityApiList.length === 0 ){
                this.communityApiListHasvalue = false;
            }            
            this.error = undefined;           
        } else if (error) {
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            this.communityApiList = undefined;
        } 
    }

    navigateToCommunityApiProduct(event) {
        //getting record id using name attribute
        const selectedRecordId = event.target.name;        
        var locOrigin = window.location.origin;
        var baseURL = basePath;
        var communityApiUrl = locOrigin+'/'+baseURL+'/communityapi/'+selectedRecordId;
        document.location.href = communityApiUrl;
    }
}