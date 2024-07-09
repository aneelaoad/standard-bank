/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 02-07-2024
@ Name of the Class : Cib_comp_baseSectionScreen
@ Description       : This class is used to manage the base section screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 02-07-2024
@ Modification Description : SFP-39692
***************************************************************************************/
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

  get isRequired1() {
    return (
      !this.applicationRecord.CIB_AB_CRS_GIINNoProvidedType__c &&
      !this.applicationRecord.CIB_AB_CRS_NonFinancialEntityType__c
    );
  }

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

  handleGIINNoProvidedTypeChange(event) {
    if (
      event.target.value !==
      this.applicationRecord.CIB_AB_CRS_GIINNoProvidedType__c
    ) {
      this.applicationRecord.CIB_AB_CRS_GIINNoProvidedType__c =
        event.target.value;
      this.applicationRecord.CIB_AB_CRS_NonFinancialEntityType__c = "";
    } else {
      this.applicationRecord.CIB_AB_CRS_GIINNoProvidedType__c = "";
    }
  }

  handleNonFinancialEntityTypeChange(event) {
    if (
      event.target.value !==
      this.applicationRecord.CIB_AB_CRS_NonFinancialEntityType__c
    ) {
      this.applicationRecord.CIB_AB_CRS_NonFinancialEntityType__c =
        event.target.value;
      this.applicationRecord.CIB_AB_CRS_GIINNoProvidedType__c = "";
    } else {
      this.applicationRecord.CIB_AB_CRS_NonFinancialEntityType__c = "";
    }
  }

  @track options = [];
  @track options1 = [];
}