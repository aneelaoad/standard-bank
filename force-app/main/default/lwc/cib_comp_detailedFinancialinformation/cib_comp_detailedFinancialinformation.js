import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_detailedFinancialinformation extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;
  @track options = [];

  async connectedCallback() {
    super.connectedCallback();
    this.options = await this.getPicklistValues(
      "Application__c",
      "CIB_DFI_ExpectedIncomeType__c"
    );
  }
}