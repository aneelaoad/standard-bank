import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getAnypointApplicationId from "@salesforce/apex/OSB_OD_MySubscription_CTRL.getAnypointApplication";

export default class OsbapiSubscriptionTile extends NavigationMixin(
    LightningElement
) {
    @api applicationId;

    name;
    anypointId;

    @wire(getAnypointApplicationId, {
        subscriptionApplicationId: "$applicationId"
    })
    WiredGetAnypointApplicationId({ data }) {
        if (data) {
            this.anypointId = data.Id;
            this.name = data.acm_pkg__Name__c;
        }
    }

    navigateToSubscriptionPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.anypointId,
                objectApiName: "acm_pkg__AnypointApplications__x",
                actionName: "view"
            },
            state: {
                name: this.name,
                tab: "OneDeveloper"
            }
        });
    }
}