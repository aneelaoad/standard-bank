/**
 * @description  : Partner Portal Registration From Component
 * User Story : SFP-5159
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date July 2021
 */
import { LightningElement, track, api } from "lwc";
import Assets from "@salesforce/resourceUrl/PP_Assets";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import partnershipRegistration from "@salesforce/apex/PP_RegistrationForm_CTRL.partnershipRegistration";
import partnershipUpdate from "@salesforce/apex/PP_RegistrationForm_CTRL.partnershipUpdate";
import partnershipRegistrationUpdate from "@salesforce/apex/PP_RegistrationForm_CTRL.partnershipRegistrationUpdate";
import initialiseOTPCode from "@salesforce/apex/PP_RegistrationForm_CTRL.initialiseOTPCode";
import validateOTPCode from "@salesforce/apex/PP_RegistrationForm_CTRL.validateOTPCode";

import { trackLink } from "c/ppEventUtils";

export default class PPRegistrationContainer extends LightningElement {
    @api termsAndConditionText;
    logo;
    backgroundImage;
    currentStep = 1;
    backBtnFlag = false;
    nextBtn = true;
    objRegistrationDetails;
    @track
    registrationData = new Map();

    /*Partner Application Id*/
    partnerApplicationId;
    relatedRecordEmailField;

    isProcessing = false;
    guid;
    stepDetailNext;
    stepDetailBack;

    counter = 1;
    refreshCounter;
    @track disabled = false;
    isResendOTP = false;
    interval;
    /*
     * @author Areeba Khan (areeba.khan@standardbank.co.za)
     * @date December 2022
     */
    ResendOTP() {
        /*This element will hide and show the Resend and countdown message */

        /*Hide Resend OTP option and start the countdown after the email is being sent.*/
        this.disabled = true;
        this.InitialiseOTPMethod();
        /*The countdown code*/
        this.interval = setInterval(
            function () {
                if (this.refreshCounter == 1) {
                    this.counter = 1;
                    this.refreshCounter = 0;
                    this.disabled = false;
                    clearInterval(interval);
                }
                this.refreshCounter = 60 - this.counter++;
            }.bind(this),
            1000
        );
    }
    get ringCounter() {
        return (100 / 60) * this.refreshCounter;
    }
    InitialiseOTPMethod() {
        initialiseOTPCode({
            relatedRecordId: this.partnerApplicationId,
        })
            .then((response) => {
                if (!response.isSuccess) {
                    this.showMessage("Notification", response.message, "error");
                }
            })
            .catch((error) => {
                this.isProcessing = false;
                this.showMessage("Notification", "Server Error");
            });
    }

    connectedCallback() {
        this.backgroundImage = Assets + "/images/reg-bg.jpg";
        this.logo = Assets + "/logos/logo.png";
        this.stepDetailNext = "your Contact details | next button click";
        this.generateGuid();

        //Adobe Analytics
        this.adobeAnalyticsPageView();

        document.dispatchEvent(
            new CustomEvent("triggerInteraction", {
                detail: {
                    eventName: "triggerApplicationStart",
                    pageName: "Registration:Step 1",
                    pageSubSection1: "Registration:Step 1",
                    application: {
                        applicationID: this.guid,
                        applicationStep: "Step 1",
                        applicationName: "Register for PartnerConnect",
                        applicationStart: true,
                        applicationComplete: false,
                    },
                    loginStatus: "guest",
                    userLoginSuccess: "false",
                    userRegistrationSuccess: "false",
                },
            })
        );
    }

