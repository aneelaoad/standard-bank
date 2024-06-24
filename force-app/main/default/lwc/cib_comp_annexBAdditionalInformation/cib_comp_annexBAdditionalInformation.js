/*
  @ Author            : silva.macaneta@standardbank.co.za
  @ Date              : 12-04-2024
  @ Name of the Class : Cib_comp_selectExistingParticipants
  @ Description       : This class is used to manage the select existing participants screen of the application.
  @ Last Modified By  : silva.macaneta@standardbank.co.za
  @ Last Modified On  : 12-04-2024
  @ Modification Description : SFP-36750
*/
import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_annexBAdditionalInformation extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  @track checkboxicon = MAU_ThemeOverrides + "/assets/images/checkboxicon.svg";
  @track info_imp = MAU_ThemeOverrides + "/assets/images/info_imp.svg";

  collectValues() {
    let values = {};
    let fields = this.template.querySelectorAll('[data-type="application"]');
    fields.forEach((field) => {
      if (field.type === "checkbox") {
        values[field.name] = this.applicationRecord[field.name];
      } else {
        values[field.name] = field.value;
      }
    });
    return values;
  }
  onchange(event) {
    this.applicationRecord[event.target.name] = event.target.checked;
  }
}