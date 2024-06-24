/**
 * @description       : Displays a list of directors
 * @author            : Mahlatse Tjale
 * @last modified on  : 11-16-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/


import {api, wire, track} from 'lwc';
import getContacts from '@salesforce/apex/AOB_CTRL_Authentication.getShareholderStatus';
import GetDigitalOffer from '@salesforce/apex/AOB_SRV_InternalGetDigitalOffer.digitalOfferCallout';
import LightningModal from 'lightning/modal';
//For the Authenticate Modal
import xds_url from '@salesforce/label/c.aob_xds_url';
import saveData from '@salesforce/apex/AOB_CTRL_Authentication.updateAuthentication';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import Verification_OBJECT from '@salesforce/schema/Verification__c';
import Status_Field from '@salesforce/schema/Verification__c.Authentication_Status__c';
import xdsFailure_Field from '@salesforce/schema/Verification__c.XDS_Failure_Reason__c';
import processData from '@salesforce/apex/AOB_CTRL_GetApplicationProcessData.applicationProcessDataCallout';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { createLogger } from 'sbgplatform/rflibLogger';
import {deleteRecord} from 'lightning/uiRecordApi';
const actions = [
	{label: 'Authenticate', name: 'show_details', type: 'button'}

];

const columns = [

	{label: 'Name', fieldName: 'Name'},
	{label: 'ID Number', fieldName: 'IdNumber'},
	{label: 'Phone', fieldName: 'Phone',editable:'true',type: 'phone'},
	{label: 'Email', fieldName: 'Email',editable:'true',type: 'email'},
	{label: 'Main Applicant', fieldName: 'Shareholder'},
	{
		label: 'Authentication', type: 'button', typeAttributes: {rowActions: actions, label: 'Authentication'}
	}
];

export default class aob_internal_comp_directorspage extends LightningModal
{
	logger = createLogger('aob_internal_comp_directorspage');
	@api applicationId;
	saveDraftValues = [];
	allContacts=[];
	showAuthenticate = false;
	@track directors = [];
	@track columns = columns;
	@track mapDataPLIE = [];
	//@track fixeddata[];
	contactdata;
	@track testadress;
	contactId;
	contacts;
	@api result = false;
	authenticated = false;
	subscription = null;
	applicationIds;

	testfield;
	shouldSkipMethod = true;

	//for the Moadal
	showAdditionalSection = false;
	selectAuthType = true;
	xdsAuth = false;
	ofvAuth = false;
	@track isButtonDisabled = true;
	urlLabel = xds_url;
	status;
	reference;
	showReasonField = false;
	xdsFailuerReason;
	authenticated = false;
	value = '';
	result;
	testContact = false;

	sticky = false;
	timeout = 10000;
	isLoaded = false;
	MainShareholderId;
	showProduct=false;
	showDirectors=false;
	@track wiredContacts;
	@wire(getObjectInfo, {objectApiName: Verification_OBJECT})
	Vericationinfo;
	@wire(getPicklistValues,

			{

				recordTypeId: '$Vericationinfo.data.defaultRecordTypeId',

				fieldApiName: Status_Field

			})

	statusPicklist;
	@wire(getPicklistValues,

			{

				recordTypeId: '$Vericationinfo.data.defaultRecordTypeId',

				fieldApiName: xdsFailure_Field

			})

	xsdfailurePicklist;

	authTypeHandler(event)
	{
		if(event.target.Id.includes('xds'))
		{
			this.xdsAuth = event.target.checked;
			this.ofvAuth = false;
		}
		else if(event.target.Id.includes('ofv'))
		{
			this.xdsAuth = !event.target.checked;
			this.ofvAuth = true;
		}
		else
		{
			this.xdsAuth = false;
			this.ofvAuth = false;
		}
	}

	handleChange(event)
	{
		this.status = event.detail.value;
		if(this.status === 'Authentication Failed')
		{
			this.showReasonField = true;
		}
		else
		{
			this.showReasonField = false;
		}
	}

	handlexdsfailurechange(event)
	{
		this.XDSFailuerReason = event.detail.value;
	}

	genericFieldChange(event)
	{
		this.reference = event.target.value;
		if (this.reference.length > 0 && this.reference.charAt(0) !== 'A') {
			event.target.setCustomValidity("Please enter the Reference starting with the letter A.");
		} else {
			event.target.setCustomValidity('');
		}
		event.target.reportValidity();
	}

	connectedCallback()
	{
		this.showDirectors=true;
		this.fetchResponseCallBack();
	}
	fetchResponseCallBack(){
		GetDigitalOffer({'applicationId' : this.applicationId}).then(data =>
		{
			if(data == 200 ) {
			this.isLoaded = true;
			this.showSuccessToast('Succesful','Success');
			}else{
				this.removeApplicationRecord();
                    setTimeout(()=> {
						this.showDirectors=false;
						this.showProduct=true;
               	 }
                     ,10000);
			}
		})
		.catch(error =>
		{
			this.logger.error('An error occurred while calling GetDigitalOffer:', error);
			this.isLoaded = true;
			let errors = JSON.stringify(error);
			this.showErrorToast(errors);
			this.removeApplicationRecord();
                    setTimeout(()=> {
						this.showDirectors=false;
						this.showProduct=true;
               	 }
                     ,10000);
		});
	}
	
	@wire(getContacts,{applicationId:"$applicationId"})
    contactData(result) {
		this.isLoaded = true;
        this.contacts = result;
    };

	handleSave(event) {
		this.saveDraftValues = event.detail.draftValues;
		const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.ShowToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.saveDraftValues = [];
            return this.refresh();
        }).catch(error => {
			this.logger.error('An error occurred while calling updateRecord:', error);
            this.ShowToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }
	async refresh() {
        await refreshApex(this.contacts);
    }
    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
                title: title,
                message:message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(evt);
    }
	
	closeModal()
	{
		const closeModalEvent = new CustomEvent('closemodal');
		this.dispatchEvent(closeModalEvent);
	}

	handleButtonClick(event)
	{
		const row = event.detail.row;
		this.contactId = row.Id;
		this.openModal();

	}

	handleButtonClickxds(event)
	{
		window.open(this.urlLabel, '_blank');
	}

	handleContinues(event)
	{
		const allValid = [
			...this.template.querySelectorAll('lightning-input')
		].reduce((validSoFar, inputCmp) =>
		{
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		if(allValid)
		{

			if(this.reference != null && this.status != null)
			{
				saveData({
					reference: this.reference,
					status: this.status,
					xdsFailuerReason: this.XDSFailuerReason,
					applicationId: this.applicationId,
					contactId: this.contactId
				})
				.then(result =>
				{
					this.isLoaded = true;
					this.callProcessData();
					this.closeModal();
					this.contacts = null;
					this.contacts = result;
				})
				.catch(error =>
				{
					this.logger.error('An error occurred while calling saveData:', error);
					let errors = JSON.stringify(error);
					this.showErrorToast(errors);
				});
			}
		}

	}

	showSuccessToast(message)
	{
		this.template.querySelector("c-aob_internal_custom-toast").showToast("success", "Successful");
	}

	showErrorToast(message) {
        this.template.querySelector("c-aob_internal_custom-toast").showToast("error", message);
    }

	handleButton(event)
	{
		this.redirect();
	}
	
	callProcessData(){
		this.isLoaded = false;
        processData({applicationId:this.applicationId})
        .then(result=>{
            if (result == 'Successful') {
                this.showSuccessToast();
				this.isLoaded = false;
                setTimeout(()=> {
                    this.redirect();
                }
                ,3000);
            }else {
                    let results =JSON.stringify(result);
                    this.showErrorToast(results);
					this.removeApplicationRecord();
                    setTimeout(()=> {
						this.showDirectors=false;
						this.showProduct=true;
               	 }
                     ,10000);
                     this.createLead();
                }
        })
        .catch(error=>{
			this.logger.error('An error occurred while calling processData:', error);
            let errors = JSON.stringify(error);
            this.showErrorToast(errors);
            this.removeApplicationRecord();
                    setTimeout(()=> {
						this.showDirectors=false;
						this.showProduct=true;
               	 }
                     ,10000);
        });
    }

	redirect()
	{
		let orgUrl = window.location.origin;
		window.open(orgUrl + '/lightning/r/AOB_Application__c/' + this.applicationId + '/view', '_self');
	}

	//Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded
	@track isModalOpen = false;

	openModal()
	{
		// to open modal set isModalOpen tarck value as true
		this.isModalOpen = true;
	}

	closeModal()
	{
		// to close modal set isModalOpen tarck value as false
		this.isModalOpen = false;
	}

	submitDetails()
	{
		// to close modal set isModalOpen tarck value as false
		//Add your code to call apex method or do some processing
		this.isModalOpen = false;
	}
	removeApplicationRecord() {
        deleteRecord(this.applicationId)
            .then((result) => {
                this.applicationId = null;
            })
            .catch((error) => {
                this.logger.error('An error occurred while calling deleteRecord:', error);
                this.error = error;
            });

    }


}