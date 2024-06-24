import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class Cib_comp_generalTermsConditions extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";

  get options() {
    return [
      {
        label: "Accept terms & conditions",
        value: "true"
      }
    ];
  } 

  get termsAndConditionsValue() {
    return String(this.applicationRecord.CIB_TC_AcceptedTermsConditions__c);
  }

  collectValues() {
    return {
      CIB_TC_AcceptedTermsConditions__c: this.template.querySelector(
        "[data-id='Accepttermsconditions']"
      ).value === 'true',
      CIB_TC_AcceptedTermsConditionsDateTime__c: new Date()
        .toISOString()
        .split("T")[0]
    };
  }
}