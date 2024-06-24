import { api } from "lwc";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_ApplicationParticipantMixin from "c/cib_comp_ApplicationParticipantMixin";

export default class Cib_comp_annexControlPersonDetail extends NavigationMixin(
  Cib_comp_ApplicationParticipantMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;

  helpicon = MAU_ThemeOverrides + "/assets/images/helpIcon.svg";
  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";

  RECORD_TYPE = "Controlling_person";
}