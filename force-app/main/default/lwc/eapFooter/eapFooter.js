import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import getNextMeeting from '@salesforce/apex/EAP_CTRL_Footer.getNextMeeting';
import getNextEvent from '@salesforce/apex/EAP_CTRL_Footer.getNextEvent';
import HOME_LABEL from '@salesforce/label/c.Eap_Home_Label';
import ALL_EVENTS_LABEL from '@salesforce/label/c.Eap_AllEvents_Label';
import CURRENT_EVENT_LABEL from '@salesforce/label/c.Eap_CurrentEvent_Label';
import CURRENT_MEETING_LABEL from '@salesforce/label/c.Eap_CurrentMeeting_Label';
import PROFILE_LABEL from '@salesforce/label/c.Eap_Profile_Label';
import NO_CURRENT_EVENT_LABEL from '@salesforce/label/c.Eap_NoCurrentEvent_Label';
import NO_CURRENT_MEETING_LABEL from '@salesforce/label/c.Eap_NoCurrentMeeting_Label';
import MENU_LABEL from '@salesforce/label/c.Eap_Menu_Label';

export default class EapFooter extends NavigationMixin(LightningElement) {
    labels = {Home: HOME_LABEL, AllEvents: ALL_EVENTS_LABEL, CurrentEvent: CURRENT_EVENT_LABEL, CurrentMeeting: CURRENT_MEETING_LABEL,
            Profile: PROFILE_LABEL, NoCurrentEvent: NO_CURRENT_EVENT_LABEL, NoCurrentMeeting: NO_CURRENT_MEETING_LABEL, Menu: MENU_LABEL};
    @api isfixed = false;
    @track loading = false;
    currentPage;
    eventId = null;
    hiddenMenuIsOpen = false;
    iconStart = customIcons + '/logo.svg';
    iconCalendar = customIcons + '/calendar.svg';
    iconCalClock = customIcons + '/icn_calclock.svg';
    iconHome = customIcons + '/icn_home.svg';

    @wire(CurrentPageReference)
    getpageRef(pageRef) {
        this.currentPage = pageRef.attributes.name;
        if (pageRef.state.eventId !== null)
            this.eventId = pageRef.state.eventId;
    }

    showAllEvents() {
        this.loading = true;
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Events_List__c'
            },
            state: {
                allEvents: true
            }
        });
    }

    showCurrentEvent() {
        this.loading = true;
        getNextEvent()
        .then(data => {
            if (data) {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: 'Event_Detail__c'
                    },
                    state: {
                        eventId: data.Id
                    }
                });

            }else {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: 'Confirmation__c'
                    },
                    state: {
                        type: 'Error',
                        message: this.labels.NoCurrentEvent,
                        destination: this.currentPage,
                        eventId: this.eventId
                    }
                });
            }
        })
        .catch(error => {});
    }

    showHome() {
        this.loading = true;
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Home'
            }
        });
    }

    showCurrentMeeting() {
        this.loading = true;
        getNextMeeting()
        .then(data => {
            if (data) {
                    this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: 'Meeting_Information__c'
                    },
                    state: {
                        meetingId: data.Id
                    }
                });
            
            }else {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: 'Confirmation__c'
                    },
                    state: {
                        type: 'Error',
                        message: this.labels.NoCurrentMeeting,
                        destination: this.currentPage,
                        eventId: this.eventId
                    }
                });
            }
        })
        .catch(error => { })
    }

    showProfile() {
        this.loading = true;
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: 'Profile__c'
            }
        });
    }

    openHiddenMenu() {
        this.hiddenMenuIsOpen = true;
    }

    closeHiddenMenu() {
        this.hiddenMenuIsOpen = false;
    }
}