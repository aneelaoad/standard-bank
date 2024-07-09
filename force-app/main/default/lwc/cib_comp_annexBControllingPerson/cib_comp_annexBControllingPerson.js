/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 02-07-2024
@ Name of the Class : Cib_comp_baseSectionScreen
@ Description       : This class is used to manage the base section screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 02-07-2024
@ Modification Description : SFP-39692
***************************************************************************************/

import { api, track } from "lwc";
import helpIcon from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class CibCompAnnexBControllingPerson extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  helpIcon = helpIcon + "/assets/images/helpIcon.svg";

  @track options = [];

  get isRequired() {
    return (
      this.applicationRecord.CIB_AB_CRS_NonFinancialEntityType__c ===
      ("Passive non-financial entity. If you have confirmed that the entity is a passive non-financial entity" +
        ", please provide details of the controlling persons by completing section 5 below")
    );
  }

  async connectedCallback() {
    super.connectedCallback();
    this.options = await this.getPicklistValues(
      "Application__c",
      "CIB_AB_CP_ControllingPersonType__c"
    );
  }
}