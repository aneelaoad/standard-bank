import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import IS_GUEST from "@salesforce/user/isGuest";
import Name from "@salesforce/schema/User.Name";
import USER_ID from "@salesforce/user/Id";
const MALL_MY_DASHBOARD_GREETING = "Hello";
const MALL_MY_DASHBOARD_GREETING_MESSAGE = "welcome back";
const MALL_MY_DASHBOARD_SUPPORTING_MESSAGE = "Your dashboard, your way: effortlessly configure Quick links and widgets.";
const MALL_MY_DASHBOARD_OTP_HEADING = "Security verification OTP";
const MALL_MY_DASHBOARD_OTP_HELP_LABEL = "Help";
const MALL_MY_DASHBOARD_OTP_BACK_LABEL = "Back";
const MALL_MY_DASHBOARD_OTP_SUBMIT_LABEL = "Submit";
const MALL_MY_DASHBOARD_OTP_RESEND_LABEL = "Resend";

export default class MallMyDashboard extends LightningElement {
    isGuestBool = IS_GUEST;
    windowEl = window;
    supportingMessage = MALL_MY_DASHBOARD_SUPPORTING_MESSAGE;
    showOtp = false;
    otpHeading = MALL_MY_DASHBOARD_OTP_HEADING;
    otpHelpLabel = MALL_MY_DASHBOARD_OTP_HELP_LABEL;
    otpBackLabel = MALL_MY_DASHBOARD_OTP_BACK_LABEL;
    otpSubmitLabel = MALL_MY_DASHBOARD_OTP_SUBMIT_LABEL;
    otpResendLabel = MALL_MY_DASHBOARD_OTP_RESEND_LABEL;

    showHelpButton = true;
    toggleHelpState = true;
    showResendButton = false;
    showSubmitButton = true;

    @wire(getRecord, { recordId: USER_ID, fields: [Name] })
    user;


    get introMessage() {
        let firstName = "";
        if (this.user.data !== undefined) {
            // We grab just the first name from the field
            firstName = getFieldValue(this.user.data, Name).split(" ")[0];
        }

        return `${MALL_MY_DASHBOARD_GREETING} ${firstName}, ${MALL_MY_DASHBOARD_GREETING_MESSAGE}`;
    }

    handleOtpHelp() {
        this.template.querySelector("c-mall-otp-stepper").showHelp(this.toggleHelpState);
        this.toggleHelpState = !this.toggleHelpState;
    }

    resend() {
        this.showResendButton = false;
        this.showSubmitButton = true;
        this.template.querySelector("c-mall-otp-stepper").resendOtp();
    }

    submitOtp() {
        this.template.querySelector("c-mall-otp-stepper").submitOtpValue();
    }

    handleOtpStateChange(event) {
        const state = event.detail.displayResendButton
        this.showResendButton = state;
        this.showSubmitButton = !state;

    }

    connectedCallback() {
        this.windowEl.addEventListener("initOtpStepper", () => {
            this.showOtp = !this.showOtp;
        })
    }

    disconnectedCallback() {
        this.windowEl.removeEventListener("initOtpStepper");
    }
}