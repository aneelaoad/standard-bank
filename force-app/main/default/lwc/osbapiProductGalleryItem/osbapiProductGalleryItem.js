import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { publish, MessageContext } from "lightning/messageService";
import eventChannel from "@salesforce/messageChannel/osbMenuEvents__c";
import OSB_Logo from "@salesforce/resourceUrl/OSB_logoBadge";

export default class OsbapiProductGalleryItem extends NavigationMixin(
    LightningElement
) {
    SBLogo = OSB_Logo;

    @api title;
    @api description;
    @api recordId;
    @api icon = "";
    solTM = false;
    destinationUrl;
    hasIcon = false;
    cssStyle;

    @wire(MessageContext)
    messageContext;
    handleProductInformation() {
        const payload = {
            ComponentName: "api product catalogue",
            Details: {
                productId: this.recordId
            }
        };
        publish(this.messageContext, eventChannel, payload);
    }

    navigateToDetailsPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: "CommunityApi__c",
                actionName: "view"
            },
            state: {
                tab: "OneDeveloper"
            }
        });
    }

    handleNavigation() {
        this.handleProductInformation();
        this.navigateToDetailsPage();
    }

    setCssClass() {
        if (this.icon.length !== 0) {
            this.hasIcon = true;
        } else {
            this.hasIcon = false;
        }
    }

    connectedCallback() {
        this.setCssClass();
    }
}