import { LightningElement, api, wire, track } from "lwc";
import isGuest from "@salesforce/user/isGuest";
import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";
import USER_ID from "@salesforce/user/Id";
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME from "@salesforce/schema/User.Name";
import EMAIL from "@salesforce/schema/User.Email";
import CONTACTID from "@salesforce/schema/User.ContactId";
import CASE_CONTACT_FIELD from "@salesforce/schema/Case.ContactId";
import CASE_WEB_NAME from "@salesforce/schema/Case.SuppliedName";
import CASE_WEB_EMAIL from "@salesforce/schema/Case.SuppliedEmail";
import CASE_WEB_PHONE from "@salesforce/schema/Case.SuppliedPhone";
import CASE_SUBJECT_FIELD from "@salesforce/schema/Case.Subject";
import CASE_COMMENT_FIELD from "@salesforce/schema/Case.Description";
import CASE_CASESOURCE_FIELD from "@salesforce/schema/Case.Origin";
import CASE_CASETYPE_FIELD from "@salesforce/schema/Case.Case_Type__c";
import getContactUsEmailByCountry from "@salesforce/apex/MallDataService.getContactUsEmailByCountry";
import createCaseRecord from "@salesforce/apex/MallCaseManagementUtil.createCaseRecord";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { mallStateName, getUserState } from "c/sbgUserStateUtils";
import { MallTranslationService } from 'c/mallTranslationService';
import MALL_CONTACT_BANKER_TITLE from '@salesforce/label/c.MALL_CONTACT_BANKER_TITLE';
import MALL_CONTACT_US_FORM_LABEL from '@salesforce/label/c.MALL_CONTACT_US_FORM_LABEL';
import MALL_CONTACT_BANKER_DESCRIPTION from '@salesforce/label/c.MALL_CONTACT_BANKER_DESCRIPTION';
import MALL_MESSAGE_TYPE_LABEL from '@salesforce/label/c.MALL_MESSAGE_TYPE_LABEL';
import MALL_FULL_NAME_LABEL from '@salesforce/label/c.MALL_FULL_NAME_LABEL';
import MALL_PLACEHOLDER_FULL_NAME from '@salesforce/label/c.MALL_PLACEHOLDER_FULL_NAME';
import MALL_EMAIL_ADDRESS_LABEL from '@salesforce/label/c.MALL_EMAIL_ADDRESS_LABEL';
import MALL_PLACEHOLDER_EMAIL_ADDRESS from '@salesforce/label/c.MALL_PLACEHOLDER_EMAIL_ADDRESS';
import MALL_MOBILE_LABEL from '@salesforce/label/c.MALL_MOBILE_LABEL';
import MALL_PLACEHOLDER_MOBILE_LABEL from '@salesforce/label/c.MALL_PLACEHOLDER_MOBILE_LABEL';
import MALL_CODE_LABEL from '@salesforce/label/c.MALL_CODE_LABEL';
import MALL_MESSAGE_SUBJECT_LABEL from '@salesforce/label/c.MALL_MESSAGE_SUBJECT_LABEL';
import MALL_MESSAGE_SUBJECT_PLACEHOLDER from '@salesforce/label/c.MALL_MESSAGE_SUBJECT_PLACEHOLDER';
import MALL_YOUR_MESSAGE_LABEL from '@salesforce/label/c.MALL_YOUR_MESSAGE_LABEL';
import MALL_PLACEHOLDER_YOUR_MESSAGE_LABEL from '@salesforce/label/c.MALL_PLACEHOLDER_YOUR_MESSAGE_LABEL';
import MALL_CONTACTUS_THANKYOU from '@salesforce/label/c.MALL_CONTACTUS_THANKYOU';
import MALL_CONTACT_BANKER_FEEDBACK_MESSAGE from '@salesforce/label/c.MALL_CONTACT_BANKER_FEEDBACK_MESSAGE';
import MALL_CONTACT_BANKER_SEND_DESCRIPTION from '@salesforce/label/c.MALL_CONTACT_BANKER_SEND_DESCRIPTION';
import MALL_SEND_BUTTON_LABEL from '@salesforce/label/c.MALL_SEND_BUTTON_LABEL';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { navigateToWebPage } from "c/mallNavigation";
import getRelationshipManagerInfo from "@salesforce/apex/CTRL_Mall_ClientRelationshipManager.getRelationshipManagerInfo";


