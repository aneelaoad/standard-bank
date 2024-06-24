import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class EapEventDetailContent extends NavigationMixin(LightningElement) {
    @track eventId;
    pageLoaded = {"Description" : false, "Meetings" : false, "Buttons": false};

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

    adaptHeight() {
        let description = this.template.querySelector('c-eap-event-detail-description');
        //let meetings = this.privateChild('c-eap-event-detail-meetings');
        let buttons = this.template.querySelector('c-eap-event-detail-buttons');
        let descriptionHeight = description.getBoundingClientRect().height;
        let meetingsHeight = 190;
        let footerHeight = 50;
        let buttonsHeight = buttons.getBoundingClientRect().height;
        let viewportHeight = window.innerHeight;

        let filler = this.template.querySelector('[class="relleno"]');
        let fillerHeight = viewportHeight - (buttonsHeight + meetingsHeight + descriptionHeight + footerHeight);
        filler.style.height = fillerHeight + "px";
    }

    checkHasLoaded(){
        let hasLoaded = true;
        let componentsLoaded = Object.values(this.pageLoaded);

        if (!componentsLoaded.every(this.checkValue))
            hasLoaded = false;

        if (hasLoaded){
            this.adaptHeight();
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        }
    }

    checkValue(val) {
        return (val === true);
    }

    descriptionLoaded(){
        this.pageLoaded.Description = true;
        this.checkHasLoaded();
    }

    meetingsLoaded(){
        this.pageLoaded.Meetings = true;
        this.checkHasLoaded();
    }

    buttonsLoaded(){
        this.pageLoaded.Buttons = true;
        this.checkHasLoaded();
    }

    needToLoad(){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);
    }
}