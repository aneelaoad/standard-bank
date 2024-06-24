/**
 * @description  : Partner Portal Regisrtaion Form Sub Component
 * User Story : SFP-5159
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date July 2021
 */
import { LightningElement, api, wire, track } from "lwc";
import Assets from "@salesforce/resourceUrl/PP_Assets";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import Partnership_Object from "@salesforce/schema/PP_PartnerApplication__c";
import PARTNER_OBJECT from "@salesforce/schema/PP_PartnerApplication__c";

export default class PpPartnershipGoal extends LightningElement {
    @api pageIndex;
    countryOptions = [];
    partnershipOptions = new Map();
    /*New attribute for Partnership Goal*/
    partnershipGoalOptions = [];
    selectedPartnershipGoal = "";
    country;
    currencyOptions = [];
    currency;
    turnoverOptions;
    @track
    filteredTurnoverOptions = [];
    turnover;
    selectedPartnershipOptions = [];
    isValid;
    checkboxGroupValidationError = "";
    isValidCheckboxGroup;
    icon;
    showOtherField;
    partnershipGoalOther = "";
    dependentDisabled = true;
    turnoverValidationError;
    otherFieldValidationError;
    adobeEventFired = false;

    @wire(getObjectInfo, { objectApiName: Partnership_Object })
    partnershipObj;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: PARTNER_OBJECT,
        recordTypeId: "$partnershipObj.data.defaultRecordTypeId",
    })
    fetchPicklist({ error, data }) {
        if (data && data.picklistFieldValues) {
            data.picklistFieldValues["PP_OperatingCountry__c"].values.forEach((optionData) => {
                this.countryOptions.push({ label: optionData.label, value: optionData.value });
            });

            data.picklistFieldValues["PP_Partnership_Goal__c"].values.forEach((goal) => {
                this.partnershipGoalOptions.push({ label: goal.label, value: goal.value });
                this.partnershipOptions.set(goal.value, false);
                this.selectedPartnershipOptions.push({ value: goal.value, checked: false });
            });

            data.picklistFieldValues["PP_Currency__c"].values.forEach((curr) => {
                this.currencyOptions.push({ label: curr.label, value: curr.value });
            });

            this.turnoverOptions = data.picklistFieldValues["PP_AnnualBusinessTurnover__c"];
        }
    }

    connectedCallback() {
        this.icon = Assets + "/Icons/reg-goal-icon.png";
    }

    renderedCallback() {
        let options = this.template.querySelectorAll('[data-id="option"]');
        let lastOption = options[options.length - 1];
        if (lastOption) {
            lastOption.className = "no-border-option";
        }
    }

    @api
    updatedRegistrationDetails() {
        let registrationDataTemp = new Map();
        registrationDataTemp.set("partnershipValues", this.setPartneshipValues());
        registrationDataTemp.set("country", this.country);
        registrationDataTemp.set("partnershipGoalOther", this.partnershipGoalOther);
        registrationDataTemp.set("currency", this.currency);
        registrationDataTemp.set("turnover", this.turnover);
        return registrationDataTemp;
    }

    handleInputChange(event) {
        if (this.adobeEventFired === false) {
            //Adobe Analytics Event
            document.dispatchEvent(
                new CustomEvent("triggerInteraction", {
                    detail: {
                        eventName: "globalFormStart",
                        formName: "Group | Register | Partnership Goal",
                        formIsSubmitted: false,
                        formStatus: "",
                    },
                })
            );
            this.adobeEventFired = true;
        }

        if (event.target.name === "Country") {
            this.country = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        }

        if (event.target.name === "PartnershipGoalOther") {
            this.partnershipGoalOther = event.target.value;
            this.otherFieldValidationError = "";
        }
        if (event.target.dataset.id === "checkbox") {
            var checked = event.detail.checked;
            if (event.target.value === "Other (Please specify)" && checked) {
                this.showOtherField = true;
            } else {
                this.showOtherField = false;
                this.partnershipGoalOther = "";
            }

            /*Make the other checkboxes unchecked if the user checks any checkbox*/
            let boxes = this.template.querySelectorAll("lightning-input");
            let currentBox = event.target.name;
            for (let i = 0; i < boxes.length; i++) {
                let box = boxes[i];

                if (box.name !== currentBox && box.checked) {
                    box.checked = false;
                    this.partnershipOptions.set(box.name, box.checked);
                    this.selectedPartnershipGoal = event.target.value;
                    this.selectedPartnershipOptions = Array.from(this.partnershipOptions, ([value, checked]) => ({ value, checked }));
                } else if (box.name === currentBox && box.checked) {
                    this.partnershipOptions.set(box.name, box.checked);
                    this.selectedPartnershipGoal = event.target.value;
                    this.selectedPartnershipOptions = Array.from(this.partnershipOptions, ([value, checked]) => ({ value, checked }));
                    this.checkboxGroupValidationError = "";
                }
            }
        }
        if (event.target.name === "Currency") {
            this.filteredTurnoverOptions = [];
            const selectedVal = event.target.value;
            let controllerValues = this.turnoverOptions.controllerValues;
            this.turnoverOptions.values.forEach((depVal) => {
                depVal.validFor.forEach((depKey) => {
                    if (depKey === controllerValues[selectedVal]) {
                        this.dependentDisabled = false;
                        this.filteredTurnoverOptions.push({
                            label: depVal.label,
                            value: depVal.value,
                        });
                    }
                });
            });
            this.currency = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        }
        /*added a new block of IF for partnership goal drop-down menu*/
        if (event.target.name == "PartnershipGoal") {
            this.selectedPartnershipGoal = event.detail.value;
            var inputCmp = this.template.querySelector("." + event.target.name);
            inputCmp.setCustomValidity("");
        }
        if (event.target.name === "Turnover") {
            this.turnover = event.detail.value;
            this.turnoverValidationError = "";
        }
    }

    @api
    validateFields() {
        this.isValid = true;
        this.isValidCheckboxGroup = false;
        this.formValidation("lightning-input");
        this.formValidation("lightning-combobox");
        this.formValidation("input");
        if (this.isValidCheckboxGroup == true && this.isValid == true) {
            this.isValid = true;
            this.checkboxGroupValidationError = "";
        } else {
            this.isValid = false;
        }
        return this.isValid;
    }

    formValidation(inputType) {
        let fieldErrorMsg = "Please Enter";
        this.template.querySelectorAll(inputType).forEach((item) => {
            let fieldValue = item.value;
            let fieldLabel = item.label;
            let fieldName = item.name;

            if (typeof fieldValue == "object") {
                if (item.value.length == 0) {
                    item.setCustomValidity(fieldErrorMsg + " " + fieldLabel);
                    this.isValid = false;
                }
            } else if (!fieldValue) {
                if (fieldName === "Currency" || fieldName === "Turnover") {
                    this.turnoverValidationError = "Please Enter Annual Business Turnover";
                } else if (fieldName === "PartnershipGoalOther") {
                    this.otherFieldValidationError = "Please Enter Partnership Goal";
                } else {
                    item.setCustomValidity(fieldErrorMsg + " " + fieldLabel);
                }
                this.isValid = false;
            } else {
                item.setCustomValidity("");
            }
            item.reportValidity();
        });

        let errorMsg = "Please Select a Partnership Goal";
        if (this.selectedPartnershipGoal != null && this.selectedPartnershipGoal != undefined && this.selectedPartnershipGoal != "") {
            this.isValidCheckboxGroup = true;
            errorMsg = "";
        }
        this.checkboxGroupValidationError = errorMsg;
    }
    get renderFlag() {
        return this.pageIndex == 4 ? true : false;
    }

    setPartneshipValues() {
        let partnershipValues;
        this.selectedPartnershipOptions.forEach((goal) => {
            if (goal.checked) {
                partnershipValues = goal.value;
            }
        });
        return partnershipValues;
    }
}