const DEFAULT_ORIGIN = "BCB Platform";
const DEFAULT_CASETYPE = "Contact your banker";
const DEFAULT_MALL_COUNTRY = "South Africa";

export default class MallContactYourBanker extends NavigationMixin(LightningElement) {
  error;
  showSpinner = false;
  isFormSubmitted = false;
  selectedType = "Support";
  countryCodesList = [];
  selectedCountryCode;
  isFirstRender = true;
  name = "";
  email = "";
  countryContactUsEmail;
  mailToCountryContactUsEmail;
  navigateToWebPage = navigateToWebPage.bind(this);
  @track relationManagerInfo = {};

  backIcon = sbgVisualAssets + "/icn_chevron_left.svg";
  sendMessageIcon = sbgVisualAssets + "/send_message.svg";

  contactUsTitle = MALL_CONTACT_BANKER_TITLE;
  contactUsFormLabel = MALL_CONTACT_US_FORM_LABEL;
  appreciationMessageLabel = MALL_CONTACT_BANKER_DESCRIPTION;
  messageTypeTitleLabel = MALL_MESSAGE_TYPE_LABEL;
  fullNameLabel = MALL_FULL_NAME_LABEL;
  fullNamePlaceholder = MALL_PLACEHOLDER_FULL_NAME
  emailAddressLabel = MALL_EMAIL_ADDRESS_LABEL;
  emailAddressPlaceholder = MALL_PLACEHOLDER_EMAIL_ADDRESS;
  mobileNumberLabel = MALL_MOBILE_LABEL;
  mobileNumberPlaceholder = MALL_PLACEHOLDER_MOBILE_LABEL;
  codeLabel = MALL_CODE_LABEL;
  messageSubjectLabel = MALL_MESSAGE_SUBJECT_LABEL;
  messageSubjectPlaceholder = MALL_MESSAGE_SUBJECT_PLACEHOLDER;
  yourMessageLabel = MALL_YOUR_MESSAGE_LABEL;
  yourMessagePlaceholder = MALL_PLACEHOLDER_YOUR_MESSAGE_LABEL;
  contactUsThankYouNote = MALL_CONTACTUS_THANKYOU;
  feedbackMessage = MALL_CONTACT_BANKER_FEEDBACK_MESSAGE;
  sendEmailMessageLabel = MALL_CONTACT_BANKER_SEND_DESCRIPTION;
  sendButtonLabel = MALL_SEND_BUTTON_LABEL;

  buttonInteractionIntent;
  buttonInteractionScope;
  buttonInteractionType;
  buttonInteractionText;
  buttonInteractionTextBefore;
  organizationId;

  @api countryCodes;
  @api hours;

  @wire(getRecord, { recordId: USER_ID, fields: [NAME, EMAIL, CONTACTID] })
  user;

  get contactName() {
    return getFieldValue(this.user.data, NAME)
      ? getFieldValue(this.user.data, NAME)
      : "";
  }
  get contactEmail() {
    return getFieldValue(this.user.data, EMAIL)
      ? getFieldValue(this.user.data, EMAIL)
      : "";
  }

  get contactId() {
    return getFieldValue(this.user.data, CONTACTID)
      ? getFieldValue(this.user.data, CONTACTID)
      : "";
  }

  setTaggingAttributes(button, type, scope){
    button.map((item) => {
        this.buttonInteractionIntent = "navigational";
        this.buttonInteractionScope = scope || "test buttonInteractionScope";
        this.buttonInteractionType = "click";
        // this.buttonInteractionText = item.shopName + " | " + item.title || "test buttonInteractionText";
        this.buttonInteractionTextBefore = type || "test buttonInteractionTextBefore" ;            
    });
}

