import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_notesFATCACRSClassificationStatus extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";
}