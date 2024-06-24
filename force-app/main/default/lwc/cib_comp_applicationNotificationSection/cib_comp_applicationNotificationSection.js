import { api, track, wire } from "lwc";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import getNotifiedOnRevisionRequested from "@salesforce/apex/CIB_CTRL_HubScreen.getNotifiedOnRevisionRequested";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import { refreshApex } from "@salesforce/apex";
export default class Cib_comp_applicationNotificationSection extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  mau_chevronrightIcon =
    MAU_ThemeOverrides + "/assets/images/chevronRightIcon.png";
  @api recordId;
  @track notificationRecords = [];
  @track selectedId;
  @track isLoading = true;

  getTimeDifference(lastModifiedDate) {
    const currentDate = new Date();
    const lastModifiedDateTime = new Date(lastModifiedDate);
    const timeDiff = Math.abs(currentDate - lastModifiedDateTime);
    const minutes = Math.floor(timeDiff / (1000 * 60));
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) {
      return `${days} days, ${hours % 24} hours ago`;
    } else if (hours > 0) {
      return `${hours} hours ago`;
    }
    return `${minutes} minutes ago`;
  }

  get isEmpty() {
    return this.notificationRecords.length === 0;
  }

  get processedData() {
    return this.notificationRecords.map((record) => {
      return {
        ...record,
        timeReceived: this.getTimeDifference(record.LastModifiedDate)
      };
    });
  }

  get isSubmitDisabled() {
    return true;
  }

  @api refreshNotifications() {
    return refreshApex(this._wiredNotifications);
  }
  _wiredNotifications;
  @wire(getNotifiedOnRevisionRequested, { applicationId: "$recordId" }) 
  wiredNotifyRecs(_wiredNotifications) {
    let { data } = _wiredNotifications;
    this._wiredNotifications = _wiredNotifications;
    if (data) {
      this.notificationRecords = data;
    }
    this.isLoading = false;
  }

  navigateToSection(event) {
    this.selectedId = event.currentTarget.dataset.sectionId;
    const selectEvent = new CustomEvent("sectionclick", {
      detail: this.selectedId
    });
    this.dispatchEvent(selectEvent);
  }
  navigateToNext() {
    
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "Previous_Registration_in_another_country__c"
      }
    });
  }
  navigateToBack() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "mauritius-onboarding-hub"
      }
    });
  }
}