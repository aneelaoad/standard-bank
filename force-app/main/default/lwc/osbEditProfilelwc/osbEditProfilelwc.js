import { LightningElement, api, wire } from 'lwc';
import Id from "@salesforce/user/Id";
import { NavigationMixin } from "lightning/navigation";
import getUserDetails from "@salesforce/apex/OSB_EditProfile_CTRL.getUserDetails";
import INDUSTRY_FIELD from '@salesforce/schema/Contact.Company_Industry__c';
import PHONECOUNTRY_FIELD from '@salesforce/schema/Contact.Phone_Country__c';
import updateUserProfile from "@salesforce/apex/OSB_EditProfile_CTRL.updateUserProfile";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import OSBEDITPROFILEICON from '@salesforce/resourceUrl/osbEditProfileIcon';
import isUserLoggedIn from '@salesforce/apex/OSB_EditProfile_CTRL.isUserLoggedIn';
import { interactionForm, addAnalyticsInteractions } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbProfilesAndSettings extends NavigationMixin(LightningElement) {

    osbEditProfileIcon = OSBEDITPROFILEICON;


    userId = Id;
    userDetailsDisplay;
    @api toastMessage = "";
    @api toastType = 'success';
    showToastSuccess = false;
    showToastWarning = false;

    @api blankResponse = false;

    userDetailMap = {};

    countryCodeOptions = [];
    IndustryOptions = [];
    selectedValue;

    givenName = '';;
    familyName = '';;
    countryCode = '';;
    email = '';;
    industry = '';;
    title = '';;
    organisation = '';
    departmentVal = '';
    descriptionVal = '';

    isLoading = false;
    userMap = {};
    userMapInfo;
    userProfileUpdatedSuccessfully;
    pingReturnedData = false;
    phoneCodes = [];

    formStartedValue = false;
    eventValues = {
        name: "globalFormStart",
        formName: 'edit profile',
        formStatus: '',
        formisSubmitted: 'false'
    };
    countryCodeValues = [];


    connectedCallback() {
        this.init();
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

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;


    init() {

        this.isLoading = true;

        isUserLoggedIn()
            .then(result => {
                this.isLoggedIn = result;
                if (this.isLoggedIn) {
                    this.isLoading = true;
                    getUserDetails()
                        .then(data => {
                            if (data) {
                                this.pingReturnedData = data;
                                this.isLoading = false;
                                this.userMap = { ...data.userDetailMap };

                            }

                        }).catch(error => {

                            this.isLoading = false;
                            this.blankResponse = true;
                        });
                }

            }).catch(error => {
                this.error = error;
            });
    }

    @wire(getPicklistValues, { recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId', fieldApiName: INDUSTRY_FIELD })
    wiredData({ error, data }) {

        if (data) {

            this.IndustryOptions = data.values.map(objPL => {
                return {
                    name: `${objPL.name}`,
                    value: `${objPL.value}`
                };
            });

        } else if (error) {
            this.error = error;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId', fieldApiName: PHONECOUNTRY_FIELD })
    wiredDataPhone({ error, data }) {

        if (data) {
            this.countryCodeOptions = data.values.map(objPh => {
                return {
                    name: `${objPh.name}`,
                    value: `${objPh.value}`
                };
            });

        } else if (error) {
            this.error = error;

        }

    }



    submitForm(event) {
        event.preventDefault();

        if (this.checkIfError()) {
            var userMapInfo = this.userMap;
            updateUserProfile({
                userMap: userMapInfo

            }).then(() => {

                let event = this.eventValues;
                event.name = 'globalFormComplete';
                event.formStatus = 'complete';
                event.formisSubmitted = true;
                this.setInitalAdobeFields();
                this.toastMessage = 'Your changes have been saved successfully.'
                this.showToastSuccess = true;
           

            }).catch(error => {
                this.error = error;

            });

        } else {

        }



    }
    checkIfError() {
        var areAllValid = true;
        var inputs = this.template.querySelectorAll('.inputFields')
        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                areAllValid = false;
            }
        });
        return areAllValid;
    }

    handleFieldChange(event) {
        if (event.target.name == 'givenName') {
            if (event.target.value.length < 1) {
                event.target.setCustomValidity("Enter a first name.");
            } else {
                event.target.setCustomValidity("");
            }
        } else if (event.target.name == 'familyName') {
            if (event.target.value.length < 1) {
                event.target.setCustomValidity("Enter a surname.");
            } else {
                event.target.setCustomValidity("");
            }
        } else if (event.target.name == 'phoneNumber') {
            if (event.target.value.length < 1) {
                event.target.setCustomValidity("Enter a valid cellphone number.");
            } else {
                event.target.setCustomValidity("");
            }
        } else if (event.target.name == 'organization') {
            if (event.target.value.length < 1) {
                event.target.setCustomValidity("Enter a valid company name.");
            } else {
                event.target.setCustomValidity("");
            }
        } else if (event.target.name == 'title') {
            if (event.target.value.length < 1) {
                event.target.setCustomValidity("Enter a job title.");
            } else {
                event.target.setCustomValidity("");
            }
        }
        this.userMap[event.target.name] = event.target.value;

    }

    resetForm() {

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: "Home"
            },
        });

    }
    handleReload() {
        this.init();


    }

    firstFormSubmit() {
        if (!this.formStartedValue) {
            this.formStartedValue = true;
            this.setInitalAdobeFields();
        }
    }


    closeSpinnerTimer(event) {
        if (this.isLoading) {
            setTimeout(function () {
                this.isLoading = false;
            }, 10000);
        }
    }
    closeTimedToast(event) {
        if (this.loading) {
            setTimeout(function () {
                this.showMessageToast = false;
            }, 10000);
        }
    }


    closeToast(event) {
        this.showMessageToast = false;
    }

    setInitalAdobeFields() {
        interactionForm(this.eventValues);
    }
  
}