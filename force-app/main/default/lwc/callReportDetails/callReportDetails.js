import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord } from "lightning/uiRecordApi";
import CALL_REPORT_OBJECT from "@salesforce/schema/Call_Report__c";
import END_DATE from "@salesforce/schema/Call_Report__c.End__c";
import MEETING_FORMAT from "@salesforce/schema/Call_Report__c.Meeting_Format__c";
import NUMBER_OF_ATTENDED from "@salesforce/schema/Call_Report__c.Number_Of_Attended_Attendees__c";
import REMINDER_REQUIRED from "@salesforce/schema/Call_Report__c.Attendee_Reminder_Required__c";
import TOTAL_EVENT_COST from "@salesforce/schema/Call_Report__c.Total_Event_Costs__c";

export default class CallReportDetails extends LightningElement {
  @api recordId;

  @track layoutSections = [];
  @track fieldsToRetrieve = [];
  @track activeAccordionSections = [];

  recordTypeId;
  isView = true;
  showSpinner = true;
  errorMessage = undefined;
  _callReportRecord;
  _callReportObject;
  _callReportLayout;
  _sections = [];
  _fieldsToRetrieve = [];
  _retrievedFields;
  _currencyFields = {};
  _focusedField = undefined;

  @wire(getRecord, { recordId: "$recordId", fields: "$fieldsToRetrieve" })
  callReport({ error, data }) {
    if (error) {
      this.errorMessage = error;
      this.showSpinner = false;
    }
    if (data) {
      this._retrievedFields = data;
      Object.entries(data.fields).forEach(([fieldName, fieldValue]) => {
        if (this._currencyFields[fieldName]) {
          this._currencyFields[fieldName].value = fieldValue.value;
        }
      });
    }
  }

  renderedCallback() {
    console.log(this._focusedField);
    if (this._focusedField) {
      let inputField = this.template.querySelector(this._focusedField);
      if (inputField) {
        setTimeout(() => {
          inputField.focus();
          this._focusedField = undefined;
        });
      }
    }
  }

  handleViewLoad(event) {
    if (!this.recordTypeId) {
      this.recordTypeId = event.detail.records[this.recordId].recordTypeId;
      this._callReportRecord = event.detail.records[this.recordId];
      this._callReportObject = event.detail.objectInfos.Call_Report__c.fields;
      this._callReportLayout =
        event.detail.layouts.Call_Report__c[
          this.recordTypeId
        ].Full.View.sections;
      this.layoutSections = [];
      let activeAccordionSections = [];
      let i = 0;
      Object.entries(this._callReportLayout).forEach(([key, section]) => {
        let tempSection = {};
        let sectionIdentifier = "sectionIdentifier" + i++;
        tempSection.sectionIdentifier = sectionIdentifier;
        activeAccordionSections.push(sectionIdentifier);
        tempSection.label = section.heading;
        if (section.columns === 1) {
          tempSection.hasTwoColumns = false;
          tempSection.layoutItems = [];
          Object.entries(section.layoutRows).forEach(([key, layoutItem]) => {
            if (layoutItem.layoutItems[0].layoutComponents[0].apiName) {
              tempSection.layoutItems.push(this.prepareItem(layoutItem, 0));
            }
          });
        } else if (section.columns === 2) {
          tempSection.hasTwoColumns = true;
          tempSection.leftColumn = [];
          tempSection.rightColumn = [];
          Object.entries(section.layoutRows).forEach(([key, layoutItem]) => {
            if (layoutItem.layoutItems[0].layoutComponents[0].apiName) {
              tempSection.leftColumn.push(this.prepareItem(layoutItem, 0));
            }
            if (layoutItem.layoutItems[1].layoutComponents[0].apiName) {
              tempSection.rightColumn.push(this.prepareItem(layoutItem, 1));
            }
          });
        }
        this._sections.push(tempSection);
      });
      if (
        this._callReportRecord.recordTypeInfo.name === "Meeting" ||
        this._callReportRecord.recordTypeInfo.name === "BCB SA Meeting"
      ) {
        this._fieldsToRetrieve.push(
          CALL_REPORT_OBJECT.objectApiName +
            "." +
            REMINDER_REQUIRED.fieldApiName
        );
        this._fieldsToRetrieve.push(
          CALL_REPORT_OBJECT.objectApiName + "." + TOTAL_EVENT_COST.fieldApiName
        );
        this._fieldsToRetrieve.push(
          CALL_REPORT_OBJECT.objectApiName +
            "." +
            NUMBER_OF_ATTENDED.fieldApiName
        );
      }
      this.fieldsToRetrieve = this._fieldsToRetrieve;
      this.layoutSections = this._sections;
      this.activeAccordionSections = activeAccordionSections;
      this.showSpinner = false;
    }
  }

