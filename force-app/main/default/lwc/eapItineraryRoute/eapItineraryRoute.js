import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getItinerary from '@salesforce/apex/EAP_CTRL_ItineraryPage.getItinerary';
import EVENT_ITINERARY_LABEL from '@salesforce/label/c.Eap_EventItinerary_Label';
import ADD_MORE_LABEL from '@salesforce/label/c.Eap_AddMore_Label';
import ADD_ITINERARY_LABEL from '@salesforce/label/c.Eap_AddItinerary_Label';
import NO_ITINERARY_ADDED_LABEL from '@salesforce/label/c.Eap_NoItineraryAdded_Label';
import START_LABEL from '@salesforce/label/c.Eap_Start_Label';
import FLIGHT_TO_LABEL from '@salesforce/label/c.Eap_FlightTo_Label';
import END_LABEL from '@salesforce/label/c.Eap_End_Label';
import DAYS_LABEL from '@salesforce/label/c.Eap_Days_Label';
import HOURS_LABEL from '@salesforce/label/c.Eap_Hours_Label';
import MINUTES_LABEL from '@salesforce/label/c.Eap_Minutes_Label';
import TO_LABEL from '@salesforce/label/c.Eap_To_Label';
import MAP_LINK_BASE_LABEL from '@salesforce/label/c.Eap_MapLinkBase_Label';

export default class EapItineraryRoute extends NavigationMixin(LightningElement) {
    labels = {EventItinerary: EVENT_ITINERARY_LABEL, AddMore: ADD_MORE_LABEL, AddItinerary: ADD_ITINERARY_LABEL, NoItineraryAdded: NO_ITINERARY_ADDED_LABEL,
            Start: START_LABEL, FLightTo: FLIGHT_TO_LABEL, End: END_LABEL, Days: DAYS_LABEL, Hours: HOURS_LABEL, Minutes:MINUTES_LABEL, To: TO_LABEL, MapLinkBase: MAP_LINK_BASE_LABEL};
    @track mapLink = this.labels.MapLinkBase;

    blueShield = customIcons + '/blueShield.svg';
    arrow = customIcons + '/arrowRight.svg';
    takingOffAirplane = customIcons + '/takingOffAirplane.svg';
    iconCar = customIcons + '/icn_car.svg';
    iconBus = customIcons + '/icn_bus.svg';
    iconDocument = customIcons + '/icn_document.svg';
    iconLocation = customIcons + '/location.svg';
    mapa = customIcons + '/mapaTest.svg';


    @track isFlight = false;

    @track mapMarkers = [];
    mapOptions = { disableDefaultUI: true };
    @track itinerary = [];
    _eventId;
    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
        this.loadTravel();
    }

    loadTravel(){
        getItinerary({eventId: this.eventId})
        .then(data => {
            let waypoints = '';
            if (data.length > 0)
            {
                let t = 0;
                let start = {
                                Id: t,
                                Title: this.labels.Start + " " + data[0].EAP_Origin__c,
                                IconStart: this.iconDocument,
                            };
                if (data[0].EAP_FlightDepartureTime__c !== null) {
                    start.Subtitle = this.getHour(data[0].EAP_FlightDepartureTime__c);
                
                }else{
                    start.Subtitle = this.getHour(data[0].EAP_StartDate__c);
    
                }
                this.itinerary.push(start);
                this.mapMarkers.push({ location: { Street: data[0].EAP_OriginAddress__c, City: data[0].EAP_OriginCity__c }, title: start.EAP_OriginAddress__c});
                this.mapLink = this.mapLink + '&origin=' + data[0].EAP_OriginAddress__c + ',' + data[0].EAP_OriginCity__c;
                t++;
    
                for (let i = 0; i < data.length; i++){
                    let travel = { Id: t, IconEnd: this.arrow };
                    if (data[i].EAP_FlightDepartureTime__c !== null)
                    {
                        this.isFlight = true;
                        travel.IconStart = this.takingOffAirplane;
                        travel.Title = this.labels.FLightTo + ' ' + data[i].EAP_Destination__c;
                        travel.Subtitle = this.getTime(data[i].EAP_FlightDepartureTime__c, data[i].EAP_FlightArrivalTime__c);
                        travel.realId = data[i].Id;
                    
                    }else {
                        this.isFlight = false;
                        travel.Title = data[i].EAP_ServiceName__c + ' ' + this.labels.To + ' ' + data[i].EAP_Destination__c;
                        travel.Subtitle = this.getTime(data[i].EAP_StartDate__c, data[i].EAP_EndDate__c);
                        travel.realId = data[i].Id;
    
                        if (data[i].EAP_ServiceName__c === 'Bus'){
                            travel.IconStart = this.iconBus;
                        }else{
                            travel.IconStart = this.iconCar;
                        }
                    }
    
                    this.itinerary.push(travel);
                    this.mapMarkers.push({ location: { Street: data[i].EAP_Address__c, City: data[i].EAP_City__c, Country: data[i].EAP_Country__c }, title: travel.EAP_Address__c});

                    if (i < data.length - 2){
                        waypoints = waypoints + data[i].EAP_OriginAddress__c + ',' + data[i].EAP_OriginCity__c + '|';
                    } else if (i < data.length - 1){
                        waypoints = waypoints + data[i].EAP_OriginAddress__c + ',' + data[i].EAP_OriginCity__c;
                    }
                    t++;
                }
    
                let end = {
                    Id: t,
                    Title: this.labels.End + " " + data[data.length-1].EAP_Destination__c,
                    IconStart: this.iconLocation
                }
                this.itinerary.push(end);
                this.mapLink = this.mapLink + '&destination=' + data[data.length-1].EAP_Address__c + ',' + data[data.length-1].EAP_City__c;
                
                if (data.length > 2) {
                    this.mapLink = this.mapLink + '&waypoints=' + waypoints;
                
                } else if (data[0].EAP_FlightDepartureTime__c) {
                    this.mapLink = this.mapLink + '&mode=flying';
                
                }

            }
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);

        })
        .catch(error => {
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        })
    }

    getTime(start, end){
        let startTime = new Date(start);
        let endTime = new Date(end);

        let duration = (endTime - startTime) / (1000 * 60);
        if (duration >= 60)
        {
            duration = duration / 60;
            if (duration >= 24)
            {
                duration = duration / 24;
                duration = parseInt(duration) + " " + this.labels.Days;
            
            }else{
                duration = parseInt(duration) + " " + this.labels.Hours;
            }
        
        }else{
            duration = parseInt(duration) + " " + this.labels.Minutes;
        }

        return duration;
    }

    getHour(start){
        let time;
        let startDate = new Date(start);
        let startMinutes = startDate.getMinutes();
        if (startMinutes.toString().length === 1){
            startMinutes = "0" + startMinutes;
        }
        time = startDate.getHours() + ":" + startMinutes;
        return time;
    }

    get haveItinerary() {
        if (this.itinerary.length > 0){
            return true;
        
        }else{
            return false;
        }
    }

    openItineraryStep(e){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);

        let detailId = e.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Itinerary_Detail__c'
            },
            state:{
                travelId: detailId,
                eventId: this.eventId,
                prevPage: 'Itinerary__c'
            }
        });
    }

    addItinerary(){

        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);
        
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Add_Itinerary__c'
            },
            state:{
                prevPage: 'Itinerary__c',
                eventId: this.eventId
            }
        });
    }

    testLoad() {
        this.template.querySelector('.siteforceSpinnerManager.siteforcePanelsContainer').classList.add('hideEl');
    }

}