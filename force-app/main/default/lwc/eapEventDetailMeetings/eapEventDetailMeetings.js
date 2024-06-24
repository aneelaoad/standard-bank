import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getMeetingsByEvent from '@salesforce/apex/EAP_CTRL_EventDetailPage.getMeetingsByEvent';
import getRolInEvent from '@salesforce/apex/EAP_CTRL_EventDetailPage.getRolInEvent';
import getAgendaPublicLink from '@salesforce/apex/EAP_CTRL_EventDetailPage.getAgendaPublicLink';
import EVENT_SCHEDULE_LABEL from '@salesforce/label/c.Eap_MyEventSchedule_Label';
import MEETINGS_LABEL from '@salesforce/label/c.Eap_Meetings_Label';
import OTHER_LABEL from '@salesforce/label/c.Eap_AndOther_Label';
import VIEW_SCHEDULE_LABEL from '@salesforce/label/c.Eap_ViewSchedule_Label';
import MEETING_AVAILABILITY_LABEL from '@salesforce/label/c.Eap_MeetingAvailability_Label';
import DOWNLOAD_AGENDA_LABEL from '@salesforce/label/c.Eap_DownloadAgenda_Label';


export default class EapEventDetailMeetings extends NavigationMixin(LightningElement) {
    labels = {EventSchedule: EVENT_SCHEDULE_LABEL, ViewSchedule: VIEW_SCHEDULE_LABEL, MeetingAvailability: MEETING_AVAILABILITY_LABEL,
            AndOther: OTHER_LABEL, Meetings: MEETINGS_LABEL, DownloadAgenda: DOWNLOAD_AGENDA_LABEL};
    iconShield = customIcons + '/shield.svg';
    bgLight = customIcons + '/rectangle_light.svg';
    bgDark = customIcons + '/rectangle_dark.svg';
    @track hasForm = false;

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
        this.loadMeetings();
    }

    @track meetings;
    @track _eventId;

    loadMeetings(){
        getMeetingsByEvent({eventId: this.eventId})
        .then((data) => {
            if (data.length){
                let meeting = data[0];
                let dates = this.getDates(meeting.EAP_StartDate__c);
                
                this.meetings =  {
                        Title: meeting.Name,
                        Day: dates.Day,
                        MonthYear: dates.MonthYear,
                        NumMeetings:data.length - 1
                    }
            }

            getRolInEvent({eventId: this.eventId})
            .then((data) => {
                if ((data === 'Corporate') || (data === 'Investor')){
                    this.hasForm = true;
                }
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            })
            .catch((error) => {})
        })
        .catch((error) => {})
    }

    getDates(start){
        let dates = {};
        let startDate = new Date(start);
        let startMonth = new Intl.DateTimeFormat('en', { month: 'short' }).format(startDate);

        dates.Day = startDate.getDate();
        dates.MonthYear = startMonth + " " + startDate.getFullYear();

        return dates;
    }

    showEventSchedule(){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Event_Schedule__c'
            },
            state: {
                eventId:  this._eventId
            }
        });
    }

    get backgroundStyle() {
        return 'background-image: url('+ this.bgLight +');';
    }

    get backgroundStyleDark() {
        return 'background-image: url('+ this.bgDark +');';
    }

    get hasMeetingsAndForm() {
        if (this.meetings && this.hasForm){
            return true;
        
        } else {
            return false;
        }
    }

    openForm(){
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Availability_Detail__c'
            },
            state: {
                eventId:  this._eventId
            }
        });
    }

    async getAgendaUrl() {
        try {
            const url = await getAgendaPublicLink({eventId: this.eventId});
            this.redirectToAgendaPdf(url);
        } catch(err) { }
    }

    redirectToAgendaPdf(url) {
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        };
        this[NavigationMixin.Navigate](config);
    }
}