import { LightningElement, api, wire, track } from "lwc";
import getAPIAccessType from "@salesforce/apex/ACM_LeadOrSubscribe.getAPIAccessType";
import RESOURCE_BASE_PATH from "@salesforce/resourceUrl/ACM_Assets";

export default class AcmLeadOrSubscribe extends LightningElement {
  @track isLead = false;
  @track isSubscription = false;
  @track isBoth = false;
  @track registerInterest = false;
  @api recordId;

  @wire(getAPIAccessType, { recordId: "$recordId" })
  retrieveAPIAccessType(resultP) {
    let result = resultP.data;
    if (result != null || result !== undefined || result !== "") {
      switch (result) {
        case "both":
          this.isBoth = true;
          break;
        case "lead":
          this.isLead = true;
          this.isSubscription = false;
          break;
        case "subscription":
          this.isSubscription = true;
          break;
        default:
          if (resultP.error) {
            this.isSubscription = true;
          }
      }
    }
  }

  get close() {
    return RESOURCE_BASE_PATH + "/close.png ";
  }

  get inputVariables() {
    return [
      { name: "viQueueName", type: "String", value: "C4EMarketplaceManager" },
      { name: "RecordId", type: "String", value: this.recordId }
    ];
  }

  showModal() {
    this.registerInterest = true;
    this.inputVariables();
  }

  closeModal() {
    this.registerInterest = false;
  }
}