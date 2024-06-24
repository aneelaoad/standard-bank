import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAUThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class Cib_comp_surveyModal extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api sectionId;
  @api isOpenned;
  @api invitationLink;
  static renderMode = "light";
  closeIcon = MAUThemeOverrides + "/assets/images/icn_close_standard.svg";

  afterSurvey() {
    this.dispatchEvent(
      new CustomEvent("confirm", {
        detail: true
      })
    );
  }

  onSurveyClosed() {
    this.dispatchEvent(
      new CustomEvent("close", {
        detail: this.isOpenned
      })
    );
  }
}