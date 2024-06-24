import { LightningElement, api } from "lwc";
import getExisitingManagedFundRecord from "@salesforce/apex/OMF_BulkOnboardMyFund.getExisitingManagedFundRecord";
import deleteManagedFundRecord from "@salesforce/apex/OMF_BulkOnboardMyFund.deleteManagedFundRecord";
import inititateKYC from "@salesforce/apex/OMF_UploadDocumentsController.inititateKYC";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Omf_bulkOnboardMyFund extends LightningElement {
  @api recordId;
  blnAddManagedFund; // Boolean to set as true when clicked on add managed fund record.
  blnAttachDocument; //Boolean to store if attact document option is selected.
  blnModalSpinner; //Show the spinner on the top of modal.
  blnSpinner; //Show the spinner on the screen.
  blnDeleteRow; // Boolean to show the modal for delete warning message.
  retrievedRecordId = false;
  blnStep1;
  blnStep2;
  blnStep3;
  blnNextDisabled = true; //Disable next button if no fund record found;
  blnAddFundDisabled = false; //Disable next button record is cancelled found;
  blnDisableSubmitButton = false;
  blnCancelledDisabled = false;

  strSelectedRowId; //Store the selected row id.
  strSelectedRowName; //Store the selected row name.
  strAction; //Store the action of the screen i.e Edit or Add Fund.

  index; //Index to store the row number of table.

  list_ManagedFundRecord = []; //List to store the managed fund record.
  list_ManagedFundRecordId = []; //List to store the managed fund record Id.

   async renderedCallback() {
    //Prevent from rendering
    if (!this.retrievedRecordId && this.recordId) {
      this.retrievedRecordId = true;
      this.blnSpinner = true;
      try {
        const result = await getExisitingManagedFundRecord({ strRecordId: this.recordId });
        if(result){
          if (result.includes) {
            this.list_ManagedFundRecord = JSON.parse(
              JSON.stringify(result)
            );
            this.handleNextDisable();
          }
          if (result.strOnboardStatus == "Cancelled") {
            this.blnNextDisabled = true;
            this.blnAddFundDisabled = true;
            this.blnCancelledDisabled = true;
          }
          this.blnStep1 = true;
          this.blnSpinner = false;
        }
      } catch (error) {
        this.blnSpinner = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "An error occurred, please try again.",
            variant: "error",
          })
        );
      }
    }
  }

  handleAddFund() {
    this.strAction = "Add Fund";
    this.blnAddManagedFund = true;
  }

  handleAddRow(event) {
    //Check if the list is having some values
    if (this.list_ManagedFundRecord) {
      this.list_ManagedFundRecord = [
        ...this.list_ManagedFundRecord,
        ...event.detail
      ];
    } else {
      this.list_ManagedFundRecord = JSON.parse(JSON.stringify(event.detail));
    }

    this.blnAddManagedFund = false;
    this.handleNextDisable();
  }

  handleEditRecord(event) {
    this.blnSpinner = true;
    this.strAction = "Edit Fund";
    this.blnAddManagedFund = true;
    this.strSelectedRecordId =
      this.list_ManagedFundRecord[event.target.value].Id;
    this.blnSpinner = false;
  }

  handleAttachment(event) {
    this.strSelectedRecordId =
      this.list_ManagedFundRecord[event.target.value].Id;
    this.blnAttachDocument = true;
  }

  handleDelete(event) {
    this.blnDeleteRow = true;
    this.strSelectedRowName =
      this.list_ManagedFundRecord[event.target.value].Fund__r.Name;
    this.strSelectedRowId = this.list_ManagedFundRecord[event.target.value].Id;
  }

  async handleDeleteConfirm() {
    this.blnModalSpinner = true;
    try {
      const result = await deleteManagedFundRecord({ strRecordId: this.strSelectedRowId });
      if (result == true) {
        this.list_ManagedFundRecord.splice(
          this.list_ManagedFundRecord.findIndex(
            (row) => row.Id === this.strSelectedRowId
          ),
          1
        );
        this.blnDeleteRow = false;
        this.blnModalSpinner = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: `The record ${this.strSelectedRowName} has been deleted successfully.`,
            variant: "success",
          })
        );
        this.handleNextDisable();
      }
      else{
        this.blnSpinner = false;
        this.blnDeleteRow = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "An error occurred, please try again.",
            variant: "error",
          })
        );
      }
    } catch (error) {
      this.blnSpinner = false;
      this.blnDeleteRow = false;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "An error occurred, please try again.",
          variant: "error",
        })
      );
    }
  }
  

  handleNext(event) {
    //Extract the ID from the list
    this.list_ManagedFundRecordId = this.list_ManagedFundRecord.map(
      (element) => element.Id
    );
    this.blnStep2 = true;
    this.blnStep1 = false;
  }

  //Handles the close of the modal
  handleCloseModal(event) {
    this.blnDeleteRow = false;
  }

  handleAttachDocumentClose(event) {
    this.blnAttachDocument = event.detail;
  }

  handlenAddManagedFundClose(event) {
    this.blnAddManagedFund = event.detail;
  }

  //Handle the redirect of the URL fields.
  handleRedirect(event) {
    const targetIndex = this.list_ManagedFundRecord[event.target.dataset.index];
    let recordId = targetIndex[event.target.name];
    const redirectURL = window.location.origin + "/" + recordId;
    window.open(redirectURL, "_blank");
  }

  //Handles the click of the previous screen.
  handlePrevious() {
    this.blnStep2 = false;
    this.blnStep1 = true;
  }

  //Handle the submit for the onboarding
  handleSubmitForOnboarding() {
    this.blnSpinner = true;
    inititateKYC({ list_ManagedFundId: this.list_ManagedFundRecordId })
      .then((result) => {
        if (result == true) {
          this.blnSpinner = false;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "The KYC Process has been initiated successfully.!",
              variant: "success"
            })
          );
          window.location.reload();
        }
        else{
          this.blnSpinner = false;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: "An error occurred,please try again later.",
              variant: "error"
            })
          );
        }
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "An error occurred,please try again later.",
            variant: "error"
          })
        );
      });
  }

  //Handles the enable/disable of the next button
  handleNextDisable() {
    if (Object.keys(this.list_ManagedFundRecord).length > 0) {
      this.blnNextDisabled = false;
    } else {
      this.blnNextDisabled = true;
    }
  }

   //Handles the enable/disable of the "Submit for Onboarding" button
  handleDisableSubmitButton(event) {
    this.blnDisableSubmitButton = event.detail;
  }
}