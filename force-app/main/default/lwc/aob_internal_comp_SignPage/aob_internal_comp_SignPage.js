/**
 * @description       : Signing comfirmation screen.
 * @author            : Sibonelo Ngcobo
 * @group             : 
 * @last modified on  : 10-11-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-20-2023   Sibonelo Ngcobo   SFP-25089
**/
import {api, wire, track,LightningElement} from 'lwc';
import getContactsByAccount from '@salesforce/apex/AOB_CTRL_Authentication.getAllContactsToSign';
import xds_url from '@salesforce/label/c.aob_xds_url';
import saveData from '@salesforce/apex/AOB_CTRL_Authentication.updateSignedContract';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import Verification_OBJECT from '@salesforce/schema/Verification__c';
import Status_Field from '@salesforce/schema/Verification__c.Authentication_Status__c';
import xdsFailure_Field from '@salesforce/schema/Verification__c.XDS_Failure_Reason__c';
import executeAccountOnboarding from '@salesforce/apex/AOB_CTRL_AccountOnboardingRequest.executeAccountOnboarding';
import completeApplication from '@salesforce/apex/AOB_CTRL_InternalCompleteApplication.completeApplicationCallout';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { createLogger } from 'sbgplatform/rflibLogger';

const actions = [
	{label: 'Authentication', name: 'show_details', type: 'button'}

];

const columns = [

	{label: 'Name', fieldName: 'Name'},
	{label: 'ID Number', fieldName: 'Identity_Number__c'},
	{label: 'Phone Number', fieldName: 'Phone'},
	{
		label: 'Signed', type: 'button', typeAttributes: {rowActions: actions, label: 'Yes', variant: 'Base'}
	}
];

export default class aob_internal_comp_SignPage extends LightningElement
{
	@api applicationId = {};
	showContacts=false;
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
	applicationComplete=false;
	showContracts=true;
	sticky = false;
	timeout = 10000;
	isLoaded = false;
	@track wiredContacts;
	@wire(getObjectInfo, {objectApiName: Verification_OBJECT})
	Vericationinfo;
	directorsNotSigned = true;
	logger = createLogger('aob_internal_comp_SignPage');

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
			this.notSigned();
			if(this.contacts.length==0){
				this.showContacts=false;
				this.showNoContacts=true;
			}
			else{
			this.showContacts=true;
			}
		})
		.catch(error =>
		{
			this.logger.error('An error occurred while fetching contact list:', error);
			let errors = JSON.stringify(error);
			this.showToast(errors, 'Error');
		});
	}

	closeModal()
	{
		const closeModalEvent = new CustomEvent('closemodal');
		this.dispatchEvent(closeModalEvent);
	}

	handleButtonClick(event)
	{
		this.isLoaded = false;
		const row = event.detail.row;
		this.contactId = row.Id;
		{
			saveData({
				applicationId: this.applicationId,
				contactId: this.contactId
			})
			.then(result =>
			{
				this.logger.debug('Signed Contact updated successfuly:', result);
				this.isLoaded = true;
				this.closeModal();
				this.contacts = null;
				this.contacts = result;
				this.notSigned();

				if(this.contacts.length==0){
				this.showContacts=false;
				this.showNoContacts=true;
				}
				this.showToast('Succesful','success');		
			})
			.catch(error =>
			{
				this.logger.error('An error occurred while updating signed contacts:', error);
				this.isLoaded=true;
				let errors = JSON.stringify(error);
				this.showToast(errors, 'Error');
			});
		}

	}
	
	notSigned(){
		if(this.contacts.length==0){
			this.directorsNotSigned = false;
		}else{
			this.directorsNotSigned = true;

		}
	}


	get onDirectorsNotSigned(){
		
		return this.directorsNotSigned;
	}

	onContinue(){
			this.completeAppCallout();
	}

	completeAppCallout() {
		this.isLoaded = false;
		completeApplication({applicationId:this.applicationId})
		.then(results => {
			this.logger.debug('Complete Application callout successful:', results);
			let result = JSON.parse(JSON.stringify(results));
            if (result == 'Successful') {
				this.showToast(result,'success');
				this.isLoaded = true;
                this.callexecuteAccountOnboarding();
				
			}else {
				this.isLoaded = true;
				let results =JSON.stringify(result);
				this.showToast(result,'Error');
			}
		})
		.catch(errors => {
			this.logger.error('An error occurred while while calling Complete Application API:', error);
			this.isLoaded = true;
			const message = 'Some unexpected error,Please contact your administrator';
			let error = JSON.parse(JSON.stringify(errors));
			this.showToast(message,'error');
		})
	}
	callexecuteAccountOnboarding(){
		this.isLoaded = false;
		executeAccountOnboarding({applicationId:this.applicationId})
		.then(result=>{
			this.logger.debug('Execute Account Onboarding callout successful:', result);
            if (result) {
				if (result == 'Successful') {
					this.isLoaded = true;
					this.showToast(result,'success');
					this.showContracts=false;
					this.applicationComplete=true;
				} else {
					this.isLoaded = true;
					this.showToast(result,'error');
				}
			}
		})
		.catch(error=>{
			this.logger.error('An error occurred while while calling Execute Account Onboarding API:', error);
			this.isLoaded = true;
			let errors = JSON.stringify(error);
			this.showToast(errors, 'Error');
		});
	}

	handleButtonClickxds(event)
	{

		window.open(this.urlLabel, '_blank');
	}

	handleButton(event)
	{
		this.redirect();
	}

	redirect()
	{
		let orgUrl = window.location.origin;
		window.open(orgUrl + '/lightning/r/AOB_Application__c/' + this.applicationId + '/view', '_self');
	}

	@track isModalOpen = false;

	openModal()
	{
		this.isModalOpen = true;
	}

	closeModal()
	{
		this.isModalOpen = false;
	}

	submitDetails()
	{
		this.isModalOpen = false;
	}
	showToast(message,variant) {

		const event = new ShowToastEvent({

			label:'',

			variant:variant,

			message:message,

		});

		this.dispatchEvent(event);

	}
}