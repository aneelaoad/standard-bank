/***************************************************************************************
@ Author            : silva.macaneta@standardbank.co.za
@ Date              : 12-04-2024
@ Name of the Class : Cib_comp_baseSectionScreen
@ Description       : This class is used to manage the base section screen of the application.
@ Last Modified By  : silva.macaneta@standardbank.co.za
@ Last Modified On  : 12-04-2024
@ Modification Description : SFP-36750
***************************************************************************************/
import { LightningElement, api, track } from "lwc";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent
} from "lightning/flowSupport";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getApplicationRecord from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getApplicationRecord";
import getApplicationSectionRecord from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getApplicationSectionRecord";
import updateApplication from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.updateApplication";
import updateApplicationSection from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.updateApplicationSection";
import getPicklistValues from "@salesforce/apex/CIB_CTRL_BaseSectionScreen.getPicklistValues";

export default class Cib_comp_baseSectionScreen extends LightningElement {
  SCREEN_API_NAME = this.name;
  @api recordId;
  @api sectionId;
  @api availableActions = [];
  objectApiNames = [
    "Application__c",
    "Application_Section__c",
    "Application_Document__c",
    "Application_Participant__c",
    "Application_Line_Item__c"
  ];

  @track isLoaded = false;
  @track isLoading = true;
  @track applicationRecord = {};
  @track applicationParticipantRecord = [];
  @track applicationDocumentRecords = [];
  @track sectionRecord = {};
  @track sectionMetadata = {};

  connectedCallback() {
    this.getApplicationRecord();
    this.getApplicationSectionRecord();
  }

  @track isApplicationLoaded = false;
  async getApplicationRecord() {
    try {
      const data = await getApplicationRecord({ applicationId: this.recordId });
      if (data) {
        this.applicationRecord = data;
        this.onApplicationLoaded(data);
        this.isApplicationLoaded = true;
        if (this.isSectionLoaded) {
          this.isLoaded = true;
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  @track isSectionLoaded = false;
  async getApplicationSectionRecord() {
    try {
      const data = await getApplicationSectionRecord({
        sectionId: this.sectionId
      });
      if (data) {
        this.sectionRecord = data;
        this.onSectionLoaded(data);
        this.isSectionLoaded = true;
        if (this.isApplicationLoaded) {
          this.isLoaded = true;
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  onSectionLoaded(_data) {}
  
  onApplicationLoaded(_data) {}

  getAllElements() {
    return [
      ...this.template.querySelectorAll('[data-type="application"]'),
      ...this.template.querySelectorAll("c-cib_comp_documents-container")
    ];
  }

  validateRecord() {
    return this.getAllElements().reduce((isValid, element) => {
      if (!isValid) {
        return false;
      }
      if (element.reportValidity) {
        return element.reportValidity();
      }
      if (element.value) {
        return true;
      }
      return false;
    }, true);
  }

  async saveRecord() {
    this.isLoaded = false;
    try {
      await this.updateSectionRecord("Started");
      await this.updateApplicationRecord();
      this.successToast("Progress Saved!");
    } catch (error) {
      this.handleError(error);
    }
    this.isLoaded = true;
  }

  async submitRecord() {
    this.isLoaded = false;
    try {
      const isValid = this.validateRecord();
      if (isValid) {
        this.sectionRecord = {
          ...this.sectionRecord,
          CompletionPercentage__c: this.getCompetionPercentage(),
          Status__c: "Submitted"
        };
        await this.updateSetionRecord();
        await this.updateApplicationRecord();
        this.navigateToNextScreen();
      }
    } catch (error) {
      this.handleError(error);
    }
    this.isLoaded = true;
  }

  async updateSectionRecord(status = "Submitted") {
    this.sectionRecord = {
      ...this.sectionRecord,
      CompletionPercentage__c: this.getCompetionPercentage(),
      Status__c: status
    };
    await this.updateSetionRecord();
  }

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

  async updateSetionRecord() {
    const sectionRecord = {
      Id: this.sectionRecord.Id,
      CompletionPercentage__c: this.sectionRecord.CompletionPercentage__c,
      Status__c: this.sectionRecord.Status__c
    };
    try {
      await updateApplicationSection({ sectionRecord: sectionRecord });
    } catch (error) {      
      this.handleError(error);
    }
  }

  collectValues() {
    return [
      ...this.template.querySelectorAll('[data-type="application"]')
    ].reduce(
      (acc, element) => ({
        ...acc,
        [element.dataset.fieldname]:
          element.type === "checkbox" && element.tagName === "INPUT"
            ? element.checked
            : element.value
      }),
      {}
    );
  }

  async updateApplicationRecord() {
    const applicationRecord =
      typeof this.collectValues === "function"
        ? this.collectValues()
        : this.applicationRecord;
    applicationRecord.Id = this.recordId;
    try {
      await this.updateApplication(applicationRecord);
    } catch (error) {
      this.handleError(error);
    }
  }

  async updateApplication(applicationRecord) {
    return updateApplication({ applicationRecord: applicationRecord });
  }

  navigateToNextScreen() {
    const attributeChangeEvent = new FlowAttributeChangeEvent("sectionId", "");
    this.dispatchEvent(attributeChangeEvent);

    if (this.availableActions.find((action) => action === "NEXT")) {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    }
  }

  navigateToPreviousScreen() {
    this.navigateToNextScreen();
  }

  handleError(error) {    
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Something went wrong!",
        message: error.getMessage ? error.getMessage() : error.toString(),
        variant: "error"
      })
    );
    console.error(JSON.stringify(error, null, 2));
  }

  successToast(message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success!",
        message: message,
        variant: "success"
      })
    );
  }

  async getPicklistValues(objectName, fieldName) {
    return getPicklistValues({
      objectName,
      fieldName
    });
  }
}