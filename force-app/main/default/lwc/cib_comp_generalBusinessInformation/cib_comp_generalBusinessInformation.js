import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_ApplicationLineItemMixin from "c/cib_comp_ApplicationLineItemMixin";

export default class Cib_comp_generalBusinessInformation extends NavigationMixin(
  Cib_comp_ApplicationLineItemMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;

  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";
  delete_row_icon = MAU_ThemeOverrides + "/assets/images/delete_row_icon.svg";

  RECORD_TYPE = "Nature_Of_Business";

  getAllElements() {
    return [
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("c-cmn_comp_acpicklist")
    ];
  }

  onApplicationLoaded(application) {
    const elements = this.querySelectorAll("[data-type='application']");
    elements.forEach((element) => {
      if (element.dataset.fieldname) {
        element.value = application[element.dataset.fieldname];
      }
    });
  }

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