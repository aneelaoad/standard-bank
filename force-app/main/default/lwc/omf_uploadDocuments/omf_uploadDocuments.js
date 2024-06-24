import { LightningElement, api } from "lwc";
import getKYCDocuments from "@salesforce/apex/OMF_UploadDocumentsController.getKYCDocuments";
import inititateKYC from "@salesforce/apex/OMF_UploadDocumentsController.inititateKYC";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class Omf_uploadDocuments extends LightningElement {
  @api strManagedFundId;
  @api listManagedFundId;
  @api recordId;
  @api blnKycUploadDocument;

  blnModal;
  blnSpinner;
  blnRequiredDocument;
  blnTempRequiredDocument = true;
  blnTempAdditonalDocumemt = false;

  list_kycDocument = [];
  list_additionalDocument = [];
  retrievedRecordId; //boolean to stop recersion

  connectedCallback() {
    this.blnSpinner = true;
    if (this.strManagedFundId) {
      const list_managedFundId = this.strManagedFundId;
      getKYCDocuments({
        list_managedFundId: list_managedFundId,
        blnRequiredDocuments: false
      })
        .then((result) => {
          result.forEach((element) => {
            this.list_kycDocument.push(element);
          });
          this.strHeader = "Attach additional documents";
          this.strSubHeader = "Additional Documents";
          this.blnModal = true;
        })
        .catch((error) => {
          this.error = error;
          this.blnSpinner = false;
        });
    }
    if (this.listManagedFundId) {
      getKYCDocuments({
        list_managedFundId: this.listManagedFundId,
        blnRequiredDocuments: true
      })
        .then((result) => {
          this.list_kycDocument = result;

          this.list_kycDocument.forEach((element) => {
            if (element.strFileName != undefined) {
              element.blnDocumentUpload = true;
            } 
            else if(element.list_masterAgreementDetails != undefined) {
              element.list_masterAgreementDetails.forEach((key) => {
                if (key.strFileName != undefined) {
                  key.blnDocumentUpload = true;
                }
                else {
                  key.blnDocumentUpload = false;
                }
              });
            }
            else {
              element.blnDocumentUpload = false;
            }
          });
          this.handleDisableSubmitButton();
          this.blnRequiredDocument = true;
          this.blnSpinner = false;
        })
        .catch((error) => {
          this.error = error;
          this.blnSpinner = false;
        });
    }
  }

  renderedCallback() {
    if (!this.retrievedRecordId && this.recordId) {
      this.retrievedRecordId = true;
      this.blnSingleManagedFundEdit = true;
      this.blnSpinner = false;
      const requiredDocumentList = [];
      const additionalDocumentList = [];
      getKYCDocuments({
        list_managedFundId: this.recordId
      })
      .then((result) => {
        result.forEach(element => {
          if(element.strDocumentHeader != undefined){
            requiredDocumentList.push(element);
          }
          else{
            additionalDocumentList.push(element);
          }
        });
        this.list_kycDocument = requiredDocumentList;
        this.list_additionalDocument = additionalDocumentList;
      })
      .catch((error) => {});
    }
  }

  handleUpload(event) {
    const strSelectedKYCId = event.detail.list_kycRecordId;
    let blnIsDocumentUploaded = event.detail.isDocumentUploaded;
    
    this.list_kycDocument.forEach((element) => {
      if (element.list_kycStatusId.toString() == strSelectedKYCId.toString()) {
        element.blnDocumentUpload = blnIsDocumentUploaded;
      }
      if (element.list_masterAgreementDetails != undefined) {
        element.list_masterAgreementDetails.forEach((key) => {
          if (key.list_kycStatusId.toString() == strSelectedKYCId.toString()) {
            key.blnDocumentUpload = blnIsDocumentUploaded;
          }
        });
      }
    });
    this.handleDisableSubmitButton();
  }

  handleDisableSubmitButton() {
    let blnDocumentUploaded = false;

    for (var element in this.list_kycDocument) {
      if (this.list_kycDocument[element].blnDocumentUpload == false) {
        blnDocumentUploaded = true;
        break;
      }
      for(var key in this.list_kycDocument[element].list_masterAgreementDetails){
        if (this.list_kycDocument[element].list_masterAgreementDetails[key].blnDocumentUpload == false) {
          blnDocumentUploaded = true;
          break;
        }
      }
    }
    const selectedEvent = new CustomEvent("disablesubmitbutton", {
      detail: blnDocumentUploaded
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  handleCloseModal() {
    this.blnModal = false;
    const selectedEvent = new CustomEvent("closemodal", {
      detail: false
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  handleAttach(){
    this.blnModal = false;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: "The documents has been uploaded successfully.",
        variant: "success"
      })
    );
    const selectedEvent = new CustomEvent("closemodal", {
      detail: false
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  handleUploadSubmit(){
    this.blnSpinner = true;
    inititateKYC({list_ManagedFundId : this.recordId})
    .then((result) => {
      if(result == true){
        this.blnSpinner = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "The KYC Process has been initiated successfully.!",
            variant: "success"
          })
        );
        this.handleUploadClose();
      }
    })
    .catch((error)=>{
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "An error occurred,please try again later.",
          variant: "error"
        })
      );
    })
  }

  handleUploadClose(){
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}