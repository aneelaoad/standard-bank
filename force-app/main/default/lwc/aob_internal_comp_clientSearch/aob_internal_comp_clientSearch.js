/**
 * @description       : Screen to search clients
 * @author            : Mahlatse Tjale
 * @last modified on  : 07-20-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/
import {LightningElement } from 'lwc';
import getAccountData from '@salesforce/apex/AOB_internal_CTRL_Onboarding.getAccountData';
import openApplications from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.getOpenApplications';

export default class aob_internal_comp_clientSearch extends LightningElement {
    showModal = true;
    result;
    searchKey;
    accounts;
    showAccount=false;
    showSearch=true;
    showOpenApplications=false;
    isLoaded;
    showLoader=false;
    
   handelSearchKey(event){
    this.searchKey = event.target.value;
}
getOpenApplications() {
    openApplications({ Registration: this.searchKey })
        .then(result => {
            if (result && result.length > 0) {
                this.showLoader=false;
                this.showSearch = false;
                this.getAccountForOpenApplications();
            } else {
                this.getAccountData();
                this.showSearch = false;
            }
        })
        .catch(error => {
            this.showOpenApplications = false;
            this.showSearch = false;
            this.getAccountData();
        });
}

SearchAccountHandler(){
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
    
    if (isInputsCorrect) {
        this.showLoader=true;
        this.getOpenApplications();
    }
}

getAccountData(){
    getAccountData({textkey: this.searchKey})
    .then(result => {
            this.showLoader=false;
            this.accounts = result;
            this.showAccount=true;
    })
    .catch( error=>{
        this.showLoader=false;
        this.error=error;
        this.showAccount=true;
    });
}
getAccountForOpenApplications(){
    getAccountData({textkey: this.searchKey})
    .then(result => {
        this.accounts = result;
        this.showOpenApplications = true;
    })
    .catch( error=>{
        this.error=error;
    });
}
}