import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_annexBCRSClassification extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  @track info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";
  @track checkboxicon = MAU_ThemeOverrides + "/assets/images/checkboxicon.svg";

  async connectedCallback() {
    super.connectedCallback();

    const result = await Promise.all([
      this.getPicklistValues(
        "Application__c",
        "CIB_AB_CRS_GIINNoProvidedType__c"
      ),
      this.getPicklistValues(
        "Application__c",
        "CIB_AB_CRS_NonFinancialEntityType__c"
      )
    ]);

    this.options = result[0];
    this.options1 = result[1];
  }

  @track options = [];
  @track options1 = [];
}