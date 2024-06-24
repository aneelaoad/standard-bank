import { LightningElement, track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getEventAccommodations from '@salesforce/apex/EAP_CTRL_AccommodationPage.getEventAccommodations';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';
import ADD_RESERVATION_LABEL from '@salesforce/label/c.Eap_AddReservation_Label';
import NO_ACCOMMODATION_LABEL from '@salesforce/label/c.Eap_NoAccommodationAdded_Label';
import FULL_ADDRESS_LABEL from '@salesforce/label/c.Eap_FullAddress_Label';
import PHONE_NUMBER_LABEL from '@salesforce/label/c.Eap_PhoneNumber_Label';
import EMAIL_LABEL from '@salesforce/label/c.Eap_Email_Label';
import NIGHTS_LABEL from '@salesforce/label/c.Eap_Nights_Label';

const DEFAULT_IMG = customIcons+'/StandardBankLogo.png';

export default class EapAccommodationContent extends NavigationMixin(LightningElement) {
    labels = {AddReservation: ADD_RESERVATION_LABEL, 
        NoAccommodation: NO_ACCOMMODATION_LABEL,
        FullAddress: FULL_ADDRESS_LABEL,
        PhoneNumber: PHONE_NUMBER_LABEL,
        Email: EMAIL_LABEL,
        Nights: NIGHTS_LABEL};
    @track eventId;
    @track hotelsData = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.eventId = this.urlStateParameters.eventId || null;
        this.loadAccommodations();
    }

    loadAccommodations(){
        getEventAccommodations({eventId: this.eventId})
        .then((data) => {
            if(data) {
                let accommList = data;
                let imagesParam = [];
                for(let i=0; i<accommList.length; i++){
                    imagesParam.push(
                        {
                            objId: accommList[i].accommodation.Id,
                            docId: accommList[i].mainPhoto
                        }
                    )
                }
                if(imagesParam.length > 0){
                    getDocImages({docImageList: JSON.stringify(imagesParam)})
                    .then((data) => {
                        if(data) {
                            let mapEvDoc = data;
                            for(let i=0; i<accommList.length; i++){
                                let accomm = accommList[i].accommodation;
                                let docPhoto = mapEvDoc[accomm.Id];

                                this.hotelsData.push({
                                    Id: i,
                                    Hotel: accomm.EAP_HotelName__c,
                                    Location: accomm.EAP_Location__c,
                                    Dates: (accomm.EAP_BookingDate__c !==undefined)?this.getFormatDates(accomm.EAP_BookingDate__c,accomm.EAP_Nights__c):null,
                                    Nights: (accomm.EAP_Nights__c !== undefined)?accomm.EAP_Nights__c+ ' ' + this.labels.Nights:null,
                                    FullAddress: accomm.EAP_Address__c,
                                    PhoneNumber: accomm.EAP_ContactPhone__c,
                                    Email: accomm.EAP_ContactEmail__c,
                                    FullAddressActive: false,
                                    PhoneNumberActive: false,
                                    EmailActive: false,
                                    ImageHotel: (docPhoto !== undefined)?docPhoto:DEFAULT_IMG,
                                    clickAddress(){
                                        this.showInformation(this.hotelsData[i], 'FullAddressActive');
                                    },
                                    clickPhoneNumber(){
                                        this.showInformation(this.hotelsData[i], 'PhoneNumberActive');
                                    },
                                    clickEmail(){
                                        this.showInformation(this.hotelsData[i], 'EmailActive');
                                    }
                                
                                });
                                
                            }                        
                        }
                        const loadedEvent = new CustomEvent('loaded', {});
                        this.dispatchEvent(loadedEvent);
                    })
                    .catch((error) => {
                        const loadedEvent = new CustomEvent('loaded', {});
                        this.dispatchEvent(loadedEvent);
                    });
                }else{
                    const loadedEvent = new CustomEvent('loaded', {});
                    this.dispatchEvent(loadedEvent);
                }
                
            
            }
        })
        .catch((error) => {
            console.error(error);
        });
    }

    getFormatDates(bookDate,nights){
        let date = new Date(bookDate);

        let day = date.getDate();
        let month = new Intl.DateTimeFormat('en', { month: 'short' }).format(date);

        let strTime = day + ' '+ month;

        if(nights !== undefined && nights > 0){
            date.setDate(date.getDate() + (nights));
            let day = date.getDate();
            let month = new Intl.DateTimeFormat('en', { month: 'short' }).format(date);
            strTime += ' - '+day + ' '+ month;
        }
        return strTime;
    }

    showInformation(hotel, requestedData) {
        if (hotel[requestedData])
        {
            hotel[requestedData] = false;
        }else
        {
            this.clearInformation();
            hotel[requestedData] = true;   
        }
    }

    clearInformation() {
        for(let i = 0; i < this.hotelsData.length; i++){
            this.hotelsData[i].FullAddressActive = false;
            this.hotelsData[i].PhoneNumberActive = false;
            this.hotelsData[i].EmailActive = false;
        }
    }

    addReservation() {
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);
        
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Add_Accommodation__c'
            },
            state: {
                eventId:  this.eventId
            }
        });
    }

    get haveAccommodation(){
        if (this.hotelsData.length > 0){
            return true;
        
        }else {
            return false;
        }
    }
}