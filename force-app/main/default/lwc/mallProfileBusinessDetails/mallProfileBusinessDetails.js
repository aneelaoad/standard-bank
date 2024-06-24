import { LightningElement, api } from 'lwc';
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import updateRecords from '@salesforce/apex/MallProfileManagementController.updateRecords';
import MALL_PROFILE_BUSINESS_DETAILS_HELP_TEXT from '@salesforce/label/c.MALL_PROFILE_BUSINESS_DETAILS_HELP_TEXT';
import MALL_PROFILE_SAVE_TEXT from '@salesforce/label/c.MALL_PROFILE_SAVE_TEXT';

export default class MallProfileUserPrefences extends LightningElement {

    @api userProfile;
    businessName = '';
    cipc = '';
    accountId = '';
    vatRegistrationNumber = '';
    @api countryName;
    
    businessHelpText = MALL_PROFILE_BUSINESS_DETAILS_HELP_TEXT;
    sendButtonLabel = MALL_PROFILE_SAVE_TEXT;
   
    mallSavingIcon = mallIcons + '/mallLoadingIcon.svg';
    mallSavedIcon = mallIcons + '/mallSavedIcon.svg';
    isSaved = false;
    isSaving = false;
    error;

    connectedCallback() {
        if(this.userProfile && this.userProfile.user.Contact != null) {
            this.accountId = this.userProfile.user.AccountId;
            if (this.userProfile.user.Contact.Account.Name) {
                this.businessName = this.userProfile.user.Contact.Account.Name;
            }
            if (this.userProfile.user.Contact.Account.VAT_Registration_Number__c) {
                this.vatRegistrationNumber = this.userProfile.user.Contact.Account.VAT_Registration_Number__c;
            }
            if (this.userProfile.user.Contact.Account.CIPC__c) {
                this.cipc = this.userProfile.user.Contact.Account.CIPC__c;
            }       
        }
    }

    get showCIPC(){
        return this.countryName=='South Africa';
    }

    handleInputChange(event) {
        this[event.target.name] = event.target.value;
    }

    async handleBusinessInfoChange(event) {
        event.preventDefault();
        this.isSaving = true;
        let sObject = {};
        sObject.Id = this.accountId;
        if (this.cipc) {
            sObject.CIPC__c = this.cipc;
        }
        if (this.businessName) {
            sObject.Name = this.businessName;
        }
        if (this.vatRegistrationNumber) {
            sObject.VAT_Registration_Number__c = this.vatRegistrationNumber;
        }
        try {
            this.isSaving = true;
            this.isSaved = false;
            await updateRecords({ records: [sObject] });
            this.isSaving = false;
            this.isSaved = true;
            this.timer = setInterval(() => {
                this.isSaved = false;
            }, 3000);
        } catch (error) {
            this.error = error;
        }
    }
}