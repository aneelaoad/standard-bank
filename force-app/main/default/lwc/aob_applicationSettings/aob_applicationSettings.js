import { LightningElement, api } from "lwc";
import ApplicationSettings from "@salesforce/apex/AOB_CTRL_ApplicationSettings.getApplicationSettings";

export default class aob_applicationSettings extends LightningElement {
  @api result=[];
  @api records = "records";
  @api teams =[];
  metadataRecords() {
    ApplicationSettings({teams:this.teams})
      .then((data) => {
        this.result = data;
        this.dispatchEvent(
          new CustomEvent(this.records, { detail: this.result })
        );
      })
      .catch((error) => {
      });
  }

  connectedCallback() {
    this.metadataRecords();
  }
}