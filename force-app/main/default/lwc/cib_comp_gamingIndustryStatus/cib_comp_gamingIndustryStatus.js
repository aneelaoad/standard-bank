import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Cib_comp_baseSectionScreen from "c/cib_comp_baseSectionScreen";

export default class Cib_comp_gamingIndustryStatus extends NavigationMixin(
  Cib_comp_baseSectionScreen
) {
  @api recordId;
  @api sectionId;

  get gamingIndustryStatus() {
    return this.options.reduce((acc, option) => {
      if (this.applicationRecord[option.value]) {
        return [...acc, option.value];
      }
      return acc;
    }, []);
  }

  @track options = [
    { label: "Business", value: "CIB_GII_HasBusinessInvolvement__c" },
    { label: "Customers", value: "CIB_GII_HasCustomerInvolvement__c" },
    { label: "Supplier", value: "CIB_GII_HasSupplerInvolvement__c" }
  ];

  onApplicationLoaded(application) {
    const elements = this.getAllElements();
    elements.forEach((element) => {
      const fieldname = element.dataset.fieldname;
      if (element.tagName === "LIGHTNING-CHECKBOX-GROUP") {
        let selected = this.options.reduce((acc, option) => {
          if (application[option.value]) {
            return [...acc, option.value];
          }
          return acc;
        }, []);
        element.value = selected;
      } else {
        element.value = application[fieldname];
      }
    });
  }

  onchange(event) {
    const fieldname = event.target.dataset.fieldname;
    if (event.target.tagName === "LIGHTNING-CHECKBOX-GROUP") {
      this.options.forEach((option) => {
        this.applicationRecord[option.value] = false;
      });
      event.target.value.forEach((value) => {
        this.applicationRecord[value] = true;
      });
    } else {
      this.applicationRecord[fieldname] = event.target.value;
    }
  }

  /**
   * @description Method to get All Distinct Input Fields from UI
   */
  getAllElements() {
    const elements = [
      ...this.template.querySelectorAll("lightning-checkbox-group"),
      ...this.template.querySelectorAll("lightning-textarea")
    ];
    return elements;
  }

  collectValues() {
    let aValues = this.getAllElements().reduce((values, element) => {
      const fieldname = element.dataset.fieldname;
      if (element.tagName === "LIGHTNING-CHECKBOX-GROUP") {
        this.options.forEach((option) => {
          this.applicationRecord[option.value] = element.value.includes(option.value);
          values[option.value] = element.value.includes(option.value);
        });       
      } else {
        this.applicationRecord[fieldname] = element.value;
        values[fieldname] = element.value;
      }
      return values;
    }, {});
    return aValues;
  }
}