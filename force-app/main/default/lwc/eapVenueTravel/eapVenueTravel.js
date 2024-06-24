import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getVenueTravel from '@salesforce/apex/EAP_CTRL_VenuePage.getVenueTravel';

import PARKING_LABEL from '@salesforce/label/c.Eap_Parking_Label';
import TRAVEL_LABEL from '@salesforce/label/c.Eap_Travel_Label';
import NO_TRAVEL_PARKING_LABEL from '@salesforce/label/c.Eap_NoTravelParking_Label';

export default class EapVenueTravel extends NavigationMixin(LightningElement) {
    labels = {Parking: PARKING_LABEL, Travel: TRAVEL_LABEL, NoTravelParking: NO_TRAVEL_PARKING_LABEL};
    @track _eventId;

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this._eventId = value;
        this.loadVenue();
    }

    @track travelInfo = [];

    loadVenue(){
        getVenueTravel({eventId: this.eventId})
        .then((data) => {
            if(data) {
                let venue = data;  
                let id = 1;
                if(venue.EAP_Parking__c){
                    this.travelInfo.push({
                        Id: 1,
                        Title: this.labels.Parking,
                        Content: venue.EAP_Parking__c,
                    });
                    id++;
                }
                if(venue.EAP_Parking__c){
                    this.travelInfo.push({
                        Id: 1,
                        Title: this.labels.Travel,
                        Content: venue.EAP_TravelAdvice__c,
                    });
                    id++;
                }
            }

            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        })
        .catch((error) => {
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        });
    }

    get haveInformation(){
        if (this.travelInfo.length > 0) {
            return true;
        
        }else {
            return false;
        }
    }

}