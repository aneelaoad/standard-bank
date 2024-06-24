/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 12-04-2024
@ Name of the Class : Cib_comp_generateMandatePdf
@ Description       : This class is used to manage the generate mandate pdf screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 12-04-2024
@ Modification Description : SFP-36750
***************************************************************************************/
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-await-in-loop */
import { LightningElement, api, track } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import generatePdf from "@salesforce/apex/CIB_CTRL_AOMandateGeneratePdf.generatePdf";
import generateCertDocumentsPdf from "@salesforce/apex/CIB_CTRL_AOMandateGeneratePdf.generateCertificationDocuments";
import generateMandateAgreement from "@salesforce/apex/CIB_CTRL_AOMandateGeneratePdf.generateMandateAgreement";
import saveCertificationAgreement from "@salesforce/apex/CIB_CTRL_AOMandateGeneratePdf.saveCertificationAgreement";
import getFileBody from "@salesforce/apex/CIB_CTRL_AOMandateGeneratePdf.getFileBody";

import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import { CloseActionScreenEvent } from "lightning/actions";

import PDFJS from "@salesforce/resourceUrl/PDFJS";
import getApplicationParticipants from "@salesforce/apex/CIB_CTRL_ApplicationParticipant.getApplicationParticipants";
import getApplicationRecord from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getApplicationRecord";
import getSessionId from "@salesforce/apex/CIB_CTRL_ApplicationZipFileDownload.getSessionId";
import getApplicationDocuments from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getApplicationDocuments";

