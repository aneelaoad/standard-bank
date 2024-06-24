import { LightningElement, api } from "lwc";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";

const icons = {
  completed: MAU_ThemeOverrides + "/assets/images/icn_check_circle.svg",
  note: MAU_ThemeOverrides + "/assets/images/mau_note.svg",
  edit: MAU_ThemeOverrides + "/assets/images/col-icon-left.svg"
};

export default class Cib_comp_applicationSection extends LightningElement {
  @api section = {};
  @api type = "In Progress";
  @api isLoading = false;

  onSectionClick() {
    this.dispatchEvent(
      new CustomEvent("sectionclick", { detail: this.section.Id })
    );
  }

  get isCompleted() {
    return this.section.Status__c === "Completed";
  }

  get completionStatus() {
    if (
      this.section.Status__c === "Started" ||
      this.section.Status__c === "Not Started"
    ) {
      return "Awaiting completion";
    }

    if (
      (this.section.Status__c === "Started" ||
        this.section.Status__c === "Not Started" ||
        this.section.Status__c === "Revision Requested") &&
      this.section.CompletionPercentage__c > 0
    ) {
      return `${this.section.CompletionPercentage__c}% complete`;
    }

    return `Completed`;
  }

  get iconUrl() {
    return this.type === "Completed" ? icons.completed : icons.note;
  }

  get buttonLabel() {
    if (
      this.section.Status__c === "Submitted" &&
      this.section.CompletionPercentage__c > 0
    ) {
      return "Edit";
    }
    if (this.section.Status__c === "Completed") {
      return "Completed";
    }
    return "Complete Form";
  }

  get displayEditIcon() {
    return (
      this.section.Status__c === "Submitted" &&
      this.section.CompletionPercentage__c > 0
    );
  }

  get editIconUrl() {
    return icons.edit;
  }

  get cardClasses() {
    const classes = ["slds-card", "aob_todo-card"];

    if (this.section.Status__c === "Submitted") {
      classes.push("aob_todo-card-success");
    }

    if (this.section.Status__c === "Completed") {
      classes.push("aob_todo-card-gray");
    }

    return classes.join(" ");
  }
}