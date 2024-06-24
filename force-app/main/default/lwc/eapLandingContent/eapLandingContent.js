import { LightningElement, wire, track } from 'lwc';

export default class EapLandingContent extends LightningElement {
    pageLoaded = {"Meetings" : false, "Carrousel" : false};

    checkHasLoaded(){
        let hasLoaded = true;
        let componentsLoaded = Object.values(this.pageLoaded);

        if (!componentsLoaded.every(this.checkValue))
            hasLoaded = false;

        if (hasLoaded){
            const loadedEvent = new CustomEvent('loaded', {});
            this.dispatchEvent(loadedEvent);
        }
    }

    checkValue(val) {
        return (val === true);
    }

    meetingLoaded(){
        this.pageLoaded.Meetings = true;
        this.checkHasLoaded();
    }

    carrouselLoaded(){
        this.pageLoaded.Carrousel = true;
        this.checkHasLoaded();
    }

    needToLoad(){
        const loadedEvent = new CustomEvent('reload', {});
        this.dispatchEvent(loadedEvent);
    }
}