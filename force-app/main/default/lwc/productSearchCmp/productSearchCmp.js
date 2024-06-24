import { LightningElement, api, wire } from 'lwc';
import getProductList from '@salesforce/apex/SearchProductController.getProductList';
import saveSbProductList from '@salesforce/apex/SearchProductController.saveSbProductList';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import OPPORTUNITY_ACCOUNTID_FIELD from '@salesforce/schema/Opportunity.AccountId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const COLUMNS = [
    { label: 'Name', fieldName: 'Name',wrapText: true },
    { label: 'Grand Parent Product', fieldName: 'Grand_Parent_Product__c',wrapText: true },
    { label: 'Parent Product', fieldName: 'Parent_Product__c',wrapText: true },
    { label: 'Product Division', fieldName: 'Product_Division__c',wrapText: true }
];
 
export default class customSearch extends LightningElement {
    data       =[];
    filterData =[];
    columns    =COLUMNS;
    searchValue;
    clientId;
    productRecord;
    @api recordId;    
    spinner = true;
    constructor() {
        super();
     
        document.addEventListener("lwc://refreshView", () => {
            this.showToast('Success', 'Product\'s are created!', 'success');
            this.dispatchEvent(new CloseActionScreenEvent());
        });
      }
    @wire(getRecord, { recordId: '$recordId', fields: [OPPORTUNITY_ACCOUNTID_FIELD] }) oppRecord;
    
    get accountId() {
        return getFieldValue(this.oppRecord.data, OPPORTUNITY_ACCOUNTID_FIELD);
    }

    handleFormInputChange(event) {
        this.searchValue = event.target.value;
    }

    search() {
        this.spinner = true;
        if (this.searchValue || this.searchValue !== '') {
            try{
                this.filterData = this.data.filter(list => {
                    const exp = new RegExp(this.searchValue, 'i'); 
                    return (
                        exp.test(list.Name) || 
                        exp.test(list.Grand_Parent_Product__c) ||
                        exp.test(list.Parent_Product__c) ||
                        exp.test(list.Product_Division__c)
                    );
                });
            } catch (error) {
                this.showToast('Error', error.body.message, 'error');
                this.spinner = false;   
            }
        }
        this.spinner = false;   
    }

    enterHandle(event) {  
        if (event.keyCode === 13) {
            this.search();
        }
    }        

    connectedCallback() {          
        getProductList({})
            .then(result => {
                // set @track contacts variable with return contact list from server  
                this.data = result;
                this.spinner = false;
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });       
    }
    saveSbProducts() {
        //if none selected then throw toast error message            
        let selectedRecords = this.template.querySelector("lightning-datatable")?.getSelectedRows();
        if (selectedRecords && selectedRecords.length > 0) {
            this.spinner = true;
            saveSbProductList({ products: selectedRecords, oppId :this.recordId, clientId : this.accountId })
                .then((result) => {  
                    if (result.startsWith("error")) {                    
                        this.showToast('Error', result, 'error');
                        this.spinner = false;
                    } else if (result === 'success') {
                        document.dispatchEvent(new CustomEvent("aura://refreshView"));
                       
                    }                               
                })
                .catch((error) => {
                    this.error = error;
                    this.showToast('Error', error.body.message, 'error');
                });
        } else {
            this.showToast('Error', 'Please, select at least one product!', 'error');   
        }
    }
      
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(event);
    }
}