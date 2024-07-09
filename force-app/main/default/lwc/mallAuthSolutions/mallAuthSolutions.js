import { LightningElement, wire } from 'lwc';
import getMySolutions from '@salesforce/apex/CTRL_MallAuthSolutions.getMySolutions';



export default class MallAuthSolutions extends LightningElement {

    mySolutions;
    error;    

    @wire(getMySolutions)
    wiredMySolutions({ error, data }) {
        if (data) {
            this.mySolutions = data;
            console.log('@@Solutions:', this.mySolutions);
        } else if (error) {
            console.error('@@Error:',error);
        }
    }
    

    handleRedirectionAction(event){
        const redirectUrl = event.detail.redirectUrl;
        if(redirectUrl!=''){
            console.log('RedirectURL:', redirectUrl);
            window.location.href = redirectUrl;

        }else{

            console.log('RedirectURL is empty');
        }
        
    }
}