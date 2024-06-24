import { LightningElement } from 'lwc';
import mallIcons from "@salesforce/resourceUrl/mallIcons";
import MALL_PROFILE_MANAGE_NOTIFICATIONS_HELP_TEXT from '@salesforce/label/c.MALL_PROFILE_MANAGE_NOTIFICATIONS_HELP_TEXT';
import MALL_PROFILE_SAVE_TEXT from '@salesforce/label/c.MALL_PROFILE_SAVE_TEXT';
import getNotificationTypes from "@salesforce/apex/MallManageNotificationsCtrl.getNotificationTypes";
import getUserNotificationTypes from "@salesforce/apex/MallManageNotificationsCtrl.getUserNotificationTypes";
import upsertNotifications from "@salesforce/apex/MallManageNotificationsCtrl.upsertNotifications";
import getUserProfile from '@salesforce/apex/MallProfileManagementController.getUserProfile';
import loggedInUserId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const NOTIFICATION_CHANNEL_EMAIL = "Email";
const NOTIFICATION_CHANNEL_INAPP = "InApp";
const NOTIFICATION_CHANNEL_SMS = "SMS";
const NOTIFICATION_CHANNEL_IN_SBG_MALL = "In app notification";
const NOTIFICATION_CHANNEL_BOTH = "Both";

    
export default class MallProfileUserPrefences extends LightningElement {
    notificationTypes = [];
    userProfile;
    userNotificationTypes = {};
    userNotificationTypesIds = []
    userNotificationTypesMap
    error;
    notificationHelpText = MALL_PROFILE_MANAGE_NOTIFICATIONS_HELP_TEXT;
    sendButtonLabel = MALL_PROFILE_SAVE_TEXT;
   
    mallSavingIcon = mallIcons + '/mallLoadingIcon.svg';
    mallSavedIcon = mallIcons + '/mallSavedIcon.svg';
    configuredNotificationTypes = {};
    isSaved = false;
    isSaving = false;

    connectedCallback() {
        this.getUserProfileDetails();
        this.getNotificationTypeSettings();
    }

    checkForNotificationTypeForAudience(notificationType) {
        let profileName = this.userProfile.user.Profile.Name
        if(profileName == "Store Manager" && notificationType.Available_for_Store_Manager__c) {
            return true;
        }
        else if(profileName == "Store Representative" && notificationType.Available_for_Store_Worker__c) {
            return true;
        }
        else if(profileName == "Mall Experience User" && notificationType.Available_for_Mall_Experience_User__c) {
            return true;
        }
        return false;
    }

    async getUserProfileDetails() {
        try {
            this.userProfile = await getUserProfile({ currentUserId: loggedInUserId });
        }catch(error) {
            this.error = error;
        }
    }

    async getNotificationTypeSettings() {
        try {
            const notificationTypes = await getNotificationTypes();
            const userNotificationTypes = await getUserNotificationTypes();
            this.processUserNotificationTypes(userNotificationTypes);
            this.processNotificationTypes(notificationTypes);
        } catch (error) {
            this.error = error;
        }
    }

    processUserNotificationTypes(userNotificationTypes) {
        const userNotificationTypesMap = new Map();
        for(let row = 0; row < userNotificationTypes.length; row++) {
            userNotificationTypesMap.set(userNotificationTypes[row].Name, userNotificationTypes[row]);
        }
        this.userNotificationTypesMap = userNotificationTypesMap;
    }

    processNotificationTypes(notificationTypes) {
        let notificationTypesAvailable = [];
        let userNotificationTypesIds = [];
        for(let row = 0; row < notificationTypes.length; row++) {
            if(notificationTypes[row].IsActive__c && this.checkForNotificationTypeForAudience(notificationTypes[row])) {
                let notificationTypeAvailable = {};
                let notificationRec = {};
                notificationTypeAvailable.id = notificationTypes[row].Id;
                if(this.userNotificationTypesMap.has(notificationTypes[row].Label)){
                    notificationRec = this.userNotificationTypesMap.get(notificationTypes[row].Label);
                    userNotificationTypesIds.push(notificationRec.Id);
                    notificationTypeAvailable.id = notificationRec.Id;
                }
                notificationTypeAvailable.name = notificationTypes[row].Label;
                notificationTypeAvailable.active = notificationTypes[row].IsActive__c;
                notificationTypeAvailable.required = notificationTypes[row].IsRequired__c;
                notificationTypeAvailable.order = notificationTypes[row].Order__c;
                notificationTypeAvailable.channels = [];
                notificationTypeAvailable.options = [];
                notificationTypeAvailable.selectedOptionValue = '';
                let checked = true;
                //to track if all the channels are selected or not
                let allAllowedChecked = 0;
                //if notification record exists, then checked value from record else set itz
                
                if(notificationTypes[row].In_App__c) {
                    checked = notificationRec.Id ? notificationRec.In_App__c : true;
                    if(checked) {
                        notificationTypeAvailable.selectedOptionValue = NOTIFICATION_CHANNEL_INAPP;
                        allAllowedChecked++;
                    }
                    notificationTypeAvailable.options.push({label: NOTIFICATION_CHANNEL_IN_SBG_MALL, value: NOTIFICATION_CHANNEL_INAPP});
                }
                if(notificationTypes[row].Email__c) {
                    checked = notificationRec.Id ? notificationRec.Email__c : true;
                    if(checked) {
                        notificationTypeAvailable.selectedOptionValue = NOTIFICATION_CHANNEL_EMAIL;
                        allAllowedChecked++;
                    }                    
                    notificationTypeAvailable.options.push({label: NOTIFICATION_CHANNEL_EMAIL, value: NOTIFICATION_CHANNEL_EMAIL});
                }
                if(notificationTypes[row].SMS__c) {
                    checked = notificationRec.Id ? notificationRec.SMS__c : true;
                    if(checked) {
                        notificationTypeAvailable.selectedOptionValue = NOTIFICATION_CHANNEL_SMS;
                        allAllowedChecked++;
                    }                    
                    notificationTypeAvailable.options.push({label: NOTIFICATION_CHANNEL_SMS, value: NOTIFICATION_CHANNEL_SMS});
                }
                //If required and both checked
                if(notificationTypeAvailable.required && notificationTypeAvailable.options.length > 1) {
                    notificationTypeAvailable.options.push({label: NOTIFICATION_CHANNEL_BOTH, value: NOTIFICATION_CHANNEL_BOTH});

                    if(allAllowedChecked >= 2) {
                        notificationTypeAvailable.selectedOptionValue =  NOTIFICATION_CHANNEL_BOTH;
                    }
                }

                if(notificationTypeAvailable.required && notificationTypeAvailable.options.length == 1) {
                    notificationTypeAvailable.selectedOptionValue =  notificationTypeAvailable.options[0].value;
                    notificationTypeAvailable.disabled = true;      
                } 
                notificationTypesAvailable.push(notificationTypeAvailable);
            }
        }

        notificationTypesAvailable = this.sortData("order", "asc", notificationTypesAvailable, "number");
        this.notificationTypes = [...notificationTypesAvailable];
        this.userNotificationTypesIds = [...userNotificationTypesIds];
    }

