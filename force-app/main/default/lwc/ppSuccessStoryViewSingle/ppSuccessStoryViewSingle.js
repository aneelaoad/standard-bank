import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

const FIELDS = [
    'Knowledge__kav.Title',
    'Knowledge__kav.Summary',
    'Knowledge__kav.Info__c',
    'Knowledge__kav.Image__c',
    'Knowledge__kav.LastPublishedDate',
];

export default class PpSuccessStoryDetail extends LightningElement {

    @api
    recordId;
    @api
    storyDetail;
    @api
    breadcrumbOneUrl;
    @api
    breadcrumbTwoUrl;
    article;
    title;
    summary;
    info;
    recordType;
    lastPublishedDate;
    breadcrumbArrowIcon;
    bannerImg;


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    articleRecord({ error, data }) {

        if (error) {
            alert('error');
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Article',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.article = data;
            this.title = this.article.fields.Title.value;
            this.summary = this.article.fields.Summary.value;
            this.info = this.article.fields.Info__c.value;
            this.bannerImg = this.article.fields.Image__c.value;
            this.lastPublishedDate = this.article.fields.LastPublishedDate.value;
            this.recordType = this.article.recordTypeInfo.name.split("-")[1];
            this.bannerImg = this.bannerImg.split('src=')[1].substring(1).replace("\"></img>", '').replaceAll('amp;', '');

            //Adobe Analytics Event
            document.dispatchEvent(new CustomEvent('triggerInteraction', {
                'detail': {
                    eventName: 'globalVirtualPageView',
                    articleCategory: this.recordType,
                    articleName: this.title,
                    pageName: this.recordType + ":" + this.title,
                    pageSubSection1: this.recordType,
                    pageSubSection2: this.recordType + ":" + this.title,
                    loginStatus: "guest",
                    userLoginSuccess: "false",
                    userRegistrationSuccess: "false"
                }
            }));
        }
    }


    connectedCallback() {
        this.breadcrumbArrowIcon = Assets + '/Icons/flechitaBreadcrumb.png';
        let path = basePath.split('/s')[0];
        if (path === '') {
            this.breadcrumbOneUrl = '/s' + this.breadcrumbOneUrl;
            this.breadcrumbTwoUrl = '/s' + this.breadcrumbTwoUrl;
        } else {
            this.breadcrumbOneUrl = path + '/s' + this.breadcrumbOneUrl;
            this.breadcrumbTwoUrl = path + '/s' + this.breadcrumbTwoUrl;
        }
    }

    tracker(event) {
        trackLink(event);
      }    
}