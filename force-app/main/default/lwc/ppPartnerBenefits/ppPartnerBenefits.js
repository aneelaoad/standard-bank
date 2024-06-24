/**
* @description  : Partner Portal Partner Home Page Benefit Component
* User Story : SFP-4962
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date June 2021
*/
import { api, LightningElement } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';

export default class PpPartnerBenefits extends LightningElement {

    @api
    mainheading;
    @api
    headingOne;
    @api
    headingTwo;
    @api
    headingThree;
    @api
    headingFour;
    @api
    textOne;
    @api
    textTwo;
    @api
    textThree;
    @api
    textFour;
    @api
    iconOne;
    @api
    iconTwo;
    @api
    iconThree;
    @api
    iconFour;
    shieldIcon;

    connectedCallback() {
        this.iconOne = Assets + '/Icons'+this.iconOne;
        this.iconTwo = Assets + '/Icons'+this.iconTwo;
        this.iconThree = Assets + '/Icons'+this.iconThree;
        this.iconFour = Assets + '/Icons'+this.iconFour;
        this.shieldIcon = Assets + '/Icons/shield.png';
    }
}