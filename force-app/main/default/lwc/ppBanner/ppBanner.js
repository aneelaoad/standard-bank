/**
* @description  : Partner Portal Home Page Banner Component
* User Story : SFP-4962
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date June 2021
*/
import { LightningElement, api } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'


export default class PpBanner extends LightningElement {

	@api imagePath;
	@api content;
	@api linkLabel;
	@api title;
	@api link;
	bannerImageLink;

	connectedCallback() {

		this.bannerImageLink = Assets + '/banners' + this.imagePath;
		let path = basePath.split('/s')[0];
		if (path === '') {
			this.link = '/s' + this.link;
		} else {
			this.link = path + '/s' + this.link;
		}

		document.dispatchEvent(new CustomEvent('triggerInteraction', {
			'detail': {
				eventName: 'globalVirtualPageView',
				pageName: "Home",
				loginStatus: "guest",
				userLoginSuccess: "false",
				userRegistrationSuccess: "false",
				pageSubSection1: "Home"
			}
		}));

	}

	tracker(event) {
        trackLink(event);
    }
}