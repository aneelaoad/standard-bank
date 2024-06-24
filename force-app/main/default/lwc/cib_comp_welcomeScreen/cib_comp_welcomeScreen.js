/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 12-04-2024
@ Name of the Class : Cib_comp_welcomeScreen
@ Description       : This class is used to manage the welcome screen of the application. 
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 12-04-2024
@ Modification Description : SFP-36750
***************************************************************************************/
import { api, track } from "lwc";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import getMarketingConsentDetails from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getMarketingConsentDetails";
import saveMarketingConsentDetails from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.saveMarketingConsentDetails";
import { NavigationMixin } from "lightning/navigation";
export default class Cib_comp_welcomeScreen extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;
  saveButton = true;
  firstScreen = true;

  checkIcon = MAU_ThemeOverrides + "/assets/images/checkIcon.png";
  ideaIcon = MAU_ThemeOverrides + "/assets/images/ideaIcon.png";
  peopleIcon = MAU_ThemeOverrides + "/assets/images/peopleIcon.png";
  closeIcon = MAU_ThemeOverrides + "/assets/images/icn_close_standard.svg";
  avatarAlert = MAU_ThemeOverrides + "/assets/images/avatar_alert.svg";
  helpIcon = MAU_ThemeOverrides + "/assets/images/helpIcon.svg";
  termsAndConditionsUrl = MAU_ThemeOverrides + "/assets/pdf/TC_Mauritius.pdf";

  @track isLoaded = false;
  @track displayModal = false;
  @track saveEnabled = false;
  @track termsAndConditionsRead = false;
  @track isErrorConsent = false;
  @track contactPointConsentMarketing = {};
  @track contactPointConsentTermsAndConditions = {};

  connectedCallback() {
    super.connectedCallback();
    this.getMarketingConsent();
  }

  enableSaveButton(event) {
    this.termsAndConditionsRead = true;
  }

  get isSavingNotActive() {
    return !this.termsAndConditionsRead;
  }

  /**
   * @description Method to get the marketing consent status
   */
  async getMarketingConsent() {
    try {
      const result = await getMarketingConsentDetails();
      console.log("result", JSON.stringify(result, null, 2));
      this.isLoaded = true;
      for (let index = 0; index < result.length; index++) {
        const consent = result[index];
        if (consent.Name.includes("Email Marketing")) {
          this.contactPointConsent = consent;
        }
        if (consent.Name.includes("Terms and Conditions ")) {
          this.contactPointConsentTermsAndConditions = consent;
          if (
            ["NotSeen", "Seen", "OptInPending", "OptOutPending"].includes(
              consent.PrivacyConsentStatus
            )
          ) {
            this.displayModal = true;
          }
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  /**
   * @description to give the marketing consent
   */
  onAccept() {
    const inputs = [
      ...this.template.querySelectorAll('input[type="checkbox"]')
    ];
    let outcome = inputs.reduce((acc, input) => {
      if (input.name === "termsAndConditions" && input.checked) {
        this.isErrorConsent = false;
        this.contactPointConsentTermsAndConditions = {
          ...this.contactPointConsentTermsAndConditions,
          PrivacyConsentStatus: "OptIn"
        };
        return true;
      } else if (input.name === "termsAndConditions" && !input.checked) {
        this.isErrorConsent = true;
        return false;
      }
      if (input.name === "marketingConsent") {
        this.contactPointConsentMarketing = {
          ...this.contactPointConsent,
          PrivacyConsentStatus: input.checked ? "OptIn" : "OptOut"
        };
        return true;
      }
      return acc;
    }, false);
    if (outcome) {
      this.displayModal = false;
      this.saveMarketingConsent();
    }
  }

  /**
   * @description to reject the marketing consent
   */
  onReject() {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "home"
      }
    });
  }

  /**
   * @description Method to close the modal and save the marketing consent
   */
  async saveMarketingConsent() {
    this.isLoaded = false;
    try {
      const result = await Promise.all([
        saveMarketingConsentDetails({
          contactPointConsent: this.contactPointConsentMarketing
        }),
        saveMarketingConsentDetails({
          contactPointConsent: this.contactPointConsentTermsAndConditions
        })
      ]);
      if (result) {
        this.displayModal = false;
      }
    } catch (error) {
      this.handleError(error);
    }
    this.isLoaded = true;
  }
}