import { LightningElement, track, api } from 'lwc';
const MALL_OTP_ENTER_PIN_HEADING = "Enter One-Time Pin";
const MALL_OTP_SENT_TO_MESSAGE = "We've sent an OTP to {placeholder}";
const MALL_OTP_SENT_TO_HINT = "You have {placeholder} attempts to enter the correct pin.";
const MALL_OTP_RESEND_BUTTON_LABEL = "Resend";
const MALL_OTP_VALIDATION_ERROR = "Incorrect OTP. Please try again";
const MALL_OTP_VALIDATION_SUCCESS = "We've sent you a new OTP";
const MALL_OTP_SESSION_EXPIRE_MESSAGE = "This session will expire in: ";
const MALL_OTP_HELP_MESSAGE = "<p>Each OTP (one-time PIN) is valid for 15 minutes and can only be used once.</p><p>If you request to “resend” a new OTP, your previous one becomes invalid.</p><p>You have 3 attempts to enter the correct OTP. If you fail all 3 attempts, a new OTP will be sent. You will thenhave another 3 attempts to enter the new OTP. If you fail all 3 attempts, your OTP will be locked across allStandard Bank services.</p><p>If you have any further queries please call:</p><p><a href='tel:0860123000'>0860 123 000</a><br />South Africa</p>";
const MALL_OTP_SESSION_EXPIRED_TITLE = "Your session has expired"
const MALL_OTP_SESSION_EXPIRED_DESCRIPTION = "Your OTP is only valid for 15 minutes.<br/>Please try again."

export default class MallOtpStepper extends LightningElement {
    enterPinHeading = MALL_OTP_ENTER_PIN_HEADING;
    otpSentToMessage = MALL_OTP_SENT_TO_MESSAGE;
    otpHint = MALL_OTP_SENT_TO_HINT;
    helpContent = MALL_OTP_HELP_MESSAGE;

    resendButtonLabel = MALL_OTP_RESEND_BUTTON_LABEL;
    sessionExpireMessage = MALL_OTP_SESSION_EXPIRE_MESSAGE;

    //This iterates the count of inputs to display
    inputs = [0, 1, 2, 3, 4];
    showHelperText = false;

    responseType;
    responseMessage;

    displayHelp = false;
    otpValue = "";

    @track minutes = 15;
    @track seconds = 0;
    timerInterval;

    showState = false;
    state;
    stateTitle;
    stateDescription;
    paste = false;

    /**
     * The function `requestOtp()` generates a new OTP (One-Time Password) and handles the success
     * response by setting the appropriate variables and restarting the expire timer.
     */
    requestOtp() {
        //API call to generate new OTP

        //On success
        this.responseType = "success";
        this.responseMessage = MALL_OTP_VALIDATION_SUCCESS;
        this.showHelperText = true;

        //Restart the expire timer
        this.resetTimer();
    }

    connectedCallback() {
        this.startTimer();
    }

    /**
     * The startTimer function calculates the total time in seconds, updates the timer every second by
     * decrementing the total time, and stops the timer when it reaches 0.
     */
    startTimer() {
        // Calculate the total time in seconds
        let totalTimeInSeconds = this.minutes * 60 + this.seconds;

        // Update the timer every second
        this.timerInterval = setInterval(() => {
            // Calculate minutes and seconds
            this.minutes = Math.floor(totalTimeInSeconds / 60);
            this.seconds = totalTimeInSeconds % 60;

            // Decrement the total time
            totalTimeInSeconds--;

            // Stop the timer when it reaches 0
            if (totalTimeInSeconds < 0) {
                clearInterval(this.timerInterval);
                // Call the timerExpired method
                this.timerExpired();
            }
        }, 1000);
    }

    /**
     * The function resets a timer to 15 minutes and starts it again.
     */
    resetTimer() {
        // Clear the current timer interval
        clearInterval(this.timerInterval);

        // Reset the timer to 15 minutes
        this.minutes = 15;
        this.seconds = 0;

        // Start the timer again
        this.startTimer();
    }

