import { api, LightningElement } from 'lwc';

export default class CmnSpacer extends LightningElement {
    @api height;
    style = '';

    connectedCallback(){
        this.style = 'height:' + this.height + ';';
    }
}