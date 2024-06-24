/**
 * @description       : Searches for a product.
 * @author            : Sibonelo Ngcobo
 * @last modified on  : 07-20-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-20-2023   Sibonelo Ngcobo   SFP-25089
**/
import {LightningElement,api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import AOB_Search_Modal from '@salesforce/resourceUrl/AOB_Search_Modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkProducts from '@salesforce/apex/AOB_internal_CTRL_Onboarding.findApplicationByProductId';
import { NavigationMixin } from 'lightning/navigation';

export default class aob_internal_comp_searchProduct extends NavigationMixin(LightningElement) {
    @api content;
    @api headerText;
    @api accounts;
    @api account;
    isLoaded=false;
    message;
    email;
    businessName;
    accountId;
    accountName;
    result;
    showProduct=false;
    showNoAccount=false;
    showAccounts=false;
    checkEvent=false;
    product;
    registrationNumber;
    showProductSearch=true;
    showPreApplication=false;
    productName;
    showExistingProduct=false;
    cols = [
        {label:'Account Name', fieldName:'Name' , type:'text'} ,
        {label:'Phone', fieldName:'Phone' , type:'Phone'} ,
        {label:'Industry', fieldName:'Industry' , type:'text'},
        {
        type:"button",
        fixedWidth: 150,
        typeAttributes: {
            label: 'Select',
            name: 'edit',
            variant: 'brand'
        }    
    }
    ];
    sticky = false;
    timeout = 3000;
   
    connectedCallback() {
        
            if(this.accounts==null){
                this.isLoaded=true;
                this.showAccounts=false;
                let message='Client not found';
                let variant='warning';
                this.showToast(message,variant);
            }else{
            const accountObj = JSON.parse(JSON.stringify(this.accounts));
            this.registrationNumber = accountObj[0].Registration_Number__c;
            if(this.accounts){
            this.showAccounts=true;
            this.isLoaded=true;
            }
        }
            
    }
    renderedCallback() {
        
        Promise.all([
            loadStyle( this, AOB_Search_Modal)
            ]).then(() => {
            })
            .catch(error => {
        });

    }
    handleRowAction(event) {
        const row = event.detail.row;
        this.accountName=row.Name;
        this.accountId=row.Id;
        this.showAccounts=false;
    }
    checkProducts(){
        checkProducts({registration:this.registrationNumber,productId:this.product})
        .then(result=>{
            if(result){
            this.applicationId=result.Id;
            this.productName=result.Name;
            this.showExistingProduct=true;
            this.preAppNavigation();
            }else{
            this.preAppNavigation();
            }
        })
        .catch(error=>{
            this.preAppNavigation();
        })
    }
    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: this.applicationId,
            objectApiName: 'AOB_Application__c',
            actionName: 'view' 
          }
        });
    }
    preAppNavigation(){
        if(this.showExistingProduct==false){
            if(this.product){
                this.showProductSearch=false;
                this.showPreApplication=true;
            }else{
                let message='Please select a product';
                this.showToast(message,'error');        }
            } 
    }
    handleButtonClick(){
    this.checkProducts();    
    }

    handleEvent(event){
        this.product=event.detail;
    }

    handleCancel(){
        this.showProductSearch=false;
        this.showSearch=true;
    }
    
    showToast(message,variant) {
        const event = new ShowToastEvent({
            title: 'Warning',
            variant:variant,
            message:message,
        });
        this.dispatchEvent(event);
    }
   
}