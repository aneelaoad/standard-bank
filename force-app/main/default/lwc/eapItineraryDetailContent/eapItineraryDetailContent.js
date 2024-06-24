import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getTravel from '@salesforce/apex/EAP_CTRL_ItineraryPage.getTravel';
import getBoardingPass from '@salesforce/apex/EAP_CTRL_ItineraryPage.getBoardingPass';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';
import FLIGHT_LABEL from '@salesforce/label/c.Eap_Flight_Label';
import SEAT_LABEL from '@salesforce/label/c.Eap_SeatNumber_Label';
import SHORT_SUNDAY_LABEL from '@salesforce/label/c.Eap_SeatNumber_Label';
import SHORT_MONDAY_LABEL from '@salesforce/label/c.Eap_SeatNumber_Label';
import SHORT_TUESDAY_LABEL from '@salesforce/label/c.Eap_SeatNumber_Label';
import SHORT_WEDNESDAY_LABEL from '@salesforce/label/c.Eap_SeatNumber_Label';
import SHORT_THURSDAY_LABEL from '@salesforce/label/c.Eap_SeatNumber_Label';
import SHORT_FRIDAY_LABEL from '@salesforce/label/c.Eap_SeatNumber_Label';
import SHORT_SATURDAY_LABEL from '@salesforce/label/c.Eap_SeatNumber_Label';
import YOU_ARE_CHECK_IN_LABEL from '@salesforce/label/c.Eap_YouAreCheckIn_Label';
import FLIGHT_DETAILS_LABEL from '@salesforce/label/c.Eap_FlightDetails_Label';
import SHUTTLE_LABEL from '@salesforce/label/c.Eap_Shuttle_Label';
import MAP_LINK_BASE_LABEL from '@salesforce/label/c.Eap_MapLinkBase_Label';

export default class EapItineraryDetailContent extends NavigationMixin(LightningElement) {
    labels = {Flight: FLIGHT_LABEL, Seat: SEAT_LABEL, ShortSunday: SHORT_SUNDAY_LABEL, ShortMonday: SHORT_MONDAY_LABEL,
            ShortTuesday: SHORT_TUESDAY_LABEL, ShortWednesday: SHORT_WEDNESDAY_LABEL, ShortThursday: SHORT_THURSDAY_LABEL,
            ShortFriday: SHORT_FRIDAY_LABEL, ShortSaturday: SHORT_SATURDAY_LABEL, YouAreCheck:YOU_ARE_CHECK_IN_LABEL,
            FlightDetails: FLIGHT_DETAILS_LABEL, Shuttle: SHUTTLE_LABEL, MapLinkBase: MAP_LINK_BASE_LABEL};
    @track mapLink = this.labels.MapLinkBase;

    iconPDF = customIcons + '/pdf.svg';
    iconCar = customIcons + '/car.svg';
    arrow = customIcons + '/arrowRight.svg';
    takingOffAirplane = customIcons + '/icn_planeup.svg';
    delayingAirplane = customIcons + '/icn_planedown.svg';
    mapa = customIcons + '/mapaTest.svg';
    
    @track mapLoaded = false;
    @track mapMarkers = [];
    mapOptions = { disableDefaultUI: true };
    @track boarding;
    @track flight = {};
    @track shuttle = {};
    @track isFlight = true;
    @api travelName = "";
    _travelId;
    @api 
    get travelId(){
        return this._travelId;
    }
    set travelId(value) {
        this.setAttribute('v', value);
        this._travelId = value;
        this.loadTravel();
    }

