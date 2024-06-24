import { LightningElement,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import NOTIFICATIONS_LABEL from '@salesforce/label/c.Eap_NoCurrentMeeting_Label';
import GO_BACK_LABEL from '@salesforce/label/c.Eap_GoBack_Label';

export default class EapHeaderDetail extends NavigationMixin(LightningElement) {
    labels = {Notifications: NOTIFICATIONS_LABEL, GoBack: GO_BACK_LABEL};
    returnPage = 'Home';
    actualPage;
    mapNav;
    eventId;
    meetingId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            if(this.urlStateParameters !== undefined && this.urlStateParameters !== null){
                this.actualPage = currentPageReference.attributes.name;
                this.setParametersBasedOnUrl();
            }
        }
    }

    setParametersBasedOnUrl() {
        this.mapNavigation();

        this.eventId = this.urlStateParameters.eventId || null;
        this.meetingId = this.urlStateParameters.meetingId || null;
        let prevPage = this.urlStateParameters.prevPage || null;

        if(prevPage !== null){
            this.returnPage = prevPage;
        }else{
            if(this.mapNav.get(this.actualPage) !== undefined){
                this.returnPage = this.mapNav.get(this.actualPage);
            }
        }
    }

    mapNavigation(){
        this.mapNav = new Map();
        this.mapNav.set('Event_Detail__c', 'Home');
        this.mapNav.set('Profile__c', 'Home');
        this.mapNav.set('Events_List__c', 'Home');
        this.mapNav.set('Archived_Detail__c', 'Events_List__c');
        this.mapNav.set('Delegates__c', 'Event_Detail__c');
        this.mapNav.set('Venue__c', 'Event_Detail__c');
        this.mapNav.set('Contacts__c', 'Event_Detail__c');
        this.mapNav.set('Accommodation__c', 'Event_Detail__c');
        this.mapNav.set('Documents__c', 'Event_Detail__c');
        this.mapNav.set('Itinerary__c', 'Event_Detail__c');
        this.mapNav.set('Itinerary_Detail__c', 'Itinerary__c');
        this.mapNav.set('Event_Schedule__c', 'Event_Detail__c');
        this.mapNav.set('Change_Request__c', 'Meeting_Information__c');
        this.mapNav.set('Availability_Detail__c', 'Event_Detail__c');
    }

    @api title = "Notifications";

    iconLogo = customIcons + '/logo.svg';
    iconUser = customIcons + '/user.svg';
    iconStart = "utility:chevronleft";
    startText = "Go back";

    clickStart() {
        if(this.eventId !== undefined){
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: this.returnPage
                },
                state: {
                    eventId: this.eventId
                }
            });
        }else if (this.meetingId !== undefined)
        {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: this.returnPage
                },
                state: {
                    meetingId: this.meetingId
                }
            });
        }else{
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: this.returnPage
                }
            });
        }
        
    }

    @api iconsEnd = [
        {
            Id:1,
            Name:this.iconUser,
            Click: function() {
                this.clickStart();
            }
        }
    ]

    renderedCallback() {
        let title = this.template.querySelector('[class="v1_span_title"]');
        let titleContainer = this.template.querySelector('[class="v1_div_heading"]');
    }
}