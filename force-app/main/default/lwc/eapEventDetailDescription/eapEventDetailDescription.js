import { LightningElement, track, api } from 'lwc';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getEventById from '@salesforce/apex/EAP_CTRL_EventDetailPage.getEventById';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';
import WEBSITE_LABEL from '@salesforce/label/c.Eap_Website_Label';
import LOCATION_LABEL from '@salesforce/label/c.Eap_Location_Label';
import getVenueInfo from '@salesforce/apex/EAP_CTRL_VenuePage.getVenueInfo';

const DEFAULT_IMG = '/StandardBankLogo.png';

export default class EapEventDetailDescription extends LightningElement {
    labels = {Website: WEBSITE_LABEL, Location: LOCATION_LABEL};
    iconGlobe = customIcons + '/iconGlobe.svg';
    iconLocation = customIcons + '/location.svg';

    @track todayEvent = {};
    @track _eventId;
    location;

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
        this.loadEvent();
    }

    async getVenueLocation(eventId) {
        try {
            const venue = await getVenueInfo({eventId: eventId});
            return venue
        } catch(err) {}
    }

    loadEvent(){
        getEventById({eventId: this.eventId})
        .then(async (data) => {
            let receivedEvent = data.event;
            let eventImg = data.mainPhoto;
            let dates = this.getDates(receivedEvent.EAP_StartDate__c, receivedEvent.EAP_EndDate__c);

            let imagesParam = [];
            if(receivedEvent !== undefined){
                imagesParam.push(
                    {
                        objId: receivedEvent.Id,
                        docId: eventImg
                    }
                )
            }
            const venue = await this.getVenueLocation(this.eventId);
        
            getDocImages({docImageList: JSON.stringify(imagesParam)})
            .then((data) => {
                if(data) {
                    let mapEvDoc = data;
                    let docPhoto = mapEvDoc[receivedEvent.Id];
                    this.todayEvent = {
                        Id: receivedEvent.Id,
                        Subject: receivedEvent.Name,
                        Img: (docPhoto !== undefined) ? docPhoto:customIcons + DEFAULT_IMG,
                        Location: receivedEvent.EAP_Location__c,
                        StartTime: dates.Start,
                        EndTime: dates.End,
                        Information: receivedEvent.EAP_Description__c,
                        Online: receivedEvent.EAP_Format__c,
                        Venue: (venue !== null ? venue.venue.Name : '')
                    }; 
                    
                }
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            })
            .catch((error) => {});

            if(imagesParam.length === 0){
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

    renderedCallback(){
        this.adaptFiller();      
    }

    adaptFiller(){
        let filler = this.template.querySelector('div[class="relleno"]');
        let background = this.template.querySelector('div[class="v1_div_background"]');
        let card = this.template.querySelector('div[class="v1_div_firstCard"]');
        let backgroundHeight = background.offsetHeight;
        let cardHeight = card.offsetHeight;

        let fillerNewHeight = cardHeight - backgroundHeight + 20;
    }

}