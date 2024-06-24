import { LightningElement } from 'lwc';

export default class OsbManageCookies extends LightningElement {
    handleManageCookies(event){
        if(event.currentTarget.name === 'Manage Cookies'){
            this.dispatchEvent(new CustomEvent(
                'showCookieOneTrustManager',
                { bubbles: true, composed : true }
            ));
        }
    }
}