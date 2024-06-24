import getContainerDocuments from "@salesforce/apex/CIB_CTRL_DocumentContainer.getContainerDocuments";
import { LightningElement, api, track } from "lwc";

export default class Cib_comp_documentsContainer extends LightningElement {
  @api applicationId;
  @api sectionId;
  @api isParticipant = false;

  @track documents = [];
  @track isLoading = true;
  @track isInitiated = false;
  @track _participantId;

  @api get participantId() {
    return this._participantId;
  }
  set participantId(value) {
    this._participantId = value;
  }

  @api reportValidity() {
    const items =
      [...this.template.querySelectorAll("c-cib_comp_document-uploader")] || [];

    return items.reduce((acc, item) => {
      return acc && item.reportValidity();
    }, true);
  }

  @api async setParticipantId(id) {
    const items =
      [...this.template.querySelectorAll("c-cib_comp_document-uploader")] || [];

    await Promise.all(items.map((item) => item.setParticipantId(id)));
  }

  async connectedCallback() {
    if (this.applicationId && this.sectionId) {
      this.debouncedFetchDocuments();
    }
  }

  async fetchDocuments() {
    try {
      const responce = await getContainerDocuments({
        applicationId: this.applicationId,
        sectionId: this.sectionId,
        isParticipant: this.isParticipant
      });
      this.documents = responce;
    } catch (error) {
      console.info(error);
    }
    this.isLoading = false;
  }

  debouncedFetchDocuments = this.debounce(this.fetchDocuments.bind(this), 1000);

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
}