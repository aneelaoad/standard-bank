import { api,track, LightningElement } from 'lwc';
import verifyRecaptcha from '@salesforce/apex/OSB_Recapture.checkRecapture';

export default class OSBRecapture extends LightningElement {
    @api wiredCase;
    @track wiredConversations;

    connectedCallback() {
        document.addEventListener("grecaptchaVerified", function(e) {
            verifyRecaptcha({
              recaptchaResponse: e.detail.response,
            })
              .then((result) => {
                setTimeout(function(){ 
                    document.dispatchEvent(new Event("grecaptchaReset")); 
                }, 200);  
                this.dispatchEvent(new CustomEvent('checkvalue', {
                  bubbles: true,
                  detail: result
                }));
              })
        });
    } 

    renderedCallback() {
        let divElement = this.template.querySelector('div.recaptchaInvisible');
        let payload = {element: divElement, badge: 'bottomleft'};
        document.dispatchEvent(new CustomEvent("grecaptchaRender", {"detail": payload}));
    }

    @api
    doSubmit(evt){
        document.dispatchEvent(new Event("grecaptchaExecute"));
    }
}