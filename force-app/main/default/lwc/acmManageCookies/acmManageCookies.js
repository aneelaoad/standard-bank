import { LightningElement } from 'lwc';

export default class AcmManageCookies extends LightningElement {
    handleManageCookies(event){
        console.log('::--->::',event.currentTarget.name);
        if(event.currentTarget.name === 'Manage Cookies'){
            this.dispatchEvent(new CustomEvent(
                'showOneTrustManager',
                { bubbles: true, composed : true }
            ));
        }
    }
}