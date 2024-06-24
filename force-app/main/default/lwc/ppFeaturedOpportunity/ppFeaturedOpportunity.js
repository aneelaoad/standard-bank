import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getSingleFeaturedOpportunity from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.getSingleFeaturedOpportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class PpFeaturedOpportunity extends NavigationMixin(LightningElement) {

  @api
  heading;
  @api
  text;
  @api
  opportunityDetailBaseUrl;
  featuredOppty = { 'sobjectType': 'PP_PartnershipOpportunity__c' };
  featuredImg;

  connectedCallback() {
    this.getFeaturedArticle();
    let path = basePath.split('/s')[0];
    if (path === '') {
      this.opportunityDetailBaseUrl = '/s' + this.opportunityDetailBaseUrl;
    } else {
      this.opportunityDetailBaseUrl = path + '/s' + this.opportunityDetailBaseUrl;
    }
  }

  getFeaturedArticle() {
    getSingleFeaturedOpportunity().then(response => {
      this.featuredOppty = response;
      this.featuredImg = response.PP_Image__c.split('src=')[1].substring(1).replace("\"></img>", '').split('" alt')[0].replaceAll('amp;', '');
    });
  }

  handleOpportunityClick(event) {
    this.tracker(event);
    let opptyId = event.target.dataset.id;
    this.navigateToOpportunity(opptyId)
  }

  navigateToOpportunity(opptyId) {

    this[NavigationMixin.Navigate]({

      "type": "standard__webPage",
      "attributes": {
        "url": this.opportunityDetailBaseUrl + '/' + opptyId
      }
    });

  }

  toast(title, toastVariant) {
    const toastEvent = new ShowToastEvent({
      title,
      variant: toastVariant
    })
    this.dispatchEvent(toastEvent)
  }

  tracker(event) {
    trackLink(event);
  }
}