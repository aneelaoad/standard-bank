import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fullCalendar from "@salesforce/resourceUrl/EapFullCalendar";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getMeetingsByEvent from '@salesforce/apex/EAP_CTRL_EventSchedulePage.getMeetingsByEvent';
import MEETING_ROUTE_LABEL from '@salesforce/label/c.Eap_MeetingRoute_Label';

const COLORS = ['rgba(232, 164, 180, 0.8)', 'rgba(193, 188, 232, 0.8)', 'rgba(226, 185, 232, 0.8)', 'rgba(157, 225, 178, 0.8)', 'rgba(170, 219, 240, 0.8)', 'rgba(255, 225, 172, 0.8)', 'rgba(254, 196, 164, 0.8)'];
const LIGHT_COLORS = ['rgba(246, 221, 227, 0.8)', 'rgba(224, 222, 243, 0.8)', 'rgba(237, 211, 241, 0.8)', 'rgba(206, 240, 216, 0.8)', 'rgba(223, 242, 249, 0.8)', 'rgba(255, 237, 198, 0.8)', 'rgba(255, 217, 198, 0.8)'];

export default class EapEventScheduleContent extends NavigationMixin(LightningElement) {
    calendar;
    fullCalendarInitialized = false;
    _eventId;
    @track meetings = [];

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
    }

    renderedCallback() {
        if (this.fullCalendarInitialized) {
            return;
        }
        this.fullCalendarInitialized = true;

        Promise.all([
            loadScript(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/core/main.js"),
            loadStyle(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/core/main.css")
        ])
        .then(() => {
            Promise.all([
                loadScript(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/daygrid/main.js"),
                loadStyle(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/daygrid/main.css"),
            ])
            .then(() => {
                Promise.all([
                    loadScript(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/list/main.js"),
                    loadStyle(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/list/main.css"),
                    loadScript(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/timegrid/main.js"),
                    loadStyle(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/timegrid/main.css"),
                    loadScript(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/interaction/main.js"),
                    loadScript(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/moment/main.js"),
                    loadScript(this, fullCalendar + "/FullCalendar/fullcalendar-4.4.3/packages/moment-timezone/main.js"),
                ])
                .then(() => {
                    this.loadMeetings();
                });
            });
        })
        .catch(error => { });
    }

    loadMeetings(){
        getMeetingsByEvent({eventId: this.eventId})
        .then((data) => {
            if (data.length){

                let t = 0;
                for (let i = 0; i < data.length; i++){
                    let meetingInfo = data[i].meeting;
                    let startDate = new Date(data[i].StartDate);
                    let endDate = new Date(data[i].EndDate);
                    let offset = startDate.getTimezoneOffset() / 60;
                    startDate.setHours(startDate.getHours() + offset);
                    endDate.setHours(endDate.getHours() + offset);

                    let meeting = {
                        title: meetingInfo.Name + '\n',
                        start: startDate,
                        end: endDate,
                        color: this.selectColor(t, startDate),
                        textColor: this.selectTextColor(endDate),
                        url:  window.location.origin +MEETING_ROUTE_LABEL+meetingInfo.Id
                    };

                    if (meetingInfo.EAP_Format__c === 'Online'){
                        meeting.title += 'Online';
                    
                    }else if (meetingInfo.EAP_Room__c){
                        meeting.title += meetingInfo.EAP_Room__c;
                    
                    }else if (meetingInfo.EAP_Location__c){
                        meeting.title += meetingInfo.EAP_Location__c;
                    }

                    this.meetings.push(meeting);

                    t++;
                    if (t >= COLORS.length) {
                        t = 0;
                    
                    }
                }
            }

            this.init();

        })
        .catch((error) => {})
    }

    init() {
        let calendarEl = this.template.querySelector(".calendar");
        this.calendar = new FullCalendar.Calendar(calendarEl, {
            plugins: ["timeGrid"],
            header: {center: 'title', left: 'prev,next', right: 'today'},
            defaultView: "timeGridDay",
            nowIndicator: true,
            height: "parent",
            allDaySlot: false,
            columnHeader: false,
            displayEventTime: false,
            minTime: '06:00:00',
            eventSources: [
                {
                events: this.meetings,
                id: "custom"
                }
            ]
        });
        this.calendar.render();

        const loadedEvent = new CustomEvent('loaded', {});
        this.dispatchEvent(loadedEvent);
    }

    selectColor(i, start){
        let now = new Date();
        let startDate = new Date(start);

        if (startDate > now)
            return COLORS[i];
        else
            return LIGHT_COLORS[i];
    }

    selectTextColor(start){
        let now = new Date();
        let startDate = new Date(start);

        if (startDate > now)
            return 'black';
        else
            return '#858D9D';
    }
}