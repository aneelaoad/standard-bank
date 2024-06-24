import { api, LightningElement } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';


export default class PpSidebarComponent extends LightningElement {
    
    @api
    icon;
    @api
    backgroundImg;
    @api
    headingOne;
    @api
    headingTwo;
    @api
    textOne;
    @api
    textTwo;
    @api
    textThree;
    @api
    textFour


    connectedCallback() {
        this.icon = Assets + '/Icons' + this.icon;
        this.backgroundImg = Assets + '/images' + this.backgroundImg;
    }
}