import { LightningElement, api, wire, track } from 'lwc';
/* IMPORT UI */
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import modalCSS from "@salesforce/resourceUrl/LWC_Action_Style";
import { loadStyle } from "lightning/platformResourceLoader";
import { CloseActionScreenEvent } from "lightning/actions";


/* IMPORT LABELS */
import error_title from '@salesforce/label/c.case_return_process_error_title';
import no_datas from '@salesforce/label/c.case_return_process_no_datas';
import success_title from '@salesforce/label/c.case_return_process_success_title';
import success_body_save from '@salesforce/label/c.case_return_process_success_body_save';
import success_body_confirm from '@salesforce/label/c.case_return_process_success_body_confirm';
import modal_title from '@salesforce/label/c.case_return_process_table_modal_title';
import table_product_name from '@salesforce/label/c.case_return_process_table_product_name';
import table_sku from '@salesforce/label/c.case_return_process_table_sku';
import table_unit_price from '@salesforce/label/c.case_return_process_table_unit_price';
import table_total_price from '@salesforce/label/c.case_return_process_table_total_price';
import table_requested_quantity from '@salesforce/label/c.case_return_process_table_requested_quantity';
import table_quantity_requested from '@salesforce/label/c.case_return_process_table_quantity_requested';
import table_updated_total_price from '@salesforce/label/c.case_return_process_table_updated_total_price';

/* IMPORT APEX */
import getItemsFromCase from "@salesforce/apex/NAM_CTRL_CaseProcessReturnController.getItemsFromCase";
import updateItems from '@salesforce/apex/NAM_CTRL_CaseProcessReturnController.updateItems';
import confirmItems from '@salesforce/apex/NAM_CTRL_CaseProcessReturnController.confirmItems';

const itemsColumns = [
    { label: table_sku, fieldName: 'SKUId', type: 'url', editable: false,  typeAttributes: {label: { fieldName: 'SKUName' }, target: '_blank'}},
    { label: table_product_name, fieldName: 'productId', type: 'url', editable: false, typeAttributes: {label: { fieldName: 'productName' }, target: '_blank'}},
    { label: 'Status', fieldName: 'Status__c', type: 'text', editable: false},
    { label: table_unit_price, fieldName: 'Atonit_Mktplace__UnitPrice__c', type: 'currency', editable: false},
    { label: table_total_price, fieldName: 'Atonit_Mktplace__TotalPrice__c', type: 'currency', editable: false},
    { label: table_requested_quantity, fieldName: 'Atonit_Mktplace__Quantity__c', type: 'number', editable: false},
    { label: table_quantity_requested, fieldName: 'Quantity_Returned__c', type: 'number', editable: { fieldName: 'editable'}, cellAttributes: { class: { fieldName: 'alreadyEditCSSClass' }}},
    { label: table_updated_total_price, fieldName: 'UpdatedTotalPrice', type: 'currency', editable: false}
];

export default class CaseProcessReturnTable extends LightningElement {
    @api recordId;
    @api community;
    @track loading = false;
    @track error;
    draftValues = [];
    @track itemsColumns = itemsColumns;
    disableConfirm = false;

    labels = {
        modal_title,
        no_datas
    };

    connectedCallback() {
        loadStyle(this, modalCSS);
      }

    @api invoke(){
        console.log(recordId);
    }

    listItems = [];
    @track lastwiredAnswersResponseListItems; // used for programmatical refresh
    @wire(getItemsFromCase, { caseId: '$recordId' })
    getItemsFromCase(response) {
        this.lastwiredAnswersResponseListItems = response;
        this.loading = true;
        if(response.data) {
            let currentData = []; //datas temp
            response.data.forEach((row) => {
                let returnedQuantity = row.Quantity_Returned__c !== undefined ? row.Quantity_Returned__c : 0;
                let editable = row.Status__c === 'Confirmed' ? false : true;
                this.disableConfirm = this.disableConfirm === false && row.Quantity_Returned__c === undefined ? true : false;
                let alreadyEditCSSClass = editable ? 'borderRed' : 'slds-box slds-theme_shade slds-theme_alert-texture';
                let UpdatedTotalPrice = (row.Atonit_Mktplace__Quantity__c * row.Atonit_Mktplace__UnitPrice__c) - (returnedQuantity * row.Atonit_Mktplace__UnitPrice__c);
                currentData.push(
                    {
                        Id: row.Id,
                        productId: '/lightning/r/Atonit_Mktplace__Occurrence_Item__c/' + row.Id + '/view',
                        productName : row.Name,
                        SKUId : '/lightning/r/Atonit_Mktplace__Product_Variant__c/' + row.Atonit_Mktplace__ProductVariant__c + '/view',
                        SKUName : row.Atonit_Mktplace__ProductVariant__r.Name,
                        Status__c : row.Status__c,
                        Atonit_Mktplace__UnitPrice__c : row.Atonit_Mktplace__UnitPrice__c,
                        Atonit_Mktplace__TotalPrice__c : row.Atonit_Mktplace__TotalPrice__c,
                        Atonit_Mktplace__Quantity__c : row.Atonit_Mktplace__Quantity__c,
                        Quantity_Returned__c: row.Quantity_Returned__c,
                        UpdatedTotalPrice: UpdatedTotalPrice,
                        editable: editable,
                        alreadyEditCSSClass: alreadyEditCSSClass
                    }
                );
                this.listItems = currentData;
            });
        } else if (response.error) {
            console.log(response.error);
            this.error = response.error.body.message;
        }
        this.loading = false;
    }

    get iflistItems() {
        return (this.listItems !== undefined && this.listItems.length >= 1);
    }

    async handleSaveTable(event) {
        this.loading = true;
        const updatedFields = event.detail.draftValues;
        this.draftValues = [];

        try {
            // Pass edited fields to the updateItems Apex controller
            await updateItems({ itemsForUpdate: updatedFields});

            // Report success with a toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: success_title,
                    message: success_body_save,
                    variant: 'success'
                })
            );
        } catch (error) {
            this.loading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: error_title,
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
        finally {
            await refreshApex(this.lastwiredAnswersResponseListItems);
            this.loading = false;
        }
    }
    
    async handleConfirm(event) {
        this.loading = true;

        try {
            // Pass edited fields to the updateItems Apex controller
            await confirmItems({
                itemsForUpdate: this.listItems,
                caseId: this.recordId
            });

            // Report success with a toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: success_title,
                    message: success_body_confirm,
                    variant: 'success'
                })
            );
        } catch (error) {
            this.loading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: error_title,
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
        finally {
            this.loading = false;
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}