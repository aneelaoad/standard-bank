import { LightningElement, api } from "lwc";
import SBDS_3_0 from "@salesforce/resourceUrl/SBDS_3_0_100";
import { loadStyle } from "lightning/platformResourceLoader";
/**
 * @slot header Slot for the header
 * @slot footer Slot for the footer
 * @slot default Slot for our content
 */

export default class SbdsLwrThemeLayout extends LightningElement {
  @api uiLibraryVersion;
  cacheBangVersion = "81";
  cacheBang = `?v=0.${this.cacheBangVersion}`;

  connectedCallback() {
    switch (this.uiLibraryVersion) {
      case "3.0":
        Promise.all([
          loadStyle(this, SBDS_3_0 + `/Styles/dist/style.css${this.cacheBang}`)
        ])
          .then(() => {})
          .catch(() => {});
    }
    this.template.host.setAttribute(`data-sbds-ui-v`, this.uiLibraryVersion);
  }
}