import { LightningElement, api } from "lwc";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class Cmn_comp_reviewComment extends LightningElement {
  @api section = {};
  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";

  get reviewerComment() {
    return this.section.Comment__c;
  }

  get hasReviewComment() {
    return !!this.section?.Comment__c;
  }
}