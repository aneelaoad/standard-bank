import { LightningElement, wire, api } from 'lwc';
import Id from '@salesforce/user/Id';
import OSB_OnehubDashboard from '@salesforce/resourceUrl/OSB_OnehubDashboard';
import getUserNameIfLoggedIn from '@salesforce/apex/OSB_Header_CTRL.getUserNameIfLoggedIn';
import getCustomMetadataRecord from '@salesforce/apex/OSB_OtpManagement_CTRL.getCustomMetadataRecord';
import initialiseOTP from '@salesforce/apex/OSB_OtpManagement_CTRL.initialiseOTP';
import createCase from '@salesforce/apex/OSB_OtpManagement_CTRL.createCase';
import validateOTPCode from '@salesforce/apex/OSB_OtpManagement_CTRL.validateOTPCode';
import sendOutMailOTP from '@salesforce/apex/OSB_OtpManagement_CTRL.sendOutMailOTP';
const maxLength = 5;
const suspiciousActivity = 'Suspicious Activity';
export default class OsbOtpModal extends LightningElement {

    @api otpmessage = "continue to deLink device";
    @api otpreason;

    userId = Id;
    OTPImage = OSB_OnehubDashboard + '/OtpModalIllustration.svg';

    userEmail;
    otpDigits;

    showErrorMessage;
    errorMessage;
    showOTPScreen = false;
    showOTPSuccessScreen = false;

    showOTPTimer= false;
    showSupportAssistance = false;
    otpTimerBlocked = false;
    otpTimerValid = false;
    otpTime;
    otpTimer;
    timeIntervalInstance;
    otpTimeBlocked = 60;

    attempts = 0;

    isLoading = true;
    error;
    

    @wire(getUserNameIfLoggedIn)
    getUserNameIfLoggedIn(result) {
        if (result.data) {
            let email = result.data.Email;
            this.userEmail = email.replace(/(\w{2})[\w.-]+@(\w{2})[\w-]+(\w)/, (match, p1, p2) => {
                let [username, domain] = match.split("@");
                let maskedUsername = p1 + '*'.repeat(username.length - 2);
                let maskedDomain = p2 + '*'.repeat(domain.length - 2);
                return `${maskedUsername}@${maskedDomain}`;
            });
        }
    }

    connectedCallback(){
        document.body.style.overflow = 'hidden';
        this.showSupportAssistance = false;
        this.otpTimerBlocked = false;
        this.showOTPTimer = true;
        this.showOTPScreen = true;
        this.otpTimerValid = true;

        this.retrieveOTPSettings();
        this.initiateOTP();
    }

    retrieveOTPSettings(){
        getCustomMetadataRecord()
        .then((result) => {
            
            let otpSettings = result;
            this.otpTime = otpSettings.CodeDurationSeconds__c;
        })
        .catch((error) => {
            this.error = error;
        });
    }

    initiateOTP(){
        initialiseOTP()
        .then((result) => {
            let otpResponse = result;
            if(otpResponse.isSuccess){
                this.isLoading = false;
                this.initiateOTPTimer(this.otpTime);
                sendOutMailOTP({otpReason : this.otpreason});
            }
        })
        .catch((error) => {
            this.error = error;
        });
    }

    initiateOTPTimer(time){
        clearInterval(parseInt(this.timeIntervalInstance, 10));
        let actualValue = time;
        this.timeIntervalInstance = setInterval(function() {
            if(actualValue === 0){
                this.stopTimer();
                this.expiredTimer();
            }
            this.processTimer(actualValue);
            actualValue--;
        }.bind(this), 1000);
    }

    processTimer(actualValue){
        let formattedMinutes = parseInt(actualValue / 60, 10);
        let formattedSeconds = String(actualValue - formattedMinutes * 60);
        if (formattedSeconds.length < 2){
            formattedSeconds = "0" + formattedSeconds;
        }
        this.otpTimer = formattedMinutes + ":" + formattedSeconds;
    }

    stopTimer(){
        clearInterval(parseInt(this.timeIntervalInstance, 10));
    }

    expiredTimer(){
        this.otpTimerValid = false;
        this.template.querySelector(`[data-id="resend"]`).classList.remove("disabled-button-style");
        this.template.querySelector(`[data-id="resend"]`).disabled = false;
        this.template.querySelector(`[data-id="submit"]`).classList.add("disabled-button-style");
        this.template.querySelector(`[data-id="submit"]`).disabled = true;
        let inputField = this.template.querySelector("input");
        this.showErrorMessage = false;
        inputField.style = 'border-color: #5C6C80;';
        inputField.value = '';
        inputField.disabled = true;
    }

