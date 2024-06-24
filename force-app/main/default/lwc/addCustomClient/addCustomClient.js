import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import showVisibleToClient from '@salesforce/apex/AddCustomClient_Controller.showVisibleToClient';

import CUSTOM_CLIENT from '@salesforce/schema/Custom_Client_Team__c';
import TEAM_MEMBER from '@salesforce/schema/Custom_Client_Team__c.Team_Member__c';
import CLIENT_ROLE from '@salesforce/schema/Custom_Client_Team__c.Client_Role__c';
import VISIBLE_TO_CLIENT from '@salesforce/schema/Custom_Client_Team__c.Visible_to_Client__c';
import CC from '@salesforce/schema/Custom_Client_Team__c.Client_Coordinator__c';
import CCBM from '@salesforce/schema/Custom_Client_Team__c.Client_Coordinator_BM__c';
import GTB from '@salesforce/schema/Custom_Client_Team__c.GTB__c';
import ACCOUNT from '@salesforce/schema/Custom_Client_Team__c.Account__c';
import CASE_ACCESS from '@salesforce/schema/Custom_Client_Team__c.Case_Access__c';
import CLIENT_ACCESS from '@salesforce/schema/Custom_Client_Team__c.Client_Access__c';
import CONTACT_ACCESS from '@salesforce/schema/Custom_Client_Team__c.Contact_Access__c';
import OPPORTUNITY_ACCESS from '@salesforce/schema/Custom_Client_Team__c.Opportunity_Access__c';

export default class AddCustomClient extends NavigationMixin(LightningElement) {
    @track isLoading =true;
    @track showVisibleToClientField = false;
    @api account;
    @api isMobile;
    isReplace;
    isSaveAndNew = false;
    teamMember;

    customClientTeam = CUSTOM_CLIENT;
    teamMember = TEAM_MEMBER;
    clientCoordinator = CC;
    clientCoordinatorBM = CCBM;
    teamRole = CLIENT_ROLE;
    visibleToClient = VISIBLE_TO_CLIENT;
    Gtb = GTB;
    Client = ACCOUNT;
    CaseAccess = CASE_ACCESS;
    ClientAccess = CLIENT_ACCESS;
    ContactAccess = CONTACT_ACCESS;
    OpportunityAccess = OPPORTUNITY_ACCESS;

    get modalClass(){
        return this.isMobile ? 'slds-scrollable' : 'slds-modal__container slds-scrollable';
    }

    get fadeClass(){
        return this.isMobile ? '' : 'slds-backdrop slds-backdrop_open';
    }

    onSubmit() {
        this.isReplace = false;
    }

    onSubmitAndNew() {
        this.isReplace = false;
        this.isSaveAndNew = true;
    }

    onReplace(){
        this.isReplace = true;
    }

    onCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.account,
                actionName: 'view'
            }
        });
    }

    handleSubmit(event) {
       event.preventDefault();
       this.isLoading = true;
       const fields = event.detail.fields;
       console.log();
       if(this.isMobile){
           fields.Account__c = this.account;
           fields.Team_Member__c = this.teamMember;
       }
       fields.Account__c = this.account;
       if (this.isReplace) {
            fields.SourceFlag__c = 12;
            this.isReplace = false;
       } else {
            fields.SourceFlag__c = 10;
       }
       this.template.querySelector('lightning-record-edit-form').submit(fields);

    }

    handleSuccess() {
        if(this.isSaveAndNew){
            this.dispatchEvent(
                new CustomEvent('saveandnew')
            );
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.account,
                    actionName: 'view'
                }
            });
        }
    }

    handleError(event) {
        this.isLoading = false;
        let message =  event.detail.detail;
        if(message.startsWith('Client Coordinator') || message.startsWith('Same Team Role') || message.startsWith('Team member')  ){
              this.isReplace = true;
              message += ' Change Team member details or click Replace button to replace existing team member with new one.'
        }
        if (message.startsWith('insufficient access rights on cross-reference id')) {
            message = 'Insufficient Privileges: You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'
        }
        const toast = new ShowToastEvent( {
            title: 'Error Occurred',
            variant: 'error',
            mode: 'pester',
            message: message
        });
        this.dispatchEvent(toast);
    }

    changeValueAccount(event){
        this.isLoading = true;
        this.account = event.detail.value?.[0];
        showVisibleToClient({ clientId: this.account })
        .then(result => {
            this.showVisibleToClientField = result;
            this.isLoading = false;
        })
        .catch(error => {
            this.showVisibleToClientField = false;
            console.log('ERROR: ' + JSON.stringify(error));
            this.isLoading = false;
        });
    }

    changeValueTeamMember(event){
        this.teamMember = event.detail;
    }

    connectedCallback(){
        showVisibleToClient({ clientId: this.account })
            .then(result => {
                this.showVisibleToClientField = result;
                this.isLoading = false;
            })
            .catch(error => {
                console.log('ERROR: ' + JSON.stringify(error));
                this.isLoading = false;
            });
    }
}