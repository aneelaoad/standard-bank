import { LightningElement,track,api } from 'lwc';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getVenueInfo from '@salesforce/apex/EAP_CTRL_VenuePage.getVenueInfo';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';
import CONTACT_LABEL from '@salesforce/label/c.Eap_Contact_Label';
import FACILITIES_LABEL from '@salesforce/label/c.Eap_Facilities_Label';
import NO_VENUE_LABEL from '@salesforce/label/c.Eap_NoVenueAdded_Label';

const DEFAULT_IMG = '/StandardBankLogo.png';

export default class EapVenueAbout extends LightningElement {
    labels = {Contact: CONTACT_LABEL, Facilities: FACILITIES_LABEL, NoVenue: NO_VENUE_LABEL};
    decoratorIcon = customIcons +'/profileComma.svg';
    globeIcon = customIcons +'/iconGlobe.svg';
    locationIcon = customIcons +'/locationv2.svg';
    phoneIcon = customIcons +'/profilePhone.svg';

    @track _eventId;

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this._eventId = value;
        this.loadVenue();
    }

    @track venue = {};

    loadVenue(){
        getVenueInfo({eventId: this.eventId})
        .then((data) => {
            if(data) {
                let venue = data.venue;
                let venuePhoto = data.mainPhoto;

                let imagesParam = [];
                if(venue !== undefined){
                    imagesParam.push(
                        {
                            objId: venue.Id,
                            docId: venuePhoto
                        }
                    )
                }
                
                getDocImages({docImageList: JSON.stringify(imagesParam)})
                .then((data) => {
                    if(data) {
                        let mapEvDoc = data;
                        let docPhoto = mapEvDoc[venue.Id];
                        this.venue = {
                            Id: venue.Id,
                            Name: (venue.EAP_BuildingName__c)?venue.EAP_BuildingName__c:venue.Name,
                            Description: venue.EAP_Description__c,
                            Address: venue.EAP_Address__c,
                            Web: venue.EAP_Website__c,
                            Phone: venue.EAP_ContactPhone__c,
                            RoutePhone: 'tel:'+venue.EAP_ContactPhone__c,
                            Img: (docPhoto !== undefined)?docPhoto:customIcons + DEFAULT_IMG,
                            Facilities: (venue.EAP_ServiceCapability__c !== undefined)?this.getFacilities(venue.EAP_ServiceCapability__c):''
                        };

                        const loadedEvent = new CustomEvent('loaded', {});
                        this.dispatchEvent(loadedEvent);
                    }
                })
                .catch((error) => {
                    const loadedEvent = new CustomEvent('loaded', {});
                    this.dispatchEvent(loadedEvent);
                });
                
            }else{
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            }
        })
        .catch((error) => {
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        });
    }

    getFacilities(facilityString){
        let facilitiesField = facilityString.split(";");
        let facilityArray = [];
        for(let i=0; i<facilitiesField.length; i++){
            facilityArray.push({
                Id:i,
                Name:facilitiesField[i]
            });
        }
        return facilityArray;
    }

    get haveVenue(){
        if (Object.keys(this.venue).length > 0) {
            return true;
        
        }else {
            return false;
        }
    }
}