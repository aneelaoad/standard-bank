/**
* @description  : OneHub - Knowledge Tab related component
* User Story : SFP-7228
*
* @author Sharath Chandra (sharath.chintalapati@standardbank.co.za)
* @date October 2021
*/
import { LightningElement, wire, track } from 'lwc';
import getArticles from '@salesforce/apex/CB_GM_KnowledgeController.getArticles';

const DELAY = 500;
const columns = [  
    { 
        label: 'Article', 
        fieldName: 'ArticleURL', 
        type: 'url', 
        sortable: true, 
        fixedWidth: 100,
        typeAttributes: {
            label: {
                fieldName: 'ArticleNumber'
            }
        },
        cellAttributes: { alignment: 'left' } 
    },
    { label: 'Title', fieldName: 'Title', type: 'text', fixedWidth: 270,  wrapText: true },
    { label: 'Information', fieldName: 'Info__c', type: 'richText', wrapText: true, clipText: true },
    { 
        label: 'Article Type', 
        fieldName: 'RecordTypeName',
        type: 'text',
        fixedWidth: 220, 
        typeAttributes: {
            label: {
                fieldName: 'RecordType'
            }
        } 
     }
];

export default class CbKnowledgePage extends LightningElement {
    rowOffset=0;
    lstColumns=columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @track articleList=[];
    @track articleName='';

    @wire(getArticles, { searchKey:'$articleName', articleType:'' })
    retrieveArticles({ error, data }) {
        if (data) {
            let newArray = [];
            this.articleList  = JSON.parse(JSON.stringify(data));
            this.articleList.forEach(tracking => {
                let newTracking = {};
                newTracking.ArticleNumber = tracking.ArticleNumber;
                newTracking.ArticleURL = '/detail/' +tracking['Id'];
                newTracking.Title = tracking.Title;
                newTracking.Info__c = tracking.Info__c;
                newTracking.RecordTypeName = tracking.RecordType.Name;
                newArray.push(newTracking);
            });
            this.articleList = newArray;
        }
    }

    filterFAQs(){
        getArticles({ searchKey:this.articleName, articleType:'FAQ' })
        .then(result => {
            this.message = result;
            this.error = undefined;
            if (this.message !== undefined) {
                let newArray = [];
                this.articleList  = JSON.parse(JSON.stringify(result));
                this.articleList.forEach(tracking => {
                    let newTracking = {};
                    newTracking.ArticleNumber = tracking.ArticleNumber;
                    newTracking.ArticleURL = '/detail/' +tracking['Id'];
                    newTracking.Title = tracking.Title;
                    newTracking.Info__c = tracking.Info__c;
                    newTracking.RecordTypeName = tracking.RecordType.Name;
                    newArray.push(newTracking);
                });
                this.articleList = newArray;
            }
        })
        .catch(error => {
            this.errorMsg = error.message;
        });
    }

    filterHowTos(){
        getArticles({ searchKey:this.articleName, articleType:'How to Guides' })
        .then(result => {
            this.message = result;
            this.error = undefined;
            if (this.message !== undefined) {
                let newArray = [];
                this.articleList  = JSON.parse(JSON.stringify(result));
                this.articleList.forEach(tracking => {
                    let newTracking = {};
                    newTracking.ArticleNumber = tracking.ArticleNumber;
                    newTracking.ArticleURL = '/detail/' +tracking['Id'];
                    newTracking.Title = tracking.Title;
                    newTracking.Info__c = tracking.Info__c;
                    newTracking.RecordTypeName = tracking.RecordType.Name;
                    newArray.push(newTracking);
                });
                this.articleList = newArray;
            }
        })
        .catch(error => {
            this.errorMsg = error.message;
        });
    }

    filterProdInfo(){
        getArticles({ searchKey:this.articleName, articleType:'Product Info' })
        .then(result => {
            this.message = result;
            this.error = undefined;
            if (this.message !== undefined) {
                let newArray = [];
                this.articleList  = JSON.parse(JSON.stringify(result));
                this.articleList.forEach(tracking => {
                    let newTracking = {};
                    newTracking.ArticleNumber = tracking.ArticleNumber;
                    newTracking.ArticleURL = '/detail/' +tracking['Id'];
                    newTracking.Title = tracking.Title;
                    newTracking.Info__c = tracking.Info__c;
                    newTracking.PublishStatus = tracking.PublishStatus;
                    newTracking.RecordTypeName = tracking.RecordType.Name;
                    newArray.push(newTracking);
                });
                this.articleList = newArray;
            }
        })
        .catch(error => {
            this.errorMsg = error.message;
        });
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        let cloneData  = JSON.parse(JSON.stringify(this.articleList));
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.articleList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleKeyChange(event) {
        const searchString = event.target.value;
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.articleName = searchString;
        }, DELAY);
    }
}