import {
  LightningElement,
  track,
  api
} from 'lwc';
import {
  FlowNavigationNextEvent,
} from 'lightning/flowSupport';
import {
  loadScript
} from 'lightning/platformResourceLoader';
import { getErrorMessage } from 'c/aob_comp_utils';
import { NavigationMixin } from "lightning/navigation";
import fetchingPhoneNumber from '@salesforce/apex/AOB_CTRL_FormCreator.fetchPhoneNumber';
import getOtpValue from '@salesforce/apex/AOB_SRV_OTP.getOtpValue';
import callValidateOTP from '@salesforce/apex/AOB_SRV_OTP.callValidateOTP';
import getOtpController from '@salesforce/apex/AOB_SRV_OTP.getOtpController';
import checkResendOtp from '@salesforce/apex/AOB_API_OTPJS.checkResendOtp';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import incrementRetryApplication from '@salesforce/apex/AOB_CTRL_FindApplications.incrementRetryApplication';
import createExternalLead from "@salesforce/apex/AOB_API_BusinessLead_CTRL.callBusinessLead";
import setApplicationStep from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationStep';
import CallCompleteApplication from '@salesforce/apex/AOB_SRV_CompleteApplication.callCompleteApplicationAPI';
import getApplicantDataForAdobe from '@salesforce/apex/AOB_CTRL_FormCreator.getApplicantDataForAdobe';

const RETRY_NUMBER = 1;
export default class Aob_comp_OtpIdentification extends NavigationMixin(LightningElement) {
 @api teams = ["Self Assisted"];
    label = {};
  @api applicationId;
  @api selectedCard;
  @api screenName;
  @api previousScreen;
  @api nextScreen;
  displayphonefield;
  @track OTPsecurity;
  mobileNo;
  qName;
  otpAttemptsMessage;
  showOTPAttemps = false;
  failing;
  message;
  phonedisplay = '+27******';
  otpError;
  showError = false;
  @api adobeDataScope;
  @api adobePageName;
  @api productCategory;
  @api productName;
  siteErrorCode;
  adobeDataScopeApp;
  retryValue = 0;
  isGetOTPSuccess = false;
  isValidateOTPSucess = false;
  adobeDataTextBack;
  adobeformName;
  adobeDataTextContinue;
  disableResend = false;
  isLoaded;
  technicalerror;
  customerDataError;
  customerErrorMessage;
  application = {
    applicationProduct: this.adobeDataScope,
    applicationMethod: "Online",
    applicationID: "",
    applicationName: "",
    applicationStep: "",
    applicationStart: true,
    applicationComplete: false
  }
  userInfo = {
    bpguid: "",
    encryptedUsername: ""
  }
  constructor() {
    super();
    this.isMobileDevice = window.matchMedia("only screen and (max-width:576px)").matches;
  }
  connectedCallback() {
    getApplicantDataForAdobe({
      'applicationId': this.applicationId
    }).then(result => {
      let Response = JSON.parse(result);
      this.userInfo.encryptedUsername = Response['customerEmail'];
      this.userInfo.bpguid = Response['customerGUID'];
      this.userInfo.bpguid = this.userInfo.bpguid.split('-').join('');
      this.userInfo.bpguid = this.userInfo.bpguid.toUpperCase();
      window.fireUserInfoEvent(this, this.userInfo);
    }).catch(error => {
      this.failing = true;
      this.isLoaded = true;
      this.errorMessage = getErrorMessage.call(this, error);
      window.fireErrorCodeEvent(this, this.errorMessage);
    });
    this.productName = this.productName.toLowerCase();
    this.adobeDataScopeApp = this.productName + ' application';
    this.adobeDataScopeApp = this.adobeDataScopeApp.toLowerCase();
    this.adobeDataTextBack = 'enter one-time pin | Resend button click';
    this.adobeDataTextContinue = 'enter one-time pin |  Submit button click';
    this.application.applicationID = this.applicationId;
    this.application.applicationName = 'Application: ' + this.productName + ' business account';
    this.application.applicationProduct = this.productName + ' business account';
    this.application.applicationStep = this.adobeDataScope;
    this.isLoaded = false;
    this.adobePageTag = 'business:' + 'products and services:bank with us:business bank accounts: ' + this.productName + " account origination " + this.adobeDataScope + ' enter one-time pin form';
    this.adobeformName = "apply now " + 'business bank account ' + this.productName + ' account origination ' + this.adobeDataScope + ' enter one-time pin form';
    loadScript(this, FireAdobeEvents).then(() => { //Adobe tagging start
      if (!this.isEventFired) {
        this.isEventFired = true;
        //application start event fire
        window.fireScreenLoadEvent(this, this.adobePageTag);
        window.fireFormStart(this, this.adobeformName);
        window.fireFormStartEvent(this, this.application);

      }
    });
    setApplicationStep({
      'applicationId': this.applicationId,
      'currentScreen': this.screenName,
      'previousScreen': this.previousScreen
    }).then(result => {
      this.failing = false;
    }).catch(error => {
      this.failing = true;
      this.isLoaded = true;
      this.errorMessage = getErrorMessage.call(this, error);
      window.fireErrorCodeEvent(this, this.errorMessage);
    });
    fetchingPhoneNumber({
      'appId': this.applicationId
    }).then(result => {
      let Response = JSON.parse(result);
      if (Response['PhoneNumber'] != null) {
        var lastthreedigits;
        this.mobileNo = Response['PhoneNumber'];
        lastthreedigits = Response['PhoneNumber'].substring(7, 10);
        this.displayphonefield = this.phonedisplay.concat(lastthreedigits);
        this.getOTPAcessToken();
      }
    }).catch(error => {
      this.isLoaded = true;
    });

  }
   handleResultChange(event) {
        this.label = event.detail;
    }
  contactChangeVal(event) {
    this.OTPsecurity = event.target.value;
  }

