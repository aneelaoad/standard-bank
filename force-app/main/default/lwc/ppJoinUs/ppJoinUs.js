/**
* @description  : Partner Portal Join Us Component
* User Story : SFP-4962
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date June 2021
*/
import { LightningElement, api } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class PpJoinUs extends LightningElement {

    @api imagePath;
    @api content;
    @api linkLabel;
    @api title;
    @api title2;
    @api link;
    bannerImageLink;

    connectedCallback() {
        this.bannerImageLink = Assets + '/images' + this.imagePath;
        let path = basePath.split('/s')[0];
		if (path === '') {
			this.link = '/s' + this.link;
		} 
        else {
			this.link = path + '/s' + this.link;
		}
    } 
    
    tracker(event) {
        trackLink(event);
    }
}