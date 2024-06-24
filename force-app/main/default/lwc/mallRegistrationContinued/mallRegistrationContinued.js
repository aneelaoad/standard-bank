import { LightningElement, api, track } from 'lwc';

export default class MallRegistrationContinued extends LightningElement {
    registrationStage = 0;
    showModal = false;
    urlParams = {};

    browsingContextOptionsValue = [];

    browsingContextOptions = [
        { label: 'For yourself', value: 0 },
        { label: 'For your business', value: 1 }
    ];

    connectedCallback() {
        const paramValue = this.getUrlParamValue(window.location.href, 'state');
        this.handleState(paramValue);
    }

    handleState(state){
        if(state==1){
            this.openCstmModal();
        }
    }
    
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    openCstmModal(){
        this.showModal = true;
    }

    hideCstmModal(){
        this.showModal = false;
        console.log('close');
    }

    handleBrowsingContextChange(){
        console.log(this.browsingContextOptionsValue);
    }

    handleStageForward(){
        this.registrationStage = this.registrationStage + 1;
    }

    handleStageBackward(){
        if(this.registrationStage > 0){
            this.registrationStage = this.registrationStage - 1;
        }  
    }
}