    _eventId;
    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
    }

    loadTravel() {
        getTravel({travelId: this.travelId})
        .then(data => {

            this.mapLink = this.mapLink + '&origin=' + data.EAP_OriginAddress__c + ',' + data.EAP_OriginCity__c + '&destination=' + data.EAP_Address__c + ',' + data.EAP_City__c;

            if (data.EAP_FlightDepartureTime__c){
                this.isFlight = true;
                this.flight = {
                    Flight: this.labels.Flight+' #' + data.EAP_FlightNumber__c,
                    Company: data.EAP_AirlaneName__c,
                    DepartmentAirport: data.EAP_Origin__c,
                    DepartmentTime: this.formatDate(data.EAP_FlightDepartureTime__c), 
                    ArrivalAirport: data.EAP_Destination__c,
                    ArrivalTime: this.formatDate(data.EAP_FlightArrivalTime__c)
                }
    
                if (data.EAP_SeatNumber__c) {
                    this.flight.Seat = this.Seat+' #' + data.EAP_SeatNumber__c;
                }
    
                if (data.EAP_FlightClass__c) {
                    this.flight.Class = data.EAP_FlightClass__c;
                }

                this.mapLink = this.mapLink + '&mode=flying';
            
            }else{
                this.isFlight = false;
                this.shuttle = {
                    Department: data.EAP_Origin__c,
                    DepartmentTime: this.formatDate(data.EAP_StartDate__c), 
                    Arrival: data.EAP_Destination__c,
                    ArrivalTime: this.formatDate(data.EAP_EndDate__c)
                }
            }

            this.mapMarkers.push({ location: { Street: data.EAP_OriginAddress__c, City: data.EAP_OriginCity__c }, title: data.EAP_OriginAddress__c});
            this.mapMarkers.push({ location: { Street: data.EAP_Address__c, City: data.EAP_City__c, Country: data.EAP_Country__c}, title: data.EAP_Address__c});

            this.travelName = data.Name;
            const selectedTravel = new CustomEvent('travelnamechange', {});
            this.dispatchEvent(selectedTravel);

            getBoardingPass({travelId: this.travelId})
                .then(data => {
                    if(data) {
                        let imageParam = [{objId: data.Id, docId: data.Id}];
                        getDocImages({docImageList: JSON.stringify(imageParam)})
                        .then(mapData => {
                            this.boarding = {
                                Name: data.Name,
                                Size: this.fileSizeToString(data.ContentDocumentLinks[0].ContentDocument.ContentSize),
                                Date: this.formatDate(data.LastModifiedDate),
                                openFile: function(){
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__webPage',
                                        attributes: {
                                            url: mapData[data.Id]
                                        }
                                    }, false );
                                }
                            }
                            const loadedEvent = new CustomEvent('loaded', {});
                            this.dispatchEvent(loadedEvent);

                        })
                        .catch(error => {})

                    }else{
                        const loadedEvent = new CustomEvent('loaded', {});
                        this.dispatchEvent(loadedEvent);
                    }
                })
                .catch(error => {})

            this.mapLoaded = true;
                
        })
        .catch(error => {})
    }

    formatDate(dateString){
        let date = new Date(dateString);

        let day = date.getDate();
        let weekdayArray = [this.labels.ShortSunday, this.labels.ShortMonday, this.labels.ShortTuesday, this.labels.ShortWednesday, this.labels.ShortThursday, this.labels.ShortFriday, this.labels.ShortSaturday];
        let weekday = weekdayArray[date.getDay()];
        let month = new Intl.DateTimeFormat('en', { month: 'short' }).format(date);
        let year = date.getFullYear();
        let hour = date.getHours();
        let minute = date.getMinutes();
        if (minute.toString().length === 1){
            minute = "0" + minute;
        }

        let strTime = weekday + ' ' + day + ' '+ month +' ' + year + ' - ' + hour + '.' + minute;
        return strTime;
    }

    fileSizeToString(value) {
        let sizes = ['bytes', 'kb', 'mb', 'gb', 'tb'];
        if (value === 0) return '0 Byte';
        let i = parseInt(Math.floor(Math.log(value) / Math.log(1024)));

        return Math.round(value / Math.pow(1024, i), 2) + ' ' + sizes[i];
    }

    get checkDetails() {
        let details = [];
        if (this.isFlight){
            let dataFlight = {
                Id: 1,
                Title: this.flight.Flight,
                Subtitle: this.flight.Company,
                IconStart: this.takingOffAirplane
            };
            let dataDepartment ={
                Id: 2,
                Title: this.flight.DepartmentAirport,
                Subtitle: this.flight.DepartmentTime,
                IconStart: this.takingOffAirplane
            };
            let dataArrival ={
                Id: 3,
                Title: this.flight.ArrivalAirport,
                Subtitle: this.flight.ArrivalTime,
                IconStart: this.delayingAirplane
            };
            details.push(dataFlight, dataDepartment, dataArrival);
        
        }else{
            let dataDepartment ={
                Id: 2,
                Title: this.shuttle.Department,
                Subtitle: this.shuttle.DepartmentTime,
                IconStart: this.iconCar
            };
            let dataArrival ={
                Id: 3,
                Title: this.shuttle.Arrival,
                Subtitle: this.shuttle.ArrivalTime,
                IconStart: this.iconCar
            };
            details.push(dataDepartment, dataArrival);
        }

        return details;
    }

    get haveDetails() {
        if (this.flight.Seat || this.flight.Class)
            return true;
        else
            return false;
    }
}