/**
 * @description  : Partner Portal Regisrtaion Form Sub Component
 * User Story : SFP-5159
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date July 2021
 */
import { LightningElement, api } from "lwc";
import Assets from "@salesforce/resourceUrl/PP_Assets";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { trackLink } from "c/ppEventUtils";

const MAX_FILE_SIZE = 100000000; //10mb
export default class PpBriefDescription extends LightningElement {
    @api recordId;
    @api pageIndex;
    description;
    fileData;
    isValid;
    validationError = "";
    icon;
    textareaMaxLength = 750;
    charCount = 0;
    filename;
    adobeEventFired = false;

    connectedCallback() {
        this.icon = Assets + "/Icons/reg-business-icon.png";
    }

    openfileUpload(event) {
        this.tracker(event);
        const file = event.target.files[0];
        if (file.size > MAX_FILE_SIZE) {
            this.toast("File Size Can not exceed " + MAX_FILE_SIZE);
        } else {
            let reader = new FileReader();
            reader.onload = () => {
                let base64 = reader.result.split(",")[1];
                this.fileData = {
                    filename: file.name,
                    base64: base64,
                };
                this.filename = file.name;
            };
            reader.readAsDataURL(file);
        }
    }

    descriptionHandleChange(event) {
        let desc = this.template.querySelector("textarea");
        this.description = desc.value;
        this.validationError = "";
    }

    @api
    updatedRegistrationDetails() {
        let registrationDataTemp = new Map();
        registrationDataTemp.set("description", this.description);
        registrationDataTemp.set("fileData", this.fileData);
        return registrationDataTemp;
    }

    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success",
        });
        this.dispatchEvent(toastEvent);
    }

    get renderFlag() {
        return this.pageIndex == 5 ? true : false;
    }

    @api
    validateFields() {
        this.isValid = true;
        this.formValidation("textarea");
        return this.isValid;
    }

    formValidation(inputType) {
        let fieldErrorMsg = "Please Enter";
        this.template.querySelectorAll(inputType).forEach((item) => {
            let fieldValue = item.value;
            let fieldname = item.name;
            if (!fieldValue) {
                this.validationError = fieldErrorMsg + " " + fieldname;
                this.isValid = false;
            } else {
                this.validationError = "";
            }
        });
    }

    textareaKeyUp() {
        let desc = this.template.querySelector("textarea");
        if (desc.value.length <= 750) {
            this.charCount = desc.value.length;
        }

        if (this.adobeEventFired === false) {
            //Adobe Analytics Event
            document.dispatchEvent(
                new CustomEvent("triggerInteraction", {
                    detail: {
                        eventName: "globalFormStart",
                        formName: "Group | Register | Business Idea",
                        formIsSubmitted: false,
                        formStatus: "",
                    },
                })
            );

            this.adobeEventFired = true;
        }
    }

    removeFile() {
        this.fileData = null;
        this.filename = null;
    }

    tracker(event) {
        trackLink(event);
    }
}