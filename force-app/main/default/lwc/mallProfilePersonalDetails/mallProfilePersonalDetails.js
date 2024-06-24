import { LightningElement, api } from 'lwc';
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import MALL_PROFILE_UPDATE_DETAILS from '@salesforce/label/c.MALL_PROFILE_UPDATE_DETAILS';
import MALL_PROFILE_UPDATE_TEXT from '@salesforce/label/c.MALL_PROFILE_UPDATE_TEXT';
import { getBaseUrl } from "c/mallNavigation";

export default class MallProfilePersonalDetails extends LightningElement {

    @api user;
    firstName = '';
    lastName = '';
    cellPhone = '';
    userName = '';
    emailAddress = '';
    isSaving = false;
    isSaved = false;
    
    sendButtonLabel = MALL_PROFILE_UPDATE_DETAILS;
    mallProfileUpdateText = MALL_PROFILE_UPDATE_TEXT;

    updateProfileDetailLink = getBaseUrl() + '/mall/s/update-personal-details';

    mallSavingIcon = mallIcons + '/mallLoadingIcon.svg';
    mallSavedIcon = mallIcons + '/mallSavedIcon.svg';


    connectedCallback() {
        if(this.user) {
            this.firstName = this.user.FirstName ? this.user.FirstName : '';
            this.lastName = this.user.LastName ? this.user.LastName : '';
            this.emailAddress = this.user.Email ? this.user.Email : '';
            this.userName = this.user.Ping_UserName__c ? this.user.Ping_UserName__c : '';
            this.cellPhone = this.user.MobilePhone ? this.user.MobilePhone : '';
        }
    }
}