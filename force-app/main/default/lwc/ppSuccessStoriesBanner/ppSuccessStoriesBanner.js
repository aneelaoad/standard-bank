/**
* @description  : Partner Portal All Success Stories Page Banner Component
* User Story : SFP-4962
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date June 2021
*/
import { LightningElement } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
export default class PpSuccessStoriesBanner extends LightningElement {

    bannerImg;

    connectedCallback() {
        this.bannerImg = Assets + '/banners/sucessStoriesBanner.png';
    }


}