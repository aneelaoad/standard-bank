import { LightningElement, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import isGuest from "@salesforce/user/isGuest";
import NAME from "@salesforce/schema/User.Name";
import EMAIL from "@salesforce/schema/User.Email";
import USER_ID from "@salesforce/user/Id";
import CONTACTID from "@salesforce/schema/User.ContactId";
import CASE_CONTACT_FIELD from "@salesforce/schema/Case.ContactId";
import CASE_WEB_NAME from "@salesforce/schema/Case.SuppliedName";
import CASE_WEB_EMAIL from "@salesforce/schema/Case.SuppliedEmail";
import CASE_SUBJECT_FIELD from "@salesforce/schema/Case.Subject";
import CASE_DESCRIPTION_FIELD from "@salesforce/schema/Case.Description";
import CASE_COMMENT_FIELD from "@salesforce/schema/Case.Comment__c";
import CASE_CASESOURCE_FIELD from "@salesforce/schema/Case.Origin";
import CASE_CASETYPE_FIELD from "@salesforce/schema/Case.Case_Type__c";
import { addAnalyticsInteractions } from "c/mallAnalyticsTagging";
import { MallTranslationService } from 'c/mallTranslationService';
import MALL_SHOP_FORM_TEXT_TITLE from '@salesforce/label/c.MALL_SHOP_FORM_TEXT_TITLE';
import MALL_NO_SHOP_TEXT from '@salesforce/label/c.MALL_NO_SHOP_TEXT';
import MALL_FULL_NAME_LABEL from '@salesforce/label/c.MALL_FULL_NAME_LABEL';
import MALL_PLACEHOLDER_FULL_NAME from '@salesforce/label/c.MALL_PLACEHOLDER_FULL_NAME';
import MALL_EMAIL_ADDRESS_LABEL from '@salesforce/label/c.MALL_EMAIL_ADDRESS_LABEL';
import MALL_PLACEHOLDER_EMAIL_ADDRESS from '@salesforce/label/c.MALL_PLACEHOLDER_EMAIL_ADDRESS';
import MALL_SHOP_SUGGESTION_TITLE_LABEL from '@salesforce/label/c.MALL_SHOP_SUGGESTION_TITLE_LABEL';
import MALL_PLACEHOLDER_SHOP_SUGGESTION_TITLE from '@salesforce/label/c.MALL_PLACEHOLDER_SHOP_SUGGESTION_TITLE';
import MALL_CONTACT_SUGGESTED_SHOP_LABEL from '@salesforce/label/c.MALL_CONTACT_SUGGESTED_SHOP_LABEL';
import MALL_PLACEHOLDER_CONTACT_SHOP_SUGGESTION_TITLE from '@salesforce/label/c.MALL_PLACEHOLDER_CONTACT_SHOP_SUGGESTION_TITLE';
import MALL_SEND_BUTTON_LABEL from '@salesforce/label/c.MALL_SEND_BUTTON_LABEL';
import MALL_THANK_YOU_NOTE from '@salesforce/label/c.MALL_THANK_YOU_NOTE';
import MALL_ADDITIONAL_NOTE from '@salesforce/label/c.MALL_ADDITIONAL_NOTE';
import MALL_SEND_ANOTHE_BUTTON_LABEL from '@salesforce/label/c.MALL_SEND_ANOTHE_BUTTON_LABEL';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCaseRecord from "@salesforce/apex/MallCaseManagementUtil.createCaseRecord";
import { NavigationMixin } from "lightning/navigation";
import { navigateToWebPage } from "c/mallNavigation";

const DEFAULT_CASETYPE = "Store suggestion";
const DEFAULT_SUBJECT = "Store suggestion"
const DEFAULT_ORIGIN = "BCB Platform";


export default class MallShopSuggestionForm extends NavigationMixin(LightningElement) {
  suppliedName = "";
  suppliedEmail = "";
  description = "";
  comment = "";
  showSpinner = false;

  isSuggestionSubmitted = false;
  shopFormTextTitle = MALL_SHOP_FORM_TEXT_TITLE;
  noShopText =  MALL_NO_SHOP_TEXT;
  fullNameLabel = MALL_FULL_NAME_LABEL;
  placeholderFullName = MALL_PLACEHOLDER_FULL_NAME;
  emailAddressLabel = MALL_EMAIL_ADDRESS_LABEL;
  placeholderEmailAddress = MALL_PLACEHOLDER_EMAIL_ADDRESS;
  shopSugegestionTitleLabel = MALL_SHOP_SUGGESTION_TITLE_LABEL;
  placeholderShopSugegestionTitle = MALL_PLACEHOLDER_SHOP_SUGGESTION_TITLE;
  contactSuggestedShopLabel = MALL_CONTACT_SUGGESTED_SHOP_LABEL;
  placeholderContactSuggestedShopLabel= MALL_PLACEHOLDER_CONTACT_SHOP_SUGGESTION_TITLE;
  sendButtonLabel = MALL_SEND_BUTTON_LABEL;
  thankYouNote = MALL_THANK_YOU_NOTE;
  additionalNote = MALL_ADDITIONAL_NOTE;
  sendAnotherButtonLabel = MALL_SEND_ANOTHE_BUTTON_LABEL;

  buttonInteractionIntent;
  buttonInteractionScope;
  buttonInteractionType;
  buttonInteractionText;
  buttonInteractionTextBefore;
  organizationId;


  buttonInteractionIntent;
  buttonInteractionScope;
  buttonInteractionType;
  buttonInteractionText;
  buttonInteractionTextBefore;

  navigateToWebPage = navigateToWebPage.bind(this);

  get isFieldRequired() {
    return isGuest ? true : false;
  }

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

  renderedCallback() {
    addAnalyticsInteractions(this.template);
    if (this.isSuggestionSubmitted && this.template.querySelector('c-mall-toast-notifcation')) {
      this.isSuggestionSubmitted = false;
      this.showSpinner = false;
      this.showSuccessToast();      
    }
  }

  showSuccessToast() {
    this.template.querySelector('c-mall-toast-notifcation').showToast('success', this.additionalNote, this.thankYouNote);
  }

  connectedCallback() {
    this.getTranslatedLabels();
    this.getOrgnizationId();
    const param = "success";
    const paramValue = this.getUrlParamValue(window.location.href, param);
    if (paramValue) {
      this.isSuggestionSubmitted = paramValue;
    }
  }

  async getOrgnizationId() {
    try{
      let orgId = await getORGId();
      this.organizationId = orgId;
    }catch(error) {
      this.error = error;
    }
  }

  //Code to setup the translations for the labels
  tokenVsLabelsObject = {
    "shopFormTextTitle" : "MALL_SHOP_FORM_TEXT_TITLE",
    "noShopText" :  "MALL_NO_SHOP_TEXT",
    "fullNameLabel" : "MALL_FULL_NAME_LABEL",
    "placeholderFullName" : "MALL_PLACEHOLDER_FULL_NAME",
    "emailAddressLabel" : "MALL_EMAIL_ADDRESS_LABEL",
    "placeholderEmailAddress" : "MALL_PLACEHOLDER_EMAIL_ADDRESS",
    "shopSugegestionTitleLabel" : "MALL_SHOP_SUGGESTION_TITLE_LABEL",
    "placeholderShopSugegestionTitle" : "MALL_SHOP_SUGGESTION_TITLE",
    "contactSuggestedShopLabel" : "MALL_CONTACT_SUGGESTED_SHOP_LABEL",
    "placeholderContactSuggestedShopLabel" : "MALL_CONTACT_SHOP_SUGGESTION",
    "sendButtonLabel" : "MALL_SEND_BUTTON_LABEL",
    "thankYouNote" : "MALL_THANK_YOU_NOTE",
    "additionalNote" : "MALL_ADDITIONAL_NOTE",
    "sendAnotherButtonLabel" : "MALL_SEND_ANOTHE_BUTTON_LABEL"
  }

  //get the translated labels
  async getTranslatedLabels() {
      try {
      const translatedLabelsInstance = MallTranslationService.getInstance();
      const translatedLabels = await translatedLabelsInstance.getTranslatedLabels();
      this.setUpTranslatedLabels(translatedLabelsInstance);
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
  }

  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }

  sendAnotherSuggestion() {
    this.isSuggestionSubmitted = false;
  }

  handleNameChange(event) {
    this.suppliedName = event.target.value;
  }

  handleEmailChange(event) {
    this.suppliedEmail = event.target.value;
  }

  handleDescriptionChange(event) {
    this.description = event.target.value;
  }

  handleCommentChange(event) {
    this.comment = event.target.value;
  }

  async handleSaveCase() {
    const fields = {};
    fields[CASE_SUBJECT_FIELD.fieldApiName] = DEFAULT_SUBJECT;
    fields[CASE_DESCRIPTION_FIELD.fieldApiName] = this.description;
    fields[CASE_COMMENT_FIELD.fieldApiName] = this.comment;
    fields[CASE_CASETYPE_FIELD.fieldApiName] = DEFAULT_CASETYPE;
    fields[CASE_CASESOURCE_FIELD.fieldApiName] = DEFAULT_ORIGIN;
    if(isGuest) {
      fields[CASE_WEB_NAME.fieldApiName] = this.suppliedName;
      fields[CASE_WEB_EMAIL.fieldApiName] = this.suppliedEmail;
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
    } 
    if(!this.description) {
        errors.push('Please enter your message');
    }
    return errors.join(', ');
  }
}