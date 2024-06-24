import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import info_imp from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_annexDeclaration extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  info_imp = info_imp + "/assets/images/info_imp.svg";
  
  RECORD_TYPE = 'Applicant';
}