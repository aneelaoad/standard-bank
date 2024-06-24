/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 12-04-2024
@ Name of the Class : Cib_comp_incorporation
@ Description       : This class is used to manage the incorporation screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 12-04-2024
@ Modification Description : SFP-36750
***************************************************************************************/
import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import info_imp from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
export default class Cib_comp_incorporation extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  info_imp = info_imp + "/assets/images/info_imp.svg";

  options = [
    { label: "Yes", value: true },
    { label: "No", value: false }
  ];

  onchange(event) {
    this.applicationRecord = {
      ...this.applicationRecord,
      [event.target.dataset.fieldname]: event.target.value === "true"
    };
  }

  collectValues() {
    const result = super.collectValues();
    result.CIB_PR_HasPreviousRegistration__c =
      this.applicationRecord.CIB_PR_HasPreviousRegistration__c;
    return result;
  }
}