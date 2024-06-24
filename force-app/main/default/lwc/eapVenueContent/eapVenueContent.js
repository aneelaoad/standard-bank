import { LightningElement,track,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import CURRENT_PAGE_LABEL from '@salesforce/label/c.Eap_CurrentPage_Label';
import ARCHIVE_LABEL from '@salesforce/label/c.Eap_Archive_Label';
import ABOUT_LABEL from '@salesforce/label/c.Eap_About_Label';
import TRAVEL_PARKING_LABEL from '@salesforce/label/c.Eap_TravelParking_Label';
import DOCUMENTS_LABEL from '@salesforce/label/c.Eap_Documents_Label';
import getVenueTravel from '@salesforce/apex/EAP_CTRL_VenuePage.getVenueTravel';
import getVenueDocs from '@salesforce/apex/EAP_CTRL_VenuePage.getVenueDocs';

export default class EapVenueContent extends LightningElement {
    labels = {CurrentPage: CURRENT_PAGE_LABEL, Archive: ARCHIVE_LABEL, About: ABOUT_LABEL, TravelParking: TRAVEL_PARKING_LABEL,
            Documents: DOCUMENTS_LABEL};
    @track isAbout = true;
    @track isTravel = false;
    @track isDocuments = false;

    @track eventId;

    constructor() {
        super();
        this.getTravelInfoAndDocs(this.eventId);
    }

    /* Receive event Id */
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.eventId = this.urlStateParameters.eventId || null;
    }

    async getTravelInfoAndDocs(eventId) {
        try {
            const travel = await getVenueTravel({eventId: this.eventId});
            const docs = await getVenueDocs({eventId: this.eventId});
            if (!docs) this.tabs.splice(2, 1);
            if (!travel) this.tabs.splice(1, 1);
        } catch(err) {}
    }

    @track title = this.labels.Archive;
    @track events = this.defaultEvents;
    activeTab = 0;
    @track tabs = [
        {
            Id: 1,
            Name: this.labels.About,
            Active: true
        },
        {
            Id: 2,
            Name: this.labels.TravelParking,
            Active: false
        },
        {
            Id: 3,
            Name: this.labels.Documents,
            Active: false
        }
    ]

    handleChangeTemplate(event) {
        let id = event.currentTarget.id[0];
        this.tabs[this.activeTab].Active = false;
        this.activeTab = id-1;
        this.changeTemplate();
    }

    changeTemplate(){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);

        this.tabs[this.activeTab].Active = true;
        if(this.activeTab === 0){
            this.isTravel = false;
            this.isDocuments = false;
            this.isAbout = true;
        }else if(this.activeTab === 1){
            this.isAbout = false;
            this.isDocuments = false;
            this.isTravel = true;
        }else if(this.activeTab === 2){
            this.isTravel = false;
            this.isAbout = false;
            this.isDocuments = true;
        }
    }

    componentsLoaded(){
        const loadedEvent = new CustomEvent('loaded', {});
        this.dispatchEvent(loadedEvent);
    }

    /* Swipe */
    xDown = null;                                                        
    yDown = null;                                               

    handleTouchStart(evt) {
        const firstTouch = evt.touches[0];
        this.xDown = firstTouch.clientX;                                      
        this.yDown = firstTouch.clientY;                                      
    };                                                

    handleTouchMove(evt) {
        if ( ! this.xDown || ! this.yDown ) {
            return;
        }

        let xUp = evt.touches[0].clientX;                                    
        let yUp = evt.touches[0].clientY;

        let xDiff = this.xDown - xUp;
        let yDiff = this.yDown - yUp;

        if ( Math.abs( xDiff ) > Math.abs( yDiff ) ) {/*most significant*/
            if ( xDiff > 0 ) {
                /* left swipe */
                if (this.activeTab+1 < this.tabs.length){
                    this.tabs[this.activeTab].Active = false;
                    this.activeTab++;
                    this.changeTemplate();
                }

            } else {
                /* right swipe */

                if (this.activeTab > 0){
                    this.tabs[this.activeTab].Active = false;
                    this.activeTab--;
                    this.changeTemplate();
                }
            }                       
        }

        /* reset values */
        this.xDown = null;
        this.yDown = null;                                             
    }

}