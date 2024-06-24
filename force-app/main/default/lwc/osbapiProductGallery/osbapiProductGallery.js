import { LightningElement, api, wire } from 'lwc';
import { MessageContext, subscribe } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/osbMenuEvents__c';


export default class OsbApiGallerylwc extends LightningElement {
    recordList;
    productsToDisplay = [];
    searchResults = [];
    noSearchResults = false;
    recordDisplay = true;
    productCategories = [];
    subscription = null;

    @wire(MessageContext)
    messageContext

    @api
    initializeComponent(recordList) {
        this.recordList = recordList;
        this.displayRecords(recordList);
    }

    @api
    handleFilter(categoryRecieved) {
        this.productCategories = categoryRecieved;
        this.searchForRecord();
    }

    handleSubscribe(){
        if (this.subscription) return;
        this.subscription = subscribe(this.messageContext, messageChannel, (message) => {
            if (message.ComponentName === 'Product Search Bar') {
                this.searchForRecord(message.Details.SearchInput);
            }
        });
    }

    searchForRecord(searchInput) {
        let recordList = this.recordList;
        let recordsToDisplay = recordList;
        if (this.productCategories.length > 0) {
            recordsToDisplay = this.filterByCategory(recordList);
        }
        if (searchInput && searchInput.length > 0) {
            this.searchResults = [];
            this.searchResults = this.handleSearch(
                recordsToDisplay,
                searchInput
            );
            recordsToDisplay = this.searchResults;
        }
        this.productsToDisplay = recordsToDisplay;
        if (recordsToDisplay.length > 0) {
            this.displayRecords(recordsToDisplay);
        }
    }

    filterByCategory(records) {
        let filteredArr = this.filterArray(records, this.productCategories);
        return filteredArr;
    }

    handleSearch(arr, searchInput) {
        let searchResult = [];
        arr.forEach((record) => {
            if (record.Name.toLowerCase().includes(searchInput.toLowerCase())) {
                searchResult.push(record);
            }
        });
        this.noSearchResults = searchResult.length <= 0;
        this.recordDisplay = searchResult.length > 0;
        return searchResult;
    }

    filterArray(arr1, arr2) {
        let results = [];
        arr1.forEach((item) => {
            for (let i = 0; i < arr2.length; i++) {
                if (item.Category === arr2[i]) {
                    results.push(item);
                }
            }
        });
        return results;
    }

    displayRecords(recordsToDisplay) {
        this.noSearchResults = false;
        this.recordDisplay = true;
        if (
            this.template.querySelector('c-osbapi-product-catalogue-pagination')
        ) {
            this.template
                .querySelector('c-osbapi-product-catalogue-pagination')
                .handleChanges(recordsToDisplay, true);
        }
    }

    connectedCallback() {
        this.handleSubscribe();
    }
}