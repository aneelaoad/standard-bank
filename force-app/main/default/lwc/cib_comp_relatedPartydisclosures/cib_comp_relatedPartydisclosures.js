import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

import helpIcon from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import info_imp from "@salesforce/resourceUrl/MAU_ThemeOverrides";

import checkboxicon from "@salesforce/resourceUrl/MAU_ThemeOverrides";

import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_relatedPartydisclosures extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  info_imp = info_imp + "/assets/images/info_imp.svg";
  checkboxicon = checkboxicon + "/assets/images/checkboxicon.svg";
  helpIcon = helpIcon + "/assets/images/infoIcon.svg";

  onchange(event) {
    if (event.target.type === "checkbox") {
      this.applicationRecord[event.target.dataset.fieldname] =
        event.target.checked;
    } else {
      this.applicationRecord[event.target.dataset.fieldname] =
        event.target.value;
    }
  }
}