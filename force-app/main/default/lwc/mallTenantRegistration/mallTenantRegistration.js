import { LightningElement, track, wire } from "lwc";
import getContactsByProviderId from "@salesforce/apex/MallTenantRegistrationController.getContactsByProviderId";
import updateTenantRegistrationEmailFlag from "@salesforce/apex/MallTenantRegistrationController.updateTenantRegistrationEmailFlag";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";

const columns = [
  {
    label: "First Name",
    fieldName: "FirstName"
  },
  {
    label: "Last Name",
    fieldName: "LastName"
  },
  {
    label: "Email",
    fieldName: "Email",
    type: "email"
  },
  {
    label: "Cellphone",
    fieldName: "MobilePhone",
    type: "phone"
  },
  {
    label: "Permissions",
    fieldName: "BCB_Platform_Tenant_Role__c"
  }
];

export default class MallTenantRegistration extends LightningElement {
  @track recordId;
  @track contacts;
  selectedContacts = [];
  @track columns = columns;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.recordId;
      this.getContacts();
    }
  }

  async getContacts() {
    let contacts = [];
    try {
      contacts = await getContactsByProviderId({ providerId: this.recordId });
      this.contacts = [...contacts];
    } catch (error) {
      this.error = error;
    }
  }

  getSelectedContacts(event) {
    const selectedRows = event.detail.selectedRows;
    let selectedContacts = [];
    for (let row = 0; row < selectedRows.length; row++) {
      let selectedContact = {};
      selectedContact["Id"] = selectedRows[row].Id;
      selectedContact["Register_Mall_Tenant__c"] = true;
      selectedContacts.push(selectedContact);
    }
    this.selectedContacts = [...selectedContacts];
  }

  async sendRegistrationEmails() {
    try {
      let selectedContacts = await updateTenantRegistrationEmailFlag({
        contacts: this.selectedContacts
      });
      const event = new ShowToastEvent({
        title: "Tenant Registration",
        message: "Tenant Registration Email Sent Successfully!!"
      });
      this.dispatchEvent(event);
    } catch (error) {
      this.error = error;
      const event = new ShowToastEvent({
        title: "Tenant Registration",
        message: this.error
      });
      this.dispatchEvent(event);
    }
  }
}