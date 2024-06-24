import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import getArticles from '@salesforce/apex/CMN_KnowledgeArticleListing_CTRL.getArticles';
import templateOne from './templateOne.html';
import templateTwo from './templateTwo.html';
import templateThree from './templateThree.html';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class CmnKnowledgeArticleListing extends NavigationMixin(LightningElement) {

  @api
  numberOfArticles;
  @api
  articleType;
  @api
  showViewAll;
  @api
  template = 'Box';
  @api
  heading;
  @api
  subHeading
  @api
  text;
  @api
  articleDetailBaseUrl;
  thumbnail;
  viewAllUrl;


  @api
  similarStories;
  viewIcon;
  @track
  articles = [];
  selectedStory
  urlName;

  render() {
    let temp;
    if (this.template === 'Box') {
      temp = templateOne;
    } else if (this.template === 'Accordion') {
      temp = templateTwo;
    } else if (this.template === 'Wide Box') {
      temp = templateThree;
    }
    return temp;
  }

  connectedCallback() {

    this.loadArticles();
    this.viewIcon = Assets + '/Icons/flechita@3x.png';
    let path = basePath.split('/s')[0];
    if (path === '') {
      this.articleDetailBaseUrl = '/s' + this.articleDetailBaseUrl;
      this.viewAllUrl = '/s/success-stories';
    } else {
      this.articleDetailBaseUrl = path + '/s' + this.articleDetailBaseUrl;
      this.viewAllUrl = path + '/s/success-stories'
    }
  }

  loadArticles() {
    if (this.numberOfArticles == '') {
      this.numberOfArticles = null;
    }
    getArticles({ articleType: this.articleType, recordLimit: this.numberOfArticles }).then(response => {
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
          "Info__c": KA.Info__c,
          "dataText": 'success stories | ' + KA.Title + ' | view link click'
        }
        knArticles.push(article);
      });
      this.articles = knArticles;
    });

  }

  handleArticleClick(event) {
    this.tracker(event);
    let artilceIndex = event.target.dataset.id;
    this.selectedArticle = this.articles[artilceIndex];
    this.urlName = this.selectedArticle.UrlName;
    this.navigateToArticle(this.urlName)
  }

  navigateToArticle(url) {
    this[NavigationMixin.Navigate]({
      "type": "standard__webPage",
      "attributes": {
        "url": this.articleDetailBaseUrl + '/' + url
      }
    });
  }

  tracker(event) {
    trackLink(event);
  }

}