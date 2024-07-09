/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 02-07-2024
@ Name of the Class : CibCompFinancialInstitutionStatus
@ Description       : This class is used to manage the base section screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 02-07-2024
@ Modification Description : SFP-39692
***************************************************************************************/
import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class CibCompFinancialInstitutionStatus extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api sectionId;
  @api recordId;

  onApplicationLoaded(application) {
    const elements = this.getAllElements();
    elements.forEach((element) => {
      const fieldname = element.dataset.fieldname;
      if (element.type === "radio") {
        element.value = String(application[fieldname]);
      } else {
        element.value = application[fieldname];
      }
    });
  }

  options = [
    { label: "Yes", value: "true" },
    { label: "No", value: "false" }
  ];

  get ssRegulatedFinancialInstitution() {
    return this.applicationRecord.CIB_FIS_IsRegulatedFinancialInstitution__c;
  }

  onchange(event) {
    const fieldname = event.target.dataset.fieldname;
    if (event.target.type === "radio") {
      this.applicationRecord[fieldname] = event.target.value === "true";
    } else {
      this.applicationRecord[fieldname] = event.target.value;
    }
  }

  /**
   * @description Method to get All Distinct Input Fields from UI
   */
  getAllElements() {
    const elements = [
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("c-cmn_comp_acpicklist"),
      ...this.template.querySelectorAll("lightning-radio-group")
    ];
    return elements;
  }

  collectValues() {
    return this.getAllElements().reduce((values, element) => {
      if (element.type === "radio") {
        values[element.dataset.fieldname] = element.value === "true";
      } else {
        values[element.dataset.fieldname] = element.value;
      }
      return values;
    }, {});
  }

  /**
   * @description  Function to get percentage
   */
  getCompetionPercentage() {
    const elements = this.getAllElements();
    const totalFields = elements.length;
    const validFields = elements.reduce((validCount, element) => {
      if (
        (element.checkValidity && element.checkValidity()) ||
        element.value !== null ||
        element.value !== undefined ||
        element.value !== ""
      ) {
        return validCount + 1;
      }
      return validCount;
    }, 0);
    return (validFields / totalFields) * 100;
  }

  validateForm() {
    return this.getAllElements().reduce((isValid, element) => {
      if (isValid && element.reportValidity) {
        return element.reportValidity();
      } else if (isValid && element.value) {
        return true;
      }
      return isValid;
    }, true);
  }
}