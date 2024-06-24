import { LightningElement } from "lwc";

const FRAUD_TITLE = "Fraud line";
const FRAUD_TEXT = "Report a new fraud incident";
const FRAUD_CONTACT = "0800 222 050";
const FRAUD_EMAIL_TITLE = "Email";
const FRAUD_EMAIL = "Reportfraud@standardbank.co.za";

export default class SbgFraud extends LightningElement {
  fraudTitle = FRAUD_TITLE;
  fraudText = FRAUD_TEXT;
  fraudContact = FRAUD_CONTACT;
  fraudEmailTitle = FRAUD_EMAIL_TITLE;
  fraudEmail = FRAUD_EMAIL;
  fraudEmailLink = "mailto:" + this.fraudEmail;
  fraudContactLink = "Tel:" + this.fraudContact;
}