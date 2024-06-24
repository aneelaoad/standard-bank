/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 12-04-2024
@ Name of the Class : Cib_comp_dashboard
@ Description       : This class is used to manage the dashboard of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 12-04-2024
@ Modification Description : SFP-36750
***************************************************************************************/
import { api, wire, track, LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDashboardDetails from "@salesforce/apex/CIB_CTRL_Dashboard.getDashboardDetails";
import chevronRightIcon from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class CibCompDashboard extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api sectionId;
  @track dashboardRecords = [];
  @track error;
  @track isLoading = true;
  @track baseURL = "/s/mauritius-onboarding-hub/application/";
  chevronRightIcon = chevronRightIcon + "/assets/images/chevronRightIcon.png";

  /**
   * @description get the Application records
   */
  get hasRecords() {
    return !this.isLoading && this.dashboardRecords && this.dashboardRecords.length > 0;
  }

  get isEmpty() {
    return (
      !this.isLoading &&
      this.dashboardRecords &&
      this.dashboardRecords.length === 0
    );
  }

  /**
   * @description Method to show message
   */
  showToast(title, message, variant, mode) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(event);
  }

  /**
   * @description Method to get the status of Application record
   */
  getStatusCompletion(item) {
    if (item.Status__c === "Submitted") {
      return "Submitted";
    } else if (
      item.CompletionPercentage__c === 0 ||
      item.CompletionPercentage__c === null
    ) {
      return "Not Yet Started";
    } else if (item.CompletionPercentage__c > 0) {
      return "Started";
    }
    return "n/a";
  }

  /**
   * @description Method used to calculate the time
   */
  getTimeDifference(createdDate) {
    const currentDate = new Date();
    const createdDateTime = new Date(createdDate);
    const timeDiff = Math.abs(currentDate - createdDateTime);
    const days = Math.floor(timeDiff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((timeDiff / (1000 * 60 * 60)) % 24);
    return `${days} days, ${hours} hours`;
  }
  /**
   * @description  Method used to get the notifications from Teams
   */
  get processedData() {
    return this.dashboardRecords.map((record) => {
      let notification = "No new notifications";
      if (
        record.Application_Sections__r &&
        record.Application_Sections__r.length
      ) {
        notification = record.Application_Sections__r.length + " notifications";
      }

      return {
        ...record,
        notification,
        createdDateDifference: this.getTimeDifference(record.CreatedDate),
        lastModifiedDifference: this.getTimeDifference(record.LastModifiedDate),
        applicationStatus: this.getStatusCompletion(record)
      };
    });
  }

  /**
   * @description Method to fetch dahborad records
   */
  @wire(getDashboardDetails, {})
  wiredDashboardDetails({ error, data }) {
    this.isLoading = true;
    if (data) {
      this.dashboardRecords = data;
      this.error = null;
    } else if (error) {
      this.error = error;
      this.dashboardRecords = null;
    }
    this.isLoading = false;
  }
  /**
   * @description Method to navigate to particular page
   */
  navigateToPage(event) {
    let recId = event.currentTarget.dataset.id;
    let launchURL = this.baseURL + recId;
    window.open(launchURL, "_self");
  }
}