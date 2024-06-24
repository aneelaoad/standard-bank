import { LightningElement, api, wire } from "lwc";
import isGuest from "@salesforce/user/isGuest";
import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";
import USER_ID from "@salesforce/user/Id";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME from "@salesforce/schema/User.Name";
import EMAIL from "@salesforce/schema/User.Email";
import getContactUsEmailByCountry from "@salesforce/apex/MallDataService.getContactUsEmailByCountry";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { mallStateName, getUserState } from "c/sbgUserStateUtils";
import { getBaseUrl } from "c/mallNavigation";
import { MallTranslationService } from 'c/mallTranslationService';
import MALL_CONTACT_US_FORM_TITLE from '@salesforce/label/c.MALL_CONTACT_US_FORM_TITLE';
import MALL_CONTACT_US_FORM_LABEL from '@salesforce/label/c.MALL_CONTACT_US_FORM_LABEL';
import MALL_APPRECIATION_MESSAGE_LABEL from '@salesforce/label/c.MALL_APPRECIATION_MESSAGE_LABEL';
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
import MALL_CONTACTUS_FEEDBACKMESSAGE from '@salesforce/label/c.MALL_CONTACTUS_FEEDBACKMESSAGE';
import MALL_SEND_EMAIL_MESSAGE_LABEL from '@salesforce/label/c.MALL_SEND_EMAIL_MESSAGE_LABEL';
import MALL_SEND_BUTTON_LABEL from '@salesforce/label/c.MALL_SEND_BUTTON_LABEL';
import getORGId from '@salesforce/apex/MallDataService.getORGId';

const DEFAULT_MALL_COUNTRY = "South Africa";

export default class SbgContactUs extends LightningElement {
  isFormSubmitted = false;
  returnUrl = getBaseUrl() + "/mall/s/contact-us?success=true";
  selectedType = "Support";
  countryCodesList = [];
  selectedCountryCode;
  isFirstRender = true;
  name = "";
  email = "";
  countryContactUsEmail;
  mailToCountryContactUsEmail;

  backIcon = sbgVisualAssets + "/icn_chevron_left.svg";
  sendMessageIcon = sbgVisualAssets + "/send_message.svg";

  contactUsTitle = MALL_CONTACT_US_FORM_TITLE;
  contactUsFormLabel = MALL_CONTACT_US_FORM_LABEL;
  appreciationMessageLabel = MALL_APPRECIATION_MESSAGE_LABEL;
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
  feedbackMessage = MALL_CONTACTUS_FEEDBACKMESSAGE;
  sendEmailMessageLabel = MALL_SEND_EMAIL_MESSAGE_LABEL;
  sendButtonLabel = MALL_SEND_BUTTON_LABEL;

  buttonInteractionIntent;
  buttonInteractionScope;
  buttonInteractionType;
  buttonInteractionText;
  buttonInteractionTextBefore;
  webToCaseUrl = getBaseUrl() + '/servlet/servlet.WebToCase?encoding=UTF-8';
  organizationId;

  @api countryCodes;
  @api hours;

  @wire(getRecord, { recordId: USER_ID, fields: [NAME, EMAIL] })
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

  async getOrgnizationId() {
    try{
      let orgId = await getORGId();
      this.organizationId = orgId;
    }catch(error) {
      this.error = error;
    }
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
    this.getOrgnizationId();
    this.getCountryContactUsEmail();

  }

  



  showSuccessToast() {
    this.template.querySelector('c-mall-toast-notifcation').showToast('success', this.feedbackMessage, this.contactUsThankYouNote);
  }

  //Code to setup the translations for the labels
  tokenVsLabelsObject = {
    "contactUsTitle" : "MALL_CONTACT_US_FORM_TITLE",
    "contactUsFormLabel" : "MALL_CONTACT_US_FORM_LABEL",
    "appreciationMessageLabel" : "MALL_APPRECIATION_MESSAGE_LABEL",
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
    "sendEmailMessageLabel" : "MALL_SEND_EMAIL_MESSAGE_LABEL",
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
}