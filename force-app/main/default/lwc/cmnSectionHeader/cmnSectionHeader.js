import { LightningElement, api } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class CmnSectionHeader extends LightningElement {

    @api
    mainHeading;
    @api
    text;
    @api
    breadcrumbText;
    @api
    breadcrumbLink;
    breadcrumbArrowIcon;

    connectedCallback() {

        this.breadcrumbArrowIcon = Assets + '/Icons/flechitaBreadcrumb.png';
        let path = basePath.split('/s')[0];
        if (path === '') {
            this.breadcrumbLink = '/s' + this.breadcrumbLink;
        } else {
            this.breadcrumbLink = path + '/s' + this.breadcrumbLink;
        }
    }

    tracker(event) {
        trackLink(event);
    }
}