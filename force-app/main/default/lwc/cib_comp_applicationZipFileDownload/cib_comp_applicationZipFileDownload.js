import { LightningElement, track, api } from "lwc";
import getfileIds from "@salesforce/apex/CIB_CTRL_ApplicationZipFileDownload.getfileIds";
import getSessionId from "@salesforce/apex/CIB_CTRL_ApplicationZipFileDownload.getSessionId";
import getApplicationRecord from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getApplicationRecord";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import { loadScript } from "lightning/platformResourceLoader";

export default class Cib_comp_applicationZipFileDownload extends LightningElement {
  @api get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;
    getApplicationRecord({ applicationId: value }).then((result) => {
      this.record = result;
    });
  }

  @track _recordId;
  @track record;
  @track fileIds = "";
  @track error = "";
  @track showSpinner = true;
  @track state = "initial";
  @track type = "";

  get instanceUrl() {
    return window.location.origin.replace("lightning.force", "my.salesforce");
  }

  async connectedCallback() {
    this.state = "initial";
    this.showSpinner = false;
    try {
      const result = await getSessionId();
      this.sessionId = result;
      this.error = undefined;
      await loadScript(this, MAU_ThemeOverrides + "/assets/js/jszip.min.js");
    } catch (error) {
      console.info("Unable to load JSZIP");
    }
  }

  get isInitial() {
    return this.state === "initial";
  }

  get isZipFiles() {
    return this.state === "ZipFiles";
  }

  get isFinal() {
    return this.state === "final";
  }

  options = [
    { label: "Application Participant", value: "participantName" },
    { label: "Application Section", value: "sectionName" }
  ];

  handleChange(event) {
    this.type = event.detail.value;
    this.state = "ZipFiles";
    this.getFieldMethod();
  }

  async getFieldMethod() {
    this.showSpinner = true;
    try {
      let result = await getfileIds({
        recordId: this.recordId
      });
      result = await this.generateZip(result);
      this.state = "final";
      this.downlaodZip(result);
    } catch (error) {
      console.error(error);
      const event = new ShowToastEvent({
        title: "Error",
        message: error.body.message,
        variant: "error"
      });
      this.dispatchEvent(event);
    }
    this.showSpinner = false;
  }

  async generateZip(data) {
    let folders = {};
    const promises = [];
    for (let idx = 0; idx < data.length; idx++) {
      const document = data[idx];
      if (!document.documentId) {
        continue;
      }
      const folderName =
        this.type === "participantName"
          ? document.participantName || "Entity Documents"
          : document.sectionName || "Other Documents";
      if (!folders[folderName]) {
        folders[folderName] = [];
      }
      const promise = fetch(
        this.instanceUrl +
          "/services/data/v59.0/sobjects/ContentVersion/" +
          document.documentId +
          "/VersionData",
        {
          method: "GET",
          headers: {
            Authorization: "OAuth " + this.sessionId
          }
        }
      )
        .then((response) => response.blob())
        .then((body) => {
          let name;
          if (this.type === "sectionName") {
            let [prefix, suffix] = document.documentType.split(".");
            name =
              prefix +
              " - " +
              (document.participantName || "Entity Document") +
              "." +
              suffix;
          } else {
            name = document.documentType;
          }
          folders[folderName].push({
            name,
            body: body
          });
        });
      promises.push(promise);
    }
    await Promise.all(promises);

    const zip = new window.JSZip();

    for (const folderName in folders) {
      if (folders[folderName]) {
        const folder = zip.folder(folderName);
        for (const file of folders[folderName]) {
          folder.file(file.name.replaceAll("/", "-"), file.body);
        }
      }
    }

    const zipBlob = await zip.generateAsync({ type: "blob" });

    return zipBlob;
  }

  downlaodZip(zipBlob) {
    const downloadLink = URL.createObjectURL(zipBlob);
    const downloadAnchor = document.createElement("a");
    downloadAnchor.href = downloadLink;
    downloadAnchor.download = `${this.record.Name} - ${
      this.record.CIB_BAI_CompanyRegisteredName__c
    } - ${new Date().toUTCString()}.zip`;
    downloadAnchor.click();
  }

  closemodal() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}