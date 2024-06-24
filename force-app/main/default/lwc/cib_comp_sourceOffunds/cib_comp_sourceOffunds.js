import { track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_sourceOffunds extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;
  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";
  checkboxicon = MAU_ThemeOverrides + "/assets/images/checkboxicon.svg";

  @track fundsOptions = [];
  @track wealthOptions = [];

  async connectedCallback() {
    super.connectedCallback();
    try {
      this.fundsOptions = await this.getPicklistValues(
        "Application__c",
        "CIB_SOF_ExpectedInitialFundsSource__c"
      );
      this.wealthOptions = await this.getPicklistValues(
        "Application__c",
        "CIB_SOF_ExpectedInitialWealthSource__c"
      );
    } catch (error) {
      this.handleError(error);
    }
  }

  get CIB_SOF_ExpectedInitialFundsSource__c() {
    return this.applicationRecord?.CIB_SOF_ExpectedInitialFundsSource__c || "";
  }

  get CIB_SOF_ExpectedInitialWealthSource__c() {
    return this.applicationRecord?.CIB_SOF_ExpectedInitialWealthSource__c || "";
  }

  get isOtherInitialFund() {
    return (
      this.applicationRecord.CIB_SOF_ExpectedInitialFundsSource__c || ""
    ).includes("Other");
  }

  get isOtherInitialWealth() {
    return (
      this.applicationRecord.CIB_SOF_ExpectedInitialWealthSource__c || ""
    ).includes("Other");
  }

  onchange(event) {
    this.applicationRecord = {
      ...this.applicationRecord,
      [event.target.name]: event.target.value
    };
  }
}