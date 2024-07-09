import { LightningElement, api, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import MAUThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import { showToast } from "c/aob_comp_utils";

/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 30-06-2024
@ Name of the Class : Cib_comp_applicationDetailPage
@ Description       : This class is used to manage the main application onboarding flow and handler an errors that might occour.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 30-06-2024
@ Modification Description : SFP-39692
***************************************************************************************/
export default class CibCompApplicationDetailPage extends LightningElement {
  flowApiName = "CIB_MAU_Account_Onboarding_Flow";
  warningIcon = MAUThemeOverrides + "/assets/images/avatar_warn.svg";

  @api recordId;

  @track flowInputVariables = [];
  @track isFlowDataLoaded = false;
  @track hasError = false;

  async connectedCallback() {
    try {
      await loadStyle(this, MAUThemeOverrides + "/styleDelta.css");
      console.log("recordId", JSON.stringify(this.recordId, null, 2));
      this.flowInputVariables = [
        {
          name: "ApplicationId",
          type: "String",
          value: this.recordId
        }
      ];
    } catch (error) {
      this.hasError = true;
      console.log("error", JSON.stringify(error, null, 2));
      showToast.call(this, {
        name: "Error",
        message: "Error loading application details"
      });
    }
    this.isFlowDataLoaded = true;
  }

  async handleFlowStatusChange(event) {
    console.log("event.detail", JSON.stringify(event.detail, null, 2));
    if (event.detail.status === "Error" || event.detail.status === "ERROR") {
      this.hasError = true;
    }
  }
  handleRefresh() {
    window.location.reload();
  }
}