    /**
     * The function "timerExpired" updates the state and display of a modal when a timer expires.
     */
    timerExpired() {
        this.showState = true;
        this.state = "error";
        this.stateTitle = MALL_OTP_SESSION_EXPIRED_TITLE;
        this.stateDescription = MALL_OTP_SESSION_EXPIRED_DESCRIPTION;

        this.updateModalButtons();
    }

    /**
     * The function `updateModalButtons` dispatches a custom event called 'otperrorstate' with a detail
     * object containing a boolean property `displayResendButton` set to true.
     */
    updateModalButtons() {
        const event = new CustomEvent('otperrorstate', {
            detail: {
                displayResendButton: true
            }
        });
        this.dispatchEvent(event);
    }

    /**
     * The function "handlePasteInput" sets the maximum length of the input target to 5 and sets a flag
     * indicating that a paste event has occurred.
     * @param event - The event parameter is an object that represents the event that triggered the
     * function. In this case, it is likely a paste event, which occurs when the user pastes content
     * into an input field or textarea.
     */
    handlePasteInput(event) {
        event.target.maxLength = 5;
        this.paste = true;
    }

    /**
     * The function formats a pasted value by assigning each character to a selected element and moving
     * to the next element until the end of the value is reached.
     * @param text - The `text` parameter is a string that represents the value that needs to be pasted
     * into the input elements.
     * @param selectedElem - The selectedElem parameter is the currently selected input element where
     * the formatted text will be pasted.
     */
    formatPastedValue(text, selectedElem) {
        const charArray = Array.from(text);

        let currentInput = selectedElem;
        let isLastInput = false;
        charArray.forEach((element, index) => {
            if (!isLastInput) {
                currentInput.value = element;
            }
            if (currentInput.nextElementSibling == null) {
                isLastInput = true;
                return;
            }

            // Move to the next input if available
            currentInput = currentInput.nextElementSibling;
        });
    }

    /**
     * The function focuses on the next input element when a value is entered and checks if the entered
     * value is a number.
     * @param event - The event parameter is an object that represents the event that triggered the
     * function. It contains information about the event, such as the target element and the type of
     * event that occurred.
     * @returns nothing (undefined).
     */
    focusNextInput(event) {
        const target = event.target;
        const val = target.value;

        if (isNaN(val)) {
            target.value = "";
            return;
        }

        if (this.paste) {
            this.paste = false;
            this.formatPastedValue(val, target);
            event.target.maxLength = 1;
        }

        if (val != "") {
            const next = target.nextElementSibling;
            if (next) {
                next.focus();
            }
        }
    }

    /**
     * The function focuses on the previous input element when the backspace or delete key is pressed.
     * @param event - The event parameter is an object that represents the event that triggered the
     * function. It contains information about the event, such as the target element and the key that
     * was pressed.
     * @returns nothing (undefined).
     */
    focusPrevInput(event) {
        const target = event.target;
        const key = event.key.toLowerCase();

        if (key == "backspace" || key == "delete") {
            target.value = "";
            const prev = target.previousElementSibling;
            if (prev) {
                prev.focus();
            }
            return;
        }
    }

    @api resendOtp() {
        this.showState = false;
        this.showHelp(false);
        this.requestOtp();
    }

    /**
     * The function "submitOtpValue" collects the values from input fields, checks if the length is
     * valid, and logs the OTP value before submitting it to an API.
     * @returns the value of `this.showHelperText`.
     */
    @api submitOtpValue() {
        const inputs = this.template.querySelectorAll(".input");

        //We clear the value first to reset it
        this.otpValue = "";
        inputs.forEach((elem) => {
            this.otpValue += elem.value;
        })

        if (this.otpValue.length < inputs.length) {
            this.responseType = "error";
            this.responseMessage = MALL_OTP_VALIDATION_ERROR;
            return this.showHelperText = true;
        }

        //Submit to API
    }

    @api showHelp(bool) {
        this.displayHelp = bool;
    }
}