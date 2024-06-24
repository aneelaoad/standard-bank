import { LightningElement, api, track } from 'lwc';
import getEventById from '@salesforce/apex/EAP_CTRL_ArchiveDetailPage.getEventById';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';

const DEFAULT_IMG = customIcons+'/StandardBankLogo.png';

export default class EapArchiveDetailOverview extends LightningElement {
    
    @api eventName;
    @track event = {}; //Name; Location; Date; Description;
    @track _eventId;

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
        this.loadEvent();
    }

    loadEvent(){
        getEventById({eventId: this.eventId})
        .then((data) => {
            let eventData = data.event;
            let dates = this.getDates(eventData.EAP_StartDate__c, eventData.EAP_EndDate__c);
            this.event = {
                Id: eventData.Id,
                Name: eventData.Name,
                Location: eventData.EAP_Location__c,
                Date: dates.Start + ' - ' + dates.End,
                Description: eventData.EAP_Description__c
            };
            this.eventName = this.event.Name;
            const selectedEvent = new CustomEvent('eventnamechange', {});
            this.dispatchEvent(selectedEvent);

            if (data.docId){
                let imagesParam = [];
                imagesParam.push(
                    {
                        objId: eventData.Id,
                        docId: data.docId
                    }
                )

                getDocImages({docImageList: JSON.stringify(imagesParam)})
                .then((data) => {
                    if(data) {
                        let docPhoto = data[this.event.Id];
                        this.event.Img = (docPhoto !== undefined) ? docPhoto : DEFAULT_IMG;
                    }

                    const loadedEvent = new CustomEvent('loaded', {});
                    this.dispatchEvent(loadedEvent);           
                })
                .catch((error) => {});
            
            }else{
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            }
        })
        .catch((error) => {});
    }

    getDates(start, end = ""){
        let dates = {};
        let startDate = new Date(start);
        let startMonth = new Intl.DateTimeFormat('en', { month: 'short' }).format(startDate);
        let endDate = new Date(end);
        let endMonth = new Intl.DateTimeFormat('en', { month: 'short' }).format(endDate);
        dates = {End: endDate.getDate() + " " + endMonth + " " + endDate.getFullYear()};

        if (startMonth !== endMonth)
        {
            if (startDate.getFullYear() !== endDate.getFullYear())
                dates.Start = startDate.getDate() + " " + startMonth + " " + startDate.getFullYear();
            else
                dates.Start = startDate.getDate() + " " + startMonth;
        }else
        {
            dates.Start = startDate.getDate();
        }
        return dates;
    }
}