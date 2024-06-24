import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_applicationLineItemMixin from "c/cib_comp_ApplicationLineItemMixin";

export default class Cib_comp_generalCompanyfinancialinformation extends NavigationMixin(
  Cib_comp_applicationLineItemMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;

  RECORD_TYPE = 'Annual_Turnover';

  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";
  delete_row_icon = MAU_ThemeOverrides + "/assets/images/delete_row_icon.svg";
  helpIcon = MAU_ThemeOverrides + "/assets/images/helpIcon.svg";

  /**
   * @description Method to get All Distinct Input Fields from UI
   */
  getAllElements() {
    const elements = [
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("c-cmn_comp_acpicklist"),
      ...this.template.querySelectorAll("input")
    ];
    return elements;
  }

  get hasIndependentAuditor() {
    return String(this.applicationRecord?.CIB_GCFI_HasIndependentAuditor__c);
  }

  onchange(event) {
    const element = event.target;
    if (element.type === "radio") {
      this.applicationRecord[element.dataset.fieldname] =
        element.value === "true";
    }
  }

  options = [
    { label: "Yes", value: "true" },
    { label: "No", value: "false" }
  ];

  async updateApplicationRecord() {
    await super.updateApplication({
      Id: this.recordId,
      ...[
        ...this.template.querySelectorAll('[data-type="application"]')
      ].reduce((acc, element) => {
        if(element.type === 'radio') {
          acc[element.dataset.fieldname] = element.value === 'true';
        } else {
          acc[element.dataset.fieldname] = element.value;
        }
        return acc;
      }, {})
    });

    return super.updateApplicationRecord();
  }
}