  getOTPAcessToken() {
    getOtpController({ 'applicationId': this.applicationId }).then(result => {
      if (result != null) {
        this.callGetOTP(result);
      }
    }).catch(error => {
      this.isLoaded = true;
    });
  }

  validateOTPAcessToken() {
    getOtpController({ 'applicationId': this.applicationId }).then(result => {
      if (result != null) {
        this.verifyOTP(result);
      }
    }).catch(error => {
      this.isLoaded = true;
    });

  }


  callGetOTP(accessToken) {
    getOtpValue({
      'phoneNumber': this.mobileNo,
      'applicationId': this.applicationId,
      'accessToken': accessToken
    }).then(result => {
      this.qName = result.qName;
      if (result.message == 'OK') {
        this.isGetOTPSuccess = true;
        this.isLoaded = true;
      }
      else {
        if (this.retryValue === RETRY_NUMBER) {
          let leadReason = 'callGetOTP API failed ';
          this.createLeadForAPI(leadReason);
        } else {
          this.isLoaded = true;
          this.technicalerror = true;
          this.customerErrorMessage = result.message;
        }
        this.siteErrorCode = 'business error | ' + this.customerErrorMessage;
        window.fireErrorEvent(this, this.siteErrorCode);

      }
    }).catch(error => {
      this.errorMessage = getErrorMessage.call(this, error);
      if (this.retryValue === RETRY_NUMBER) {
        let leadReason = 'callGetOTP API failed ';
        this.createLeadForAPI(leadReason);
      }
      this.isLoaded = true;
      this.technicalerror = true;

    });
  }
  continuetonextpage(event) {
    window.fireButtonClickEvent(this, event);
    this.showError = false;
    this.isLoaded = false;
    this.validateOTPAcessToken();
    window.fireFormCompleteEvent(this, this.adobeformName);
  }

