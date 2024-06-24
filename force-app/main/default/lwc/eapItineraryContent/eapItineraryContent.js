import { LightningElement, track, api } from 'lwc';
import ROUTE_LABEL from '@salesforce/label/c.Eap_Route_Label';
import DOCUMENTS_LABEL from '@salesforce/label/c.EAP_TravelDocuments_Label';
import CURRENT_PAGE_LABEL from '@salesforce/label/c.Eap_CurrentPage_Label';

export default class EapItineraryContent extends LightningElement {
    labels = {Route: ROUTE_LABEL, TravelDocuments: DOCUMENTS_LABEL, CurrentPage: CURRENT_PAGE_LABEL};
    activeTab = 0;
    @track isRoute = true;
    @track tabs = [
        {
            Id: 1,
            Name: this.labels.Route,
            Active: true
        },
        {
            Id: 2,
            Name: this.labels.TravelDocuments,
            Active: false
        }
    ]

    _eventId;
    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
    }

    componentsLoaded(){
        const loadedEvent = new CustomEvent('loaded', {});
        this.dispatchEvent(loadedEvent);
    }

    /* This method will change the current tab and the visual references (color and underline on tab name) */
    handleOnClick(event) {
        let id = event.currentTarget.id[0];
        this.tabs[this.activeTab].Active = false;

        this.activeTab = id-1;
        this.changeTemplate();
        
    }

    changeTemplate(){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);

        this.tabs[this.activeTab].Active = true;

        if (this.activeTab === 0) {
            this.isRoute = true;
        
        } else {
            this.isRoute = false;
        }
        this.componentsLoaded();
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