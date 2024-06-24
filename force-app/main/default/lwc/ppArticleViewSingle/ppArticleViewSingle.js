import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import { getRecord } from 'lightning/uiRecordApi';
import Assets from '@salesforce/resourceUrl/PP_Assets';


const FIELDS = [
    'Knowledge__kav.Title',
    'Knowledge__kav.Summary',
    'Knowledge__kav.Info__c',
    'Knowledge__kav.Image__c',
    'Knowledge__kav.LastPublishedDate',
];


export default class PpArticleViewSingle extends NavigationMixin(LightningElement) {
    @api
    recordId;
    title;
    summary;
    info;
    lastPublishedDate;
    articleImg;
    articleType;

    connectedCallback() {
        this.backIcon = Assets + '/Icons/backIcon.png';
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    articleRecord({ error, data }) {
           if (data) {
            this.title = data.fields.Title.value;
            this.summary = data.fields.Summary.value;
            this.info = data.fields.Info__c.value;
            this.articleImg = data.fields.Image__c.value;
            this.lastPublishedDate = data.fields.LastPublishedDate.value;
            this.articleType = data.recordTypeInfo.name.split('-')[1];

              //Adobe Analytics Event
              document.dispatchEvent(new CustomEvent('triggerInteraction', {
                'detail': {
                    eventName: 'globalVirtualPageView',
                    articleCategory: this.articleType,
                    articleName: this.title,
                    pageName: this.articleType + ":" + this.title,
                    pageSubSection1: this.articleType,
                    pageSubSection2: this.articleType + ":" + this.title,
                    loginStatus: "guest",
                    userLoginSuccess: "false",
                    userRegistrationSuccess: "false"
                }
            }));
        }
    }

    navigateToCommunity() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'community__c'
            }
        });
    }
}