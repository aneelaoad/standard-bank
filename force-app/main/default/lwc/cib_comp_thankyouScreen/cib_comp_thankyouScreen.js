import { LightningElement, api } from "lwc";
import MAUThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";
import getSurveyInvitation from "@salesforce/apex/CIB_CTRL_ThankYouScreen.getSurveyInvitation";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Cib_comp_thankyouScreen extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api sectionId;
  finishIcon = MAUThemeOverrides + "/assets/images/icn_check_circle_solid.svg";
  chatQuestionIcon = MAUThemeOverrides + "/assets/images/icn_faq.svg";
  isSurveyDisplayed = false;
  surveyInvitation = {};
  async connectedCallback() {
    this.isLoaded = false;
    try {
      const result = await getSurveyInvitation({
        applicationId: this.recordId
      });
      if (result) {
        this.isSurveyDisplayed = true;
        this.surveyInvitation = result;
      }
    } catch (error) {
      console.error(error);
      const toastEvent = new ShowToastEvent({
        title: "Something went wrong.",
        message: error.message || "Please try again later.",
        variant: "error"
      });
      this.dispatchEvent(toastEvent);
    }
    this.isLoaded = true;
  }

  onSurveyOpen() {
    window.open(this.surveyInvitation.InvitationLink, "_blank");
    this.isSurveyDisplayed = false;
  }

  navigateToBack() {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "mauritius-onboarding-hub"
      }
    });
  }

  navigateToNext() {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "home"
      }
    });
  }
}