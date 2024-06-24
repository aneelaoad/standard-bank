import { api, LightningElement, wire, track } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import getMatchingClients from '@salesforce/apex/PP_ClientSearcher_CTRL.getMatchingClients';
import linkClient from '@salesforce/apex/PP_ClientSearcher_CTRL.linkClient';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = [
    'PP_PartnerApplication__c.Name',
    'PP_PartnerApplication__c.PP_RegistrationNumber__c',
    'PP_PartnerApplication__c.PP_Account__c',
];

const columns = [
    {
        label: 'Name', fieldName: 'AccountURL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name',
                target: '_blank'
            }
        }
    },
    { label: 'Registration No.', fieldName: 'Registration_Number__c' },
];

export default class PpClientSearcher extends LightningElement {

    @api
    recordId;
    @track accounts;
    @track columns = columns;
    hasError;
    companyName;
    regNo;
    accountId;
    isProcessing;
    warrningIcon;
    clientId;
    disableAssociateBtn = true;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredUserRecord({ error, data }) {
        if (error) {
            this.hasError = true;
        }
        else if (data) {
            this.accountId = data.fields.PP_Account__c.value;
            this.companyName = data.fields.Name.value;
            this.regNo = data.fields.PP_RegistrationNumber__c.value;
            this.getMatchingClientList();
        }
    }


    connectedCallback() {
        this.warrningIcon = Assets + '/Icons/warning.png';
    }

    getMatchingClientList() {
        this.isProcessing = true;
        getMatchingClients({ companyName: this.companyName, regNo: this.regNo }).then(response => {
            response.forEach(item => item['AccountURL'] = '/lightning/r/Account/' + item['Id'] + '/view');
            this.isProcessing = false;
            this.accounts = response;
        }).catch(error => {
            this.isProcessing = false;
        });
    }

    onRowSelection(event) {
        this.clientId = event.detail.selectedRows[0].Id;
        this.disableAssociateBtn = false;
    }

    associateClient() {
        this.isProcessing = true;
        linkClient({ recordId: this.recordId, clientId: this.clientId }).then(response => {
            this.toast('Client has been linked!', 'success');
            this.isProcessing = false;
            getRecordNotifyChange([{ recordId: this.recordId }]);
        }).catch(error => {
            this.toast('Something went wrong', 'error');
            this.isProcessing = false;
        });
    }

    toast(title, toastVariant) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: toastVariant
        })
        this.dispatchEvent(toastEvent)
    }

}