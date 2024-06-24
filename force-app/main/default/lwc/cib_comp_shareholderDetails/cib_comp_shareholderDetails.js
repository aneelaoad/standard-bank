import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import helpIcon from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import delete_row_icon from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import info_imp from "@salesforce/resourceUrl/MAU_ThemeOverrides";

import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_ApplicationParticipantMixin from "c/cib_comp_ApplicationParticipantMixin";

export default class Cib_comp_shareholderDetails extends NavigationMixin(
  Cib_comp_ApplicationParticipantMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;

  helpIcon = helpIcon + "/assets/images/helpIcon.svg";
  info_imp = info_imp + "/assets/images/info_imp.svg";
  delete_row_icon = delete_row_icon + "/assets/images/delete_row_icon.svg";

  RECORD_TYPE = "Immediate_Shareholder";
}