import { api, LightningElement, track } from 'lwc';
import CURRENT_PAGE_LABEL from '@salesforce/label/c.Eap_CurrentPage_Label';
import OVERVIEW_LABEL from '@salesforce/label/c.Eap_Overview_Label';
import INFORMATION_LABEL from '@salesforce/label/c.Eap_Information_Label';

export default class EapArchiveDetailContent extends LightningElement {
    labels = {CurrentPage: CURRENT_PAGE_LABEL, Overview: OVERVIEW_LABEL, Information: INFORMATION_LABEL};
    activeTab = 0;
    @track isOverview = true;
    @track tabs = [{ Id: 1, Name: this.labels.Overview, Active: true },
                    { Id: 2, Name: this.labels.Information, Active: false }]
    @api eventName;
    @track _eventId;

    @api 
    get eventId(){
        return this._eventId;
    }
    set eventId(value) {
        this.setAttribute('v', value);
        this._eventId = value;
    }

    handleEventNameChange(){
        this.eventName = this.template.querySelector('c-eap-archive-detail-overview').eventName;
        const selectedEvent = new CustomEvent('eventnamechange', {});
        this.dispatchEvent(selectedEvent);
    }

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
        this.isOverview = !this.isOverview;
    }

    componentsLoaded(){
        const loadedEvent = new CustomEvent('loaded', {});
        this.dispatchEvent(loadedEvent);
    }

    /* Swipe to the left / right */
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