import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";


export default class Cib_comp_stateOwnershipStatus extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;
  helpIcon = MAU_ThemeOverrides + "/assets/images/helpIcon.svg";

  /**
   * @description Method to get All Distinct Input Fields from UI
   */
  getAllElements() {
    const elements = [...this.template.querySelectorAll("lightning-input")];
    return elements;
  }

  /**
   * @description  Function to get percentage
   */
  getCompetionPercentage() {
    const elements = this.getAllElements();
    const totalFields = elements.length;
    const validFields = elements.reduce((validCount, element) => {
      if (
        (element.checkValidity && element.checkValidity()) ||
        element.value !== null ||
        element.value !== undefined ||
        element.value !== ""
      ) {
        return validCount + 1;
      }
      return validCount;
    }, 0);

    return (validFields / totalFields) * 100;
  }

  onApplicationLoaded(data) {
    this.template.querySelectorAll("lightning-input").forEach((element) => {
      element.value = data[element.name];
    });
  }

  /**
   *@description Method to navigate next
   */
  navigateToNext() {
    if (this.validateFormSave()) {
      this.buttonClick = "Submit";
      this.isLoaded = false;
      this.updateRecord();
    }
  }

  /**
   *@description Method to navigate to back
   */
  navigateToBack() {
    super.navigateToNextScreen();
  }

  /**
   *@description Method to Validate Save Record
   */
  validateRecord() {
    let isValid = true;
    this.template.querySelectorAll("lightning-input").forEach((element) => {
      this.removeError(element);
      if (element.value) {
        if (!element.reportValidity()) {
          isValid = false;
        }
      }
    });
    return isValid;
  }

  collectValues() {
    return [...this.template.querySelectorAll("lightning-input")].reduce(
      (collection, element) => {
        collection[element.name] = element.value;
        return collection;
      },
      {}
    );
  }

  /**
   *@description validity check
   */
  removeError(element) {
    element.setCustomValidity("");
    element.reportValidity();
  }
}