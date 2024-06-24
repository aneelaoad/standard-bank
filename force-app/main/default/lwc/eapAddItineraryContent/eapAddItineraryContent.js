import { LightningElement, track, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import insertTravel from '@salesforce/apex/EAP_CTRL_ItineraryPage.insertTravel';
import getClassTravel from '@salesforce/apex/EAP_CTRL_ItineraryPage.getClassTravel';
import getCountryPicklist from '@salesforce/apex/EAP_CTRL_ItineraryPage.getCountryPicklist';

import FLIGHT_LABEL from '@salesforce/label/c.Eap_Flight_Label';
import TRANSPORT_LABEL from '@salesforce/label/c.Eap_Transport_Label';
import TYPE_LABEL from '@salesforce/label/c.Eap_Type_Label';
import FLIGHT_ADDED_LABEL from '@salesforce/label/c.Eap_FlightAdded_Label';
import NO_FLIGHT_LABEL from '@salesforce/label/c.Eap_NoFlightAdded_Label';
import SHUTTLE_ADDED_LABEL from '@salesforce/label/c.Eap_ShuttleAdded_Label';
import NO_SHUTTLE_LABEL from '@salesforce/label/c.Eap_NoShuttleAdded_Label';
import SELECT_FLIGHT_LABEL from '@salesforce/label/c.Eap_SelectFlight_Label';
import TRAVEL_NAME_LABEL from '@salesforce/label/c.Eap_TravelName_Label';
import AIRLINE_LABEL from '@salesforce/label/c.Eap_Airline_Label';
import FLIGHT_NUMBER_LABEL from '@salesforce/label/c.Eap_FlightNumber_Label';
import ORIGIN_LABEL from '@salesforce/label/c.Eap_Origin_Label';
import NAME_LABEL from '@salesforce/label/c.Eap_Name_Label';
import COUNTRY_LABEL from '@salesforce/label/c.Eap_Country_Label';
import CITY_LABEL from '@salesforce/label/c.Eap_City_Label';
import ADDRESS_LABEL from '@salesforce/label/c.Eap_Address_Label';
import DESTINATION_LABEL from '@salesforce/label/c.Eap_Destination_Label';
import DEPARTURE_LABEL from '@salesforce/label/c.Eap_Departure_Label';
import ARRIVAL_LABEL from '@salesforce/label/c.Eap_Arrival_Label';
import CLASS_LABEL from '@salesforce/label/c.Eap_Class_Label';
import SEAT_NUMBER_LABEL from '@salesforce/label/c.Eap_SeatNumber_Label';
import SAVE_LABEL from '@salesforce/label/c.Eap_Save_Label';
import SELECT_TYPE_LABEL from '@salesforce/label/c.Eap_SelectFlight_Label';
import COMPANY_LABEL from '@salesforce/label/c.Eap_Company_Label';
import SERVICE_LABEL from '@salesforce/label/c.Eap_Service_Label';
import START_DATE_LABEL from '@salesforce/label/c.Eap_StartDate_Label';
import END_DATE_LABEL from '@salesforce/label/c.Eap_EndDate_Label';

export default class EapAddItineraryContent extends NavigationMixin(LightningElement) {
    labels = {Flight: FLIGHT_LABEL, Transport: TRANSPORT_LABEL, Type: TYPE_LABEL, FlightAdded: FLIGHT_ADDED_LABEL, 
            NoFlight: NO_FLIGHT_LABEL, ShuttleAdded: SHUTTLE_ADDED_LABEL, NoShuttle: NO_SHUTTLE_LABEL, SelectFlight: SELECT_FLIGHT_LABEL,
            Save: SAVE_LABEL, SeatNumber: SEAT_NUMBER_LABEL, Class: CLASS_LABEL, Arrival: ARRIVAL_LABEL, Departure: DEPARTURE_LABEL,
            Address: ADDRESS_LABEL, City: CITY_LABEL, Country: COUNTRY_LABEL, Name: NAME_LABEL, Destination: DESTINATION_LABEL,
            Origin: ORIGIN_LABEL, FlightNumber: FLIGHT_NUMBER_LABEL, Airline: AIRLINE_LABEL, TravelName: TRAVEL_NAME_LABEL,
            SelectType: SELECT_TYPE_LABEL, Company: COMPANY_LABEL, Service: SERVICE_LABEL, StartDate: START_DATE_LABEL,
            EndDate: END_DATE_LABEL};
    iconFlight = customIcons + '/takingOffAirplane.svg';
    shieldMessage = this.labels.SelectFlight;

    haveAdded = false;
    travel = {};
    @track hasError = {};
    @track showType = true;
    @track showFlight = false;
    @track showTransport = false;
    @track stepList = [{ Id: 0, Title: this.labels.Type, TemplateActive: true },
                    { Id: 1, Title: this.labels.Flight+'/'+this.labels.Transport, TemplateActive: false }];
    thisStep = {Id: 0, Title: this.labels.Type};

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
    }
    @track classOptions = [];
    @track countryOptions = [];

    @wire(getClassTravel)
    wiredTravel({ error, data }) {
        if (data) {
            for(let i = 0; i < Object.keys(data).length; i++){
                this.classOptions.push({label: data[i], value: data[i]});
            }

        }

        getCountryPicklist()
        .then(dataCountry => {
            for(let i = 0; i < Object.keys(dataCountry).length; i++){
                this.countryOptions.push({label: dataCountry[i], value: dataCountry[i]});
            }

            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        })
        .catch((error) => {});
    }

    saveTravel() {
        if (this.showFlight){
            if (this.passValidation(["TravelName", "Airline", "FlightNumber", "Origin", "Destination", "StartDate", "Departure", "EndDate", "Arrival", "Address", "Country", "City"]) && this.dateValidation())
            {
                if (!this.haveAdded){
                    this.haveAdded = true;
                    const reloadEvent = new CustomEvent('reload', {});
                    this.dispatchEvent(reloadEvent);
                    insertTravel({eventId: this.eventId, travelToInsert: JSON.stringify(this.travel)})
                    .then(data => {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                name: 'Confirmation__c'
                            },state: {
                                message: this.labels.FlightAdded,
                                destination: 'Itinerary__c',
                                type: 'Success',
                                eventId:  this.eventId
                            }
                        });
                    })
                    .catch(error => {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                name: 'Confirmation__c'
                            },state: {
                                message: this.labels.NoFlight,
                                destination: 'Itinerary__c',
                                type: 'Error',
                                eventId:  this.eventId
                            }
                        });
                    });
                }
            }
            
        }else{
            if (this.passValidation(["TravelName", "Origin", "Destination", "Company", "Service", "StartDate", "Departure", "EndDate", "Arrival", "Address", "Country", "City"]) && this.dateValidation())
            {
                if (!this.haveAdded){
                    this.haveAdded = true;
                    const reloadEvent = new CustomEvent('reload', {});
                    this.dispatchEvent(reloadEvent);
                    insertTravel({eventId: this.eventId, travelToInsert: JSON.stringify(this.travel)})
                    .then(data => {
                        const loadedEvent = new CustomEvent('reload', {});
                        this.dispatchEvent(loadedEvent);
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                name: 'Confirmation__c'
                            },state: {
                                message: this.labels.ShuttleAdded,
                                destination: 'Itinerary__c',
                                type: 'Success',
                                eventId:  this.eventId
                            }
                        });
                    })
                    .catch(error => {
                        const loadedEvent = new CustomEvent('reload', {});
                        this.dispatchEvent(loadedEvent);
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                name: 'Confirmation__c'
                            },state: {
                                message: this.labels.NoShuttle,
                                destination: 'Itinerary__c',
                                type: 'Error',
                                eventId:  this.eventId
                            }
                        });
                    });
                }
            }
        }

    }

    passValidation(expectedFields) {
        let valid = true;
        expectedFields.forEach(field => {
            if (this.travel[field] === undefined || this.travel[field] === ""){
                valid = false;
                this.hasError[field] = true;
            }else {
                this.hasError[field] = false;
            }
        });

        return valid;
    }

    handleInputChange(e){
        let field = e.target.name;
        field = field.charAt(0).toUpperCase() + field.slice(1);
        let value = e.target.value;
        this.travel[field] = value;
        
        if (value.trim() === "")
        {
            this.hasError[field] = true;

        }else if (this.hasError[field])
        {
            this.hasError[field] = false;
        }
    }

    dateValidation() {
        let startDate = new Date(this.travel.StartDate);
        let time = this.travel.Departure.split(':');
        startDate.setHours(time[0]);
        startDate.setMinutes(time[1]);
        startDate.setSeconds(0);
        startDate.setMilliseconds(0);
        this.travel.DepartureDate = startDate;

        let endDate = new Date(this.travel.EndDate);
        let timeArr = this.travel.Arrival.split(':');
        endDate.setHours(timeArr[0]);
        endDate.setMinutes(timeArr[1]);
        endDate.setSeconds(0);
        endDate.setMilliseconds(0);
        this.travel.ArrivalDate = endDate;

        if (this.travel.DepartureDate < this.travel.ArrivalDate){
            this.hasError.StartDate = false;
            this.hasError.Departure = false;
            this.hasError.EndDate = false;
            this.hasError.Arrival = false;
            return true;

        }else {
            this.hasError.StartDate = true;
            this.hasError.Departure = true;
            this.hasError.EndDate = true;
            this.hasError.Arrival = true;
            return false;
        }
    }

    selectType(e) {
        let option = e.target.name;

        this.thisStep.Id = 1;
        if (option === "flight")
        {
            this.showFlight = true;
            this.stepList[1].Title = this.labels.Flight;
            this.thisStep.Title = this.stepList[1].Title;
        }else {
            this.showTransport = true;
            this.stepList[1].Title = this.labels.Transport;
            this.thisStep.Title = this.stepList[1].Title;
        }

        this.stepList[1].TemplateActive = true;
        this.showType = false;
    }
}