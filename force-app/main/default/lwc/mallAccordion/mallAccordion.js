import { LightningElement, api } from "lwc";
import { mallNavigation } from "c/mallNavigation";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";

export default class MallAccordion extends LightningElement {
  @api accordionData;
  @api type = "mall";

  setAccordionsArray() {
    const collection =
      this.accordionData && this.accordionData !== []
        ? JSON.parse(this.accordionData)
        : [];

    return collection;
  }

  get accordionSections() {
    return this.setAccordionsArray();
  }
  toggleAccordion(event) {
    const elementTarget = event.target;
    if (
      elementTarget.classList.contains("open") ||
      elementTarget.closest(".accordion").classList.contains("open")
    ) {
      elementTarget.classList.contains(".accordion")
        ? elementTarget.classList.remove("open")
        : elementTarget.closest(".accordion").classList.remove("open");
      return;
    }
    this.clearAccordions(elementTarget);
    elementTarget.classList.contains(".accordion")
      ? elementTarget.classList.add("open")
      : elementTarget.closest(".accordion").classList.add("open");
  }

  clearAccordions(eventElement) {
    const accordionWrapper = eventElement.closest(".accordion-wrapper");
    const accordions = accordionWrapper.querySelectorAll(".accordion");

    accordions.forEach((element) => {
      element.classList.remove("open");
    });
  }

  renderedCallback() {
    this.template.querySelectorAll("a[href]").forEach((element) => {
      element.addEventListener(
        new CustomEvent("navigate"),
        mallNavigation.navigateToPage()
      );
    });

    addAnalyticsInteractions(this.template);
  }
}