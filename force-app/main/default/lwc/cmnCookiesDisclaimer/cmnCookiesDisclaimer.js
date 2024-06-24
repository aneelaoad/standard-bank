import { LightningElement, api } from 'lwc';
import ASSETS_URL from '@salesforce/resourceUrl/CMN_Assets'

const ICON_CLOSE = '/Icons/close.png';

export default class CmnCookiesDisclaimer extends LightningElement {
  @api privacyPolicyLink;
  @api privacyPolicyLinkLabel;
  @api privacyPolicyText;

  showDisclaimer = true;
  closeIconUrl = ASSETS_URL + ICON_CLOSE;

  connectedCallback() {
    if (document.cookie.replace(/(?:(?:^|.*;\s*)firstTimeUser\s*\=\s*([^;]*).*$)|^.*$/, "$1") === "true") {
      this.hideDisclaimer();
    }
  }

  handleCloseButtonClick() {
    document.cookie = "firstTimeUser=true; expires=Fri, 31 Dec 9999 23:59:59 GMT; false; SameSite=None;Secure";
    this.hideDisclaimer();
  }
  
  hideDisclaimer() {
    this.showDisclaimer = false;
  }
}