import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_additionalCompanyInformation extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";

  @api recordId;
  @api sectionId;

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

  tradingOptions = [
    { label: "Same as registered business name", value: "true" },
    { label: "Other", value: "false" }
  ];

  stockExchangeOptions = [
    { label: "Yes", value: "true" },
    { label: "No", value: "false" }
  ];

  get showTradingNameInput() {
    return !this.applicationRecord.CIB_ACI_IsTradingWithRegisteredName__c;
  }
  get showStockExchangeInput() {
    return this.applicationRecord.CIB_ACI_HasStockExchangeListing__c;
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
      ...this.template.querySelectorAll("lightning-radio-group"),
      ...this.template.querySelectorAll("c-cmn_comp_acpicklist"),
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("input")
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
      if (isValid && element.checkValidity) {
        return element.checkValidity();
      } else if (isValid && element.value) {
        return true;
      }
      return isValid;
    }, true);
  }
}