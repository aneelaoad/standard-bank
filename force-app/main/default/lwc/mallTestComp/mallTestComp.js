import { LightningElement } from 'lwc';
import getMyToken from '@salesforce/apex/CTRL_MALL_TestController.getMyToken';

export default class MallTestComp extends LightningElement {
    
    connectedCallback() {
        this.fetchMyToken();
    }

    async fetchMyToken() {
        try {
            let token = await getMyToken();
            console.log(token);
        } catch (error) {
            this.error = error;
        }
    }
}