/**
 * @description       : Displays a list of directors to authenticate
 * @author            : Mahlatse Tjale
 * @last modified on  : 10-17-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/


import {api, wire, track} from 'lwc';
import getContactsByAccount from '@salesforce/apex/AOB_CTRL_Authentication.getAllContactsByApplicationId';
import LightningModal from 'lightning/modal';
//For the Authenticate Modal
import xds_url from '@salesforce/label/c.aob_xds_url';
import saveData from '@salesforce/apex/AOB_CTRL_Authentication.updateAuthentication';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import Verification_OBJECT from '@salesforce/schema/Verification__c';
import Status_Field from '@salesforce/schema/Verification__c.Authentication_Status__c';
import xdsFailure_Field from '@salesforce/schema/Verification__c.XDS_Failure_Reason__c';
import executeUpdateCustomerCallout from '@salesforce/apex/AOB_CTRL_UpdateCustomer.updateCustomerCallout';
import { createLogger } from 'sbgplatform/rflibLogger';

const actions = [
	{label: 'Authenticate', name: 'show_details', type: 'button'}

];

const columns = [

	{label: 'Name', fieldName: 'Name'},
	{label: 'ID Number', fieldName: 'Identity_Number__c'},
	{
		label: 'Authentication', type: 'button', typeAttributes: {rowActions: actions, label: 'Authentication'}
	}
];

export default class aob_internal_comp_authenticate extends LightningModal
{
	logger = createLogger('aob_internal_comp_authenticate');
	@api applicationId;

	showAuthenticate = false;
	@track directors = [];
	@track columns = columns;
	@track mapDataPLIE = [];
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
	showContacts=false;
	showNoContacts=false;

	sticky = false;
	timeout = 10000;
	isLoaded = false;
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
		if(event.target.id.includes('xds'))
		{
			this.xdsAuth = event.target.checked;
			this.ofvAuth = false;
		}
		else if(event.target.id.includes('ofv'))
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
		this.getContacts();

	}

	getContacts()
	{
		getContactsByAccount({applicationId: this.applicationId})
		.then(data =>
		{
			this.isLoaded = true;
			this.contacts = data;
			if(data.length !== 0)
				{	
				this.showContacts=true;
				}
				else{
					this.showNoContacts=true;
					this.updateCustomerCallouts();
				}
		})
		.catch(error =>
		{
			this.logger.error('An error occurred while calling getContactsByAccount:', error);
			this.isLoaded = true;
			this.showNoContacts=true;
			let errors = JSON.stringify(error);
			this.showErrorToast(errors);
		});
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
					this.closeModal();
					this.contacts = null;
					this.contacts = result;
					
					if(result.length !== 0)
					{	
						this.showContacts=true;

						
					}else{
						this.showNoContacts=true;
						this.updateCustomerCallouts();
					}
				})
				.catch(error =>
				{
					this.logger.error('An error occurred while calling saveData:', error);
					this.showNoContacts=true;
					let errors = JSON.stringify(error);
					this.showErrorToast(errors);
				});
			}
		}

	}

	showSuccessToast()
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
	
	updateCustomerCallouts(){
        executeUpdateCustomerCallout({'applicationId':`${this.applicationId}`})
        .then(result=>{
            if (result == 'Successful') {
				this.isLoaded=true;
                this.showSuccessToast();
            }else {
				this.isLoaded=true;
                let results =JSON.stringify(result);
                this.showErrorToast(results);
                }
        })
        .catch(error=>{
			this.logger.error('An error occurred while calling executeUpdateCustomerCallout:', error);
			this.isLoaded=true;
			let message='Unexpected Error, Please contact your administrator';
			this.showErrorToast(message);
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
}