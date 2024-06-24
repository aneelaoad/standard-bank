import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMeetingOverview from '@salesforce/apex/EAP_CTRL_ChangeRequestPage.getMeeting';
import getAttendance from '@salesforce/apex/EAP_CTRL_ChangeRequestPage.getAttendance';
import saveRequest from '@salesforce/apex/EAP_CTRL_ChangeRequestPage.saveRequest';
import SUBMIT_LABEL from '@salesforce/label/c.Eap_Submit_Label';
import CHANGE_MESSAGE_LABEL from '@salesforce/label/c.Eap_ChangeMessage_Label';
import NO_REQUEST_LABEL from '@salesforce/label/c.Eap_NoRequest_Label';
import SUBJECT_LABEL from '@salesforce/label/c.Eap_Subject_Label';
import REASON_LABEL from '@salesforce/label/c.Eap_Reason_Label';
import TYPE_REASON_LABEL from '@salesforce/label/c.Eap_TypeReason_Label';
import TYPE_SUBJECT_LABEL from '@salesforce/label/c.Eap_TypeSubject_Label';
import PROPOSED_TIME_LABEL from '@salesforce/label/c.Eap_ProposedTime_Label';

const NUMBER_CONTACTS_TO_SHOW = 6;

export default class EapChangeRequestContent extends NavigationMixin(LightningElement) {
    labels = {Submit: SUBMIT_LABEL, Message: CHANGE_MESSAGE_LABEL, NoRequest: NO_REQUEST_LABEL, Subject: SUBJECT_LABEL,
            TypeSubject: TYPE_SUBJECT_LABEL, Reason: REASON_LABEL, TypeReason: TYPE_REASON_LABEL, ProposedTime: PROPOSED_TIME_LABEL}
    changeMessage = this.labels.Message;
    buttonText = this.labels.Submit;

    haveAdded = false;
    request = {};
    @track hasError = {};
    @track meeting = {};

    _meetingId;
    @api 
    get meetingId(){
        return this._meetingId;
    }
    set meetingId(value) {
        this.setAttribute('v', value);
        this._meetingId = value;
        this.loadMeeting();
    }

    loadMeeting(){
        getMeetingOverview({meetingId: this.meetingId})
        .then((data) => {
            let meeting = data.meeting;
            let dates = this.getDates(data.StartDate, data.EndDate);
            if(meeting) {
                this.meeting = {
                    Id: meeting.Id,
                    Name: meeting.Name,
                    Location: meeting.EAP_Room__c,
                    Date: dates.Date,
                    Time: dates.Start + " - " + dates.End,
                    Contacts: []
                };

                this.loadAttendance();
            }
        })
        .catch((error) => {});
    }

    loadAttendance(){
        getAttendance({meetingId: this.meetingId})
        .then((data) => {
            for(let i = 0; i < data.length; i++){
                let attendee = data[i];
                let attendeeToInsert = {
                    Id: attendee.id,
                    Img: attendee.contactPhoto,
                    style: "img" + (i+1)
                };

                this.meeting.Contacts.push(attendeeToInsert);
            }
            
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);

        this.template.querySelector('.siteforceSpinnerManager.siteforcePanelsContainer').classList.add('hideEl');

        })
        .catch((error) => {});

    }

    getDates(start, end = ""){
        let dates = {};
        let startDate = new Date(start);
        let endDate = new Date(end);
        let offset = startDate.getTimezoneOffset() / 60;
        startDate.setHours(startDate.getHours() + offset);
        endDate.setHours(endDate.getHours() + offset);

        let startDay = startDate.getDate();
        let startMonth = new Intl.DateTimeFormat('en', { month: 'short' }).format(startDate);
        let startYear = startDate.getFullYear();

        let startMinutes = startDate.getMinutes();
        if (startMinutes.toString().length === 1){
            startMinutes = "0" + startMinutes;
        }

        let endMinutes = endDate.getMinutes();
        if (endMinutes.toString().length === 1){
            endMinutes = "0" + endMinutes;
        }

        dates = {End: endDate.getHours() + ":" + endMinutes,
                Start: startDate.getHours() + ":" + startMinutes,
                Date: startDay + " " + startMonth + " " + startYear};

        return dates;
    }

    submitRequest() {
        if (this.passValidation(["Subject", "Reason", "DateRequest", "TimeRequest"]) && !this.haveAdded){
            this.haveAdded = true;
            const reloadEvent = new CustomEvent('reload', {});
            this.dispatchEvent(reloadEvent);

            saveRequest({meetingId: this.meetingId, request: JSON.stringify(this.request)})
            .then(data => {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: 'Confirmation__c'
                    },state: {
                        message: this.changeMessage,
                        destination: "Home",
                        type: 'Info'
                    }
                });
            })
            .catch(error => {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: 'Confirmation__c'
                    },state: {
                        message: this.labels.NoRequest,
                        destination: "Home",
                        type: 'Error'
                    }
                });
            })
        }
    }

    //Validate Formulary
    handleInputChange(e){
        let field = e.target.name;
        field = field.charAt(0).toUpperCase() + field.slice(1);
        let value = e.target.value;
        this.request[field] = value.trim();
        
        if (value.trim() === "")
        {
            this.hasError[field] = true;

        }else if (this.hasError[field])
        {
            this.hasError[field] = false;
        }
    }

    passValidation(expectedFields) {
        let valid = true;

        expectedFields.forEach(field => {
            if (this.request[field] === undefined || this.request[field] === ""){
                valid = false;
                this.hasError[field] = true;
            }else {
                this.hasError[field] = false;
            }
        });

        return valid;
    }

    //Show Contacts
    get contactsToShow() {
        let list = [];
        let max = NUMBER_CONTACTS_TO_SHOW;
        if (NUMBER_CONTACTS_TO_SHOW > this.meeting.Contacts.length){
            max = this.meeting.Contacts.length;
        }

        for(let i = 0; i < max; i++){
            list[i] = this.meeting.Contacts[i];
        }

        return list;
    }

    
    get restContacts() {
        let rest = this.meeting.Contacts.length - NUMBER_CONTACTS_TO_SHOW;

        if (rest <= 0){
            rest = false;
        }
        return rest;
    }

    get haveContacts() {
        if (this.meeting.Contacts.length > 0)
            return true;
        else
            return false;
    }
}