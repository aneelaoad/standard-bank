import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_ApplicationParticipantMixin from "c/cib_comp_ApplicationParticipantMixin";

export default class Cib_comp_companyDeclaration extends NavigationMixin(
  Cib_comp_ApplicationParticipantMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;

  checkboxicon = MAU_ThemeOverrides + "/assets/images/checkboxicon.svg";
  delete_row_icon = MAU_ThemeOverrides + "/assets/images/delete_row_icon.svg";

  RECORD_TYPE = 'Applicant';
}