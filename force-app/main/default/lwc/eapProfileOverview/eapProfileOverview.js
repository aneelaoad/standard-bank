import { LightningElement, wire, track } from 'lwc';
import getUserInfo from '@salesforce/apex/EAP_CTRL_ProfilePage.getUserInfo';
import updateUserInfo from '@salesforce/apex/EAP_CTRL_ProfilePage.updateUserInfo';
import getAllInterests from '@salesforce/apex/EAP_CTRL_ProfilePage.getAllInterests';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';

import TITLE_LABEL from '@salesforce/label/c.Eap_Title_Label';
import ABOUT_ME_LABEL from '@salesforce/label/c.Eap_AboutMe_Label';
import CONTACT_INFORMATION_LABEL from '@salesforce/label/c.Eap_ContactInformation_Label';
import EMAIL_LABEL from '@salesforce/label/c.Eap_Email_Label';
import MOBILE_LABEL from '@salesforce/label/c.Eap_Mobile_Label';
import PHONE_LABEL from '@salesforce/label/c.Eap_PhoneNumber_Label';
import TIME_ZONE_LABEL from '@salesforce/label/c.Eap_TimeZone_Label';
import MY_INTERESTS_LABEL from '@salesforce/label/c.Eap_MyInterests_Label';
import BUSINESS_INTERESTS_LABEL from '@salesforce/label/c.Eap_BusinessInterests_Label';
import PERSONAL_INTERESTS_LABEL from '@salesforce/label/c.Eap_PersonalInterests_Label';

export default class EapProfileOverview extends LightningElement {
    labels = {Title: TITLE_LABEL, AboutMe: ABOUT_ME_LABEL, ContactInfo: CONTACT_INFORMATION_LABEL,
            Email:EMAIL_LABEL, Mobile: MOBILE_LABEL, Phone: PHONE_LABEL, TimeZone: TIME_ZONE_LABEL,
            MyInterests: MY_INTERESTS_LABEL, BusinessInterests: BUSINESS_INTERESTS_LABEL, PersonalInterests: PERSONAL_INTERESTS_LABEL};
    decoratorIcon = customIcons +'/profileComma.svg';
    emailIcon = customIcons +'/profileEmail.svg';
    phoneIcon = customIcons +'/profilePhone.svg';
    mobileIcon = customIcons +'/profileMobile.svg';
    editIcon = customIcons + '/appiconedit-add.svg';
    checkIcon = customIcons + '/check.svg';
    closeIcon = customIcons + '/close.svg';

    @track user = {};
    temporalUser = {};
    @track interestData = [];
    @track businessInterestsList = [];
    @track interestsList = [];
    @track timeZonesList = [];
    @track editMode = false;

    @wire(getUserInfo)
    wiredUser({ error, data }) {
        if (data) {
            let userData = data.user;
            let interestsList = data.interests;
            this.user = {
                Id: userData.Id,
                Name: userData.Name,
                Img: userData.FullPhotoUrl,
                Title: userData.Title,
                Subtitle: userData.Department,
                About: userData.AboutMe,
                Email: userData.UserEmail__c,
                Mobile: userData.Phone,
                Phone: userData.MobilePhone,
                TimeZone: userData.TimeZoneSidKey
            };

            for (let i = 0; i < interestsList.length; i++){
                this.interestData.push({
                    Id: i,
                    Name: interestsList[i]
                })
            }

            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);

        }
    }

    get haveInterest(){
        if (this.interestData.length > 0)
            return true;
        else
            return false;
    }

    saveChanges() {
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);

        let selectedInterests = [];
        let selectedBInterests = [];
        this.interestsList.forEach(item => {

            if (item.Selected)
                selectedInterests.push(item.Value);
        })

        this.businessInterestsList.forEach(item => {

            if (item.Selected)
            selectedBInterests.push(item.Value);
        })

        this.temporalUser.Interests = selectedInterests.join(";");
        this.temporalUser.BusinessInterests = selectedBInterests.join(";");

        updateUserInfo({newInformation: JSON.stringify(this.temporalUser)})
        .then(data => {
            this.user = {...this.user, ...this.temporalUser};
            window.location.reload();
            this.editMode = !this.editMode;

        })
        .catch(error => {
            window.location.reload();
            this.editMode = !this.editMode;
        });
    }

    cancelChanges() {
        this.editMode = false;
    }

    fillInformation() {
        this.temporalUser = {...this.user};
        this.editMode = !this.editMode;
        getAllInterests()
        .then(data => {
            let bInterests = data.businessInterests;
            let interests = data.interests;
            let timeZones = data.timeZones;

            for (let i = 0; i < interests.length; i++){
                this.interestsList.push({
                    Id: i,
                    Value: interests[i],
                    Selected: this.isSelected(interests[i])
                });
            }

            for (let i = 0; i < bInterests.length; i++){
                this.businessInterestsList.push({
                    Id: i,
                    Value: bInterests[i],
                    Selected: this.isSelected(bInterests[i])
                });
            }

            for (let i = 0; i < timeZones.length; i++){
                let value = timeZones[i].substring(timeZones[i].lastIndexOf('(')+1, timeZones[i].lastIndexOf(')'));
                this.timeZonesList.push({
                    Id: i,
                    Value: value,
                    Label: timeZones[i],
                    Selected: (value === this.user.TimeZone) ? true : false
                });
            }

            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        })
        .catch(error => {});
    }

    isSelected(value) {
        let found = false;
        let i = 0;
        while (i < this.interestData.length && !found){
            if (this.interestData[i].Name === value){
                found = true;

            }else {
                i++;
            }
        };

        if (!found)
            return false;
        else
            return true;
    }

    handleInputChange(e){
        let field  = e.target.name;
        let value  = e.target.value.trim();
        if (value !== "" || value !== undefined)
        {
            this.temporalUser[field] = value;
        }
    }

    handleBIClick(e){
        let buttonValue = e.target.dataset.name;
        let i = 0;
        let found = false;

        do{
            if (this.businessInterestsList[i].Value !== buttonValue)
                i++;
            else
                found = true;
        }while (i < this.businessInterestsList.length && !found);

        this.businessInterestsList[i].Selected = !this.businessInterestsList[i].Selected
    }

    handleInterestClick(e){
        let buttonValue = e.target.dataset.name;
        let i = 0;
        let found = false;

        do{
            if (this.interestsList[i].Value !== buttonValue)
                i++;
            else
                found = true;
        }while (i < this.interestsList.length && !found);

        this.interestsList[i].Selected = !this.interestsList[i].Selected
    }
}