  connectedCallback() {
    this.getTranslatedLabels();
    const param = "success";
    const paramValue = this.getUrlParamValue(window.location.href, param);
    this.isFormSubmitted = paramValue;
    this.getCountryContactUsEmail();
    this.fetchRelationshipManagerInfo();
  }

  showSuccessToast() {
    this.template.querySelector('c-mall-toast-notifcation').showToast('success', this.feedbackMessage, this.contactUsThankYouNote);
  }

  //Code to setup the translations for the labels
  tokenVsLabelsObject = {
    "contactUsTitle" : "MALL_CONTACT_BANKER_TITLE",
    "contactUsFormLabel" : "MALL_CONTACT_US_FORM_LABEL",
    "appreciationMessageLabel" : "MALL_CONTACT_BANKER_DESCRIPTION",
    "messageTypeTitleLabel" : "MALL_MESSAGE_TYPE_LABEL",
    "fullNameLabel" : "MALL_FULL_NAME_LABEL",
    "fullNamePlaceholder" : "MALL_PLACEHOLDER_FULL_NAME",
    "emailAddressLabel" : "MALL_EMAIL_ADDRESS_LABEL",
    "emailAddressPlaceholder" : "MALL_PLACEHOLDER_EMAIL_ADDRESS",
    "mobileNumberLabel" : "MALL_MOBILE_LABEL",
    "mobileNumberPlaceholder" : "MALL_PLACEHOLDER_MOBILE_LABEL",
    "codeLabel" : "MALL_CODE_LABEL",
    "messageSubjectLabel" : "MALL_MESSAGE_SUBJECT_LABEL",
    "messageSubjectPlaceholder" : "MALL_MESSAGE_SUBJECT_PLACEHOLDER",
    "yourMessageLabel" : "MALL_YOUR_MESSAGE_LABEL",
    "yourMessagePlaceholder" : "MALL_PLACEHOLD_YOUR_MESSAGE_LABEL",
    "contactUsThankYouNote" : "MALL_CONTACTUS_THANKYOU",
    "feedbackMessage" : "MALL_CONTACTUS_FEEDBACKMESSAGE",
    "sendEmailMessageLabel" : "MALL_CONTACT_BANKER_SEND_DESCRIPTION",
    "sendButtonLabel" : "MALL_SEND_BUTTON_LABEL"
  }

  //get the translated labels
  async getTranslatedLabels() {
      try {
      const translatedLabelsInstance = MallTranslationService.getInstance();
      const translatedLabels = await translatedLabelsInstance.getTranslatedLabels();
      this.setUpTranslatedLabels(translatedLabels);
      } catch (error) {
          this.error = error;
      }
  }

  // Method to create and setting up labels as properties
  setUpTranslatedLabels(translatedLabelsInstance, translatedLabels) {
      //Add translation for defined tokenVsLabelsObject 
      if(this.tokenVsLabelsObject) {
        for (let property in this.tokenVsLabelsObject) {
            const value = translatedLabelsInstance.getTranslatedLabelByLabelName(this.tokenVsLabelsObject[property], translatedLabels)
            this[property] = value ? value : this[property];
        }
      }
      let options = [...this.options];
      let optionsUpdated = [];
      for(let row=0; row< options.length; row++) {
        let translatedLabel;
        let option = {...options[row]};
        if(option.value == "Support") {
          translatedLabel = translatedLabelsInstance.getTranslatedLabelByLabelName("MALL_CONTACT_US_SUPPORT", translatedLabels);
        }
        else if(option.value == "Compliment") {
          translatedLabel = translatedLabelsInstance.getTranslatedLabelByLabelName("MALL_CONTACT_US_COMPLIMENT", translatedLabels);
        }
        else if(option.value == "Complaint") {
          translatedLabel = translatedLabelsInstance.getTranslatedLabelByLabelName("MALL_CONTACT_US_COMPLAINT", translatedLabels);
        }
        option.translatedLabel = translatedLabel;
        optionsUpdated.push(option);
      }
      this.options = [...optionsUpdated];
  }

