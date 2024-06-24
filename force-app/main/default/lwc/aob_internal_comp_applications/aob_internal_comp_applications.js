/**
 * @description       : Displays list of existing applications
 * @author            : Mahlatse Tjale
 * @last modified on  : 07-20-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/
import { LightningElement,api } from 'lwc';
import openApplications from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.getOpenApplications';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'Name' },
            name: 'navigateToRecord',
            title: 'Click to View',
            variant: 'base',
            class: 'slds-button_link'
        }
    },
    { label: 'Client Name', fieldName: 'AOB_Client_Name__c' },
    { label: 'Status', fieldName: 'AOB_Status__c' }
];

const actions = [
    { label: 'View', name: 'view' }
];
export default class Aob_internal_comp_applications extends NavigationMixin(LightningElement) {
  applications;  
  columns=columns;
  @api registration;
  @api accounts;
  accountId;
  isLoaded=false;
  showAccount=false;
  hideApplications=false
    connectedCallback(){
        openApplications({Registration:this.registration})
        .then(result=>{
            this.isLoaded=true;
            this.applications = result.map(app => ({
                ...app,
                AOB_Client_Name__c: app.AOB_Client__r.Name
            }));
            this.accountId=this.accounts;
            
        })
        .catch(error=>{
            this.isLoaded=true;
            console.error(error);
        });
    }
    handleCreateApplication(){
        this.hideApplications=true;
        this.showAccount=true;
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
    
        if (actionName === 'navigateToRecord') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    actionName: 'view'
                }
            });
        }
    }
    
      
}