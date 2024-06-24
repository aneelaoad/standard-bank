import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import Cib_comp_applicationLineItemMixin from "c/cib_comp_ApplicationLineItemMixin";

export default class Cib_comp_taxJurisdictionInfo extends NavigationMixin(
  Cib_comp_applicationLineItemMixin(Cib_comp_baseSectionScreen)
) {
  @api recordId;
  @api sectionId;

  RECORD_TYPE = "Tax_Residence";
  helpIcon = MAU_ThemeOverrides + "/assets/images/infoIcon.svg";
  info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";
  delete_row_icon = MAU_ThemeOverrides + "/assets/images/delete_row_icon.svg";

  getAllElements() {
    const elements = [
      ...this.template.querySelectorAll("input"),
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("c-cmn_comp_date-picker"),
      ...this.template.querySelectorAll("c-cmn_comp_file-upload")
    ];
    return elements;
  }

  onLineItemsLoaded(lineItems) {
    super.onLineItemsLoaded(lineItems);
    this.template.querySelector("lightning-radio-group").value = String(
      lineItems[0].CIB_HasTINNumber__c
    );
  }

  onchange(event) {
    this.lineItems = this.lineItems.map((lineItem) => {
      return {
        ...lineItem,
        CIB_HasTINNumber__c: event.target.value === "true"
      };
    });
  }

  collectValues(lineItem) {
    return {
      CIB_HasTINNumber__c: this.lineItems[0].CIB_HasTINNumber__c
    };
  }

  get TINNumberValue() {
    return String(this.lineItems[0].CIB_HasTINNumber__c);
  }

  get isAvailableTIN() {
    return this.lineItems[0].CIB_HasTINNumber__c;
  }

  get isUnavailableTIN() {
    return !this.lineItems[0].CIB_HasTINNumber__c;
  }

  options = [
    { label: "Yes", value: "true" },
    { label: "No", value: "false" }
  ];
}