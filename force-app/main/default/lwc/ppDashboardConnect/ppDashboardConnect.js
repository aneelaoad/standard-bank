import { api, LightningElement } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class PpDashboardConnect extends LightningElement {
    @api
    heading;
    @api
    textOne;
    @api
    textTwo;
    @api
    link;
    @api
    linkUrl;
    img;
    connectedCallback() {
        this.img = Assets + '/images/connect-db-img.png';
        let path = basePath.split('/s')[0];
        if (path === '') {
            this.linkUrl = '/s' + this.linkUrl;
        } else {
            this.linkUrl = path + '/s' + this.linkUrl;
        }
    }

    tracker(event) {
        trackLink(event);
    }
}