import { LightningElement, wire } from 'lwc';
import Id from "@salesforce/user/Id";
import getUserDetails from '@salesforce/apex/OSB_NewCaseForm_CTRL.isUserLoggedIn';
import getPingUserDetails from '@salesforce/apex/OSB_NewCaseForm_CTRL.getPingUserDetails';
import getUserContactDetails from '@salesforce/apex/OSB_NewCaseForm_CTRL.getUserContactDetails';
import createCaseWithContactId from '@salesforce/apex/OSB_NewCaseForm_CTRL.createCaseWithContactId';
import getSolutions from "@salesforce/apex/OSB_SolutionShowcase_CTRL.getSolutions";
import PHONECOUNTRY_FIELD from '@salesforce/schema/Contact.Phone_Country__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { interactionForm, addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbNewCaseFormLwc extends LightningElement {
    infoSupportTitle = "Customer Support and Feedback";
    infoEmail = "onehub@standardbank.co.za";
    eMTTitle = "eMarketTrader Support";
    eMTEmail = "cs@standardbank.com";
    eMTClientServices = "Global Markets Client Services";
    eMTClientServicesNumber = "+27 11 415 4600";
    isUserloggedIn = false;
    userEmail;
    userName;
    userCountryCode;
    userPhoneNumber;
    CaseType;
    CaseTypeSelected = false;
    countryCodes = [];
    picklistOrdered = [];
    searchResults;
    selectedSearchResult;
    userMap;
    userId = Id
    showToastFailure = false;
    showToastSuccess = false;
    showPopUp = false;
    isLoading = false;
    formStartedValue = false;
    searchinput;
    refreshResult;
    eventValues = {
        name: "globalFormStart",
        formName: 'contact us',
        formStatus: "",
        formisSubmitted: false
    };

    get selectedValue() {

        return this.selectedSearchResult ? this.selectedSearchResult.label : null;

    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PHONECOUNTRY_FIELD
    })
    wiredDataPhone({ data }) {
        if (data) {
            this.countryCodes = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        }
    }

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }

    disconnectedCallback() {
        if (this.formStartedValue) {
            let event = this.eventValues;
            event.name = 'globalFormAbandon';
            event.formStatus = 'abandon';
            event.formisSubmitted = false;
            this.setInitalAdobeFields();
        }
    }

    connectedCallback() {
        getUserDetails()
            .then(data => {
                if (data) {
                    this.isUserloggedIn = JSON.parse(JSON.stringify(data));
                    if (this.isUserloggedIn) {
                        getPingUserDetails()
                            .then(data => {
                                if (data) {
                                    this.userMap = JSON.parse(JSON.stringify(data));
                                    this.userCountryCode = this.userMap.countryCode;
                                    this.userPhoneNumber = this.userMap.phoneNumber;
                                }
                            });
                        if (this.isUserloggedIn) {
                            getUserContactDetails()
                                .then(data => {
                                    if (data) {
                                        this.userEmail = data.Email;
                                        this.userName = data.Name;
                                    }
                                });
                        }
                    }
                }
            });
    }

    @wire(getSolutions)
    solutionShowcaseData({ error, data }) {
        if (data) {
            let articles = JSON.parse(JSON.stringify(data));
            for (let i = 0; i < articles.length; i++) {
                this.picklistOrdered = [...this.picklistOrdered, { value: articles[i].Title, label: articles[i].Title }];
            }
            this.picklistOrdered = this.picklistOrdered.sort((a, b) => {
                if (a.label.toLowerCase() < b.label.toLowerCase()) {
                    return -1
                }
            });
            this.picklistOrdered.unshift({ value: "OneDeveloper", label: "OneDeveloper" });
            this.picklistOrdered.unshift({ value: "OneHub", label: "OneHub" });
            this.picklistOrdered.push({ value: "Other", label: "Other" });
        } else if (error) {
            this.error = error;
        }
    }

    handleInputChange(event) {
        const inputBox = event.currentTarget;
        inputBox.setCustomValidity("");
        inputBox.reportValidity();
    }

    search(event) {
        const input = event.detail.value.toLowerCase();
        const result = this.picklistOrdered.filter((picklistOption) =>
            picklistOption.label.toLowerCase().includes(input)
        );
        this.searchResults = result;
    }

    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedSearchResult = this.picklistOrdered.find(
            (picklistOption) => picklistOption.value === selectedValue
        );
        this.clearSearchResults();
    }

    clearSearchResults() {
        this.searchResults = "";
    }

    handleFocusOut() {
        this.clearSearchResults();
    }

    showPicklistOptions() {
        if (!this.searchResults) {
            this.searchResults = this.picklistOrdered;
        }
    }

    setCaseItem(event) {
        if (event) {
            let caseOption = event.target.value;;
            const inputBox = event.currentTarget;
            inputBox.setCustomValidity("");
            inputBox.reportValidity();
            this.CaseType = caseOption;
            this.CaseTypeSelected = true;
            this.formChecker(caseOption);
        }
    }

    get options() {
        return [
            { label: 'Support', value: 'Support' },
            { label: 'Compliment', value: 'Compliment' },
            { label: 'Complaint', value: 'Complaint' }
        ];
    }

    createCase() {
        let email = undefined;
        let contact = undefined;
        let description = undefined;
        let message = undefined;
        let phoneNum = this.userPhoneNumber;
        let EmailUser = this.userEmail;
        let NameUser = this.userName;
        if (!EmailUser) {
            let emailField = this.template.querySelector(`[data-id="EmailCase"]`);
            email = emailField ? emailField.value : "";
        } else {
            email = EmailUser;
        }
        if (!NameUser) {
            let fullNameField = this.template.querySelector(`[data-id="FullNameCase"]`);
            contact = fullNameField ? fullNameField.value : "";
        } else {
            contact = NameUser;
        }
        let origin = "Web";
        let status = "New";
        let subject = 'Onehub - ' + this.CaseType + (this.selectedValue ? ' - ' + this.selectedValue : "");
        let query = this.CaseType;
        let messagefield = this.template.querySelector(`[data-id="description"]`);
        message = messagefield ? messagefield.value : "";
        description = message;
        if (description && query) {
            let newCase = {
                Origin: origin,
                Status: status,
                SuppliedEmail: email,
                SuppliedName: contact,
                SuppliedPhone: phoneNum,
                Description: description,
                Type: query,
                Subject: subject
            }
            if (this.isUserloggedIn) {
                this.submitCase(newCase);
            }
        }
    }

    handleSubmit() {
        let dropdownField = this.template.querySelector(`[data-id="options"]`);
        let dropdown = dropdownField ? dropdownField.value : "";
        let DescriptionField = this.template.querySelector(`[data-id="description"]`);
        let description = DescriptionField ? DescriptionField.value : "";

        if (!dropdown) {
            let dropdownFld = this.template.querySelector(".dropdownOptions");
            dropdownFld.setCustomValidity("Please select a valid option");
            dropdownFld.reportValidity();
        } else {
            this.template.querySelector(".dropdownOptions").setCustomValidity("");
        }
        if (!description) {
            let DescriptionFld = this.template.querySelector(".description");
            DescriptionFld.setCustomValidity("Please enter a description");
            DescriptionFld.reportValidity();
        } else {
            this.template.querySelector(".description").setCustomValidity("");
        }

        if (dropdown && description) {
            this.createCase();
        } else {
            if (!this.showToastFailure) {
                window.scrollTo(0, 0);
                this.showToastFailure = true;
                setTimeout(() => {
                    this.showToastFailure = false;
                }, 5000);
            } else {
                this.template.querySelector('c-osb-toast').opentoast();
            }
        }
    }

    submitCase(newCase) {
        this.isLoading = true;
        createCaseWithContactId({ caseRecord: newCase }).then(data => {
            if (data) {
                this.isLoading = false;
                window.scrollTo(0, 0);
                this.showToastSuccess = true;
                this.template.querySelector(`[data-id="solutionSearch"]`).value = "";
                this.template.querySelector(`[data-id="options"]`).value = "";
                this.template.querySelector(`[data-id="description"]`).value = "";
                this.selectedSearchResult = "";
                this.CaseType = "";
                this.CaseTypeSelected = false;
                this.showPopUp = false;
                setTimeout(() => {
                    this.showToastSuccess = false;
                }, 5000);
            }
        });
        this.template.querySelector(`[data-id="submit"]`).style = "";
        let event = this.eventValues;
        event.name = 'globalFormComplete';
        event.formStatus = 'complete';
        event.formisSubmitted = true;
        this.setInitalAdobeFields();
    }

    callCapture(newCase) {
        this.template.querySelector('c-osb-recapture').doSubmit(newCase);
        this.showToastSuccess = true;
        this.template.querySelector(`[data-id="solutionSearch"]`).value = "";
        this.template.querySelector(`[data-id="description"]`).value = "";
        this.selectedSearchResult = "";
        this.CaseType = "";
        this.CaseTypeSelected = false;
        this.showPopUp = false;
        this.showToastSuccess = false;
    }

    cancelCase() {
        this.showPopUp = true;
        this.eventValues.eventName = 'globalFormAbandon';
        interactionForm(this.eventValues);
    }

    formChecker() {
        if (!this.formStartedValue) {
            this.formStartedValue = true;
            this.setInitalAdobeFields();
        }
    }

    handleCloseEvent(event) {
        if (event.detail === 'YES') {
            this.template.querySelector(`[data-id="solutionSearch"]`).value = "";
            this.selectedSearchResult = "";
            this.template.querySelector(`[data-id="description"]`).value = "";
            this.template.querySelector(`[data-id="options"]`).value = "";
            this.showPopUp = false;
            this.showToastSuccess = false;
        } else {
            this.showPopUp = false;
        }
    }

    setInitalAdobeFields() {
        interactionForm(this.eventValues);
    }
}