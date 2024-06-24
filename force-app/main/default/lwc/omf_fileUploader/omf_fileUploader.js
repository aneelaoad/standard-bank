/***************************************************************************************
@Name of the component : omf_fileUploader.js
@Description : To upload documents
@Author : Naveen B
@Created Date : 28-09-2022
/***************************************************************************************
@Last Modified By : Aman Kumar 
@Last Modified On : 06-05-2024
@Modification description: SFP-Number - SFP-38048
***************************************************************************************/
import { LightningElement, api, track } from "lwc";
import { updateRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createContentDocumentLink from "@salesforce/apex/OMF_UploadDocumentsController.createContentDocumentLink";
import deleteContentDocumentLink from "@salesforce/apex/OMF_UploadDocumentsController.deleteContentDocumentLink";
import deleteDocument from "@salesforce/apex/OMF_UploadDocumentsController.deleteDocument";
import getDocumentSizeError from  "@salesforce/apex/OMF_UploadDocumentsController.getDocumentSizeError";

export default class Omf_fileUploader extends NavigationMixin(
  LightningElement
) {
  @api required;
  @api label;
  @api help;
  @api name;
  @api parentId;
  @api fileId;
  @api fileName;
  @api kycRecordId;
  @api listKycRecordId;
  @api singleManagedFund;
  @api helpText;
  @track fileNames = [];
  @track documentIds = [];

  isUploaded = false;
  isLoading = false;
  accept = [".pdf"];

  connectedCallback() {
    if (this.fileId && this.fileName) {
      this.fileNames = [this.fileName];
      this.documentIds = [this.fileId];
      this.isUploaded = true;
    }
  }

  handleUploadFinished(event) {
    this.isLoading = true;
    const lstUploadedFiles = event.detail.files;
    const maxSize = 2 * 1024 * 1024;
    if (lstUploadedFiles[0].size > maxSize) {
        const errorMessage = 'File size exceeds the limit of 2MB.';
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error',
            })
        );
        return;
    }

    const contentDocumentId = lstUploadedFiles.map((file) => {
        this.fileNames.push(file.name);
        this.documentIds.push(file.documentId);
        return file.contentBodyId;
    })[0];

    getDocumentSizeError({
        contentDocumentId: lstUploadedFiles[0].documentId
    }).then((result) => {
        if (result == false) {
            if (!this.required || this.singleManagedFund === "true") {
                const fields = {
                    Id: this.parentId
                };
                fields.Status__c = "Received";
                fields.Date_Received__c = new Date().toISOString().slice(0, 10);
                updateRecord({
                        fields
                    })
                    .then(() => {
                        this.isUploaded = true;
                        this.isLoading = false;
                        this.showNotification(
                            "Success!",
                            `${this.fileNames[0]} has been uploaded successfully.`,
                            "success"
                        );
                    })
                    .catch(() => {
                        this.isLoading = false;
                        this.showNotification(
                            "Error",
                            "An error occurred, please try again.",
                            "error"
                        );
                    });
            }
            if (this.required && this.singleManagedFund === "false") {
                const list_kycRecordId = this.kycRecordId || this.listKycRecordId;
                createContentDocumentLink({
                        list_KYCStatusRecordId: list_kycRecordId,
                        strContentDocumentId: lstUploadedFiles[0].documentId
                    })
                    .then(() => {
                        this.isUploaded = true;
                        this.isLoading = false;
                        this.dispatchEvent(
                            new CustomEvent("selection", {
                                detail: {
                                    list_kycRecordId,
                                    isDocumentUploaded: true
                                }
                            })
                        );
                        this.showNotification(
                            "Success!",
                            `${this.fileNames[0]} has been uploaded successfully.`,
                            "success"
                        );

                    })
                    .catch(() => {
                        this.isLoading = false;
                        this.showNotification(
                            "Error",
                            "An error occurred, please try again.",
                            "error"
                        );
                    });
            }
        } else {
            this.isLoading = false;
            this.isUploaded = false;
            this.fileNames.pop();
            this.showNotification(
                "Error",
                "Please upload a file less than 2MB",
                "error"
            );
        }
    }).catch(() => {
        this.isLoading = false;
        this.showNotification(
            "Error",
            "An error occurred, please try again.",
            "error"
        );
    })

}

  async handleDelete() {
    const {
      documentIds,
      required,
      singleManagedFund,
      parentId,
      fileNames,
      listKycRecordId
    } = this;

    if (!documentIds || documentIds.length === 0) {
      return;
    }

    this.isLoading = true;

    var documentDelete = documentIds[0];
    if(this.singleManagedFund === "false" || this.singleManagedFund == undefined){
      await deleteDocument({ strDocumentId: documentDelete});
    }
    if(this.singleManagedFund === "true"){
      const result = await deleteContentDocumentLink({ recordId: this.parentId });
    }

    this.isUploaded = false;
    this.documentIds = [];

    let fields = {};
    fields["Id"] = parentId;
    fields["Status__c"] = "Outstanding";
    fields["Date_Received__c"] = "";

    if (this.required == false) {
      const fields = {};
      fields["Id"] = this.parentId;
      fields["Status__c"] = "Outstanding";
      fields["Date_Received__c"] = "";
      const recordInput = { fields };
      updateRecord(recordInput);
    }
    if (this.required == true && this.singleManagedFund == "true") {
      const fields = {};
      fields["Id"] = this.parentId;
      fields["Status__c"] = "Outstanding";
      fields["Date_Received__c"] = "";
      const recordInput = { fields };
      updateRecord(recordInput);
    }
    if (this.required == true && this.singleManagedFund == "false") {
      const recordUpdatePromises = this.listKycRecordId.forEach((element) => {
        var fields = {};
        fields["Id"] = element;
        fields["Status__c"] = "Outstanding";
        fields["Date_Received__c"] = "";
        const recordInput = { fields };
        updateRecord(recordInput);
      }); 
    }

    const fileName = fileNames[0];

    const objFileUploaded = listKycRecordId;
    const selectEvent = new CustomEvent("selection", {
      detail: {
        list_kycRecordId: objFileUploaded,
        isDocumentUploaded: false
      }
    });
    this.dispatchEvent(selectEvent);
    this.isLoading = false;
    this.showNotification(
      "Success!",
      fileName + " has been deleted successfully.",
      "success"
    );
    this.fileNames = [];
  }

  handlePreview() {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview"
      },
      state: {
        selectedRecordId: this.documentIds[0]
      }
    });
  }

  showNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}