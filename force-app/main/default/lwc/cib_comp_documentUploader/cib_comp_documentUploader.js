/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 02-07-2024
@ Name of the Class : CibCompDocumentUploader
@ Description       : This class is used to manage the base section screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 02-07-2024
@ Modification Description : SFP-39692
***************************************************************************************/
import { LightningElement, api, track } from "lwc";

import getFile from "@salesforce/apex/CIB_CTRL_DocumentUploader.getFile";
import getSessionId from "@salesforce/apex/CIB_CTRL_DocumentUploader.getSessionId";
import updateStatus from "@salesforce/apex/CIB_CTRL_DocumentUploader.updateStatus";
import PDFJS from "@salesforce/resourceUrl/PDFJS";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class CibCompDocumentUploader extends LightningElement {
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

  get instanceUrl() {
    return window.location.origin
      .replace("lightning.force", "my.salesforce")
      .replace("sandbox.preview.salesforce-experience", "my.salesforce");
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

  async handleFileChange(event) {
    const file = event.target.files[0];
    if (file.size > this.maxAllowedSize) {
      event.target.value = null;
      this.validationMessage = "File size should be less than 8MB";
      return;
    }
    if (
      this.acceptedFormats &&
      !this.acceptedFormats.includes(file.name.split(".").pop())
    ) {
      event.target.value = null;
      this.validationMessage = "File format not supported";
      return;
    }
    this.validationMessage = "";
    this.fileExists = true;
    this.isUploading = true;

    const view = this.base64ToUint8Array(await this.fileToBase64(file));
    const entitydata = {
      ContentLocation: "S",
      Title: file.name,
      PathOnClient: file.name
    };
    const cvInsertResponce = await this.insertMultiPartContentVersion(
      this.gen_multipart(entitydata, view)
    );
    const contentVersions = await fetch(
      this.instanceUrl +
        `/services/data/v58.0/query?q=SELECT+ContentDocumentId+FROM+ContentVersion+WHERE+Id+=+'${cvInsertResponce.id}'`,
      {
        headers: {
          Authorization: `Bearer ${this._sessionId}`,
          "Content-Type": "application/json"
        }
      }
    ).then((res) => res.json());

    let contentDocumentId = contentVersions.records[0].ContentDocumentId;

    this.uploadWithProgress(file, contentDocumentId);
  }

  async fileToBase64(file) {
    return new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const base64Data = event.target.result.split(",")[1];
        resolve(base64Data);
      };
      reader.readAsDataURL(file);
    });
  }

  uploadWithProgress(file, contentDocumentId) {
    this.progress = 0;
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
            contentDocumentId: contentDocumentId,
            documentExtension: file.name.split(".").pop(),
            documentStatus: this.isParticipantDocument ? "Pending" : "Uploaded"
          }
        })
      );
    };
    reader.readAsDataURL(file);
  }

  insertMultiPartContentVersion(multipartForm) {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open(
        "POST",
        this.instanceUrl + "/services/data/v50.0/sobjects/ContentVersion",
        true
      );
      xhr.setRequestHeader("Authorization", "OAuth " + this._sessionId);
      xhr.setRequestHeader(
        "Content-Type",
        "multipart/form-data; boundary=BOUNDARY"
      );
      xhr.upload.addEventListener("progress", (progressEvent) => {
        if (progressEvent.lengthComputable) {
          this.progress = Math.round(
            (progressEvent.loaded / progressEvent.total) * 100
          );
        }
      });
      xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
          if (xhr.status === 201) {
            resolve(JSON.parse(xhr.responseText));
          } else {
            console.error("Error creating ContentVersion");
            reject(JSON.parse(xhr.responseText));
          }
        }
      };
      xhr.send(multipartForm);
    });
  }

  gen_multipart(entitydata, file) {
    file = new Uint8Array(file);

    let before = [
      "--BOUNDARY",
      'Content-Disposition: form-data; name="entity_content"',
      "Content-Type: application/json",
      "",
      JSON.stringify(entitydata),
      "",
      "--BOUNDARY",
      "Content-Type: application/octet-stream",
      'Content-Disposition: form-data; name="VersionData"; filename="' +
        entitydata.PathOnClient +
        '"',
      "",
      ""
    ].join("\n");
    let after = "\n--BOUNDARY--";
    let size = before.length + file.byteLength + after.length;
    let uint8array = new Uint8Array(size);
    let i = 0;

    for (; i < before.length; i++) {
      uint8array[i] = before.charCodeAt(i) & 0xff;
    }
    for (let j = 0; j < file.byteLength; i++, j++) {
      uint8array[i] = file[j];
    }
    for (let j = 0; j < after.length; i++, j++) {
      uint8array[i] = after.charCodeAt(j) & 0xff;
    }
    return uint8array.buffer;
  }

  base64ToUint8Array(base64) {
    const binary = window.atob(base64);
    const len = binary.length;
    const buffer = new ArrayBuffer(len);
    const view = new Uint8Array(buffer);
    for (let i = 0; i < len; i++) {
      view[i] = binary.charCodeAt(i);
    }
    return view;
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

  maxAllowedSize = 8 * 1024 * 1024; // 8MB
}