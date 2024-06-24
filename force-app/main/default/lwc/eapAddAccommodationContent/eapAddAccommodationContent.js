import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import saveAccommodation from '@salesforce/apex/EAP_CTRL_AddAccommodationPage.saveAccommodation';
import HOTEL_NAME_LABEL from '@salesforce/label/c.Eap_HotelName_Label';
import START_DATE_LABEL from '@salesforce/label/c.Eap_StartDate_Label';
import CHECK_IN_LABEL from '@salesforce/label/c.Eap_CheckIn_Label';
import END_DATE_LABEL from '@salesforce/label/c.Eap_EndDate_Label';
import CHECK_OUT_LABEL from '@salesforce/label/c.Eap_CheckOut_Label';
import ADD_LOCATION_LABEL from '@salesforce/label/c.Eap_AddLocation_Label';
import ADD_FULL_ADDRESS_LABEL from '@salesforce/label/c.Eap_AddFullAddress_Label';
import TYPE_TELEPHONE_LABEL from '@salesforce/label/c.Eap_TypeTelephone_Label';
import TYPE_EMAIL_LABEL from '@salesforce/label/c.Eap_TypeEmail_Label';
import NEXT_LABEL from '@salesforce/label/c.Eap_Next_Label';
import CONTACT_DETAILS_LABEL from '@salesforce/label/c.Eap_ContactDetails_Label';
import HOTEL_BOOKING_LABEL from '@salesforce/label/c.Eap_HotelBooking_Label';
import HOTEL_ADDED_LABEL from '@salesforce/label/c.Eap_HotelAdded_Label';
import NO_HOTEL_ADDED_LABEL from '@salesforce/label/c.Eap_NoHotelAdded_Label';

export default class EapAddAccommodationContent extends NavigationMixin(LightningElement) {
    labels = {HotelName: HOTEL_NAME_LABEL, StartDate: START_DATE_LABEL, CheckIn: CHECK_IN_LABEL, EndDate: END_DATE_LABEL,
            CheckOut: CHECK_OUT_LABEL, AddLocation: ADD_LOCATION_LABEL, AddFullAddress: ADD_FULL_ADDRESS_LABEL,
            TypeTelephone: TYPE_TELEPHONE_LABEL, TypeEmail: TYPE_EMAIL_LABEL, Next: NEXT_LABEL, ContactDetail: CONTACT_DETAILS_LABEL,
            HotelBooking: HOTEL_BOOKING_LABEL, HotelAdded: HOTEL_ADDED_LABEL, NoHotelAdded: NO_HOTEL_ADDED_LABEL};
    haveAdded = false;
    @track _eventId;
    accommodation = {};

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
        this.componentsLoaded();
    }

    @track show1 = true;
    @track show2 = false;
    @track hasError = {};
    @track stepList = [
        {
            Id: 1,
            Title: this.labels.HotelBooking,
            TemplateActive: this.show1
        },
        {
            Id: 2,
            Title: this.labels.ContactDetail,
            TemplateActive: this.show2
        }
    ];
    @track thisStep = this.stepList[0];

    handleLocation(event) {
        this.value = event.detail.value;
    }
    
    nextStep() {
        let nextStepId = this.thisStep.Id;
        if (nextStepId < this.stepList.length){
            
            if (this.passValidation(["HotelName", "StartDate", "EndDate", "CheckIn", "CheckOut"])){
                this.thisStep = this.stepList[1];
                this.show1 = false;
                this.show2 = true;
                this.stepList[0].TemplateActive = false;
                this.stepList[1].TemplateActive = true;
            }
        
        }else
        {
            if (this.passValidation(["Location", "FullAddress", "Telephone", "Email"])){
                if (!this.haveAdded){
                    this.haveAdded = true;
                    const loadedEvent = new CustomEvent('reload', {});
                    this.dispatchEvent(loadedEvent);
                    
                    saveAccommodation({eventId: this.eventId, travelToInsert: JSON.stringify(this.accommodation)})
                    .then((data) => {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                name: 'Confirmation__c'
                            },state: {
                                message: this.labels.HotelAdded,
                                destination: 'Accommodation__c',
                                type: 'Success',
                                eventId:  this.eventId
                            }
                        });
                    }).catch((error) => {
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                            attributes: {
                                name: 'Confirmation__c'
                            },state: {
                                message: this.labels.NoHotelAdded,
                                destination: 'Accommodation__c',
                                type: 'Error',
                                eventId:  this.eventId
                            }
                        });
                    });
                }
            }
        }
    }

    componentsLoaded(){
        const loadedEvent = new CustomEvent('loaded', {});
        this.dispatchEvent(loadedEvent);
    }

    handleInputChange(e){
        let field = e.target.name;
        field = field.charAt(0).toUpperCase() + field.slice(1);
        let value = e.target.value;
        this.accommodation[field] = value.trim();
        
        if (value.trim() === "")
        {
            this.hasError[field] = true;

        }else if (this.hasError[field])
        {
            this.hasError[field] = false;
        }
    }

    passValidation(expectedFields) {
        let valid = true;
        let validDates = true;
        let validEmail = true;

        expectedFields.forEach(field => {
            if (this.accommodation[field] === undefined || this.accommodation[field] === ""){
                valid = false;
                this.hasError[field] = true;
            }else {
                if (field === 'StartDate' || field === 'EndDate')
                    validDates = this.dateValidation();
                
                else if (field === 'Email')
                    validEmail = this.emailValidation();
                
                else
                    this.hasError[field] = false;
            }
        });

        return (valid && validDates && validEmail);
    }

    dateValidation() {

        if (this.accommodation.StartDate && !this.accommodation.EndDate){
            this.hasError.StartDate = false;
        
        }else if (!this.accommodation.StartDate && this.accommodation.EndDate){
            this.hasError.EndDate = false;

        }else if (this.accommodation.StartDate <= this.accommodation.EndDate){
            this.hasError.StartDate = false;
            this.hasError.EndDate = false;

        }else {
            this.hasError.StartDate = true;
            this.hasError.EndDate = true;
            return false;
        }

        return true;
    }

    emailValidation() {
        let regex = /^[\w-\.]+@([\w-]+\.)+[\w-]+$/g;

        if (this.accommodation.Email.match(regex))
        {
            this.hasError.Email = false;
            return true;
        }
        else
        {
            this.hasError.Email = true;
            return false;
        }
    }
}