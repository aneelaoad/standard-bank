import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTypeOfEvent from '@salesforce/apex/EAP_CTRL_EventDetailPage.getTypeOfEvent';
import getOnsiteInformation from '@salesforce/apex/EAP_CTRL_EventDetailPage.getOnsiteInformation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import DELEGATES_LABEL from '@salesforce/label/c.Eap_Delegates_Label';
import DOCUMENTS_LABEL from '@salesforce/label/c.Eap_Documents_Label';
import CONTACTS_LABEL from '@salesforce/label/c.Eap_EventContacts_Label';
import ITINERARY_LABEL from '@salesforce/label/c.Eap_TravelItinerary_Label';
import VENUE_LABEL from '@salesforce/label/c.Eap_VenueDetails_Label';
import ACCOMMODATION_LABEL from '@salesforce/label/c.Eap_Accommodation_Label';

export default class EapEventDetailButtons extends NavigationMixin(LightningElement) {
    labels = {Delegates: DELEGATES_LABEL, Documents: DOCUMENTS_LABEL, Contacts: CONTACTS_LABEL, Itinerary: ITINERARY_LABEL, Venue: VENUE_LABEL, Accommodation: ACCOMMODATION_LABEL};
    iconDelegate = customIcons + '/delegates.svg';
    iconVenue = customIcons + '/location.svg';
    iconDocument = customIcons + '/document.svg';
    iconAccommodation = customIcons + '/accommodation.svg';
    iconPhone = customIcons + '/phone.svg';
    iconItinerary = customIcons + '/takingOffAirplane.svg';
    @track hasItinerary = false;
    @track hasAccommodation = false;

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
        this.getType();
    }

    @track isOnline = false;
    @track _eventId;

    getType(){
        getTypeOfEvent({eventId: this.eventId})
        .then(data => {
            if (data === 'Online')
            {
                this.isOnline = true;
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            }else
            {
                this.isOnline = false;
                getOnsiteInformation({eventId: this.eventId})
                .then(dataOnsite => {
                    this.hasItinerary = dataOnsite.hasItinerary;
                    this.hasAccommodation = dataOnsite.hasAccommodation;
                    const loadedEvent = new CustomEvent('loaded', {});
                    this.dispatchEvent(loadedEvent);
                })
                .catch(error => {
                    const loadedEvent = new CustomEvent('loaded', {});
                    this.dispatchEvent(loadedEvent);
                });
            }
        })
        .catch(error => {
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        });
    }

    // Methods
    showOtherView(namePage){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: namePage
            },
            state: {
                eventId:  this._eventId
            }
        });
    }

    showAccommodation(){
        this.showOtherView('Accommodation__c');
    }

    showDelegates(){
        this.showOtherView('Delegates__c');
    }

    showDocuments(){
        this.showOtherView('Documents__c');
    }

    showItinerary(){
        this.showOtherView('Itinerary__c');
    }

    showContacts(){
        this.showOtherView('Contacts__c');
    }

    showVenue(){
        this.showOtherView('Venue__c');
    }
}