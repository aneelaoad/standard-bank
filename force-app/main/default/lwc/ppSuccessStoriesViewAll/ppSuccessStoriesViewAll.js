/**
* @description  : Partner Portal Home Page Success Stories Component
* User Story : SFP-4963
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
import { LightningElement, track, api } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class AllSuccessStories extends NavigationMixin(LightningElement) {

  breadcrumbArrowIcon;
  bannerImg;
  @api
  mainHeading;
  @api
  subHeading;
  @api
  text;
  @api
  numberOfArticles;
  @api
  articleType;
  @api
  template = 'Box';
  @api
  breadcrumbUrl;
  @api
  articleDetailBaseUrl;

  connectedCallback() {
    this.bannerImg = Assets + '/banners/sucessStoriesBanner.png';
    this.breadcrumbArrowIcon = Assets + '/Icons/flechitaBreadcrumb.png';
    let path = basePath.split('/s')[0];
    if (path === '') {
      this.breadcrumbUrl = '/s' + this.breadcrumbUrl;
    } else {
      this.breadcrumbUrl = path + '/s' + this.breadcrumbUrl;
    }

    document.dispatchEvent(new CustomEvent('triggerInteraction', {
      'detail': {
        eventName: 'globalVirtualPageView',
        pageName: "Success stories",
        pageSubSection1: "success stories",
        loginStatus: "guest",
        userLoginSuccess: "false",
        userRegistrationSuccess: "false"
      }
    }));
  }

  tracker(event) {
    trackLink(event);
  }

}