  verifyOTP(accessToken) {
    callValidateOTP({
      'phoneNumber': this.mobileNo,
      'num': this.OTPsecurity,
      'qname': this.qName,
      'applicationId': this.applicationId,
      'accessToken': accessToken
    }).then(result => {
      if (result == 'OK') {
        this.isValidateOTPSucess = true;
        this.callUpdateApplicationCompleteAPI();
      }
      else {

        this.showError = true;
        this.otpError = result;
        this.isLoaded = true;
      }
    }).catch(error => {
      if (this.retryValue === RETRY_NUMBER) {
        let leadReason = 'validate OTP API failed';
        this.createLeadForAPI(leadReason);
      }
      this.errorMessage = getErrorMessage.call(this, error);
      this.isLoaded = true;
      this.technicalerror = true;
    });
  }


  callUpdateApplicationCompleteAPI() {
    CallCompleteApplication({
      'applicationId': this.applicationId
    }).then(result => {
      if (result == '200') {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
      } else if (result != '200') {
        if (this.retryValue === RETRY_NUMBER) {
          let leadReason = 'CallCompleteApplication API failed ';
          this.createLeadForAPI(leadReason);
        }
        else {
          if (this.retryValue === RETRY_NUMBER) {
            let leadReason = 'CallCompleteApplication API failed ';
            this.createLeadForAPI(leadReason);
          } else {
            this.isLoaded = true;
            this.technicalerror = true;
            this.failing = true;
          }
        }
      }
    }).catch(error => {
      if (this.retryValue === RETRY_NUMBER) {
        let leadReason = 'CallCompleteApplication API failed ';
        this.createLeadForAPI(leadReason);
      } else {
        this.errorMessage = getErrorMessage.call(this, error);
        this.isLoaded = true;
        this.failing = true;
        this.technicalerror = true;
      }
    });
  }


  resendOTP(event) {
    this.showError = false;
    this.isLoaded = false;
    checkResendOtp({
      'applicationId': this.applicationId
    }).then(result => {
      this.showOTPAttemps = true;
      this.otpAttemptsMessage = `OTP Attempts ${result.userAttempts} of ${result.totalAttempts}`;
      this.siteErrorCode = 'Client Side | ' + this.otpAttemptsMessage;
      window.fireErrorEvent(this, this.siteErrorCode);
      if (result.Status) {
        this.otpError = 'You have exceeded Maximum OTP limits.Please contact Admin';
        this.disableResend = true;
        this.showError = true;
        this.isLoaded = true;
        this.siteErrorCode = 'Client Side | ' + this.otpError;
        window.fireErrorEvent(this, this.siteErrorCode);
      } else {
        this.isLoaded = false;
        this.getOTPAcessToken();
      }
    }).catch(error => {
      this.isLoaded = true;
      this.failing = true;
    });
    window.fireButtonClickEvent(this, event);
  }

  retryInitiateAPI(event) {
    this.technicalerror = false;
    this.isLoaded = false;
    incrementRetryApplication({
      'applicationId': this.applicationId
    }).then(response => {
      this.retryValue = parseInt(response);
      if (this.retryValue <= RETRY_NUMBER) {
        if (!this.isGetOTPSuccess) {
          this.getOTPAcessToken();
        } else if (!this.isValidateOTPSucess) {
          this.validateOTPAcessToken();
        }
        else {
          this.callUpdateApplicationCompleteAPI();
        }
      }
    }).catch(error => {
      this.isLoaded = true;
    });
  }

  createLeadForAPI(leadReason) {
    createExternalLead({
      applicationId: this.applicationId,
      leadReason: leadReason
    }).then((result) => {
      this.isLoading = false;
      this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
          name: 'PreApplication_Automatic_Lead__c'
        }
      });
    }).catch((error) => {
      this.isLoading = true;
      this.errorMessage = getErrorMessage.call(this, error);
      this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
      window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
    });
  }
}