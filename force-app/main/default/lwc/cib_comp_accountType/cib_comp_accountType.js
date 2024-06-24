import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_accountType extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  helpIcon = MAU_ThemeOverrides + "/assets/images/helpIcon.svg";
  checkboxicon = MAU_ThemeOverrides + "/assets/images/checkboxicon.svg";

  onchange(event) {
    if (event.target.type === "checkbox") {
      this.applicationRecord[event.target.dataset.fieldname] =
        event.target.checked;
    } else {
      this.applicationRecord[event.target.dataset.fieldname] =
        event.target.value;
    }
    this.applicationRecord = { ...this.applicationRecord };
  }

  validateRecord() {
    const result = super.validateRecord();
    if (
      !this.applicationRecord.CIB_AT_IsCurrentAccountPlus__c &&
      this.applicationRecord.CIB_AT_CurrentAccountPlusCurrencies__c
    ) {
      this.handlerError("Please select atleast one of the account types");
      return result * false;
    }
    return result;
  }
}