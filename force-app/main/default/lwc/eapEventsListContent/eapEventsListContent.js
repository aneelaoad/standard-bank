import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getArchivedEvents from '@salesforce/apex/EAP_CTRL_EventsListPage.getArchivedEvents';
import getAllEvents from '@salesforce/apex/EAP_CTRL_EventsListPage.getAllEvents';
import getDocImages from '@salesforce/apex/EAP_UTIL_EventsApp.getDocImages';
import SEARCH_LABEL from '@salesforce/label/c.Eap_Search_Label';
import ENTER_SEARCH_LABEL from '@salesforce/label/c.Eap_EnterSearch_Label';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';

export default class EapEventsListContent extends NavigationMixin(LightningElement) {
    labels = {Search: SEARCH_LABEL, EnterSearch: ENTER_SEARCH_LABEL};
    searchIcon = customIcons + '/icn_search.svg';
    //Variables
    _allEvents;
    defaultEvents = [];
    @track events = [];

    @api
    get allEvents(){
        return this._allEvents;
    }
    set allEvents(value) {
        this.setAttribute('v', value);
        this._allEvents = value;
        this.defaultEvents = [];
        this.events = [];

        if (this._allEvents){
            this.loadAllEvents();
        
        }else{
            this.loadArchivedEvents();
        }
    }

    loadArchivedEvents(){
        getArchivedEvents()
        .then((data) => {
            data.forEach(item =>{
                let evt = item.event;
                let img = item.docId;
                
                let eventToInsert = {
                    Id: evt.Id,
                    Title: evt.Name,
                    SupTitle: this.formatDates(new Date(evt.EAP_StartDate__c),new Date(evt.EAP_EndDate__c)),
                    SubTitle: evt.EAP_Location__c,
                    Initials: this.getInitials(evt.Name),
                    openEventDetail: function(){
                        const loadedEvent = new CustomEvent('reload', {});
                        this.dispatchEvent(loadedEvent);
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                                    attributes: {
                                        name: 'Archived_Detail__c'
                                    },
                            state: {
                                eventId: evt.Id
                            }
                        });
                    }
                };

                if (!img){
                    eventToInsert.Initials = this.getInitials(eventToInsert.Title);
                }

                this.events.push(eventToInsert);
                this.defaultEvents.push(eventToInsert);
            });

            let eventList = data;
            let imagesParam = [];
            for(let i = 0; i < eventList.length; i++){
                imagesParam.push(
                    {
                        objId: eventList[i].event.Id,
                        docId: eventList[i].docId
                    }
                )
            }

            getDocImages({docImageList: JSON.stringify(imagesParam)})
            .then((dataImg) => {
                if(dataImg) {
                    let mapEvDoc = dataImg;
                    for(let i=0; i<eventList.length; i++){
                        let docPhoto = mapEvDoc[this.events[i].Id];
                        if (docPhoto !== undefined){
                            this.events[i].Img = docPhoto;
                            this.defaultEvents[i].Img = docPhoto;
                        
                        }else{
                            this.events[i].Initials = this.getInitials(this.events[i].Title);
                            this.defaultEvents[i].Initials = this.getInitials(this.defaultEvents[i].Title);
                        }
                        
                    }
                }

                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            })
            .catch((error) => {});

            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);

        })
        .catch((error) => { });
    }

    //Event_Detail__c
    loadAllEvents(){
        getAllEvents()
        .then((data) => {
            data.forEach(item =>{
                let evt = item.event;
                let img = item.docId;
                
                let eventToInsert = {
                    Id: evt.Id,
                    Title: evt.Name,
                    SupTitle: this.formatDates(new Date(evt.EAP_StartDate__c),new Date(evt.EAP_EndDate__c)),
                    SubTitle: evt.EAP_Location__c,
                    Initials: this.getInitials(evt.Name),
                    openEventDetail: function(){
                        const loadedEvent = new CustomEvent('reload', {});
                        this.dispatchEvent(loadedEvent);
                        this[NavigationMixin.Navigate]({
                            type: "comm__namedPage",
                                    attributes: {
                                        name: 'Event_Detail__c'
                                    },
                            state: {
                                eventId: evt.Id
                            }
                        });
                    }
                };

                if (!img){
                    eventToInsert.Initials = this.getInitials(eventToInsert.Title);
                }

                this.events.push(eventToInsert);
                this.defaultEvents.push(eventToInsert);
            });

            let eventList = data;
            let imagesParam = [];
            for(let i = 0; i < eventList.length; i++){
                imagesParam.push(
                    {
                        objId: eventList[i].event.Id,
                        docId: eventList[i].docId
                    }
                )
            }

            getDocImages({docImageList: JSON.stringify(imagesParam)})
            .then((dataImg) => {
                if(dataImg) {
                    let mapEvDoc = dataImg;
                    for(let i=0; i<eventList.length; i++){
                        let docPhoto = mapEvDoc[this.events[i].Id];
                        if (docPhoto !== undefined){
                            this.events[i].Img = docPhoto;
                            this.defaultEvents[i].Img = docPhoto;
                        
                        }else{
                            this.events[i].Initials = this.getInitials(this.events[i].Title);
                            this.defaultEvents[i].Initials = this.getInitials(this.defaultEvents[i].Title);
                        }
                        
                    }
                }

                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            })
            .catch((error) => {});

            if(imagesParam.length === 0){
                const loadedEvent = new CustomEvent('loaded', {});
                this.dispatchEvent(loadedEvent);
            }

        })
        .catch((error) => {});
    }

    formatDates(starDate,endDate) {
        let dayStart = starDate.getDate();
        let dayEnd = endDate.getDate();
        let monthStart = new Intl.DateTimeFormat('en', { month: 'short' }).format(starDate);
        let monthEnd = new Intl.DateTimeFormat('en', { month: 'short' }).format(endDate);
        let year = starDate.getFullYear();
        let strTime;
        if(monthStart === monthEnd){
            strTime = dayStart + '-' + dayEnd + ' ' + monthStart + ' ' + year;
        }else{
            strTime = dayStart + ' '+ monthStart + ' - ' + dayEnd + ' ' + monthEnd + ' ' + year;
        }
        return strTime;
    }

    getInitials(fullName){
        let fullNameArray = fullName.split(" ");
        let initials = '';

        fullNameArray.forEach(name => {
            initials += name[0];
        })

        return initials;
    }

    //Functions
    findEvent(){
        let filteredEvents = [...this.defaultEvents];
        let lookingfor = this.lookingfor = this.template.querySelector("[name='searchEvent']").value;
        if (this.lookingfor !== "")
        {
            filteredEvents = filteredEvents.filter(event => event.Title.toLowerCase().startsWith(lookingfor.toLowerCase()))
        }
        this.events = filteredEvents;
    }
}