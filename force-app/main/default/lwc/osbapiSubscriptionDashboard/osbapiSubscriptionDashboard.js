import { LightningElement, wire } from 'lwc';
import getSubscriptions from '@salesforce/apex/OSB_OD_MySubscription_CTRL.getUserSubscriptions';

export default class OsbapiSubscriptionDashboard extends LightningElement {
    subscriptionList = [];
    hasSubscriptions;

    @wire(getSubscriptions)
    WiredGetSubscriptions({ data }) {
        if (data) {
            this.subscriptionList = data;
        }
        this.hasSubscriptions = this.subscriptionList.length > 0;
    }
}