  renderedCallback() {
    if (!this.isFirstRender) {
      return;
    }
    addAnalyticsInteractions(this.template);
    this.isFirstRender = false;
    let codesList = [];
    let codes = this.countryCodes.split(",");
    codes.forEach((code) => {
      codesList.push({ label: "+" + code, value: code });
    });
    this.countryCodesList = codesList;

    if (this.isFormSubmitted && this.template.querySelector('c-mall-toast-notifcation')) {
      this.isFormSubmitted = false;
      this.showSpinner = false;
      this.showSuccessToast(); 
    }
  }

  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }

  options = [
      { label: "Support", value: "Support", selected: true, translatedLabel: "Support" },
      { label: "Compliment", value: "Compliment", selected: false, translatedLabel: "Compliment" },
      { label: "Complaint", value: "Complaint", selected: false,  translatedLabel: "Complaint"}
  ];


  get isFieldRequired() {
    return isGuest ? true : false;
  }

  get isFieldDisabled() {
    return !isGuest;
  }

  goBack() {
    history.back();
  }

  async getCountryContactUsEmail() {
    
    let mallUserSelectedCountry = getUserState(
      mallStateName.mallUserSelectedCountry,
      DEFAULT_MALL_COUNTRY
    );
    try {
      this.countryContactUsEmail = await getContactUsEmailByCountry({
        countryName: mallUserSelectedCountry
      });
      this.mailToCountryContactUsEmail = "mailto:" + this.countryContactUsEmail;
      
    } catch (error) {
      this.error = error;
    }
  }

  handleCaseTypeChange(event) {
    this.caseType = event.target.value;
  }

  handleNameChange(event) {
    this.suppliedName = event.target.value;
  }

  handleEmailChange(event) {
    this.suppliedEmail = event.target.value;
  }
  handleMobileNumberChange(event) {
    this.suppliedPhone = event.target.value;
  }

  handleDescriptionChange(event) {
    this.description = event.target.value;
  }

  handleSubjectChange(event) {
    this.subject = event.target.value;
  }

  async handleSaveCase() {
    const fields = {};
    fields[CASE_SUBJECT_FIELD.fieldApiName] = this.subject;
    fields[CASE_COMMENT_FIELD.fieldApiName] = this.description;
    fields[CASE_CASETYPE_FIELD.fieldApiName] = DEFAULT_CASETYPE;
    fields[CASE_CASESOURCE_FIELD.fieldApiName] = DEFAULT_ORIGIN;
    if(isGuest) {
      fields[CASE_WEB_NAME.fieldApiName] = this.suppliedName;
      fields[CASE_WEB_EMAIL.fieldApiName] = this.suppliedEmail;
      fields[CASE_WEB_PHONE.fieldApiName] = this.suppliedPhone;
    }
    else {
      fields[CASE_CONTACT_FIELD.fieldApiName] = this.contactId;;
    } 
    try {
      let error = this.handleSubmitCaseValidation();
      if(error) {
          this.showToast("Failure!", error, "error");
          return;
      }
      this.showSpinner = true;
      let caseId = await createCaseRecord({ caseRecord: fields });
      if(caseId) {
        let currentLocation = window.location.href;
        currentLocation += '?success=true';
        this.navigateToWebPage(currentLocation);
      } else {
        this.showToast("Failure!", "something went wrong.", "error");
      }
    } catch(error) {
      this.showToast("Failure!", error, "error");
      this.error = error;
    }
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  handleSubmitCaseValidation() {
    let errors = [];
    if(isGuest) {
      if(!this.suppliedName) {
        errors.push('Pleas enter your name');
      }
      if(!this.suppliedEmail) {
          errors.push('Please enter your email address');
      }
      if(!this.suppliedPhone) {
          errors.push('Please enter your phone');  
      }
    } 
    if(!this.subject) {
      errors.push('Please enter the subject of your message ');
    }
    if(!this.description) {
        errors.push('Please enter your message');
    }
    return errors.join(', ');
  }

  async fetchRelationshipManagerInfo() {
    try {
      const relationManagerInfo = await getRelationshipManagerInfo();
      this.relationManagerInfo = {...relationManagerInfo};
      console.log(JSON.stringify(relationManagerInfo));
    } catch(error) {
      console.log(JSON.stringify(error));
      this.error = error;
    }
  }
}