    handleNext(event) {
        this.tracker(event);

        if (this.currentStep == 1) {
            if (this.validate("c-pp-communication-details")) {
                this.setorUpdateRegistrationData("c-pp-communication-details");

                this.registration();
                //Adobe Analytics
                this.adobeAnalyticsPageView();
                this.adobeAnalyticsFormCompleted();
                document.dispatchEvent(
                    new CustomEvent("triggerInteraction", {
                        detail: {
                            eventName: "",
                            pageName: "Registration:Step 2",
                            pageSubSection1: "Registration:Step 2",
                            application: {
                                applicationID: this.guid,
                                applicationStep: "Step 2",
                                applicationName: "Register for PartnerConnect",
                                applicationStart: true,
                                applicationComplete: false,
                            },
                        },
                    })
                );
            }
        } else if (this.currentStep == 2) {
            this.setorUpdateRegistrationData("c-pp-O-T-P-Verification");
            var otp = this.registrationData.get("otpcode");

            /*Verify the OTP code*/
            if (otp == undefined || otp === null || otp === "") {
                this.showMessage("Notification", "You have not entered the required OTP. Please enter the OTP from your email.", "error");
            } else if (otp != undefined && otp !== null) {
                /*call the apex method to check the otp codes*/
                validateOTPCode({
                    inputCode: otp,
                    relatedRecordId: this.partnerApplicationId,
                }).then((response) => {
                    if (!response.isSuccess) {
                        this.showMessage("Notification", response.message, "error");
                    } else {
                        this.showMessage("Notification", "Thank you! Your OTP verification is successful", "success");
                        this.currentStep = 3;
                        this.backBtnFlag = false; /*Hide Back button on company page after the code gets verified*/
                        this.stepDetailNext = "your business idea | next button click";
                        this.stepDetailBack = "your business idea | back button click";
                        this.isResendOTP = false;
                        this.backBtnFlag = false; /*Hide back button on company page after the otp gets verified*/
                        //Adobe Analytics
                        this.adobeAnalyticsPageView();
                        this.adobeAnalyticsFormCompleted();
                        document.dispatchEvent(
                            new CustomEvent("triggerInteraction", {
                                detail: {
                                    eventName: "",
                                    pageName: "Registration:Step 3",
                                    pageSubSection1: "Registration:Step 3",
                                    application: {
                                        applicationID: this.guid,
                                        applicationStep: "Step 3",
                                        applicationName: "Register for PartnerConnect",
                                        applicationStart: true,
                                        applicationComplete: false,
                                    },
                                },
                            })
                        );
                    }
                });
            }
        } else if (this.currentStep == 3) {
            if (this.validate("c-pp-Company-Information")) {
                this.currentStep = 4;
                this.setorUpdateRegistrationData("c-pp-Company-Information");
                this.stepDetailNext = "your business idea  | next button click";
                this.stepDetailBack = "your business idea | back button click";
                this.backBtnFlag = true; /*Show back button on other pages*/

                //Adobe Analytics
                this.adobeAnalyticsPageView();
                this.adobeAnalyticsFormCompleted();
                document.dispatchEvent(
                    new CustomEvent("triggerInteraction", {
                        detail: {
                            eventName: "",
                            pageName: "Registration:Step 4",
                            pageSubSection1: "Registration:Step 4",
                            application: {
                                applicationID: this.guid,
                                applicationStep: "Step 4",
                                applicationName: "Register for PartnerConnect",
                                applicationStart: true,
                                applicationComplete: false,
                            },
                        },
                    })
                );
            }
        } else if (this.currentStep == 4) {
            if (this.validate("c-pp-partnership-goal")) {
                this.currentStep = 5;
                this.setorUpdateRegistrationData("c-pp-partnership-goal");
                this.stepDetailNext = "your business idea | next button click";
                this.stepDetailBack = "your business idea | back button click";

                //Adobe Analytics
                this.adobeAnalyticsPageView();
                this.adobeAnalyticsFormCompleted();
                document.dispatchEvent(
                    new CustomEvent("triggerInteraction", {
                        detail: {
                            eventName: "",
                            pageName: "Registration:Step 5",
                            pageSubSection1: "Registration:Step 5",
                            application: {
                                applicationID: this.guid,
                                applicationStep: "Step 5",
                                applicationName: "Register for PartnerConnect",
                                applicationStart: true,
                                applicationComplete: false,
                            },
                        },
                    })
                );
            }
        } else if (this.currentStep == 5) {
            if (this.validate("c-pp-brief-description")) {
                this.setorUpdateRegistrationData("c-pp-brief-description");
                this.updatePartnerApplication();
            }
        }
    }

    handleBack(event) {
        this.tracker(event);
        if (this.currentStep !== 2) {
            let nextBtn = this.template.querySelector('[data-id="next-btn"]');
            nextBtn.className = "slds-button slds-button_neutral btn btn-next";
        }
        if (this.currentStep == 5) {
            this.stepDetailNext = "your business idea | next button click";
            this.stepDetailBack = "your business idea | back button click";
            this.currentStep = 4;
        } else if (this.currentStep == 4) {
            this.stepDetailNext = "your business idea | next button click";
            this.stepDetailBack = "your business idea | back button click";
            this.currentStep = 3;
            this.backBtnFlag = false; /*Hide back button on company information page*/
        } else if (this.currentStep == 3) {
            this.stepDetailNext = "your partnership goal | next button click";
            this.stepDetailBack = "your partnership goal | back button click";
            this.currentStep = 2;
        } else if (this.currentStep == 2) {
            this.stepDetailNext = "your communication details | next button click";
            let nextBtn = this.template.querySelector('[data-id="next-btn"]');
            nextBtn.className = "slds-button slds-button_neutral btn next-btn";
            this.isResendOTP = false;
            this.backBtnFlag = false; /*Hide back button on Communication details*/
            this.currentStep = 1;
        }
    }

