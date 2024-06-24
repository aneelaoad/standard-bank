import { LightningElement, api } from "lwc";
import Assets from "@salesforce/resourceUrl/PP_Assets";

export default class PpOTPVerification extends LightningElement {
    otpcode = "";
    icon;
    isValid;
    errorCss = "";
    adobeEventFired = false;
    @api guid;
    @api pageIndex;

    connectedCallback() {
        this.icon = Assets + "/Icons/reg-company-icon.png";
    }
    get renderFlag() {
        return this.pageIndex == 2 ? true : false;
    }

    @api
    updatedRegistrationDetails() {
        let registrationDataTemp = new Map();
        registrationDataTemp.set("otpcode", this.otpcode);
        return registrationDataTemp;
    }

    handleInputChange(event) {
        if (this.adobeEventFired === false) {
            //Adobe Analytics Event
            document.dispatchEvent(
                new CustomEvent("triggerInteraction", {
                    detail: {
                        eventName: "globalFormStart",
                        formName: "Group | Register | Company Details",
                        formIsSubmitted: false,
                        formStatus: "",
                    },
                })
            );
            this.adobeEventFired = true;
        }

        if (event.target.name == "OTP") {
            this.otpcode = event.detail.value;
        }
    }
}