    resendOTP(){
        this.template.querySelector(`[data-id="otpDigits"]`).disabled = false;
        this.showOTPTimer = true;
        this.otpTimerValid = true;
        this.otpTimerBlocked = false;
        this.showErrorMessage = false;
        this.template.querySelector(`[data-id="otpDigits"]`).value = '';
        let inputField = this.template.querySelector("input");
        inputField.style = 'border-color: #5C6C80;';
        this.template.querySelector(`[data-id="resend"]`).classList.add("disabled-button-style");
        this.template.querySelector(`[data-id="resend"]`).disabled = true;
        this.template.querySelector(`[data-id="submit"]`).classList.remove("disabled-button-style");
        this.template.querySelector(`[data-id="submit"]`).disabled = false;

        this.initiateOTP();
    }

    removeErrorState(){
        let inputField = this.template.querySelector("input");
        this.showErrorMessage = false;
        inputField.style = 'border-color: #5C6C80;';
    }

    submitOTP(){
        this.template.querySelector(`[data-id="submit"]`).disabled = true;
        let inputField = this.template.querySelector("input");
        const regExChar = /^[A-Za-z0-9]*$/;
        let isValid = false;

        if(!inputField.value){
            isValid = false;
            this.errorMessage = "Required";
        }else{
            isValid = true;
        }

        if(!(inputField.value.length === maxLength)){
            isValid = false;
            this.errorMessage = "Required";
        }else{
            isValid = true;
        }

        let isValidChar = regExChar.test(inputField.value) ? true: false;

        if(!isValidChar && isValid){
            this.errorMessage = "Invalid characters entered";
        } 

        if(isValid && isValidChar){
            this.showErrorMessage = false;
            inputField.style = 'border-color: #5C6C80;';
            this.otpDigits = inputField.value;

            this.validateOTP(inputField);

        }else{
            this.showErrorMessage = true;
            inputField.style = 'border-color: #DC0A0A;';
            this.template.querySelector(`[data-id="submit"]`).disabled = false;
        }
    }

    validateOTP(inputField){
        let otpEntered = inputField.value
        validateOTPCode({inputCode : otpEntered})
        .then((result) => {
            let otpValidationResponse = result;

            if(otpValidationResponse.isSuccess){
                this.stopTimer();
                this.successfulOTP();
            }else{
                this.template.querySelector(`[data-id="submit"]`).disabled = false;
                this.attempts++;
                this.template.querySelector(`[data-id="otpDigits"]`).value = '';
                if(this.attempts === 3 || this.attempts === 6){
                    this.failedAttemptManagement();
                }else{
                    this.errorMessage = "Incorrect PIN entered";
                    this.showErrorMessage = true;
                    inputField.style = 'border-color: #DC0A0A;';
                }
            }
        })
        .catch((error) => {
            this.error = error;
        });
    }

    successfulOTP(){
        this.showOTPScreen = false;
        this.showOTPSuccessScreen = true;
        document.body.style.overflow = 'auto';
    }

    failedAttemptManagement(){
        let inputField = this.template.querySelector("input");
        this.template.querySelector(`[data-id="resend"]`).classList.add("disabled-button-style");
        this.template.querySelector(`[data-id="resend"]`).disabled = true;
        this.template.querySelector(`[data-id="submit"]`).classList.add("disabled-button-style");
        this.template.querySelector(`[data-id="submit"]`).disabled = true;
        this.template.querySelector(`[data-id="otpDigits"]`).disabled = true;
        this.stopTimer();
        if(this.attempts === 3){
            this.otpTimer = '';
            this.showOTPTimer = false;
            this.otpTimerBlocked = true;
            inputField.style = 'border-color: #DC0A0A;';
            this.initiateOTPTimer(this.otpTimeBlocked);
        }else if(this.attempts === 6){
            inputField.style = 'border-color: #DC0A0A;';
            this.otpTimerBlocked = false;
            this.showOTPTimer = false;
            this.showSupportAssistance = true;
            createCase();
            sendOutMailOTP({otpReason : suspiciousActivity});
        }
    }

    continueToDeviceManagement(){
        this.dispatchEvent(new CustomEvent('successotp'));
    }

    cancel(){
        document.body.style.overflow = 'auto';
        this.stopTimer();
        this.dispatchEvent(new CustomEvent('cancelotp'));
    }

}