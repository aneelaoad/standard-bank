import { LightningElement } from 'lwc';

export default class MallManageCookies extends LightningElement {

    handleManageCookies(event){
        this.dispatchEvent(new CustomEvent(
            'showCookieOneTrustManager',
            { bubbles: true, composed : true }
        ));
    }
}