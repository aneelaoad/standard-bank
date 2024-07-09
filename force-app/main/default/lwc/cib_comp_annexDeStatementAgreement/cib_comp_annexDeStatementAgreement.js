/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 02-07-2024
@ Name of the Class : CibCompAnnexDeStatementAgreement
@ Description       : This class is used to manage the base section screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 02-07-2024
@ Modification Description : SFP-39692
***************************************************************************************/
import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_ApplicationParticipantMixin from "c/cib_comp_ApplicationParticipantMixin";

export default class CibCompAnnexDeStatementAgreement extends NavigationMixin(
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
        console.log('element.dataset.fieldname', JSON.stringify(element.dataset.fieldname,null,2))
        console.log('element.value', JSON.stringify(element.value,null,2))
        return acc;
      }, {})
    });

    return super.updateApplicationRecord();
  }
}