import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getBankerConversations from '@salesforce/apex/PBB_Smart2Refresher.getBankerConversations';
import getConversationsByRiskGroup from '@salesforce/apex/PBB_Smart2Refresher.getConversationsByRiskGroup';

const columns = [
    { label: 'Client Name', fieldName: 'recordLink', type: 'url', typeAttributes: { label: { fieldName: 'clientName'}}},
    { label: 'Conversation Category', fieldName: 'category'},
    { label: 'Conversation Body', fieldName: 'conversationDetail'},
    {
        type: 'button', initialWidth: 88,
        typeAttributes: { name: 'view', variant: 'Neutral', label: 'View', title: 'View' }
    },
];

export default class cmn_comp_bankerConversations extends LightningElement {
    @api recordId;
    @api isEcosystem = false;
    @api riskGroup;
    columns = columns;
    rows = [];
    displayRows = [];
    conversationCategories;
    selectedRmAeCode;
    timeoutId;
    selectedCategory;
    showSpinner = false;
    // modals
    viewedConversation;
    showConversationDetailsModal = false;

    
    connectedCallback() {
        if(this.isEcosystem){
            this.retrieveDataByGroup();
        }
    }

    processResults(result){
            let conversations = [];
            let categoriesSet = new Set();
            for (var i = 0; i < result.length; i++) {
                var conversation = {};
                conversation.clientName = result[i].Client__r ? result[i].Client__r.Name : '';
                conversation.recordLink = '/lightning/r/Account/' +  result[i].Client__c + '/view';
                conversation.category = result[i].Category__c;
                conversation.conversationDetail = result[i].Description__c;
                conversations.push(conversation);
                categoriesSet.add(result[i].Category__c);
            }
            this.rows = conversations;
            this.displayRows = conversations;
            // prepare categories filter
            let categoriesList = Array.from(categoriesSet);
            this.conversationCategories = [];
            this.conversationCategories.push({ 'value' : null,'label': '- none -' });
            this.selectedCategory = null;
            for (var i = 0; i < categoriesList.length; i++) {
                this.conversationCategories.push({ 'value' : categoriesList[i],'label': categoriesList[i] });
            }
    }
    retrieveDataByGroup(){
        this.showSpinner = true;
        this.rows = [];
        this.displayRows = [];
        // retrieve data
        getConversationsByRiskGroup({riskGroup: this.riskGroup})
        .then(result => {
            // create an array here and set field names. Doesn't work to use Account__r.Name - doesn't like the dot
            this.processResults(result);
        })
        .catch(error => {
            const toastEvent = new ShowToastEvent({
                variant: 'error',
                message: error,
            });
            this.dispatchEvent(toastEvent);
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }
    retrieveData() {
        this.showSpinner = true;
        this.rows = [];
        this.displayRows = [];
        // retrieve data
        getBankerConversations({rmAeCode: this.selectedRmAeCode })
        .then(result => {
            // create an array here and set field names. Doesn't work to use Account__r.Name - doesn't like the dot
            this.processResults(result);
        })
        .catch(error => {
            const toastEvent = new ShowToastEvent({
                variant: 'error',
                message: error,
            });
            this.dispatchEvent(toastEvent);
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }
    
    handleRmAeCodeChange(event) {
        this.selectedRmAeCode = event.target.value;
        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(this.retrieveData.bind(this), 500);
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        if (this.selectedCategory) {
            this.displayRows = [];
            for (let i = 0; i < this.rows.length; i++) {
                if (this.rows[i].category == this.selectedCategory) {
                    this.displayRows.push(this.rows[i]);
                }
            }
        }
        else {
            this.displayRows = this.rows;
        }
    }

    handleRowAction(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
        switch (actionName) {
            case 'view':
                this.viewedConversation = row;
                this.showConversationDetailsModal = true;
                break;
            default:
        }
    }

    closeConversationDetails(event) {
        this.showConversationDetailsModal = false;
        this.viewedConversation = null;
    }
}