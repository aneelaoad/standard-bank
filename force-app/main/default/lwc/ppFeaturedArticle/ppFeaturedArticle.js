import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getFeaturedArticles from '@salesforce/apex/CMN_KnowledgeArticleListing_CTRL.getFeaturedArticle';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'
export default class PpFeaturedArticle extends NavigationMixin(LightningElement) {

  @api
  heading;
  @api
  numberOfArticles;
  @api
  articleDetailBaseUrl;
  featuredArticles = [];
  connectedCallback() {
    this.loadFeaturedArticles();
    let path = basePath.split('/s')[0];
    if (path === '') {
      this.articleDetailBaseUrl = '/s' + this.articleDetailBaseUrl;
    } else {
      this.articleDetailBaseUrl = path + '/s' + this.articleDetailBaseUrl;
    }
  }

  loadFeaturedArticles() {

    if (this.numberOfArticles == '') {
      this.numberOfArticles = null;
    }

    getFeaturedArticles({ recordLimit: this.numberOfArticles }).then(response => {
      let knArticles = []
      response.forEach(function (KA) {
        let img;
        let recordType;
        if (KA.Image__c) {
          img = KA.Image__c.split('src=')[1].substring(1).replace("\"></img>", '').replaceAll('amp;', '');
        }
        recordType = KA.RecordType.DeveloperName.split('Community_Content_')[1].replace('_', ' ');
        if (recordType == 'Success Stories') {
          recordType = 'Success Story';
        }
        let article = {
          "Id": KA.Id,
          "Title": KA.Title,
          "Summary": KA.Summary,
          "RecordType": recordType,
          "UrlName": KA.UrlName,
          "LastPublishedDate": KA.LastPublishedDate,
          "Image__c": img,
          "Info__c": KA.Info__c
        }
        knArticles.push(article);
      });
      this.featuredArticles = knArticles;
    }).catch(error => {
      this.toast('Server Error', 'error');
    });
  }

  handleArticleClick(event) {
    this.tracker(event);
    let articleid = event.target.dataset.id;
    this.navigateToArticle(articleid)
  }

  navigateToArticle(articleid) {
    this[NavigationMixin.Navigate]({
      "type": "standard__webPage",
      "attributes": {
        "url": this.articleDetailBaseUrl + '/' + articleid
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