    setorUpdateRegistrationData(cmpName) {
        const updatedDetails = this.template.querySelector(cmpName);
        let registrationDetails = updatedDetails.updatedRegistrationDetails();
        this.registrationData = new Map([...this.registrationData, ...registrationDetails]);
    }
    updatePartnerApplication() {
        this.isProcessing = true;

        /*First check if partnerApplicationId variable has a value*/
        if (this.partnerApplicationId != null && this.partnerApplicationId != undefined) {
            let partnership = { sobjectType: "PP_PartnerApplication__c" };
            partnership.Id = this.partnerApplicationId;
            partnership.Name = this.registrationData.get("business_name");
            partnership.PP_RegistrationNumber__c = this.registrationData.get("registration_no");
            partnership.PP_Industry__c = this.registrationData.get("industry");
            partnership.PP_Capabilities__c = this.registrationData.get("capabilities");
            partnership.PP_PartnershipGoal__c = this.registrationData.get("partnershipValues");
            partnership.PP_Partnership_Goal__c = this.registrationData.get("partnershipValues");
            partnership.PP_OperatingCountry__c = this.registrationData.get("country");
            partnership.PP_SolutionDetails__c = this.registrationData.get("description");
            partnership.PP_FirstName__c = this.registrationData.get("fistName");
            partnership.PP_LastName__c = this.registrationData.get("lastName");
            partnership.PP_EmailAddress__c = this.registrationData.get("emailId");
            partnership.PP_Website__c = this.registrationData.get("companyWebsite");
            partnership.PP_ApplicationStatus__c = "New";
            partnership.PP_LinkedInProfile__c = this.registrationData.get("linkedInProfile");
            partnership.PP_TermsConditionsAccepted__c = this.registrationData.get("termsAndCondition");
            partnership.PP_PartnershipGoalOther__c = this.registrationData.get("partnershipGoalOther");
            partnership.PP_Currency__c = this.registrationData.get("currency");
            partnership.PP_AnnualBusinessTurnover__c = this.registrationData.get("turnover");
            partnership.PP_Mobile_Number__c = this.registrationData.get("phoneNumber");
            let fileDate = this.registrationData.get("fileData");
            let base64;
            let filename;
            if (fileDate) {
                base64 = fileDate.base64;
                filename = fileDate.filename;
            }

            partnershipUpdate({
                registrationDetails: partnership,
                base64: base64,
                filename: filename,
            })
                .then((response) => {
                    this.isProcessing = false;
                    this.currentStep = 6;
                    this.nextBtn = false;
                    this.backBtnFlag = false;

                    //Adobe Analytics
                    this.adobeAnalyticsPageView();
                    this.adobeAnalyticsFormCompleted();
                    document.dispatchEvent(
                        new CustomEvent("triggerInteraction", {
                            detail: {
                                eventName: "triggerApplicationComplete",
                                pageName: "Registration:Step 5",
                                pageSubSection1: "Registration:Step 5",
                                formName: "Group | Register | Thank You",
                                userRegistrationSuccess: true,
                                application: {
                                    applicationID: this.guid,
                                    applicationStep: "Step 5",
                                    applicationName: "Register for PartnerConnect",
                                    applicationStart: true,
                                    applicationComplete: true,
                                },
                            },
                        })
                    );
                })
                .catch((error) => {
                    this.isProcessing = false;
                    this.toast("Server Error", "error");
                });
        }
    }
    registration() {
        this.isProcessing = true;
        let partnership = { sobjectType: "PP_PartnerApplication__c" };
        partnership.PP_FirstName__c = this.registrationData.get("fistName");
        partnership.PP_LastName__c = this.registrationData.get("lastName");
        partnership.PP_Mobile_Number__c = this.registrationData.get("phoneNumber");
        partnership.PP_EmailAddress__c = this.registrationData.get("emailId");
        partnership.PP_Website__c = this.registrationData.get("companyWebsite");
        partnership.PP_LinkedInProfile__c = this.registrationData.get("linkedInProfile");
        partnership.PP_TermsConditionsAccepted__c = this.registrationData.get("termsAndCondition");

        /*First check if partnerApplicationId variable has a value*/
        if (this.partnerApplicationId != null && this.partnerApplicationId != undefined) {
            partnership.Id = this.partnerApplicationId;
            partnershipRegistrationUpdate({
                registrationDetails: partnership,
            })
                .then((response) => {
                    /*Generate and Initialise OTP methods*/
                    this.InitialiseOTPMethod();

                    this.isProcessing = false;
                    this.currentStep = 2;
                    this.backBtnFlag = true;
                    this.isResendOTP = true;
                    let nextBtn = this.template.querySelector('[data-id="next-btn"]');
                    nextBtn.className = "slds-button slds-button_neutral btn btn-next";
                    this.stepDetailNext = "Enter OTP | next button click";
                    this.stepDetailBack = "Enter OTP | back button click";

                    //Adobe Analytics
                    this.adobeAnalyticsPageView();
                    this.adobeAnalyticsFormCompleted();
                    document.dispatchEvent(
                        new CustomEvent("triggerInteraction", {
                            detail: {
                                eventName: "triggerApplicationComplete",
                                pageName: "Registration:Step 5",
                                pageSubSection1: "Registration:Step 5",
                                formName: "Group | Register | Thank You",
                                userRegistrationSuccess: true,
                                application: {
                                    applicationID: this.guid,
                                    applicationStep: "Step 5",
                                    applicationName: "Register for PartnerConnect",
                                    applicationStart: true,
                                    applicationComplete: true,
                                },
                            },
                        })
                    );
                })
                .catch((error) => {
                    this.isProcessing = false;
                    this.toast("Server Error", "error");
                });
        } else if (this.partnerApplicationId == null || this.partnerApplicationId == undefined) {
            partnershipRegistration({
                registrationDetails: partnership,
            })
                .then((response) => {
                    this.partnerApplicationId = response;
                    /*Generate and Initialise OTP methods*/
                    this.InitialiseOTPMethod();

                    this.isProcessing = false;
                    this.currentStep = 2;
                    this.backBtnFlag = true;
                    this.isResendOTP = true;
                    let nextBtn = this.template.querySelector('[data-id="next-btn"]');
                    nextBtn.className = "slds-button slds-button_neutral btn btn-next";
                    this.stepDetailNext = "Enter OTP | next button click";
                    this.stepDetailBack = "Enter OTP | back button click";

                    //Adobe Analytics
                    this.adobeAnalyticsPageView();
                    this.adobeAnalyticsFormCompleted();
                    document.dispatchEvent(
                        new CustomEvent("triggerInteraction", {
                            detail: {
                                eventName: "triggerApplicationComplete",
                                pageName: "Registration:Step 5",
                                pageSubSection1: "Registration:Step 5",
                                formName: "Group | Register | Thank You",
                                userRegistrationSuccess: true,
                                application: {
                                    applicationID: this.guid,
                                    applicationStep: "Step 5",
                                    applicationName: "Register for PartnerConnect",
                                    applicationStart: true,
                                    applicationComplete: true,
                                },
                            },
                        })
                    );
                })
                .catch((error) => {
                    this.isProcessing = false;
                    this.toast("Server Error", "error");
                });
        }
    }

