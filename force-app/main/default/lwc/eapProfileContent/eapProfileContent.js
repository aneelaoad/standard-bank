import { LightningElement, track, api } from 'lwc';

import OVERVIEW_LABEL from '@salesforce/label/c.Eap_Overview_Label';
import CURRENT_PAGE_LABEL from '@salesforce/label/c.Eap_CurrentPage_Label';
import CONTACT_US_LABEL from '@salesforce/label/c.Eap_ContactUs_Label';
import TERMS_CONDITIONS_LABEL from '@salesforce/label/c.Eap_TermsConditions_Label';

export default class EapProfileContent extends LightningElement {
    labels = {CurrentPage: CURRENT_PAGE_LABEL, Overview: OVERVIEW_LABEL, ContactUs: CONTACT_US_LABEL, TermsConditions: TERMS_CONDITIONS_LABEL};
    activeTab = 0;
    viewProfileOverview = true;
    viewProfileContactUs = false;
    viewTermsConditions = false;

    @track tabs = [{ Id: 1, Name: this.labels.Overview, Active: true },
                { Id: 2, Name: this.labels.ContactUs, Active: false },
                { Id: 3, Name: this.labels.TermsConditions, Active: false }]

    @track _viewPage;
    @api 
    get viewPage(){
        return this._viewPage;
    }
    set viewPage(value) {
        this.setAttribute('v', value);
        this._viewPage = value;

        if (this._viewPage !== 0) {
            this.tabs[0].Active = false;
            this.activeTab = this._viewPage;
            this.changeTemplate();
        }
    }

    /* This method will change the current tab and the visual references (color and underline on tab name) */
    handleOnClick(event) {
        let id = event.currentTarget.id[0];

        if (this.activeTab !== id-1) {
            this.tabs[this.activeTab].Active = false;

            this.activeTab = id-1;
            this.changeTemplate();
        }
    }

    changeTemplate(){
        const loadedEvent = new CustomEvent('reload', {});

        this.tabs[this.activeTab].Active = true;
        this.viewProfileContactUs = false;
        this.viewProfileOverview = false;
        this.viewTermsConditions = false;

        switch(this.tabs[this.activeTab].Name)
        {
            case this.labels.Overview:
                this.dispatchEvent(loadedEvent);
                this.viewProfileOverview = true;
            break;
            case this.labels.ContactUs:
                this.dispatchEvent(new CustomEvent('loaded', {}));
                this.viewProfileContactUs = true;
            break;
            case this.labels.TermsConditions:
                this.dispatchEvent(loadedEvent);
                this.viewTermsConditions = true;
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