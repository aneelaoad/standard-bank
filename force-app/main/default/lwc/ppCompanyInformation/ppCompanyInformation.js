/**
 * @description  : Partner Portal Regisrtaion Form Sub Component
 * User Story : SFP-5159
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date July 2021
 */
import { LightningElement, api, wire } from "lwc";
import Assets from "@salesforce/resourceUrl/PP_Assets";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import PARTNERSHIP_OBJECT from "@salesforce/schema/PP_PartnerApplication__c";
import INDUSTRY_FIELD from "@salesforce/schema/PP_PartnerApplication__c.PP_Industry__c";
import CAPABILITIES_FIELD from "@salesforce/schema/PP_PartnerApplication__c.PP_Capabilities__c";

export default class PpCompanyInformation extends LightningElement {
    icon;
    insudtryOptions = [];
    capabilitiesOptions = [];
    businessOrCompanyName = "";
    registrationNo = "";
    industry = "";
    capabilities = "";
    isValid;
    errorCss = "";
    adobeEventFired = false;
    @api guid;
    @api pageIndex;

    @wire(getObjectInfo, { objectApiName: PARTNERSHIP_OBJECT })
    partnershipObj;

    @wire(getPicklistValues, {
        recordTypeId: "$partnershipObj.data.defaultRecordTypeId",
        fieldApiName: INDUSTRY_FIELD,
    })
    getIndustryPicklistValues({ error, data }) {
        if (data) {
            this.insudtryOptions = data.values;
        } else if (error) {
            console.log("An error has occurred:");
            console.log(error);
            // handle your error.
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$partnershipObj.data.defaultRecordTypeId",
        fieldApiName: CAPABILITIES_FIELD,
    })
    getCapabilitiesPicklistValues({ error, data }) {
        if (data) {
            for (let i = 0; i < data.values.length; i++) {
                this.capabilitiesOptions = [
                    ...this.capabilitiesOptions,
                    { value: data.values[i].value, label: data.values[i].label },
                ];
            }
            if (this.capabilitiesOptions) {
                const multiCombobox = this.template.querySelector("c-cmn-multi-select-combobox");
            } else if (error) {
                console.log("An error has occurred:");
                console.log(error);
            }
        }
    }

    connectedCallback() {
        this.icon = Assets + "/Icons/reg-company-icon.png";
    }

    @api
    updatedRegistrationDetails() {
        let registrationDataTemp = new Map();
        registrationDataTemp.set("business_name", this.businessOrCompanyName);
        registrationDataTemp.set("registration_no", this.registrationNo);
        registrationDataTemp.set("industry", this.industry);
        registrationDataTemp.set("capabilities", this.capabilities.value);

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

        if (event.target.name == "Capabilities") {
            this.capabilities = event.detail;
            this.errorCss = "";
        } else if (event.target.name == "Company") {
            this.businessOrCompanyName = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name == "RegistrationNo") {
            this.registrationNo = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name == "Industry") {
            this.industry = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        }
    }

    get renderFlag() {
        return this.pageIndex == 3 ? true : false;
    }

    @api
    validateFields() {
        this.isValid = true;
        this.formValidation("lightning-input", false);
        this.formValidation("lightning-combobox", false);
        this.formValidation("lightning-dual-listbox", false);
        this.formValidation("c-cmn-multi-select-combobox", true);

        return this.isValid;
    }

    formValidation(inputType, isCustom) {
        if (isCustom) {
            this.validateCustomFields(inputType);
        } else {
            let fieldErrorMsg = "Please Enter";

            this.template.querySelectorAll(inputType).forEach((item) => {
                let fieldValue = item.value;
                let fieldLabel = item.label;
                let fieldName = item.name;

                if (fieldName !== "RegistrationNo") {
                    if (typeof fieldValue == "object") {
                        if (item.value.length == 0) {
                            item.setCustomValidity(fieldErrorMsg + " " + fieldLabel);
                            this.isValid = false;
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
    }

    validateCustomFields(inputType) {
        this.template.querySelectorAll(inputType).forEach((item) => {
            let fieldValue = item.value;

            if (typeof fieldValue === "object") {
                if (fieldValue.value.length === 0) {
                    this.isValid = false;
                    this.errorCss = "slds-has-error";
                }
            } else if (!fieldValue) {
                this.isValid = false;
                this.errorCss = "slds-has-error";
            }
        });
    }
}