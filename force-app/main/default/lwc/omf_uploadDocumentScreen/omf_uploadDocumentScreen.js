import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateOnboardingStageLegal from "@salesforce/apex/OMF_BulkOnboardMyFund.updateOnboardingStageLegal";

export default class Omf_uploadDocumentScreen extends LightningElement {
  @api recordId; //Get the current record id
  blnSpinner;

  //Get the current record id.
  renderedCallback() {
    if (!this.retrievedRecordId && this.recordId) {
      this.blnSpinner = true;
      this.retrievedRecordId = true;
      this.blnStep1 = true;
      this.blnSpinner = false;
    }
  }

  async handleUploadSubmit() {
    updateOnboardingStageLegal({recordId : this.recordId})
    .then((result) => {
      if(result == true){
        const event = new ShowToastEvent({
          title: "Success",
          message: "The documents has been successfully updated.",
          variant: "success",
          mode: "dismissable"
        });
        this.dispatchEvent(event);
        this.handleUploadClose();
      }
      }) .catch(error => {
        const event = new ShowToastEvent({
          title: "Error",
          message: "Error while uploading document",
          variant: "error",
          mode: "dismissable"
        });
        this.dispatchEvent(event);
        this.handleUploadClose();
      });
    
  }

  handleUploadClose() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}