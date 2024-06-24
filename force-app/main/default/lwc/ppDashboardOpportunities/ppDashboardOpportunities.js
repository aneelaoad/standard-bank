import { api, LightningElement } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import getAllPublishPartnerships from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.getAllPublishPartnerships';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class PpDashboardOpportunities extends LightningElement {
  @api
  heading
  @api
  text
  @api
  link;
  @api
  linkUrl;
  arrowIcon;
  opportunities;
  opptyCount;

  connectedCallback() {
    this.arrowIcon = Assets + '/Icons/flechitaBreadcrumb.png';
    let path = basePath.split('/s')[0];
    if (path === '') {
      this.linkUrl = '/s' + this.linkUrl;
    } else {
      this.linkUrl = path + '/s' + this.linkUrl;
    }
    this.getOpportunities();
  }

  getOpportunities() {
    getAllPublishPartnerships().then(response => {
      this.opportunities = response;
      this.opptyCount = response.length;
    });
  }

  tracker(event) {
    trackLink(event);
  }
}