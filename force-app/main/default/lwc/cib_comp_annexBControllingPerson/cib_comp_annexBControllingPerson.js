import { api, track } from "lwc";
import helpIcon from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_annexBControllingPerson extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  helpIcon = helpIcon + "/assets/images/helpIcon.svg";

  @track options = [];

  async connectedCallback() {
    super.connectedCallback();
    this.options = await this.getPicklistValues(
      "Application__c",
      "CIB_AB_CP_ControllingPersonType__c"
    );
  }
}