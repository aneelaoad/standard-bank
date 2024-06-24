import { LightningElement, api } from 'lwc';
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import MALL_PROFILE_PREFERNCE_HELP_TEXT from '@salesforce/label/c.MALL_PROFILE_PREFERNCE_HELP_TEXT';
import MALL_PROFILE_SAVE_TEXT from '@salesforce/label/c.MALL_PROFILE_SAVE_TEXT';
import DEFAULT_MALL_COUNTRY from '@salesforce/label/c.DEFAULT_MALL_COUNTRY';
import DEFAULT_MALL_LANGUAGE_ISO from '@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO';
import MALL_PROFILE_PREFERNCE_EMAIL_TEXT from '@salesforce/label/c.MALL_PROFILE_PREFERNCE_EMAIL_TEXT';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateUserPreference from '@salesforce/apex/MallUserPreferencesManagement.setUserPreferences';
import getUserPreferences from '@salesforce/apex/MallUserPreferencesManagement.getUserPreferences';
import USER_COUNTRY from "@salesforce/schema/User.User_Franco__c";
import ID_FIELD from "@salesforce/schema/User.Id";
import IS_GUEST from "@salesforce/user/isGuest";
import USER_ID from "@salesforce/user/Id";
import { updateRecord } from "lightning/uiRecordApi";
export default class MallProfileUserPrefences extends LightningElement {

    @api user;
    @api countryList;
    @api languageList;
    
    country;
    language;
    languageName;
    isSaving = false;
    isSaved = false;

    showCountryDropdown = false;
    showLanguageDropdown = false;
    showEmailOptIn = false;
    
    prefernceHelpText = MALL_PROFILE_PREFERNCE_HELP_TEXT;
    sendButtonLabel = MALL_PROFILE_SAVE_TEXT;
    emailOptInText = MALL_PROFILE_PREFERNCE_EMAIL_TEXT;

    mallSavingIcon = mallIcons + '/mallLoadingIcon.svg';
    mallSavedIcon = mallIcons + '/mallSavedIcon.svg';


    connectedCallback() {
        if(this.user) {
            this.country = this.user.User_Franco__c ? this.user.User_Franco__c : DEFAULT_MALL_COUNTRY; 
            this.getUserLanguagePreferences();
        }
    }

    async getUserLanguagePreferences() {
        try {
            let preference = await getUserPreferences();
            let language = preference.userLanguage;
            this.language = language ? language :DEFAULT_MALL_LANGUAGE_ISO ;      
            if (this.countryList && this.country) {
                let selectedCountry = this.countryList.find(cntry => cntry.value == this.country);
                this.countryFlag = selectedCountry.flagImage;
                if (this.language) {
                    this.languageName = selectedCountry.languages.find(lang => lang.value == this.language).label;
                }
                this.disableLanguageDropdown = this.languageList.length <= 1;
                this.showEmailOptIn = this.languageList.length > 1;  
            }  
        } catch ( error) {
            this.error = error;
        }
    }

    showOrHideCountryDropdown() {
        this.showCountryDropdown = !this.showCountryDropdown;
    }

    setSelectedCountry(event) {
        this.country = event.currentTarget.dataset.country;
        let selectedCountry = this.countryList.find(cntry => cntry.value == this.country);
        this.languageList = selectedCountry.languages;
        this.language = this.languageList.length == 1 ? DEFAULT_MALL_LANGUAGE_ISO : selectedCountry.languages.find(lang => lang.value != DEFAULT_MALL_LANGUAGE_ISO).value;
        if (this.language) {
            this.languageName = selectedCountry.languages.find(lang => lang.value == this.language).label;
        }
        this.disableLanguageDropdown = this.languageList.length <= 1;
        this.countryFlag = selectedCountry.flagImage;
        this.showCountryDropdown = false;
        this.showEmailOptIn = this.languageList.length > 1;       
    }

    showOrHideLanguageDropdown() {
        let selectedCountry = this.countryList.find(cntry => cntry.value == this.country);
        this.languageList = selectedCountry.languages;
        if (this.languageList.length > 1 && !this.showLanguageDropdown) {
            this.showLanguageDropdown = true;
        } else {
            this.showLanguageDropdown = false;
        }
        
    }

    setSelectedLanguage(event) {
        this.languageName = this.languageList.find(lang => lang.value == event.currentTarget.dataset.language).label;
        this.language = event.currentTarget.dataset.language;     
        this.showLanguageDropdown = false;
    }

    async saveUserPreferences() {
        try {
            this.isSaving = true;
            if (USER_ID && !IS_GUEST) {
                const fields = {};
                fields[ID_FIELD.fieldApiName] = USER_ID;
                fields[USER_COUNTRY.fieldApiName] = this.country;
                const recordInput = { fields };
                updateRecord(recordInput)
                  .then(() => {})
                  .catch((error) => {
                    this.error = error;
                });
                await updateUserPreference({userId: this.user.Id, languageName: this.language});
              }
            this.isSaving = false;
            this.isSaved = true;
            this.timer = setInterval(() => {
                this.isSaved = false;
             }, 3000);
        } catch(error) {
            this.error = error;
            this.isSaved = false;
            this.isSaving = false;
            this.showToast("Failure!", error, "error");    
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}