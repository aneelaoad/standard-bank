import { LightningElement, track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import jQuery from '@salesforce/resourceUrl/EapJQuery';
import owlCarousel from '@salesforce/resourceUrl/EapOwlCarrousel';
import getNextEvents from '@salesforce/apex/EAP_CTRL_LandingPage.getNextEvents';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';

import VIEW_ALL_LABEL from '@salesforce/label/c.Eap_ViewAll_Label';
import UPCOMING_EVENTS_LABEL from '@salesforce/label/c.Eap_UpcomingEvents_Label';
import VIEW_EVENT_LABEL from '@salesforce/label/c.Eap_ViewEvent_Label';

const DEFAULT_IMG = customIcons+'/StandardBankLogo.png';

export default class EapLandingCarrousel extends NavigationMixin(LightningElement) {
    labels = {ViewAll: VIEW_ALL_LABEL, UpcomingEvents: UPCOMING_EVENTS_LABEL, ViewEvent: VIEW_EVENT_LABEL};
    @track eventsData = [];

    @wire(getNextEvents)
    wiredEvents({ error, data }) {
        if(data) {
            let eventList = data;
            let imagesParam = [];
            for(let i=0; i<eventList.length; i++){
                imagesParam.push(
                    {
                        objId: eventList[i].event.Id,
                        docId: eventList[i].docId
                    }
                )
            }
            
            getDocImages({docImageList: JSON.stringify(imagesParam)})
            .then((data) => {
                if(data) {
                    let mapEvDoc = data;
                    for(let i=0; i<eventList.length; i++){
                        let event = eventList[i].event;
                        let docPhoto = mapEvDoc[event.Id];
                        let eventToInsert = {
                            Id: event.Id,
                            Subject: event.Name,
                            Location: event.EAP_Location__c,
                            FormatDate: this.formatCarrouselDates(new Date(event.EAP_StartDate__c),new Date(event.EAP_EndDate__c)),
                            ImageEvent: (docPhoto !== undefined)?docPhoto:DEFAULT_IMG,
                            openEventDetail: function(){
                                const loadedEvent = new CustomEvent('reload', {});
                                this.dispatchEvent(loadedEvent);
                                this[NavigationMixin.Navigate]({
                                    type: "comm__namedPage",
                                    attributes: {
                                        name: 'Event_Detail__c'
                                    },
                                    state: {
                                        eventId: event.Id
                                    }
                                });
                            }
                        };
                        this.eventsData.push(eventToInsert);
                        
                    }
                    this.renderedCarrousel();
                }

                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);           
            })
            .catch((error) => {});
            if(imagesParam.length === 0){
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            }
        }
    }

    formatCarrouselDates(starDate,endDate) {
        let dayStart = starDate.getDate();
        let dayEnd = endDate.getDate();
        let monthStart = new Intl.DateTimeFormat('en', { month: 'short' }).format(starDate);
        let monthEnd = new Intl.DateTimeFormat('en', { month: 'short' }).format(endDate);
        let year = starDate.getFullYear();

        let strTime = dayStart + ' '+ monthStart + ' - ' + dayEnd + ' ' + monthEnd + ' ' + year;
        
        return strTime;
    }
    
    showAllEventsList(){
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

    //OwlCarousel
    renderedCarrousel() {
        if(this.initialRender){return;}
        this.initialRender = true;
        loadStyle(this, owlCarousel+'/OwlCarousel2-2.3.4/dist/assets/owl.carousel.min.css')
        loadStyle(this, owlCarousel+'/OwlCarousel2-2.3.4/dist/assets/owl.theme.default.min.css')
        loadScript(this, jQuery)
            .then(e => {
                loadScript(this, owlCarousel+'/OwlCarousel2-2.3.4/dist/owl.carousel.min.js')
                .then(() => {
                    const carousel = this.template.querySelector('div[class="owl-carousel owl-theme owl-loaded"]');

                    window.$(carousel).owlCarousel({
                        items: 3,
                        margin: 10,
                        stagePadding: 30,
                        responsive: {
                            0:{
                                items:1
                            }
                        }
                    })
                })
        })
    }
}