import { LightningElement, track, api } from 'lwc';
import getAgenda from '@salesforce/apex/EAP_CTRL_MeetingInformationPage.getAgenda';
import NO_AGENDA_LABEL from '@salesforce/label/c.Eap_NoAgenda_Label';

export default class EapMeetingInformationAgenda extends LightningElement {
    labels = {NoAgenda: NO_AGENDA_LABEL};
    @track elements = [];
    @track _meetingId;
    @api 
    get meetingId(){
        return this._meetingId;
    }
    set meetingId(value) {
        this.setAttribute('v', value);
        this._meetingId = value;
        this.loadAgenda();
    }

    loadAgenda(){
        getAgenda({meetingId: this.meetingId})
        .then((data) => {
            if(data) {
                for(let i=0; i<data.length; i++){
                    let dates = this.getDates(data[i].startDate, data[i].endDate);
                    let meeting =  data[i].meeting;

                    this.elements.push({
                        Id: meeting.Id,
                        Title: meeting.Name,
                        Subtitle: dates.Start + " - " + dates.End,
                    });
                }
                    
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            }
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

    get haveElements() {
        if (this.elements.length > 0) {
            return true;
        
        } else {
            return false;
        }
    }

}