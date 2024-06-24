import { LightningElement , wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import INDUSTRY_FIELD from '@salesforce/schema/Contact.Company_Industry__c';
import PHONECOUNTRY_FIELD from '@salesforce/schema/Contact.Phone_Country__c';
import OPERATINGCOUNTRIES_FIELD from '@salesforce/schema/Contact.OSB_Operating_Country__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getOSBDocumentURL from '@salesforce/apex/OSB_LightningSelfRegisterController.getOSBDocumentURL';
import sendDataToPing from '@salesforce/apex/OSB_LightningSelfRegisterController.sendDataToPing';
import updateContact from '@salesforce/apex/OSB_LightningSelfRegisterController.updateContact';
import getLightContact from '@salesforce/apex/OSB_LightningSelfRegisterController.getLightContact';
import checkForUser from '@salesforce/apex/OSB_LightningSelfRegisterController.checkForUser';
import getLoginURL from '@salesforce/apex/OSB_Header_CTRL.getLoginURL';
import getIELoginURL from '@salesforce/apex/OSB_Header_CTRL.getIELoginURL';
import flagRegistration from '@salesforce/apex/OSB_LightningSelfRegisterController.flagRegistration';

const HaltRegistration = 'Halt Registration';
const AuthorizedPerson = 'Authorised Person';

export default class OsbRegistrationFormLwc extends NavigationMixin(LightningElement) {

    docTypeChecked = true;
    docTypeLabel = 'ID Number';
    docTypePlaceholder = 'Enter your ID number';

    countryCodeOptions = [];
    industryOptions = [];
    operatingCountriesOptions = [];
    selectedOperatingCountries = [];

    authorization;
    firstSectionAp;
    showInformation;
    additionalNpDp = false;
    passIsTyped = false;
    foundOldUser = false;
    signUpError = false;
    errorTitle = 'Incorrect URL';
    errorSubtitle = 'We suggest that you attempt the sign up process again at a later time.';
    errorMessage = 'Alternatively, retry copying the URL into a new browser window.';
    errorButtonText = 'Visit OneHub Home';
    isLoading = false;
    submitLoading = false;
    showToastFail = false;

    UserDetails = [];
    contactId;
    contactName;
    contactLastName;
    contactEmail;
    contactIdNum;
    contactPassportNum;
    contactIndustry;
    contactStatus;
    contactCompany;
    contactOperating;
    contactPhoneNum;
    contactPhoneCountry;
    contactJobTitle;

    errorCount = 1;
    passwordMessage = 'Enter a valid password';
    confirmPasswordMessage = 'Confirm entered password';
    idNumberMessage = '';

    showPasswordText = 'password';
    showConfirmPasswordText = 'password';
    showPasswordClass = 'msClass ms-icn_eye_closed eyeIcon';
    showConfirmPasswordClass = 'msClass ms-icn_eye_closed eyeIcon';

    termsConditionsURL;
    showPopUp = false;
    loginUrl;

    upperValidations = 'unfulfilled';
    lowerValidations = 'unfulfilled';
    specialValidations = 'unfulfilled';
    numberValidations = 'unfulfilled';
    whiteValidations = 'unfulfilled';
    lengthValidations = 'unfulfilled';

    containsCountries = false;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PHONECOUNTRY_FIELD
    })
    wiredDataPhone({ data }) {
        if (data) {
            this.countryCodeOptions = data.values.map((objCc) => {
                return {
                    name: `${objCc.name}`,
                    value: `${objCc.value}`,
                    selected : false
                };
                
            });
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: INDUSTRY_FIELD
    })
    wiredDataIndustry({ data }) {
        if (data) {
            this.industryOptions = data.values.map((objCi) => {
                return {
                    name: `${objCi.name}`,
                    value: `${objCi.value}`
                };
            });
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: OPERATINGCOUNTRIES_FIELD
    })
    wiredDataCountry({ data }) {
        if (data) {
            this.operatingCountriesOptions = data.values.map((objOc) => {
                return {
                    label: `${objOc.label}`,
                    value: `${objOc.value}`
                };
            });
        }
    }

    connectedCallback() {
        this.isLoading = true;
        let sPageURL = decodeURIComponent(window.location.search.substring(1)); 
        let sURLVariables = sPageURL.split('?');
        let sParameterName;
        let encodedValue;

        for (let i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] === 'record') {
                encodedValue = sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
            }
        }

        if (!encodedValue || encodedValue === 'Not found') {
            this.signUpError = true;
            return;
        }

        if (encodedValue.includes(' ')) {
            encodedValue = encodedValue.replace(/ /g,'+');
        }

        getLightContact({ contactId: encodedValue , encoded: true })
        .then(result => {
            if(result){
                for(let index in result) {
                    let user = result[index];
                    this.UserDetails.push(user);  
                }
            }
            if (this.UserDetails) {
                this.contactId = this.UserDetails[0].Id;
                this.contactName = this.UserDetails[0].FirstName;
                this.contactLastName = this.UserDetails[0].LastName;
                this.contactEmail = this.UserDetails[0].Email;
                this.contactIdNum = this.UserDetails[0].Identity_Number__c;
                this.contactPassportNum = this.UserDetails[0].OSB_Passport_Number__c;
                this.contactIndustry = this.UserDetails[0].Company_Industry__c;
                this.contactStatus = this.UserDetails[0].OSB_Community_Access_Role__c;
                this.contactCompany = this.UserDetails[0].OSB_Company_name__c;
                this.contactOperating = this.UserDetails[0].OSB_Operating_Country__c;
                this.contactPhoneNum = this.UserDetails[0].Phone;
                this.contactPhoneCountry = this.UserDetails[0].Phone_Country__c ;
                this.contactJobTitle = this.UserDetails[0].Title;
                let expiredLink = this.UserDetails[0].OSB_Expire_Sign_Up_Link__c;
                let manageFeature  = this.UserDetails[0].Manage_Site_Features__c;

                if(manageFeature){
                    if (manageFeature.includes(HaltRegistration)) {
                        this.signUpError = true;
                        this.errorTitle = 'Your account has been locked';
                        this.errorSubtitle = 'Your account has been temporarily locked because of multiple failed signin attempts.';
                        this.errorMessage = 'Please contact the OneHub support team for further details.';
                        return;
                    } else {
                        manageFeature = '';
                    }
                }

                if (expiredLink) {
                    this.errorTitle = 'Existing account';
                    this.errorSubtitle = 'It seems you have already completed the sign up process. Please sign in to continue.';
                    this.errorMessage = '';
                    this.errorButtonText = 'Sign in';
                    this.signUpError = true;
                    return;
                }

                this.checkOptionsPopulated();

                if (this.contactStatus === AuthorizedPerson) {
                    this.authorization = true;
                    this.firstSectionAp = true;
                    this.showInformation = false;
                } else {
                    this.additionalNpDp =  true;
                    this.authorization = false;
                    this.firstSectionAp = false;
                    this.showInformation = true;
                }
            }
            this.checkForReturningUser();
        })
        .catch(error => {
            this.isLoading = false;
            this.signUpError = true;
        })

        this.getTermsAndConditionsLink();
        this.getLoginPath();
        
    }

    checkEmptyInputs() {
        this.contactJobTitle = this.contactJobTitle || '';
        this.contactCompany = this.contactCompany || '';
        if(this.contactPhoneNum === '0000000000' || !this.contactPhoneNum){
            this.contactPhoneNum = '';
            this.countryCodeOptions.forEach((country) => {
                country.selected = country.value === this.contactPhoneCountry;
            });
        }
    }

    checkForReturningUser() {
        checkForUser({ userEmail: this.contactEmail })
            .then(result => {
                this.foundOldUser = result;
            })
    }

    checkOptionsPopulated() {
        let pollingInterval = setInterval(() => {
            if (this.countryCodeOptions && this.operatingCountriesOptions && this.industryOptions) {
                clearInterval(pollingInterval);
                this.selectedDropdownValues();
            }
        }, 500); 
    }

    selectedDropdownValues() {
        if(this.contactOperating){
            let chosenOperatingCountries = JSON.parse(JSON.stringify(this.contactOperating));
            this.operatingCountriesOptions.forEach((operating) => {
                if (chosenOperatingCountries.includes(operating.value)) {
                    operating.selected = true;
                    this.containsCountries = true;
                }
            });
        }
        this.selectedOperatingCountries = JSON.parse(JSON.stringify(this.operatingCountriesOptions)).filter((values) => values.selected);

        this.industryOptions.forEach((industry)=>{
            industry.selected = false;
            if(industry.value === this.contactIndustry){
                industry.selected = true;
            }
        });

        this.countryCodeOptions.forEach((country)=>{
            country.selected = false;
            if(country.value === this.contactPhoneCountry){
                country.selected = true;
            }
        });

        this.checkEmptyInputs();
        this.isLoading = false;
    }

    getTermsAndConditionsLink() {
        getOSBDocumentURL({ docName: 'Terms_Conditions' })
            .then(result => {
                this.termsConditionsURL = result;
            })
    }

    getLoginPath(){
        if (window.navigator.userAgent.indexOf("MSIE ") > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))  {
            getIELoginURL().then(data => {
                this.loginUrl = data;
            })
        } else {
            getLoginURL().then(data => {
                this.loginUrl = data;
            })
        }
    }
    
    errorProceed() {
        if(this.errorButtonText === 'Visit OneHub Home'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: "Home"
                },
            });
        } else {
            window.open(this.loginUrl,'_top');
        } 
    }

    proceed(){ 
        let count = this.errorCount;
        if (count <= 3) {
            this.errorCount = count + 1;
            let recordId = this.contactIdNum;
            let recordPassport = this.contactPassportNum;
            let idNumber = this.template.querySelector('[data-id="docTypeIdInput"]');
            let foundInput = idNumber ? idNumber.value : "";

            let docTypeIdInputError = this.template.querySelector('[data-id="docTypeIdInputError"]');
            let docTypeIdInput = this.template.querySelector('[data-id="docTypeIdInput"]');

            if (recordId === foundInput || recordPassport === foundInput ) {
                docTypeIdInputError.style = 'display: none';                
                this.authorization = true;
                this.firstSectionAp = false;
                this.showInformation = true;
            } else {  
                docTypeIdInputError.style = 'display: flex';
                docTypeIdInput.style = 'display: flex; border-color: red;';
                if (count === 1) {
                    this.idNumberMessage = "You have entered an incorrect value that is not associated with your invite. You have 2 more attempts before the invite expires and a new one will have to be resent to you.";
                } else if (count === 2) {
                    this.idNumberMessage = "You have entered an incorrect value that is not associated with your invite. You have 1 more attempt before the invite expires and a new one will have to be resent to you.";
                } else if (count === 3) {
                    flagRegistration({contactId: this.contactId});
                    this.signUpError = true;
                    this.errorTitle = 'Your account has been locked';
                    this.errorSubtitle = 'Your account has been temporarily locked because of multiple failed login attempts.';
                    this.errorMessage = 'Please contact the OneHub support team for further details.';
                    return;
                }
            }
        } 
    }

    handleChange(event){
        this.initializeValues();
        let selectedValue = event.target.value;
    
        if (selectedValue === 'ID Number' || selectedValue === 'Passport Number') {
            this.docTypeChecked = selectedValue === 'ID Number';
            this.docTypeLabel = selectedValue;
            this.docTypePlaceholder = `Enter your ${selectedValue}`;
        } else {
            let fieldName = event.target.name;
            let errorName = fieldName + 'Error';
            let inputField = this.template.querySelector(`[data-id="`+fieldName+`"]`);
            if(!inputField.checkValidity() ){
                inputField.style = 'border-color: red;';
                this.template.querySelector(`[data-id="`+errorName+`"]`).style = "display: flex;"
            } else 
            {
                inputField.style = 'border-color: grey;';
                this.template.querySelector(`[data-id="`+errorName+`"]`).style = "display: none;"
            }
        }
    }

    handleChangeAp(event){
        let selectedValue = event.target.value;
        let isIDNumber = selectedValue === 'ID Number';
        this.docTypeLabel = isIDNumber ? 'ID Number' : 'Passport Number';
        this.docTypePlaceholder = isIDNumber ? 'Enter your ID number' : 'Enter your Passport number';
        this.docTypeChecked = isIDNumber;
    }

    formSubmitted() {
        this.initializeValues();

        const isInputsCorrect = [...this.template.querySelectorAll("input")].reduce((validSoFar, inputField) => {
            let nameErrorField = inputField.name + 'Error';
            if(this.foundOldUser) {
                if(!inputField.name.includes("docType")) {
                    if(!inputField.name.includes("password")) {
                        if(!inputField.checkValidity()){
                            this.template.querySelector(`[data-id="`+nameErrorField+`"]`).style.display = 'flex';
                            inputField.style = 'border-color: red;'
                        } else {
                            this.template.querySelector(`[data-id="`+nameErrorField+`"]`).style.display = 'none';
                            inputField.style = 'border-color: grey;'
                        }
                        return validSoFar && inputField.checkValidity();
                    } else {
                        return validSoFar && true;
                    }
                } else {
                    return validSoFar && true;
                }
            } else {
                if(!inputField.name.includes("docType")) {
                    if(!inputField.checkValidity()){
                        this.template.querySelector(`[data-id="`+nameErrorField+`"]`).style.display = 'flex';
                        inputField.style = 'border-color: red;'
                    } else {
                        this.template.querySelector(`[data-id="`+nameErrorField+`"]`).style.display = 'none';
                        inputField.style = 'border-color: grey;'
                    }
                    return validSoFar && inputField.checkValidity();
                } else {
                    return validSoFar && true;
                }
            }
        }, true);

        const isSelectsCorrect = [...this.template.querySelectorAll("select")].reduce((validSoFar, selectField) => {
            let nameErrorField = selectField.name + 'Error';
                if (!selectField.checkValidity()) {
                    this.template.querySelector(`[data-id="` + nameErrorField + `"]`).style.display = 'flex';
                    selectField.style = 'border-color: red;';
                } else {
                    this.template.querySelector(`[data-id="` + nameErrorField + `"]`).style.display = 'none';
                    selectField.style = 'border-color: grey;';
                }
                return validSoFar && selectField.checkValidity();
        }, true);

        let isMultiSelectCorrect = false;
        if (!this.containsCountries) {
            this.template.querySelector('[data-id="opCountriesError"]').style.display = 'flex';
        } else { 
            this.template.querySelector('[data-id="opCountriesError"]').style.display = 'none';
            isMultiSelectCorrect = true;
        }
        this.template.querySelector('c-osb-multi-select-combo-box-lwc').validationComboBox(isMultiSelectCorrect);

        if (isInputsCorrect && isSelectsCorrect && isMultiSelectCorrect) {
            let validationResult = true;
            let passwordField = this.template.querySelector('[data-id="password"]');
            let password = passwordField ? passwordField.value : "";
            let confirmPasswordField = this.template.querySelector('[data-id="confirmPassword"]');
            let confirmPassword = confirmPasswordField ? confirmPasswordField.value : "";

            if (!this.foundOldUser) {
                const regWhiteSpace = /\s+/;
                const specialCheck = /[@$!%*?&]/;
                const caseLowerCheck = /[a-z]/;
                const caseCheckUpper = /[A-Z]/;
                const numerialCheck = /[0-9]/;
                let numbericCount = (password.match(/\d/g) || []).length;

                passwordField.style = 'border-color: red;';
                if ( password === this.contactName || password === this.contactLastName || password === this.contactEmail) {
                    this.passwordMessage = "Password cannot be the same as name, surname or email address";
                    this.template.querySelector('[data-id="passwordError"]').style = "display: flex;"
                    return;
                } else if (password.toLowerCase() === this.contactEmail.toLowerCase() || password.toLowerCase() === this.contactName.toLowerCase() || password.toLowerCase() === this.contactLastName.toLowerCase()) {
                    this.passwordMessage = "Password cannot be the same as name, surname or email address";
                    this.template.querySelector('[data-id="passwordError"]').style = "display: flex;"
                    return;
                } else if (!caseLowerCheck.test(password) || !caseCheckUpper.test(password) || !numerialCheck.test(password) || regWhiteSpace.test(password) || numbericCount === 1 || !specialCheck.test(password) || password.length < 7) {
                    this.passwordMessage = "Please update your password to meet the required criteria above";
                    this.template.querySelector('[data-id="passwordError"]').style = "display: flex;"
                    return;
                } else if (confirmPassword !== password) {
                    this.template.querySelector('[data-id="confirmPasswordError"]').style = "display: flex;"
                    this.confirmPasswordMessage = "Please ensure both password and confirm password match"
                    passwordField.style = 'border-color: grey;';
                    confirmPasswordField.style = 'border-color: red;';
                    return;
                } else {
                    validationResult = false;
                    passwordField.style = 'border-color: grey;';
                    this.template.querySelector('[data-id="passwordError"]').style = "display: none;"
                    confirmPasswordField.style = 'border-color: grey;';
                    this.template.querySelector('[data-id="confirmPasswordError"]').style = "display: none;"
                    this.confirmPasswordMessage = "";
                    this.passwordMessage = "";
                }
            } else {
                validationResult = false;
            }

            if (validationResult === false) {
                
                this.submitLoading = true;

                let docTypeField = this.template.querySelector(`[data-id="docTypeInput"]`);
                if(this.docTypeChecked && !this.authorization){
                    this.contactIdNum = docTypeField ? docTypeField.value : this.contactId;
                } else {
                    this.contactPassportNum = docTypeField ? docTypeField.value : this.contactPassportNum;
                }

                let newContact = {
                    Email: this.contactEmail,
                    FirstName: this.contactName,
                    LastName: this.contactLastName,
                    Title: this.contactJobTitle,
                    OSB_Company_name__c: this.contactCompany,
                    Phone_Country__c: this.contactPhoneCountry,
                    Phone: this.contactPhoneNum,
                    Company_Industry__c: this.contactIndustry,
                    Identity_Number__c : this.contactIdNum,
                    OSB_Passport_Number__c : this.contactPassportNum
                };

                this.selectedOperatingCountries = this.selectedOperatingCountries.map(item => {
                    return item.value;
                 });
                newContact.OSB_Operating_Country__c =  this.selectedOperatingCountries.join(";");
                newContact.Id = this.contactId;
               this.signUp(newContact, password, this.contactIdNum);
            }
        } 
        else {
            this.showToastFail = true;
            setTimeout(() => {
                this.showToastFail = false;
            }, 5000);
            return;
        }
    }   

    initializeValues() {
        let getField = (fieldName) => {
            let field = this.template.querySelector(`[data-id="${fieldName}"]`);
            return field ? field.value : "";
        };
    
        this.contactJobTitle = getField('jobTitle');
        this.contactCompany = getField('companyName');
        this.contactIndustry = getField('industry');
        this.contactPhoneCountry = getField('countryCode');
        this.contactPhoneNum = getField('phoneNumber');
    }
    
    signUp(newContact, password, IdNumberValue) {
        sendDataToPing({ newContact, password, IdNumberValue })
        .then(PingId => {
            if (PingId.includes("entryUUID")) {
                return updateContact({
                    newContact: newContact,
                    idNum: IdNumberValue,
                    pingId: PingId
                });
            } else {
                this.submitLoading = false;
                this.showPingErrorToast = true;
            }
        })
        .then(contactId => {
            this.submitLoading = false;
            if (contactId) {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'CongratulationsPage__c'
                    },
                    state: {
                        record: contactId
                    }
                });
            }
        })
    }

    cancel() {
        this.showPopUp = true;
    }
    
    handleCloseEvent(event) {
        let optionSelected = event.detail;
        if (optionSelected === 'YES') {
            location.reload();
            this.showPopUp = false;
        } else {
            this.showPopUp = false;
        }
    }

    handlePassEntered(event) {
        const passValue = event.target.value;
        this.passIsTyped = true;
        this.validatePassValue(passValue);
    }

    validatePassValue(validatePassValue){
        const regExUppercase = /(?=.*?[A-Z])/;
        const regExLowercase = /(?=.*?[a-z])/;
        const regExSpecial = /(?=.*?[#?!@$%^&*-])/;
        const regExNumber = /(?=(.*?\d){2})/;
        const regWhiteSpace = /\s+/;

        this.upperValidations = regExUppercase.test(validatePassValue) ? 'fulfilled' : 'unfulfilled';
        this.lowerValidations = regExLowercase.test(validatePassValue) ? 'fulfilled' : 'unfulfilled';
        this.specialValidations = regExSpecial.test(validatePassValue) ? 'fulfilled' : 'unfulfilled';
        this.numberValidations = regExNumber.test(validatePassValue) ? 'fulfilled' : 'unfulfilled';
        this.whiteValidations = !regWhiteSpace.test(validatePassValue) ? 'fulfilled' : 'unfulfilled';
        this.lengthValidations = validatePassValue.length > 7 ? 'fulfilled' : 'unfulfilled';
    }

    togglePassword() {
        this.showPasswordText = this.showPasswordText === 'password' ? 'text' : 'password';
        this.showPasswordClass = this.showPasswordText === 'password' ? 'msClass ms-icn_eye_closed eyeIcon' : 'msClass ms-icn_eye_open eyeIcon';
    }

    toggleConfirmPassword() {
        this.showConfirmPasswordText = this.showConfirmPasswordText === 'password' ? 'text' : 'password';
        this.showConfirmPasswordClass = this.showConfirmPasswordText === 'password' ? 'msClass ms-icn_eye_closed eyeIcon' : 'msClass ms-icn_eye_open eyeIcon';
    }

    handleChangeOC(event) {
        this.selectedOperatingCountries = event.detail;
        if(this.selectedOperatingCountries.length > 0){
            this.containsCountries = true;
            this.template.querySelector('c-osb-multi-select-combo-box-lwc').validationComboBox(true);
            this.template.querySelector('[data-id="opCountriesError"]').style = "display: none;";
        }else{
            this.containsCountries = false;
            this.template.querySelector('[data-id="opCountriesError"]').style = "display: flex;";
            this.template.querySelector('c-osb-multi-select-combo-box-lwc').validationComboBox(false);
        }
    }

}