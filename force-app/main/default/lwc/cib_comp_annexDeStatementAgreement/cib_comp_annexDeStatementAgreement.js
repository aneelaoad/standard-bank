import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_ApplicationParticipantMixin from "c/cib_comp_ApplicationParticipantMixin";

export default class Cib_comp_annexDeStatementAgreement extends NavigationMixin(
  Cib_comp_ApplicationParticipantMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;

  delete_row_icon = MAU_ThemeOverrides + "/assets/images/delete_row_icon.svg";
  checkboxicon = MAU_ThemeOverrides + "/assets/images/checkboxicon.svg";
  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";

  get CIB_AD_IsNewSubscription__c() {
    return this.participants[0].CIB_AD_IsNewSubscription__c;
  }

  RECORD_TYPE = "Internet_banking_credential";

  async updateApplicationRecord() {
    await super.updateApplication({
      Id: this.recordId,
      ...[
        ...this.template.querySelectorAll('[data-type="application"]')
      ].reduce((acc, element) => {
        acc[element.dataset.fieldname] = element.value;
        return acc;
      }, {})
    });

    return super.updateApplicationRecord();
  }
}