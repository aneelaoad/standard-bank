import { LightningElement, api, track } from "lwc";

import getFile from "@salesforce/apex/CIB_CTRL_DocumentUploader.getFile";
import getSessionId from "@salesforce/apex/CIB_CTRL_DocumentUploader.getSessionId";
import updateStatus from "@salesforce/apex/CIB_CTRL_DocumentUploader.updateStatus";
import PDFJS from "@salesforce/resourceUrl/PDFJS";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class Cib_comp_documentUploader extends LightningElement {
  uploadIcon = MAU_ThemeOverrides + "/assets/images/uploadIcon.png";
  signatureIcon = MAU_ThemeOverrides + "/assets/images/signatureIcon.svg";
  deleteIcon = MAU_ThemeOverrides + "/assets/images/deleteIcon.svg";
  pdfViewerLibray = PDFJS + "/web/viewer.html";

  @api get applicationId() {
    return this._applicationId;
  }
  set applicationId(value) {
    this._applicationId = value;
  }
  @api get participantId() {
    return this._participantId;
  }
  set participantId(value) {
    this._participantId = value;
  }
  @api get sectionId() {
    return this._sectionId;
  }
  set sectionId(value) {
    this._sectionId = value;
  }
  @api get documentId() {
    return this._documentId;
  }
  set documentId(value) {
    this._documentId = value;
  }
  @api get documentType() {
    return this._documentType;
  }
  set documentType(value) {
    this._documentType = value;
  }

  get filesClass() {
    return this.validationMessage
      ? "slds-file-selector__dropzone errorFile"
      : "slds-file-selector__dropzone ";
  }

  get displayGuidelines() {
    if (
      this.guidelines !== undefined &&
      this.guidelines !== null &&
      this.guidelines !== ""
    ) {
      return this.guidelines.split("\n");
    }

    return [];
  }

  get fileIcon() {
    if (this.fileExtension === "pdf") {
      return MAU_ThemeOverrides + "/assets/images/icn_document_pdf.svg";
    }
    if (this.fileExtension === "png") {
      return MAU_ThemeOverrides + "/assets/images/icn_document_png.svg";
    }
    return MAU_ThemeOverrides + "/assets/images/icn_document_jpg.svg";
  }

  get isPdf() {
    return this.fileExtension === "pdf";
  }

  @api async setParticipantId(participantId) {
    this._participantId = participantId;
    await updateStatus({
      documentId: this._documentId,
      participantId: participantId
    });
  }

  @api reportValidity() {
    this.validationMessage = "";

    if (this.required && !this.fileExists) {
      this.validationMessage = "Please upload a file";
      return false;
    }
    return true;
  }

  @api reset() {
    this.progress = 0;
    this.isUploading = false;
    this.filename = "Click here to upload file";
    this.fileExists = false;
    this._documentId = null;
    this._value = null;
    this.validationMessage = "";
  }

  onDeleteFile(event) {
    event.stopPropagation();
    event.preventDefault();
    this.reset();
  }

  @api isParticipantDocument = false;
  @api required = false;
  @api acceptedFormats = ".pdf,.jpg,.jpeg,.png";
  @api guidelines;
  @api label;

  @track _documentId;
  @track _participantId;
  @track _sectionId;
  @track _applicationId;
  @track _documentType;
  @track _sessionId;
  @track _url;
  @track fileExtension;
  @track progress = 0;
  @track filename = "Click here to upload file";
  @track isUploading = false;
  @track fileExists = false;
  @track validationMessage = "";
  @track isPreviewOpenned = false;
  @track isInitializing = true;

  connectedCallback() {
    if (!this.connected) {
      this.debouncedInitiateDocument();
      this.connected = true;
    }
  }

  debouncedInitiateDocument = this.debounce(
    this.initiateDocument.bind(this),
    150
  );

  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      timeout = setTimeout(later, wait);
    };
  }

  async initiateDocument() {
    this.isInitializing = true;
    try {
      this._sessionId = await getSessionId();
      const document = await getFile({
        recordId: this.isParticipantDocument
          ? this._participantId
          : this._applicationId,
        sectionId: this._sectionId,
        documentType: this._documentType
      });
      if (document != null) {
        this._documentId = document.documentId;
        this._value = document.base64;
        this.filename = document.documentName;
        this.fileExtension = document.documentExtension;
        this.fileExists = true;
      }
    } catch (error) {
      console.info(error);
    }
    this.isInitializing = false;
  }

  onDocumentUploaded() {
    this.dispatchEvent(
      new CustomEvent("documentuploaded", {
        detail: {
          documentId: this._documentId
        }
      })
    );
  }

  handleFileChange(event) {
    const file = event.target.files[0];
    if (file.size > this.maxAllowedSize) {
      event.target.value = null;
      this.validationMessage = "File size should be less than 1MB";
      return;
    }
    this.validationMessage = "";
    this.fileExists = true;
    this.uploadWithProgress(file);
  }

  uploadWithProgress(file) {
    this.progress = 0;
    this.isUploading = true;
    this.filename = file.name;
    this.fileExtension = file.name.split(".").pop();

    const reader = new FileReader();
    reader.onload = (event) => {
      const base64Data = event.target.result.split(",")[1];
      this._value = base64Data;

      const xhr = new XMLHttpRequest();
      xhr.open("POST", "/services/apexrest/CIB_CTRL_DocumentUploader", true);
      xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
      xhr.setRequestHeader("Authorization", "OAuth " + this._sessionId);

      xhr.upload.addEventListener("progress", (progressEvent) => {
        if (progressEvent.lengthComputable) {
          this.progress = Math.round(
            (progressEvent.loaded / progressEvent.total) * 100
          );
        }
      });

      xhr.onreadystatechange = () => {
        if (xhr.readyState === 4 && xhr.status === 200) {
          let responce = JSON.parse(xhr.responseText);
          this._url = responce.documentUrl;
          this._documentId = responce.documentId;
          this.onDocumentUploaded();
          this.isUploading = false;
        }
      };

      xhr.send(
        JSON.stringify({
          input: {
            recordId: this._participantId || this._applicationId,
            sectionId: this._sectionId,
            documentId: this._documentId,
            documentType: this._documentType,
            documentName: file.name,
            base64: base64Data,
            documentExtension: file.name.split(".").pop(),
            documentStatus: this.isParticipantDocument ? "Pending" : "Uploaded"
          }
        })
      );
    };
    reader.readAsDataURL(file);
  }

  get previewURI() {
    return this.pdfViewerLibray + "?file=" + this._url;
  }

  closePreview(event) {
    event.stopPropagation();
    event.preventDefault();
    this.isPreviewOpenned = false;
  }

  openPreview(event) {
    event.stopPropagation();
    event.preventDefault();

    this.isPreviewOpenned = true;
  }

  fileInputClick(event) {
    event.target.value = null;
  }

  maxAllowedSize = 1 * 1024 * 1024; // 1MB
}