import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class Cib_comp_controllingPersonDeclarationUndertakings extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  checkboxicon = MAU_ThemeOverrides + "/assets/images/checkboxicon.svg";

  onchange(event) {
    if (event.target.type === "checkbox") {
      this.applicationRecord[event.target.dataset.fieldname] =
        event.target.checked;
    }
  }
}