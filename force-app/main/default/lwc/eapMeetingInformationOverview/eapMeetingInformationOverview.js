import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getMeetingOverview from '@salesforce/apex/EAP_CTRL_MeetingInformationPage.getMeetingOverview';
import getAttendance from '@salesforce/apex/EAP_CTRL_MeetingInformationPage.getAttendance';

import MEETING_LINK_LABEL from '@salesforce/label/c.Eap_MeetingLink_Label';
import REQUEST_CHANGE_LABEL from '@salesforce/label/c.Eap_RequestMeetingChange_Label';
import ATTENDING_MEETING_LABEL from '@salesforce/label/c.Eap_AttendingMeeting_Label';
import SEARCH_LABEL from '@salesforce/label/c.Eap_Search_Label';
import ENTER_SEARCH_LABEL from '@salesforce/label/c.Eap_EnterSearch_Label';

export default class EapMeetingInformationOverview extends NavigationMixin(LightningElement) {
    labels = {MeetingLink: MEETING_LINK_LABEL, RequestChange: REQUEST_CHANGE_LABEL, Attending: ATTENDING_MEETING_LABEL,
            Search: SEARCH_LABEL, EnterSearch: ENTER_SEARCH_LABEL};
    iconClock = customIcons + '/clock.svg';
    iconLocation = customIcons + '/location.svg';
    iconWeb = customIcons + '/iconGlobe.svg';

    @track _meetingId;
    @api 
    get meetingId(){
        return this._meetingId;
    }
    set meetingId(value) {
        this.setAttribute('v', value);
        this._meetingId = value;
        this.loadMeeting();
    }

    @track meeting = {};
    @api meetingName;
    @track defaultAttendees = [];
    @track attendees = this.defaultAttendees;
    lookingfor = "";

    loadMeeting(){
        getMeetingOverview({meetingId: this.meetingId})
        .then((data) => {
            let meeting = data.meeting;
            let dates = this.getDates(data.startDate, data.endDate);
            if(data) {
                this.meeting = {
                    Id: meeting.Id,
                    Name: meeting.Name,
                    Overview: meeting.EAP_Description__c,
                    StartTime: dates.Start,
                    EndTime: dates.End,
                    Entrance: meeting.EAP_Room__c,
                    Location: meeting.EAP_Location__c,
                    Link: meeting.EAP_MeetingLink__c
                };

                if (meeting.EAP_Format__c === 'Onsite'){
                    this.meeting.Onsite = true;
                }else{
                    this.meeting.Onsite = false;
                }

                this.meetingName = this.meeting.Name;
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
                    Name: attendee.name,
                    RolInEvent: attendee.roleInEvent,
                    ClientName: attendee.clientName
                };

                if (attendeeToInsert.Img === null){
                    attendeeToInsert.Initials = this.getInitials(attendeeToInsert.Name);
                }
                this.defaultAttendees.push(attendeeToInsert);
            }

            const selectedEvent = new CustomEvent('eventnamechange', {});
            this.dispatchEvent(selectedEvent);

            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        })
        .catch((error) => {
            console.error(error);
        });

    }

    getDates(start, end = ""){
        let dates = {};
        let startDate = new Date(start);
        let endDate = new Date(end);
        let offset = startDate.getTimezoneOffset() / 60;
        startDate.setHours(startDate.getHours() + offset);
        endDate.setHours(endDate.getHours() + offset);

        let startMinutes = startDate.getMinutes();
        if (startMinutes.toString().length === 1){
            startMinutes = "0" + startMinutes;
        }

        let endMinutes = endDate.getMinutes();
        if (endMinutes.toString().length === 1){
            endMinutes = "0" + endMinutes;
        }

        dates = {End: endDate.getHours() + ":" + endMinutes,
                Start: startDate.getHours() + ":" + startMinutes};

        return dates;
    }

    getInitials(fullName){
        let fullNameArray = fullName.split(" ");
        let initials = '';

        fullNameArray.forEach(name => {
            initials += name[0];
        })

        return initials;
    }

    findAttendee(e) {
        this.lookingfor = this.template.querySelector("[name='searchAttendee']").value;
        let orderedAttendees = [...this.defaultAttendees];
        orderedAttendees = orderedAttendees.filter(attendee => attendee.Name.toLowerCase().includes(this.lookingfor.toLowerCase()));
        this.attendees = orderedAttendees;
    }

    requestChange(){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Change_Request__c'
            },
            state: {
                meetingId: this.meetingId
            }
        });
    }

    openTodayEventLink(){
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: (this.meeting.Link).includes('http')?this.meeting.Link:('https://'+this.meeting.Link)
            }
        });
    }
}