    async updateManagedNotifications(event) {
        let notificationTypesForUser = [];
        let Sobjects = [];
        for(let row = 0; row < this.notificationTypes.length; row++) {
            let Sobject = {};
            Sobject.User__c = loggedInUserId;
            Sobject.Contact__c = this.userProfile.user.ContactId;
            Sobject.Name = this.notificationTypes[row].name;
            if(this.userNotificationTypesIds.includes(this.notificationTypes[row].id)) {
                Sobject.Id = this.notificationTypes[row].id;
            }

            if(this.notificationTypes[row].selectedOptionValue == NOTIFICATION_CHANNEL_BOTH) {
                for(let i=0; i < this.notificationTypes[row].options.length; i++) {
                    if(this.notificationTypes[row].options[i].value == NOTIFICATION_CHANNEL_EMAIL) {
                        Sobject.Email__c = true;
                    }
                    else if(this.notificationTypes[row].options[i].value == NOTIFICATION_CHANNEL_SMS) {
                        Sobject.SMS__c = true;
                    }
                    else if(this.notificationTypes[row].options[i].value == NOTIFICATION_CHANNEL_IN_SBG_MALL) {
                        Sobject.In_App__c = true;
                    }
                }
            } else {
                Sobject.Email__c = false;
                Sobject.SMS__c = false;
                Sobject.In_App__c = false;
                for(let i=0; i < this.notificationTypes[row].options.length; i++) {
                    if(this.notificationTypes[row].options[i].value == this.notificationTypes[row].selectedOptionValue && this.notificationTypes[row].selectedOptionValue == NOTIFICATION_CHANNEL_EMAIL) {
                        Sobject.Email__c = true;
                    }
                    else if(this.notificationTypes[row].options[i].value == this.notificationTypes[row].selectedOptionValue && this.notificationTypes[row].selectedOptionValue == NOTIFICATION_CHANNEL_SMS) {
                        Sobject.SMS__c = true;
                    }
                    else if(this.notificationTypes[row].options[i].value == this.notificationTypes[row].selectedOptionValue && this.notificationTypes[row].selectedOptionValue == NOTIFICATION_CHANNEL_INAPP) {
                        Sobject.In_App__c = true;
                    }
                }
            }
            Sobjects.push(Sobject);
        }
        try {
            notificationTypesForUser = await upsertNotifications({notifications: Sobjects});
            this.getNotificationTypeSettings();
        } catch(error) {
            this.error;
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

    handleSelectionChange(event) {
        event.preventDefault();
        event.stopPropagation();
        const selectedOptionNotificationId = event.target.dataset.formfield;
        const selectedOptionValue = event.target.value;
        for(let row=0; row< this.notificationTypes.length; row++) {
            if(this.notificationTypes[row].options && this.notificationTypes[row].options.length > 0 && this.notificationTypes[row].id === selectedOptionNotificationId) {
                this.notificationTypes[row].selectedOptionValue = selectedOptionValue;
                break;
            }
        }
    }

    async handleRequiredNotificationChange(event) {
        try{
            this.isSaving = true;
            this.isSaved = false;
            await this.updateManagedNotifications(event);
            this.isSaving = false;
            this.isSaved = true;
            this.timer = setInterval(() => {
                this.isSaved = false;
            }, 3000);
        } catch(error) {
            this.error = error;
            this.showToast("Failure!", "Manage Notification changes failed to save", "error");  
        }
    }


    getClosestElementForSaveUpdate(element, classNameSelector, status) {
        let elementclosest;
        if(element) {
            elementclosest = element.closest(classNameSelector);
        }
        if(elementclosest) {
            elementclosest.dataset["isSaving"]=status;
        }
    }

    sortData(fieldName, sortDirection, array, type) {
        let sortResult = [...array];
        let parser = (v) => v;
        if(type==='date' || type==='datetime') {
          parser = (v) => (v && new Date(v));
        }
        let sortMult = sortDirection === 'asc'? 1: -1;
        array = sortResult.sort((a,b) => {
          let a1 = parser(a[fieldName]), b1 = parser(b[fieldName]);
          let r1 = a1 < b1, r2 = a1 === b1;
          return r2? 0: r1? -sortMult: sortMult;
        });
        return array;
    }
}