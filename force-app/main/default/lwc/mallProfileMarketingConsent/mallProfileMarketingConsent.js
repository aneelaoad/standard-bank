import { LightningElement, api } from 'lwc';
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import MALL_PROFILE_MARKETING_CONSENT_HELP_TEXT from '@salesforce/label/c.MALL_PROFILE_MARKETING_CONSENT_HELP_TEXT';
import MALL_PROFILE_SAVE_TEXT from '@salesforce/label/c.MALL_PROFILE_SAVE_TEXT';
import updateUserPreference from '@salesforce/apex/SBGNavigationBarController.updateUserPreference';

export default class MallProfileUserPrefences extends LightningElement {

    @api user;
    
    marketingConsentHelpText = MALL_PROFILE_MARKETING_CONSENT_HELP_TEXT;
    sendButtonLabel = MALL_PROFILE_SAVE_TEXT;
   
    mallSavingIcon = mallIcons + '/mallLoadingIcon.svg';
    mallSavedIcon = mallIcons + '/mallSavedIcon.svg';


    connectedCallback() {
    }

    get marketingConsentOptions() {
        
        return [
            {
                sectionLabel: 'Telesales',
                sectionValue: 'TELE-SALES CONSENT',
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Email marketing',
                sectionValue: 'EMAIL CONSENT',
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'SMS marketing',
                sectionValue: 'SMS CONSENT',
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'In-app marketing notifications',
                sectionValue: 'IN APP MARKETING',
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Data sharing within the Group',
                sectionValue: 'SHARE CUSTOMER DATA',
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Data sharing with third parties',
                sectionValue: 'SHARE CUSTOMER DATA WITH 3RD PARTY',
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Data sharing across within the Group',
                sectionValue: 'SHARE CUSTOMER DATA',
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Receive marketing',
                sectionValue: 'RECEIVE MARKETING',
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            },
            {
                sectionLabel: 'Marketing research',
                sectionValue: 'MARKETING RESEARCH',
                options: [
                    { label: 'Yes', value: 'Yes' },
                    { label: 'No', value: 'No' }
                ]        
            }
        ]
    }
    


}