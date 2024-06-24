import { LightningElement, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import MAUThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import getApplicationSectionRecord from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getApplicationSectionRecord";
import { showToast } from "c/aob_comp_utils";

export default class Cib_comp_flowHandler extends LightningElement {
  @api recordId;
  @api section;
  flowApiName = "CIB_MAU_Account_Onboarding_Flow";
  flowInputVariables = [];
  isFlowDataLoaded = false;

  async connectedCallback() {
    loadStyle(this, MAUThemeOverrides + "/mau_comp_flowHandler.css")
      .then(() => {
        
      })
      .catch((error) => {
        console.error("Error loading CSS: ", error);
      });

    try {
      const responce = await getApplicationSectionRecord({
        sectionId: this.recordId
      });
      this.flowInputVariables = [
        { name: "SectionId", type: "String", value: this.recordId },
        {
          name: "ApplicationId",
          type: "String",
          value: responce.Application__c
        }
      ];
      this.isFlowDataLoaded = true;
    } catch (error) {      
      showToast("Error loading flow data");
      this.isFlowDataLoaded = false;
    }
  }
}