    validate(cmpName) {
        const validatation = this.template.querySelector(cmpName);
        return validatation.validateFields();
    }

    toast(title, toastVariant) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: toastVariant,
        });
        this.dispatchEvent(toastEvent);
    }

    generateGuid() {
        let lut = [];
        for (var i = 0; i < 256; i++) {
            lut[i] = (i < 16 ? "0" : "") + i.toString(16);
        }
        let d0 = (Math.random() * 0xffffffff) | 0;
        let d1 = (Math.random() * 0xffffffff) | 0;
        let d2 = (Math.random() * 0xffffffff) | 0;
        let d3 = (Math.random() * 0xffffffff) | 0;
        this.guid =
            lut[d0 & 0xff] +
            lut[(d0 >> 8) & 0xff] +
            lut[(d0 >> 16) & 0xff] +
            lut[(d0 >> 24) & 0xff] +
            "-" +
            lut[d1 & 0xff] +
            lut[(d1 >> 8) & 0xff] +
            "-" +
            lut[((d1 >> 16) & 0x0f) | 0x40] +
            lut[(d1 >> 24) & 0xff] +
            "-" +
            lut[(d2 & 0x3f) | 0x80] +
            lut[(d2 >> 8) & 0xff] +
            "-" +
            lut[(d2 >> 16) & 0xff] +
            lut[(d2 >> 24) & 0xff] +
            lut[d3 & 0xff] +
            lut[(d3 >> 8) & 0xff] +
            lut[(d3 >> 16) & 0xff] +
            lut[(d3 >> 24) & 0xff];
    }

    adobeAnalyticsPageView() {
        document.dispatchEvent(
            new CustomEvent("triggerInteraction", {
                detail: {
                    eventName: "globalVirtualPageView",
                    pageName: "Registration",
                    pageCategory: "Personal",
                    pageSubSection1: "Registration",
                },
            })
        );
    }
    adobeAnalyticsFormCompleted() {
        document.dispatchEvent(
            new CustomEvent("triggerInteraction", {
                detail: {
                    eventName: "globalFormComplete",
                    formIsSubmitted: true,
                    formStatus: "submitted",
                },
            })
        );
    }

    tracker(event) {
        trackLink(event);
    }
    /*Method to show the Message*/
    showMessage(t, m, type) {
        const toastEvt = new ShowToastEvent({
            title: t,
            message: m,
            variant: type,
        });
        this.dispatchEvent(toastEvt);
    }
}