/**
 * @description       :
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             :
 * @last modified on  : 08-16-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
 **/
import { LightningElement, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from "lightning/navigation";
import validateLink from "@salesforce/apex/PP_UserRegistration_CTRL.validateLink";
import validateEmailAddress from "@salesforce/apex/PP_UserRegistration_CTRL.validateEmailAddress";
import registerUser from "@salesforce/apex/PP_UserRegistration_CTRL.registerUser";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class PpUserRegistration extends NavigationMixin(LightningElement) {
    linkIdParameter;
    isLoading = true;
    error;
    currentStep = 1;

    emailAddress;
    firstName;
    lastName;
    userName;
    mobileNumber;
    password;
    passwordRepeat;

    connectedCallback() {
        if (this.linkIdParameter) {
            validateLink({ linkIdParameter: this.linkIdParameter })
                .then((result) => {
                    this.isLoading = false;
                    this.emailAddress = result.emailAddress;
                    this.firstName = result.firstName;
                    this.lastName = result.lastName;
                    this.mobileNumber = result.mobile;
                    this.emailAddress = result.emailAddress;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.isLoading = false;
                });
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.linkIdParameter = currentPageReference.state?.id;
        }
    }

    handleInputChange(event) {
        this[event.target.name] = event.detail.value;
    }

    handleButtonClick(event) {
        let button = event.target.dataset.name;

        if (button == "next" && this.currentStep == 1) {
            this.isLoading = true;

            validateEmailAddress({ linkIdParameter: this.linkIdParameter, emailAddress: this.emailAddress })
                .then((result) => {
                    this.error = undefined;

                    if (result) {
                        this.redirectToLogin();
                    } else {
                        this.currentStep = 2;
                        this.isLoading = false;
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.isLoading = false;
                });
        } else if (button == "next" && this.currentStep == 2) {
            this.doRegisterUser();
        } else if (button == "login" && this.currentStep == 3) {
            this.redirectToLogin();
        }
    }

    doRegisterUser() {
        if (!this.validateRegistrationForm() || !this.validatePassword()) {
            return;
        }

        let registrationFormData = {
            emailAddress: this.emailAddress,
            firstName: this.firstName,
            lastName: this.lastName,
            userName: this.userName,
            mobileNumber: this.mobileNumber,
            password: this.password,
            passwordRepeat: this.passwordRepeat,
        };

        this.isLoading = true;

        registerUser({ registrationFormData: registrationFormData })
            .then((result) => {
                if (result.resultStatus == "Success") {
                    this.currentStep = 3;
                } else if (result.resultStatus == "Error") {
                    this.showMessage("Notification", result.resultMessage, "error");
                }

                this.isLoading = false;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.isLoading = false;
            });
    }

    validateRegistrationForm() {
        const allValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();

            if (inputCmp.name == "password" || inputCmp.name == "passwordRepeat") {
                inputCmp.setCustomValidity("");
            }

            return validSoFar && inputCmp.checkValidity();
        }, true);

        return allValid;
    }

    validatePassword() {
        let isValid = true;
        let password = this.template.querySelector(`[data-id="password"]`);
        let passwordRepeat = this.template.querySelector(`[data-id="passwordRepeat"]`);

        if (password.value != passwordRepeat.value) {
            passwordRepeat.setCustomValidity("Passwords do not match. Please re-enter the password.");
            isValid = false;
        } else {
            passwordRepeat.setCustomValidity("");
        }

        passwordRepeat.reportValidity();
        var passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@!%&*?])[A-Za-z\d#$@!%&*?]{8,30}$/;

        if (!password.value.match(passwordRegex)) {
            password.setCustomValidity("Password does not meet the password complexity policy.");
            isValid = false;
        } else {
            password.setCustomValidity("");
        }

        password.reportValidity();

        return isValid;
    }

    showMessage(title, message, type) {
        const toastEvt = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
        });

        this.dispatchEvent(toastEvt);
    }

    async redirectToLogin() {
        this[NavigationMixin.Navigate]({
            type: "comm__loginPage",
            attributes: {
                actionName: "login",
            },
        });
    }

    get isStepOne() {
        return this.currentStep === 1;
    }

    get isStepTwo() {
        return this.currentStep === 2;
    }

    get isStepThree() {
        return this.currentStep === 3;
    }
}