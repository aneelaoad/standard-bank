/**
 * @description  : Partner Portal Regisrtaion Form Sub Component
 * User Story : SFP-5159
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date July 2021
 */
import { LightningElement, api, track } from "lwc";
import Assets from "@salesforce/resourceUrl/PP_Assets";
import { trackLink } from "c/ppEventUtils";

export default class PpCommunicationDetails extends LightningElement {
    @api pageIndex;
    @api termsAndConditionText;
    firstName;
    lastName;
    phoneNumber;
    emailId;
    companyWebsite;
    linkedInProfile;
    termsAndCondition = false;
    isValid;
    icon;
    isModalOpen = false;
    adobeEventFired = false;

    /*Attributes that will be used for Phone number dropdown box*/
    @api CountryName = "";
    @track inputElem;
    @track iti;
    @track phoneInput;

    connectedCallback() {
        this.icon = Assets + "/Icons/reg-contact-icon.png";
    }

    @api
    updatedRegistrationDetails() {
        let registrationDataTemp = new Map();
        registrationDataTemp.set("fistName", this.firstName);
        registrationDataTemp.set("lastName", this.lastName);
        registrationDataTemp.set("emailId", this.emailId);
        registrationDataTemp.set("companyWebsite", this.companyWebsite);
        registrationDataTemp.set("linkedInProfile", this.linkedInProfile);
        registrationDataTemp.set("termsAndCondition", this.termsAndCondition);
        registrationDataTemp.set("phoneNumber", this.phoneNumber);
        return registrationDataTemp;
    }

    handleInputChange(event) {
        if (this.adobeEventFired === false) {
            //Adobe Analytics Event
            document.dispatchEvent(
                new CustomEvent("triggerInteraction", {
                    detail: {
                        eventName: "globalFormStart",
                        formName: "Group | Register | Contact Details",
                        formIsSubmitted: false,
                        formStatus: "",
                    },
                })
            );
            this.adobeEventFired = true;
        }

        if (event.target.name == "FirstName") {
            this.firstName = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name == "LastName") {
            this.lastName = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name == "phoneNumber") {
            this.phoneNumber = event.target.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
        } else if (event.target.name == "Email") {
            this.emailId = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name == "Website") {
            this.companyWebsite = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name == "LinkedIn") {
            this.linkedInProfile = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name == "TC") {
            this.termsAndCondition = event.detail.checked;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        }
    }

    @api
    validateFields() {
        this.isValid = true;
        this.formValidation("lightning-input");
        this.formValidation("input");
        return this.isValid;
    }

    formValidation(inputType) {
        let fieldErrorMsg = "Please Enter";

        this.template.querySelectorAll(inputType).forEach((item) => {
            let fieldValue = item.value;
            let fieldLabel = item.label;
            let fieldName = item.name;

            if (fieldName !== "LinkedIn" && fieldName !== "Website") {
                if (item.type === "checkbox") {
                    if (item.checked === false) {
                        this.isValid = false;
                        item.setCustomValidity("This field is required");
                    }
                } else if (fieldName === "phoneNumber") {
                    if (fieldValue == null || fieldValue == "" || fieldValue == undefined) {
                        this.isValid = false;
                        item.setCustomValidity(fieldErrorMsg + " Phone Number");
                    } else {
                        var phoneno = /(^\+)(\d{11,20})/;
                        if (!fieldValue.match(phoneno)) {
                            item.setCustomValidity(
                                "Incorrect Format. Please make sure you have entered the correct phone number. "
                            );
                            this.isValid = false;
                        }
                    }
                } else if (!fieldValue) {
                    item.setCustomValidity(fieldErrorMsg + " " + fieldLabel);
                    this.isValid = false;
                } else {
                    item.setCustomValidity("");
                }
                item.reportValidity();
            }
        });
    }

    get renderFlag() {
        return this.pageIndex == 1 ? true : false;
    }

    openModal(event) {
        this.tracker(event);
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    accept() {
        this.termsAndCondition = true;
        this.isModalOpen = false;
    }

    tracker(event) {
        trackLink(event);
    }
}