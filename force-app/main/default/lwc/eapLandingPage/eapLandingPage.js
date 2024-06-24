import { LightningElement, track } from 'lwc';

export default class EapLandingPage extends LightningElement {
    @track loading = true;

    hasLoaded(){
        this.loading = false;
        this.template.querySelector(".content").style.visibility = "visible";
    }

    needToLoad(){
        this.loading = true;
        this.template.querySelector(".content").style.visibility = "hidden";
    }
}