import { LightningElement, track, api } from 'lwc';
import CURRENT_PAGE_LABEL from '@salesforce/label/c.Eap_CurrentPage_Label';
import OVERVIEW_LABEL from '@salesforce/label/c.Eap_Overview_Label';
import AGENDA_LABEL from '@salesforce/label/c.Eap_Agenda_Label';
import DOCUMENTS_LABEL from '@salesforce/label/c.Eap_Documents_Label';
import NOTES_LABEL from '@salesforce/label/c.Eap_Notes_Label';

export default class EapMeetingInformationContent extends LightningElement {
    labels = {CurrentPage:CURRENT_PAGE_LABEL, Overview: OVERVIEW_LABEL, Agenda: AGENDA_LABEL, Documents:DOCUMENTS_LABEL, Notes: NOTES_LABEL};
    activeTab = 0;
    @track isOverview = true;
    @track isAgenda = false;
    @track isDocuments = false;
    @track isNotes = false;
    @track showNotes = false
    @track tabs = [{ Id: 1, Name: this.labels.Overview, Active: true },
                    { Id: 2, Name: this.labels.Agenda, Active: false },
                    { Id: 3, Name: this.labels.Documents, Active: false },
                    { Id: 4, Name: this.labels.Notes, Active: false }]
    @api meetingName;
    @track _meetingId;

    @api 
    get meetingId(){
        return this._meetingId;
    }
    set meetingId(value) {
        this.setAttribute('v', value);
        this._meetingId = value;
    }

    handleEventNameChange(){
        this.meetingName = this.template.querySelector('c-eap-meeting-information-overview').meetingName;
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

        this.isOverview = false;
        this.isAgenda = false;
        this.isDocuments = false;
        this.isNotes = false;
        this.showNotes = false;

        switch(this.tabs[this.activeTab].Name)
        {
            case this.labels.Overview: this.isOverview = true;
            break;
            case this.labels.Agenda: this.isAgenda = true;
            break;
            case this.labels.Documents: this.isDocuments = true;
            break;
            case this.labels.Notes:
                this.isNotes = true;
                this.showNotes = true;
            break;
        }
    }

    componentsLoaded(){
        const loadedEvent = new CustomEvent('loaded', {});
        this.dispatchEvent(loadedEvent);
    }

    needToLoad(){
        const loadedEvent = new CustomEvent('reload', {});
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