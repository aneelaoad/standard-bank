import { LightningElement, track, api } from "lwc";
import RESOURCE_BASE_PATH from "@salesforce/resourceUrl/ACM_Assets";


export default class ClientCredentialsComponent extends LightningElement {
  @api clientId = '';
  @api clientSecret = '';
  @api  modalClientSecret = null;
  @track maskedSecret = "••••••••••••••••••••••••••";
  @track showCopyIconClientId = true;
  @track showCopyText = false;
  @track showSuccessIconClientId = false;
  @track showCopyIconSecret = true;

  @track isModalOpen = false;
  @track isDoneModalOpen = false;

  get close() {
    return RESOURCE_BASE_PATH + "/close.png ";
  }

  copyClientId() {
    this.copyToClipboard(this.clientId);
    this.showCopyIconClientId = true;
    this.showCopyText = true;
    this.removeCopiedText();
  }

  copyClientSecret() {
    this.copyToClipboard(this.clientSecret);
    this.showCopyIconClientId = true;
    this.showCopyText = true;
    this.removeCopiedText();
    if(this.isDoneModalOpen){
      this.copyToClipboard(this.modalClientSecret);
      this.closeModal();
    }
  }

  removeCopiedText() {
    setTimeout(() => {
      this.showCopyText = false;
    }, 2500);
  }

  copyToClipboard(value) {
    const textArea = document.createElement("textarea");
    textArea.value = value;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand("copy");
    document.body.removeChild(textArea);
  }

  openConfirmationModal() {
    this.isModalOpen = true;
  }

  openDoneModal() {
    this.isDoneModalOpen = true;
  }

  closeModal() {
    this.isModalOpen = false;
    this.isDoneModalOpen = false;
  }

  max_random_number(max) {
  return Math.floor(Math.random() * max);
  }

  resetSecret() {
    let randomstring = this.max_random_number(Number.MAX_SAFE_INTEGER).toString(16) +this.max_random_number(Number.MAX_SAFE_INTEGER).toString(16);
    this.clientId = randomstring;
    this.isModalOpen = false;
    const resetClientCredentialEvent = new CustomEvent('updateclientcredentials', {});
    this.dispatchEvent(resetClientCredentialEvent);
    this.openDoneModal();
  }
}