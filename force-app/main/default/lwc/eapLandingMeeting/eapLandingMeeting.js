import { LightningElement, track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getNextMeeting from '@salesforce/apex/EAP_CTRL_LandingPage.getNextMeeting';
import getUserAttendanceInfo from '@salesforce/apex/EAP_CTRL_LandingPage.getUserAttendanceInfo';
import MEETING_LINK_LABEL from '@salesforce/label/c.Eap_MeetingLink_Label';
import OPEN_MEETING_LABEL from '@salesforce/label/c.Eap_OpenMeeting_Label';
import NO_MEETINGS_LABEL from '@salesforce/label/c.Eap_NoUpcomingMeetings_Label';

const NUMBER_CONTACTS_TO_SHOW = 6;

export default class EapLandingMeeting extends NavigationMixin(LightningElement) {
    labels = {MeetingLink: MEETING_LINK_LABEL, OpenMeeting: OPEN_MEETING_LABEL, NoMeetings: NO_MEETINGS_LABEL};
    iconLocation = customIcons + '/icn_position.svg';
    iconGlobe = customIcons + '/iconGlobe.svg';
    iconShield = customIcons + '/shield.svg';
    bgLight = customIcons + '/rectangle_light.svg';
    bgDark = customIcons + '/rectangle_dark.svg';
    rendered = false;
    toRender = false;

    @track noMettings = false;
    @track todayEvent = {
        Id: 0,
        Subject: '',
        Location: '',
        StartTime: '',
        EndTime: '',
        Date: '',
        MonthYear: '',
        print: false
    }
    @track meetingAttendances = [];
    
    @wire(getNextMeeting)
    wiredUser({ error, data }) {
        if(data) {
            
            this.todayEvent = {
                Id: data.Id,
                EventName: data.EAP_AppEvent__r.Name,
                Subject: data.Name,
                isOnline:(data.EAP_Format__c === 'Online')?true:false,
                Location: (data.EAP_Location__c !== null && data.EAP_Location__c !== undefined)?data.EAP_Location__c:'',
                StartTime: this.formatAMPM(new Date(data.EAP_StartDate__c)),
                EndTime: this.formatAMPM(new Date(data.EAP_EndDate__c)),
                Date: new Date(data.EAP_StartDate__c).getDate(),
                MonthYear: this.getMonthYearDate(new Date(data.EAP_StartDate__c)),
                link: data.EAP_MeetingLink__c,
                print: true
            }
            
            let attendance = data.EAP_Attendance_Meeting__r;
            if (attendance){
                this.getAttendanceList();
            }
            else {
                this.toRender = true;
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            }
            
        }else if(error){
            this.noMettings=true;
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        
        }else {
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        }

    }

    getAttendanceList(){
        getUserAttendanceInfo({ meetingId: this.todayEvent.Id })
            .then(result => {
                let mapContactIdUser = result;
                for(let i=0; i<result.length; i++){
                    let userInfo = mapContactIdUser[i];
                    let imgAtt = (userInfo ? userInfo.SmallPhotoUrl : customIcons + '/profile.jpg') ;

                    let meetAttendance = {
                        Id: i+1,
                        Img: imgAtt,
                        style: 'img'+(i+1)
                    }

                    this.meetingAttendances.push(meetAttendance);
                }

                this.adaptHeight();
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            });
    }

    renderedCallback() {
        if (!this.rendered && this.toRender) {
            this.rendered = true;
            this.adaptHeight();
        }
    }

    getMonthYearDate(starDate) {
        let month = new Intl.DateTimeFormat('en', { month: 'short' }).format(starDate);
        let year = starDate.getFullYear();
        let strTime = month + ' ' + year;
        
        return strTime;
    }

    formatAMPM(date) {
        let hours = date.getHours();
        let minutes = date.getMinutes();
        let ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12; 
        minutes = minutes < 10 ? '0'+minutes : minutes;
        let strTime = hours + ':' + minutes + ' ' + ampm;
        return strTime;
    }

    get contactsToShow() {
        let list = [];
        let max = NUMBER_CONTACTS_TO_SHOW;
        if (NUMBER_CONTACTS_TO_SHOW > this.meetingAttendances.length){
            max = this.meetingAttendances.length;
        }

        for(let i = 0; i < max; i++){
            list[i] = this.meetingAttendances[i];
        }

        return list;
    }

    
    get restContacts() {
        let rest = this.meetingAttendances.length - NUMBER_CONTACTS_TO_SHOW;

        if (rest <= 0){
            rest = false;
        }
        return rest;
    }

    get haveContactsToShow(){
        if (this.contactsToShow.length > 0)
            return true;
        else
            return false;
    }

    get haveOneInformation(){
        if (!this.haveAllInformation && (this.haveContactsToShow || this.todayEvent.link))
            return true;
        else
            return false;
    }

    get haveAllInformation(){
        if (this.haveContactsToShow && this.todayEvent.link)
            return true;
        else
            return false;
    }

    showTodayEvent(){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Meeting_Information__c'
            },
            state: {
                meetingId: this.todayEvent.Id
            }
        });
    }

    openTodayEventLink(){
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: (this.todayEvent.link).includes('http')?this.todayEvent.link:('https://'+this.todayEvent.link)
            }
        });
    }

    get backgroundStyle() {
        return 'background-image: url('+ this.bgLight +');';
    }

    get backgroundStyleDark() {
        return 'background-image: url('+ this.bgDark +');';
    }

    adaptHeight() {
        let meeting = this.template.querySelector('[class="v1_div_landingCard"]');
        let meetingHeight = meeting.offsetHeight;
        let meetingTop = meeting.offsetTop;
        let filler = this.template.querySelector('[class="rellenoBody"]');
        filler.style.height = (meetingHeight - meetingTop) + "px";
    }
}