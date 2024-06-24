import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllPublishPartnerships from '@salesforce/apex/PP_Partnership_Opportunities_CTRL.getAllPublishPartnerships';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class PpOpportunities extends NavigationMixin(LightningElement) {

  @api
  opportunityDetailBaseUrl;
  opportunities = [];
  selectedOpportunity;
  icon;

  connectedCallback() {
    this.icon = Assets + '/Icons/cube-icon.png';
    let path = basePath.split('/s')[0];
    if (path === '') {
      this.opportunityDetailBaseUrl = '/s' + this.opportunityDetailBaseUrl;
    } else {
      this.opportunityDetailBaseUrl = path + '/s' + this.opportunityDetailBaseUrl;
    }
    this.getOpportunities();
  }

  getOpportunities() {
    getAllPublishPartnerships().then(response => {
      this.opportunities = response;
    }).catch(error => {
      this.toast('Server Error', 'error');
    });
  }

  handleOpportunityClick(event) {
    this.tracker(event);
    let storyIndex = event.target.dataset.id;
    this.selectedOpportunity = this.opportunities[storyIndex];
    let opptyId = this.selectedOpportunity.Id;
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