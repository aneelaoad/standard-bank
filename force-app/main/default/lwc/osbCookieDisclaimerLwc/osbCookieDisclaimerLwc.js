import { LightningElement, api } from "lwc";
import privacyPol from "@salesforce/label/c.OSB_Privacy_Policy_URL";
import { addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbCookieDisclaimerLwc extends LightningElement {
  @api privacypolicy = privacyPol;
  @api context;

  renderedCallback() {
    addAnalyticsInteractions(this.template);
    let context = this.context;
    if (
      context === "OPTL" &&
      document.cookie.replace(
        /(?:(?:^|.*;\s*)firstTimeUser\s*\=\s*([^;]*).*$)|^.*$/,
        "$1"
      ) === "true"
    ) {
      let cmpTarget = this.template.querySelector('[data-id="header-cookie--container"]');
      cmpTarget.classList.remove("header-cookie--open");
      cmpTarget.classList.remove("header_mainSec");
      cmpTarget.classList.add("header-cookie--closed");
      cmpTarget.classList.add("header_cookie-disclaimer--close");
    }
  }

  closeDisclaimer() {
    let context = this.context;
    if (context === "OPTL") {
      document.cookie =
        "firstTimeUser=true; expires=Fri, 31 Dec 9999 23:59:59 GMT; false; SameSite=None;Secure";
    } else {
      document.cookie =
        "firstTimeUserMP=true; expires=Fri, 31 Dec 9999 23:59:59 GMT; false; SameSite=None;Secure";
    }
    let cmpTarget = this.template.querySelector('[data-id="header-cookie--container"]');
    cmpTarget.classList.remove("header-cookie--open");
    cmpTarget.classList.remove("header_mainSec");
    cmpTarget.classList.add("header-cookie--closed");
    cmpTarget.classList.add("header_cookie-disclaimer--close");
  }
}