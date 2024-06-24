import { LightningElement, api } from "lwc";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";

export default class MallHeaderDropdown extends LightningElement {
  catalogueFilterBtnText = "Apply";
  mobileFilterHeader = "Filter";
  @api navigationHeading;
  @api helperText;
  @api catalogueHelperText;
  @api catalogueFilters;
  @api navBack;
  @api isMobileCatalogue;
  invalid = false;

  applySectionButtonClass = "apply-selection-btn";
  @api set hasSelectionError(state) {
    this.invalid = state;
    if (state) {
      const elementCatalogue = this.template.querySelector(
        ".catalogue-helper-text"
      );
      if (elementCatalogue) {
        elementCatalogue.classList.add("helper-text-error");
      }
      const elementAppluButton = this.template.querySelector(
        ".apply-selection-btn"
      );
      if (elementAppluButton) {
        elementAppluButton.classList.add("selection-btn-error");
      }
    } else {
      const elementCatalogue =
        this.template.querySelector(".helper-text-error");
      if (elementCatalogue) {
        elementCatalogue.classList.remove("helper-text-error");
      }
      const elementAppluButton = this.template.querySelector(
        ".selection-btn-error"
      );
      if (elementAppluButton) {
        elementAppluButton.classList.add("selection-btn-error");
      }
    }
  }

  renderedCallback() {
    addAnalyticsInteractions(this.template);
  }

  get hasSelectionError() {
    return this.invalid;
  }

  applySelection(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dispatchEvent(new CustomEvent("apply"));
  }
}