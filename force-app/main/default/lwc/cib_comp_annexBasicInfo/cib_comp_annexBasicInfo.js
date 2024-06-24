import { api } from "lwc";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_annexBasicInfo extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  infoIcon = MAU_ThemeOverrides + "/assets/images/infoIcon.svg";
  helpIcon = MAU_ThemeOverrides + "/assets/images/helpIcon.svg";
  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";

  get ListedEntityOrMajorOwnedSubsidiary() {
    if (this.applicationRecord.CIB_AA_BI_IsListedEntity__c) {
      return "CIB_AA_BI_IsListedEntity__c";
    }
    if (this.applicationRecord.CIB_AA_BI_IsMajorOwnedSubsidiary__c) {
      return "CIB_AA_BI_IsMajorOwnedSubsidiary__c";
    }
    return "";
  }

  options = [
    {
      label: "Listed Entity",
      value: "CIB_AA_BI_IsListedEntity__c"
    },
    {
      label: "Major Owned Subsidiary",
      value: "CIB_AA_BI_IsMajorOwnedSubsidiary__c"
    }
  ];

  onchange(event) {
    this.applicationRecord = {
      ...this.applicationRecord,
      CIB_AA_BI_IsMajorOwnedSubsidiary__c:
        event.target.value === "CIB_AA_BI_IsMajorOwnedSubsidiary__c",
      CIB_AA_BI_IsListedEntity__c:
        event.target.value === "CIB_AA_BI_IsListedEntity__c"
    };
  }

  collectValues() {
    const values = super.collectValues();
    values.CIB_AA_BI_IsListedEntity__c =
      this.applicationRecord.CIB_AA_BI_IsListedEntity__c;
    values.CIB_AA_BI_IsMajorOwnedSubsidiary__c =
      this.applicationRecord.CIB_AA_BI_IsMajorOwnedSubsidiary__c;
    return values;
  }
}