export default class Cib_comp_generateMandatePdf extends NavigationMixin(
  LightningElement
) {
  siteURL;
  _recordId;
  pdfViewerLibray = PDFJS + "/web/viewer.html";

  @api set recordId(value) {
    this._recordId = value;
    this.siteURL = "/apex/CIB_ApplicationGeneratePdf?id=" + this._recordId;
  }

  get recordId() {
    return this._recordId;
  }

  get Title() {
    if (this.status === "CONFIRM_SIGNATORY") {
      return "Who is certifying all KYC documents?";
    }
    if (this.status === "CONFIRM_CERTIFICATION_PDF") {
      return (
        "Confirm consolidated documents for Certification by " +
          this.certOfficerNames[this.currentCertDocument] ||
        "Certifying Officer"
      );
    }
    if (this.status === "MANDATE_PDF") {
      return "Confirm Business Account Opening Form.";
    }
    if (this.status === "FINISH") {
      return "Agreements Generated Successfuly.";
    }
    if (this.status === "") {
      return "Loading Business Account Opening Form";
    }
    return "Generate Certification PDF";
  }

  @track loading = true;
  @track isCertifyingOfficer = true;
  @track relatedParties = [];
  @track certiOfficer = {};
  @track isLoading = false;
  @track selectedSignatory;
  @track pdfData;
  @track pdfBlob;
  @track application = {};
  @track certDocuments = [];
  @track currentCertDocument = 0;
  @track agreements = [];
  @track accessToken;
  @track certOfficerNames = [];
  @track participantCertifiers = [];
  @track section;

  get instanceUrl() {
    return window.location.origin.replace("lightning.force", "my.salesforce");
  }

  @track status = "";
  certStampUrl = MAU_ThemeOverrides + "/assets/images/certificationStamp.png";
  certStamp;

  get isNextDisabled() {
    if (this.status === "CONFIRM_SIGNATORY" && !this.isCertifyingOfficer) {
      return this.selectedSignatory === undefined;
    }
    return this.loading === true;
  }
  get pdfURL() {
    return this.pdfData;
  }
  get isMandateScreen() {
    return this.status === "MANDATE_PDF";
  }
  get isCertificationPDF() {
    return this.status === "CONFIRM_CERTIFICATION_PDF";
  }
  get isSignatory() {
    return this.status === "CONFIRM_SIGNATORY";
  }
  get isFinalScreen() {
    return this.status === "FINISH";
  }
  async connectedCallback() {
    try {
      await loadScript(this, MAU_ThemeOverrides + "/assets/js/pdf-lib.min.js");
      const responces = await Promise.all([
        getApplicationParticipants({
          applicationId: this.recordId,
          recordTypeName: null
        }),
        getApplicationRecord({
          applicationId: this.recordId
        }),
        fetch(this.certStampUrl),
        getSessionId(),
        this.generatePdfRecords(),
        getApplicationDocuments({
          applicationId: this.recordId
        })
      ]);
      this.application = responces[1];
      this.certStamp = await responces[2].arrayBuffer();
      this.accessToken = responces[3];
      this.relatedParties = responces[0]
        .filter((e) => {
          return (
            e.RecordType.Name === "Certification Official" ||
            e.IsCertifyingOfficial__c
          );
        })
        .reduce((acc, e) => {
          acc[e.Id] = e;
          return acc;
        }, {});
      this.participantCertifiers = responces[0]
        .filter((e) => {
          return (
            e.RecordType.Name === "Certification Official" ||
            e.IsCertifyingOfficial__c
          );
        })
        .map((e) => {
          return {
            ...e,
            documents: responces[5]
              .filter((document) => document.CertifyingOfficial__c === e.Id)
              .map((doc) => {
                let name = doc.Document_Type__c;
                let iconName = "doctype:attachment";
                if (
                  doc.Application_Participant__r &&
                  doc.Application_Participant__r.Name
                ) {
                  name += " - " + doc.Application_Participant__r.Name;
                } else if (
                  this.application.Client__r &&
                  this.application.Client__r.Name
                ) {
                  name += " - " + this.application.Client__r.Name;
                } else {
                  name += " - Entity Document";
                }
                if (
                  doc.Document_Label__c.includes(".pdf") ||
                  doc.Document_Label__c.includes(".PDF")
                ) {
                  iconName = "doctype:pdf";
                } else if (
                  doc.Document_Label__c.includes(".png") ||
                  doc.Document_Label__c.includes(".PNG") ||
                  doc.Document_Label__c.includes(".jpg") ||
                  doc.Document_Label__c.includes(".JPG")
                ) {
                  iconName = "doctype:image";
                }
                return {
                  Id: doc.Id,
                  iconName,
                  _Name: name
                };
              })
          };
        });
    } catch (error) {
      console.error(error);
    }
    this.loading = false;
  }

  @track mandateFile;
  onloadMandate() {
    setTimeout(() => {
      this.template
        .querySelector(".pdfFrame")
        .contentWindow.postMessage(this.mandateFile, window.location.origin);
    }, 0);
  }
  async generatePdfRecords() {
    try {
      const [mandateFile, base64Cover, base64LastPage] = await Promise.all([
        generatePdf({
          applicationId: this.recordId
        }),
        fetch(MAU_ThemeOverrides + "/assets/pdf/mandate_cover.pdf").then(
          (res) => res.arrayBuffer()
        ),
        fetch(MAU_ThemeOverrides + "/assets/pdf/mandate_lastpage.pdf").then(
          (res) => res.arrayBuffer()
        )
      ]);
      const pdfDoc = await window.PDFLib.PDFDocument.load(mandateFile);
      const coverDoc = await window.PDFLib.PDFDocument.load(base64Cover);
      const lastPageDoc = await window.PDFLib.PDFDocument.load(base64LastPage);

      const [coverPage] = await pdfDoc.copyPages(coverDoc, [0]);
      const [lastPage] = await pdfDoc.copyPages(lastPageDoc, [0]);

      pdfDoc.insertPage(pdfDoc.getPageCount(), coverPage);
      pdfDoc.insertPage(0, lastPage);

      const base64 = await pdfDoc.saveAsBase64({ dataUri: false });
      this.mandateFile = base64;
      this.status = "MANDATE_PDF";
    } catch (error) {
      console.error(error);
      const toastevt = new ShowToastEvent({
        title: "Error",
        message: "Unable to generate mandate!",
        variant: "error"
      });
      this.dispatchEvent(toastevt);
    }
    this.loading = false;
  }

  handleSectionToggle(event) {
    this.section = event.detail.openSections;
  }

  navigateToId(id) {
    const agreementPage = {
      type: "standard__recordPage",
      attributes: {
        recordId: id,
        actionName: "view"
      }
    };
    this[NavigationMixin.Navigate](agreementPage);
  }

  navigateToDocument(event) {
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.target.dataset.id,
        objectApiName: "Application_Document__c",
        actionName: "view"
      }
    }).then((url) => {
      window.open(url, "_blank");
    });
  }

  async stampDocumentPDF(pdfDoc, name, certifier) {
    const opacity = 0.7;
    const _name = certifier.Name;
    const position = certifier.Title__c;
    const address = certifier.CIB_PermanentResidentialAddress__c;
    const telephone = certifier.CIB_MobileNumber__c;

    const pages = pdfDoc.getPages();
    const lastPage = pages[pages.length - 1];
    const { height } = lastPage.getSize();
    const fontSize = 20;
    const text = name;
    await pdfDoc.embedFont(window.PDFLib.StandardFonts.Helvetica);

    lastPage.drawText(text, {
      x: 10,
      y: height - 30,
      size: fontSize,
      opacity: opacity
    });
    const stampImage = await pdfDoc.embedPng(this.certStamp);
    const stampImageAspectRatio = stampImage.width / stampImage.height;
    lastPage.drawImage(stampImage, {
      x: 0,
      y: height - 40 - stampImage.height,
      aspectRatio: stampImageAspectRatio,
      opacity: opacity
    });
    lastPage.drawText(_name, {
      x: 58,
      y: height - 112,
      size: 10,
      color: window.PDFLib.rgb(0, 0, 0),
      opacity: opacity
    });
    lastPage.drawText(position, {
      x: 124,
      y: height - 130,
      size: 10,
      color: window.PDFLib.rgb(0, 0, 0),
      opacity: opacity
    });
    lastPage.drawText(address, {
      x: 68,
      y: height - 148,
      size: 10,
      color: window.PDFLib.rgb(0, 0, 0),
      opacity: opacity
    });
    lastPage.drawText(telephone, {
      x: 40,
      y: height - 166,
      size: 10,
      color: window.PDFLib.rgb(0, 0, 0),
      opacity: opacity
    });
    lastPage.drawText("{{Sig_es_:signer1:date}}", {
      x: 50,
      y: height - 184,
      size: 10,
      color: window.PDFLib.rgb(1, 1, 1),
      opacity: opacity
    });
    lastPage.drawText("{{Sig_es_:signer1:signature}}", {
      x: 76,
      y: height - 202,
      size: 10,
      color: window.PDFLib.rgb(1, 1, 1),
      opacity: opacity
    });
    return pdfDoc;
  }

  async onConfirm() {
    switch (this.status) {
      case "MANDATE_PDF": {
        this.loading = true;
        let documentName = `Business Account Opening Form - ${this.application.Name}`;
        let [agreementId, appDocId] = await generateMandateAgreement({
          applicationId: this.recordId,
          agreementName: documentName
        });
        let contentDocumentId = await this.insertContentVersion(
          this.mandateFile,
          documentName,
          agreementId
        );
        await this.insertContentDocumentLink(contentDocumentId, appDocId);
        this.status = "CONFIRM_SIGNATORY";
        this.loading = false;
        break;
      }
      case "CONFIRM_SIGNATORY": {
        this.loading = true;
        try {
          let responce = await generateCertDocumentsPdf({
            applicationId: this.recordId
          });
          let certDocuments = [];
          for (const key in responce) {
            if (Object.hasOwnProperty.call(responce, key)) {
              const docs = responce[key];
              certDocuments.push(this.generateForSignatory(docs, key));
            }
          }
          this.certDocuments = await Promise.all(certDocuments);
          this.currentCertDocument = 0;
          this.status = "CONFIRM_CERTIFICATION_PDF";
        } catch (error) {
          const toastevt = new ShowToastEvent({
            title: "Error",
            message: "Unable to generate Agreement at this moment!",
            variant: "error"
          });
          this.dispatchEvent(toastevt);
        }
        this.loading = false;
        break;
      }
      case "CONFIRM_CERTIFICATION_PDF": {
        if (
          this.certDocuments.length > 1 &&
          this.currentCertDocument <= this.certDocuments.length - 2
        ) {
          this.loading = true;
          this.pdfBlob = this.certDocuments[this.currentCertDocument + 1];
          this.currentCertDocument++;
          this.onloadPdfViewer();
          this.loading = false;
          return;
        }
        this.loading = true;
        try {
          let promises = [];
          for (let index = 0; index < this.certDocuments.length; index++) {
            const doc = this.certDocuments[index];
            const certifierName =
              this.certOfficerNames[index] || "Certifying Officer";
            const certId = Object.keys(this.relatedParties).find(
              (key) => this.relatedParties[key].Name === certifierName
            );
            promises.push(
              this.saveCertificationAgreement({
                applicationId: this.recordId,
                certificationDocument: doc,
                certId,
                certifierName
              })
            );
          }
          this.agreements = await Promise.all(promises);
          this.status = "FINISH";
        } catch (error) {
          const toastevt = new ShowToastEvent({
            title: "Error",
            message: "Unable to save Certification Agreement!",
            variant: "error"
          });
          this.dispatchEvent(toastevt);
        }
        this.loading = false;
        break;
      }
      case "FINISH": {
        this.dispatchEvent(new CloseActionScreenEvent());
        break;
      }
      default: {
        break;
      }
    }
  }

  async generateForSignatory(documents, certId) {
    let certifier = this.relatedParties[certId];
    this.certOfficerNames.push(certifier.Name);
    let documentPdfs = [];
    let names = [];
    for (let index = 0; index < documents.length; index++) {
      const document = documents[index];
      if (document.type === "application/pdf" || document.type === "pdf") {
        documentPdfs.push(this.createPDFFromBase64(document.documentId));
        names.push(document.participantName + " - " + document.title);
      } else if (
        document.type.startsWith("image/") ||
        ["jpeg", "jpg", "png"].includes(document.type)
      ) {
        documentPdfs.push(
          this.createImagePDF(document.documentId, document.type)
        );
        names.push(document.participantName + " - " + document.title);
      } else {
        console.error("Unsupported document type:", document.type);
      }
    }
    documentPdfs = await Promise.all(documentPdfs);

    const mergedPdf = await window.PDFLib.PDFDocument.create();
    for (let index = 0; index < documentPdfs.length; index++) {
      const doc = await this.stampDocumentPDF(
        documentPdfs[index],
        names[index],
        certifier
      );
      const copiedPages = await mergedPdf.copyPages(doc, doc.getPageIndices());
      for (let pageIndex = 0; pageIndex < copiedPages.length; pageIndex++) {
        mergedPdf.addPage(copiedPages[pageIndex]);
      }
    }
    return mergedPdf.saveAsBase64({ dataUri: false });
  }

  async getFileData(doc) {
    const response = await fetch(doc);
    const data = await response.blob();
    return data;
  }

  arrayBufferToBase64(buffer) {
    let binary = "";
    const bytes = new Uint8Array(buffer);
    const len = bytes.byteLength;
    for (let i = 0; i < len; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return window.btoa(binary);
  }

  async saveCertificationAgreement({
    applicationId,
    certificationDocument,
    certifierName,
    certId
  }) {
    let documentName =
      this.application.Name + " - Certification Agreement - " + certifierName;
    const [agreementId, appDocId] = await saveCertificationAgreement({
      applicationId,
      agreementName: documentName,
      appParticipantId: certId,
      isMainAgreement: false
    });
    let contentDocumentId = await this.insertContentVersion(
      certificationDocument,
      documentName,
      agreementId
    );
    await this.insertContentDocumentLink(contentDocumentId, appDocId);
    return agreementId;
  }

  async insertContentVersion(certificationDocument, documentName, agreementId) {
    const view = this.base64ToUint8Array(certificationDocument);
    const entitydata = {
      ContentLocation: "S",
      Title: documentName,
      PathOnClient: documentName + ".pdf",
      FirstPublishLocationId: agreementId
    };
    const cvInsertResponce = await this.insertMultiPartContentVersion(
      this.gen_multipart(entitydata, view)
    );
    const contentVersions = await fetch(
      this.instanceUrl +
        `/services/data/v58.0/query?q=SELECT+ContentDocumentId+FROM+ContentVersion+WHERE+Id+=+'${cvInsertResponce.id}'`,
      {
        headers: {
          Authorization: `Bearer ${this.accessToken}`,
          "Content-Type": "application/json"
        }
      }
    ).then((res) => res.json());
    const contentVersion = contentVersions.records[0];
    return this.insertContentDocumentLink(contentVersion.ContentDocumentId);
  }

  insertMultiPartContentVersion(multipartForm) {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open(
        "POST",
        this.instanceUrl + "/services/data/v50.0/sobjects/ContentVersion",
        true
      );
      xhr.setRequestHeader("Authorization", "OAuth " + this.accessToken);
      xhr.setRequestHeader(
        "Content-Type",
        "multipart/form-data; boundary=BOUNDARY"
      );
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

  async insertContentDocumentLink(contentDocumentId, applicationId) {
    const endpoint = `/services/data/v58.0/sobjects/ContentDocumentLink`;
    const headers = {
      Authorization: `OAuth ${this.accessToken}`,
      "Content-Type": "application/json"
    };
    const body = {
      ContentDocumentId: contentDocumentId,
      LinkedEntityId: applicationId,
      Visibility: "AllUsers",
      ShareType: "V"
    };
    const options = {
      method: "POST",
      headers,
      body: JSON.stringify(body)
    };
    const response = await fetch(endpoint, options);
    const data = await response.json();
    return data.id;
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

  onCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  onchange() {
    this.isCertifyingOfficer = !this.isCertifyingOfficer;
  }

  handleRowSelection(event) {
    const selectedRows = event.detail.selectedRows;
    this.selectedSignatory = selectedRows[0];
  }

  async createPDFFromBase64(contentDocumentId) {
    const pdf = await getFileBody({
      contentDocumentId
    });
    const pdfDoc = await window.PDFLib.PDFDocument.load(
      `data:application/pdf;base64,${pdf}`,
      {
        ignoreEncryption: true
      }
    );
    return pdfDoc;
  }

  handleOfficerLoad(event) {
    const loadedData = event.detail.records;
    const currentRecord = loadedData[this.recordId];

    let fieldValues = {};

    for (let fieldName in currentRecord.fields) {
      if (currentRecord.fields[fieldName].value) {
        fieldValues[fieldName] = currentRecord.fields[fieldName].value;
      }
    }
    fieldValues = {
      ...fieldValues,
      CIB_RelatedCertOfficer__c: this.application.CIB_RelatedCertOfficer__c
    };
    this.certiOfficer = fieldValues;
  }

  handleOfficerSubmit(event) {
    event.preventDefault();
    this.isLoading = true;
    const fields = event.detail.fields;
    fields.CIB_RelatedCertOfficer__c =
      this.application.CIB_RelatedCertOfficer__c;
    this.template.querySelector("lightning-record-edit-form").submit(fields);
  }

  handleOfficerSuccess() {
    this.isLoading = false;
    const toastevt = new ShowToastEvent({
      title: "Success!",
      message: "Certifying officer updated!",
      variant: "success"
    });
    this.dispatchEvent(toastevt);
  }

  handleOfficerError() {
    this.isLoading = false;
    const toastevt = new ShowToastEvent({
      title: "Error",
      message: "Unable to update Certifying Officer!",
      variant: "error"
    });
    this.dispatchEvent(toastevt);
  }

  async createImagePDF(contentDocumentId, type) {
    const imageBase64 = await getFileBody({
      contentDocumentId
    });
    const imageURI =
      `data:image/${type.includes("png") ? "png" : "jpg"};base64,` +
      imageBase64;
    const imagePdf = await window.PDFLib.PDFDocument.create();

    const page = imagePdf.addPage();
    const { width } = page.getSize();

    let image;
    if (type.includes("png")) {
      image = await imagePdf.embedPng(imageURI);
    } else {
      image = await imagePdf.embedJpg(imageURI);
    }

    const imageAspectRatio = image.width / image.height;
    const imageWidth = width;
    const imageHeight = imageWidth / imageAspectRatio;

    const x = (width - imageWidth) / 2;
    const y = 0;

    page.drawImage(image, {
      x,
      y,
      width: imageWidth,
      height: imageHeight
    });
    return imagePdf;
  }

  onloadPdfViewer() {
    setTimeout(() => {
      this.template
        .querySelector(".pdfFrame")
        .contentWindow.postMessage(
          this.certDocuments[this.currentCertDocument],
          window.location.origin
        );
    }, 0);
  }

  handleRelatedPartyChange(event) {
    this.application.CIB_RelatedCertOfficer__c = event.detail.value;
  }

  handleIsRelatedPartyTypeChange(event) {
    this.certiOfficer.CIB_IsCertOfficialRelatedParty__c = event.detail.checked;
  }
}