  prepareItem(layoutItem, index) {
    let item = {};
    item.field = layoutItem.layoutItems[index].layoutComponents[0].apiName;
    let fieldDescription = this._callReportObject[item.field];
    if (fieldDescription.dataType === "Currency") {
      this._currencyFields[item.field] = item;
      item.isCurrency = true;
      item.label = layoutItem.layoutItems[index].label;
      item.value = this._callReportRecord.fields[item.field].value;
      if (item.field !== TOTAL_EVENT_COST.fieldApiName) {
        this._fieldsToRetrieve.push(
          CALL_REPORT_OBJECT.objectApiName + "." + item.field
        );
      }
    } else {
      item.isCurrency = false;
    }
    if (fieldDescription.updateable) {
      item.isReadonly = !layoutItem.layoutItems[index].editableForUpdate;
      item.isRequired = layoutItem.layoutItems[index].required;
    } else {
      item.isReadonly = true;
    }
    return item;
  }

  cleanUpData() {
    this.activeAccordionSections = [];
    this.fieldsToRetrieve = [];
    this._fieldsToRetrieve = [];
    this._currencyFields = {};
    this._sections = [];
  }

  handleEditButton(event) {
    this.switchToEditMode(event.currentTarget.dataset.id);
  }

  handleDbClick(event) {
    this.switchToEditMode(event.target.fieldName);
    //this.switchToEditMode(event.target.dataset.name);
  }

  switchToEditMode(value) {
    this.isView = false;
    this._focusedField = '[data-name="' + value + '"]';
  }

  handleCancel(event) {
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    if (inputFields) {
      inputFields.forEach((field) => {
        field.reset();
      });
    }
    this.isView = true;
  }

  handleSubmit(event) {
    event.preventDefault();
    const fields = event.detail.fields;
    let hasError = false;
    Object.entries(this._currencyFields).forEach(([fieldName, fieldData]) => {
      let fieldFromUi = this.template.querySelector(
        '[data-name="' + fieldName + '"]'
      );
      if (
        (this._callReportRecord.recordTypeInfo.name === "Meeting" ||
          this._callReportRecord.recordTypeInfo.name === "BCB SA Meeting") &&
        fieldName === TOTAL_EVENT_COST.fieldApiName &&
        fields[MEETING_FORMAT.fieldApiName] === "Entertainment" &&
        this._retrievedFields.fields[NUMBER_OF_ATTENDED.fieldApiName].value >
          0 &&
        new Date(fields[END_DATE.fieldApiName]) < new Date() &&
        (fieldFromUi.value == null || fieldFromUi.value == 0)
      ) {
        this.showToast(
          "Error",
          'Please complete "Total Event Cost" field for this Entertainment Meeting format.',
          "error",
          "sticky"
        );
        hasError = true;
      }
      fields[fieldName] = fieldFromUi.value;
    });
    if (!hasError) {
      this.showSpinner = true;
      if (
        this._retrievedFields.fields[REMINDER_REQUIRED.fieldApiName].value ===
        "HAS_REMINDER_NEED"
      ) {
        fields[REMINDER_REQUIRED.fieldApiName] = "HAS_REMINDER_NO_NEED";
      }
      this.template.querySelector("lightning-record-edit-form").submit(fields);
    }
  }

  handleSuccess() {
    this.isView = true;
    this.showSpinner = false;
    this.fieldsToRetrieve = [...this.fieldsToRetrieve];
    this.showToast("Success", "The record was updated", "success", "pester");
  }

  handleError(event) {
    event.preventDefault();
    let errorMessage = "";
    if (
      event.detail.message.includes("An error occurred while trying to update")
    ) {
      errorMessage =
        "An error occurred while trying to update the record. " +
        event.detail.detail +
        ". Please review the record and try again.";
    } else {
      errorMessage = event.detail.message + ". " + event.detail.detail;
    }
    this.showSpinner = false;
    this.showToast("Error", errorMessage, "error", "sticky");
  }

  showToast(title, message, variant, mode) {
    const toast = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(toast);
  }
}