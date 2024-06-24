/**
 * @description       :
 * @author            : Mahlatse Tjale
 * @last modified on  : 10-26-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
 **/
import { LightningElement, track, api,wire } from 'lwc';
/*Apex Actions */
import getFields from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.getFields';
import setApplicationData from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.setApplicationData';
import setApplicationStep from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.setApplicationStep';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import { NavigationMixin } from "lightning/navigation";
import loadInflightData from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.setExistingData';
import { getErrorMessage } from 'c/aob_comp_utils';
import { loadScript } from 'lightning/platformResourceLoader';
import isSACitizen from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.isSACitizen';
import updatePersonalDetails from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updatePersonalDetails';
import updateCompanyDetails from '@salesforce/apex/AOB_Internal_SRV_CompanyDetails.updateCompanyDetails';
import CallGetApplication from '@salesforce/apex/AOB_Internal_CTRL_RPDetails.callGetApplication';
import updateScreen from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updateScreen';
import updatePreviousScreen from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updatePreviousScreen';
import availableBundlesData from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.selectedAvailableBundles';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import updateinflight from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.updateinflight';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isNewCompanyRan from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.isNewCompanyRan';
import getCustomer from '@salesforce/apex/AOB_CTRL_InternalGetCustomer.getCustomerCallout';
import getInflight from '@salesforce/apex/AOB_Internal_CTRL_FormCreator.getInflight';
import { createLogger } from 'sbgplatform/rflibLogger';

//LMS imports
import { publish, MessageContext } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/progressMessageChannel__c';
import BackmessageChannel from '@salesforce/messageChannel/previousScreenMessageChannel__c';


export default class Aob_internal_comp_formCreator extends NavigationMixin(LightningElement) {
	logger = createLogger('Aob_internal_comp_formCreator');
	@track displayMSError = false;
	@track getMsError = false;
	@track multiselectError = "Please complete this field..";
	@api isSales = false;
	@api isCurr = false;
	@api availableActions = [];
	infoIMG = AOB_ThemeOverrides + '/assets/images/info.png';
	lockIMG = AOB_ThemeOverrides + '/assets/images/SBG_Lock.png';
	constants = {
		NEXT: 'NEXT',
		BACK: 'BACK'
	}
	responseFormDetails = {};
	step = 4;
	//Adobe Tagging
	isEventFired;
	@api adobeDataScope;
	@api adobePageName;
	@api productCategory;
	@api productName;
	adobeDataScopeApp;
	adobeDataTextBack;
	siteerror;
	adobeDataTextContinue;
	showBackButton;
	showNextButton;
	@api applicationId;
	@api screenName;
	@api previousScreen;
	@api nextScreen;
	@api recordId;
	screenTitle;
	screenSubtitle;
	isLoaded;
	issnapscan = false;
	isAtScreenLoad;
	@track form;
	apiRetryNumber;
	technicalerror;
	@track taxInputs;
	taxListError;
	@track sections;
	//This attribute would contain all the values of the fields of the form
	@track formDetails = {};
	//stringified data of the form
	@api jsonData;
	//attributes for error handling
	failing;
	errorMessage;
	gridClass;
	isRendered;
	selectedPicklistValue;
	showBackB = true;
	@track isSoleOwnership;
	@track isBusinessReg;
	isPreApplication = false;
	application = {
		applicationProduct: "Customer on boarding",
		applicationMethod: "Online",
		applicationID: "",
		applicationName: "",
		applicationStep: "",
		applicationStart: true,
		applicationComplete: false
	}
	next1;
	previous;
	hasSnapScan=false;
	hasPocketBiz=false;
	@api pocketbiz=false;
	outstandingCompliance = true;
	complianceSpinner = false;
	CompanyDetailRan=false;

	@wire(MessageContext)
	MessageContext;

	handleClicks() {
		var progressMessage={currentScreen:this.nextScreen};
		publish(this.MessageContext,messageChannel,progressMessage);
		if(this.screenName==='Personal Details'){
			this.next1='Residential Address';
		}
		else if(this.screenName==='Residential Address'){
			this.next1='Employment Details';
		}
		else if(this.screenName==='Employment Details'){
			this.next1='Company Details';
		}
		else if(this.screenName==='Company Details'){
			this.next1='Company Trading Address';
		}
		else if(this.screenName==='Company Trading Address'){
			this.next1='Company Financial Details';
		}else if(this.screenName==='Company Financial Details'){
			this.next1='Marketing Consent Internal';
		}else if(this.screenName==='Marketing Consent'||this.screenName==='Marketing Consent Internal'){
			this.next1='Card Selection';
		}else if(this.screenName==='Notifications'){
			this.next1='Available Bundles';
		}else if(this.screenName==='SnapScan'){
			this.next1='Summary';
		}
		else if(this.screenName==='Summary'){
			this.next1='Application Complete';
		}

		const message= new CustomEvent('buttonclick',
				{detail:this.next1
				});
		this.dispatchEvent(message);
		this.handlePath();
	}

	handlePath(){

		const message= new CustomEvent('buttonclickpath',
				{detail:this.screenName
				});
		this.dispatchEvent(message);
	}
	handleBackProgress(){
		var progressMessage={currentScreen:this.previousScreen};
		publish(this.MessageContext,messageChannel,progressMessage);
	}

	handleBackClick() {
		if(this.screenName=='SnapScan'){
			availableBundlesData({
				'appliId': this.applicationId
			}).then(eachBundle => {
				var totalRecs = JSON.parse(eachBundle);
				this.isPocketBiz = totalRecs.ZPOB;
				this.isSnapScan = totalRecs.ZPSS;
				if(this.isPocketBiz){
					var previousScreenMessage={previousScreen:'PocketBiz'};
					publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
				}
				else{
					var previousScreenMessage={previousScreen:'Available Bundles'};
					publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
				}
			});
		}
		else{
			var previousScreenMessage={previousScreen:this.previousScreen};
			publish(this.MessageContext,BackmessageChannel,previousScreenMessage);
		}
		this.handleBackProgress();
	}
	renderedCallback() {
		if (this.isAtScreenLoad) {
			this.isAtScreenLoad = false;
			this.template.querySelectorAll('[type="radio"]').forEach(element => {
				for (let j in this.sections) {
					for (let i in this.sections[j].fields) {
						if (element.dataset.name == this.sections[j].fields[i].name) {
							let options = this.sections[j].fields[i].options;
							if (this.formDetails[element.dataset.name]) {
								if (this.formDetails[element.dataset.name] && element.dataset.value == this.formDetails[element.dataset.name]) {
									element.checked = true;
								}
							}
							else {
								for (let p in options) {
									if (options[p].isDefault && element.dataset.value == options[p].value) {
										element.checked = true;
										this.formDetails[this.sections[j].fields[i].name] = options[p].value;
									}
								}
							}
						}

					}
				}
			});
		}

		if (!this.isRendered) {
			loadScript(this, FireAdobeEvents)
			.then(() => {
				this.isRendered = true;
			});
		}
	}

	/**
	 * @description connectedcallback to set initial config and update current/previous screen on application
	 */
	connectedCallback() {
		this.prepopulateExistingData();
		this.getinflightDetails();
		if (this.availableActions.find(action => action === this.constants.NEXT)) { this.showNextButton = true; }
		if (this.availableActions.find(action => action === this.constants.BACK)) { this.showBackButton = true; }
		this.adobeDataScopeApp = this.adobeDataScope + ' business application';
		this.adobeDataScopeApp = this.adobeDataScopeApp.toLowerCase();
		this.adobeDataTextBack = this.adobePageName + ' back button click';
		this.adobeDataTextContinue = this.adobePageName + ' continue button click';

		if (this.screenName == 'Personal Details') {
			this.showBackB = false;
			isSACitizen({
				'appId': this.applicationId
			}).then(result => {
				this.isSACitizenship = result;
			}).catch(error => {
				this.logger.error('An error occurred while calling isSACitizen:', error);
				this.failing = true;
				this.isLoaded = true;
				this.errorMessage = getErrorMessage.call(this, error);
			});

		}
		if (this.screenName == 'Card Delivery') {
			this.showBackB = false;

		}
		if (this.screenName == 'PreApplication') {
			this.isPreApplication = true;
			this.showBackB = false;
		}
		if (this.screenName == 'Residential Address') {
			this.isLoaded=false;
			this.callGetCustomer();
		}


		this.getFieldsF();

		setApplicationStep({
			'applicationId': this.applicationId,
			'currentScreen': this.screenName,
			'previousScreen': this.previousScreen
		}).then(result => {
		})
		.catch(error => {
			this.logger.error('An error occurred while calling setApplicationStep:', error);
			this.failing = true;
			this.errorMessage = getErrorMessage.call(this, error);
		});

	}
	checkNullValues(checkValue){
		if(checkValue!==null||checkValue!==""){
			return true;
		}
	}
	getinflightDetails(){
		getInflight({appId:this.applicationId,screenName:'preApplicationResponse'})
		.then(result=>{
			let response=JSON.parse(result);
			this.formDetails['Nationality']='ZA';
			this.formDetails['citizenship']='ZA';
			const directorDetails = response.cipcRegisteredDetails.directorDetails;
			let keyWithMainTrue = null;

			for (const key in directorDetails) {
				if (directorDetails[key].mainApplicant === true) {
					keyWithMainTrue = key;
				}
			}
			if (keyWithMainTrue !== null) {
				const pipDetails=directorDetails[keyWithMainTrue].pipDetails;
				const publicOfficialRelatedDetails=pipDetails.publicOfficialRelatedDetails;
				const directorAddress=directorDetails[keyWithMainTrue].directorAddress;

				if (this.checkNullValues(this.formDetails['PublicOfficial'])) {
					this.formDetails['PublicOfficial']=JSON.stringify(directorDetails[keyWithMainTrue].pipDetails.publicOfficial);
				}

				if (this.checkNullValues(this.formDetails['Related'])) {
					this.formDetails['Related']=JSON.stringify(publicOfficialRelatedDetails.relatedToPublicOfficial);
				}

				if (this.checkNullValues(this.formDetails['RelationName'])) {
					this.formDetails['RelationName']=JSON.stringify(publicOfficialRelatedDetails.name);
				}

				if (this.checkNullValues(this.formDetails['SurnameRelationName'])) {
					this.formDetails['SurnameRelationName']=JSON.stringify(publicOfficialRelatedDetails.surname);
				}

				if (this.checkNullValues(this.formDetails['RelationType'])) {
					this.formDetails['RelationType']=JSON.stringify(publicOfficialRelatedDetails.typeOfRelationship);
				}

				if (this.checkNullValues(this.formDetails['Street'])) {
					this.formDetails['Street']=JSON.parse(JSON.stringify(directorAddress.addressLine1));
				}

				if (this.checkNullValues(this.formDetails['suburb'])) {
					this.formDetails['suburb']=JSON.parse(JSON.stringify(directorAddress.addressLine3));
				}

				if (this.checkNullValues(this.formDetails['PostalCode'])) {
					this.formDetails['PostalCode']=JSON.parse(JSON.stringify(directorAddress.postalCode));
				}

				if (this.checkNullValues(this.formDetails['CELLPHONE'])) {
					this.formDetails['CELLPHONE']=JSON.parse(JSON.stringify(directorDetails[keyWithMainTrue].cellphoneNumber));
				}

				if (this.checkNullValues(this.formDetails['EMAIL ADDRESS'])) {
					this.formDetails['EMAIL ADDRESS']=JSON.parse(JSON.stringify(directorDetails[keyWithMainTrue].emailAddress));
				}
			}
		})
		.catch(error=>{
			this.logger.error('An error occurred while calling getInflight:', error);
		});
	}
	/**
	 * @description handles to fetch inflight data of the application based on current screen
	 */
	prepopulateExistingData() {
		loadInflightData({
			'appId': this.applicationId,
			'screenName': this.screenName
		})
		.then(result => {
			if (result) {
				this.formDetails = JSON.parse(result);
			}
			this.getFieldsF();
		}).catch(error => {
			this.logger.error('An error occurred while calling loadInflightData:', error);
			this.failing = true;
			this.isLoaded = true;
			this.errorMessage = getErrorMessage.call(this, error);
		});
	}
	callGetCustomer(){
		getCustomer({preApplicationId:this.applicationId})
		.then(res=>{
			let response=res;
			if(response === 'Successful'){
				this.isLoaded=true;
				this.showToast(response,'success');
			}else{
				this.isLoaded=true;
				this.showToast(response,'error')
			}
		})
		.catch(error=>{
			this.isLoaded=true;
			this.showToast('Unexpected Error, Please contact your administrator','error');
			this.logger.error('An error occurred while calling getCustomer API:', error);
		});
	}

	/**
	 * @description handles changes to tax section
	 */
	handleTaxValueChange(event) {
		const { value, target: name, inputsKey, taxDetails } = event.detail;
		this.formDetails[name] = value;
		if (taxDetails !== undefined) {
			this.formDetails[inputsKey] = JSON.parse(taxDetails);
		} else {
			this.formDetails[inputsKey] = {};
		}
		this.removeFieldErrors(name);
	}

	/**
	 * @description handles changes to child components
	 */
	genericComponentChange(event) {
		let value = event.detail.value;
		let name = event.detail.target;
		this.formDetails[name] = value;
		this.removeFieldErrors(name);
	}

	showHiddenDependentFields(event) {
		let name = event.target.dataset.name;
		let value = this.selectedPicklistValue;
		this.formDetails[name] = value;
		let id = event.target.dataset.id;
		for (let j in this.sections) {
			let fields = this.sections[j].fields;
			for (let i in fields) {
				if (fields[i].parent == id) {
					if (value == fields[i].parentControllingValue) {
						fields[i].isHidden = false;
					} else {
						fields[i].isHidden = true;
						for (let l in fields) {
							if (fields[l].parent == fields[i].id) {
								fields[l].isHidden = true;
							}
						}
					}
				}
			}
			this.sections[j].fields = fields;
			fields.sort(function (a, b) {
				return parseFloat(a.sequence) - parseFloat(b.sequence);
			});
		}
	}

	genericComponentChangeBlur(event) {
		let value = event.detail.value;
		this.selectedPicklistValue = value;
		this.showHiddenDependentFields(event);
		let name = event.detail.target;
		this.formDetails[name] = value;
		this.removeFieldErrors(name);
		this.checkFieldOnTabOff(name);
	}

	/**
	 * @description method to check if field is empty on blur
	 */
	checkFieldOnTabOff(name) {
		for (let j in this.sections) {
			for (let i in this.sections[j].fields) {
				if (name === this.sections[j].fields[i].name) {
					this.sections[j].fields[i].showError = false;
					if (!this.formDetails[name] && !this.sections[j].fields[i].isHidden && this.sections[j].fields[i].isRequired) {
						this.sections[j].fields[i].showError = true;
					}
				}
			}
		}
	}

	/**
	 * @description handles changes to multiselectfilter comp
	 */
	genericMSComponentChange(event) {
		let value = event.detail.inputs;
		let name = event.detail.target;
		let selection = event.detail.selection;
		this.formDetails[name] = "";
		if (this.isValidMultiselect(value, selection)) {
			this.formDetails[name] = value;
			this.removeFieldErrors(name);
		}
	}

	isValidMultiselect(arrayOfInputs, selection) {
		let truth = false;
		if (arrayOfInputs != undefined && selection != undefined) {
			let inptArray = JSON.parse(arrayOfInputs);
			let values = Object.values(inptArray);
			let trueValuesLength = [];
			for (let i = 0; i < values.length; i++) {
				if (values[i] != "") trueValuesLength.push(values[i]);
			}
			if (JSON.parse(selection).length == trueValuesLength.length) {
				truth = true;
			}
		}
		return truth;
	}

	/**
	 * @description handles changes to input fields
	 */
	genericFieldChange(event) {
		let value = event.target.value;
		let name = event.target.dataset.name;
		this.formDetails[name] = value;
		this.removeFieldErrors(name);
	}
	getFieldsF() {
		getFields({
			'applicationId': this.applicationId,
			'screenName': this.screenName
		})
		.then(result => {
			this.isLoaded = true;
			this.form = result;
			this.screenTitle = result.title;
			this.screenSubtitle = result.subtitle;
			this.sections = result.sections.sort((a, b) => (a.rank > b.rank) ? 1 : -1);
			this.sections.forEach(element => {
				element.fields.forEach(fieldName => {
					if (fieldName.name == 'citizenship' && this.isSACitizenship) {
						fieldName.isHidden = false;
						fieldName.isCombobox = false;
						fieldName.isRequired = false;
						delete fieldName.label;
					}
				});
			});
			this.gridClass = 'aob_form_input slds-col slds-m-top_small slds-small-size_1-of-' + this.smallDeviceColumns + ' slds-medium-size_1-of-' + this.mediumDeviceColumns + ' slds-large-size_1-of-' + this.largeDeviceColumns;
			this.loadExisitngData();
			this.isAtScreenLoad = true;
		})
		.catch(error => {
			this.logger.error('An error occurred while calling getFields:', error);
			this.failing = true;
			this.isLoaded = true;
			this.errorMessage = getErrorMessage.call(this, error);
		});

	}
	/*
	* @description fetch  inflight data of the application based on current screen
	*/
	prepopulateExistingData() {
		loadInflightData({
			'appId': this.applicationId,
			'screenName': this.screenName
		})
		.then(result => {
			if (result) {
				this.formDetails = JSON.parse(result);
			}
		}).catch(error => {
			this.logger.error('An error occurred while calling loadInflightData:', error);
			this.failing = true;
			this.errorMessage = getErrorMessage.call(this, error);
		});
	}

	//pre-populate default values into current screen
	loadExisitngData() {
		if (this.formDetails) {
			for (let j in this.sections) {
				let fields = this.sections[j].fields;
				for (let i in fields) {
					if (this.sections[j].fields[i].isTax) {
						this.sections[j].fields[i].taxInputs = this.formDetails.taxInputs;
					}
					if (this.sections[j].fields[i].isImageCheckbox) {
						if (this.sections[j].fields[i].name == 'receiveInStore') this.sections[j].fields[i].defaultValue = this.formDetails['receiveInStore'];
						if (this.sections[j].fields[i].name == 'receiveOnline') this.sections[j].fields[i].defaultValue = this.formDetails['receiveOnline'];
					}
					let fieldName = this.sections[j].fields[i].name;
					let fieldId = this.sections[j].fields[i].id;
					if (this.formDetails[fieldName]) {
						this.sections[j].fields[i].defaultValue = this.formDetails[fieldName];
						for (let j in this.sections) {
							let fields = this.sections[j].fields;
							for (let i in fields) {
								if (fields[i].parent == fieldId) {
									if (this.formDetails[fieldName] == fields[i].parentControllingValue) {
										fields[i].isHidden = false;
									} else {
										fields[i].isHidden = true;
									}
								}
							}
							this.sections[j].fields = fields;
							fields.sort(function (a, b) {
								return parseFloat(a.sequence) - parseFloat(b.sequence);
							});
						}
					}
				}
			}
		}
	}

	formatLabel() {
		for (let j in this.sections) {
			let fields = this.sections[j].fields;
			for (let i in fields) {
				if (fields[i].label) {
					let originalLabel = fields[i].label;
					fields[i].label = fields[i].label.replace('#', '\r\n');
				}
			}
		}
	}

	genericCheckboxChange(event) {
		let name = event.target.dataset.name;
		let value = event.target.checked;
		this.formDetails[name] = value;
	}
	genericRadioChange(event) {
		let name = event.target.dataset.name;
		let value = event.target.dataset.value;
		this.formDetails[name] = value;
		let id = event.target.dataset.id;
		this.removeFieldErrors(name);
		if (event.target.dataset.name == 'OwnerType') this.isSoleOwnership = event.target.dataset.value;
		if (event.target.dataset.name == 'BusinessRegistered') this.isBusinessReg = event.target.dataset.value;
		for (let j in this.sections) {
			let fields = this.sections[j].fields;
			for (let i in fields) {
				if (fields[i].parent == id) {
					if (value == fields[i].parentControllingValue) {
						fields[i].isHidden = false;
					} else {
						fields[i].isHidden = true;
						fields[i].defaultValue = '';
						delete this.formDetails[fields[i].name];
						if (fields[i].isTax) {
							delete this.formDetails['taxInputs'];
							fields[i].taxInputs = {};
						}
						for (let l in fields) {
							if (fields[l].parent == fields[i].id) {
								fields[l].isHidden = true;
								fields[i].defaultValue = '';
								delete this.formDetails[fields[l].name];
							}
						}
					}
				}
			}
			this.sections[j].fields = fields;
			fields.sort(function (a, b) {
				return parseFloat(a.sequence) - parseFloat(b.sequence);
			});
		}
	}

	/**
	 * @description Method to rorder fields
	 */
	reorderFields() {
		for (let j in this.sections) {
			let fields = this.sections[j].fields;
			fields.sort(function (a, b) {
				return parseFloat(a.sequence) - parseFloat(b.sequence);
			});
		}
	}

	/**
	 * @description Method to remove errors
	 */
	removeFieldErrors(name) {
		for (let j in this.sections) {
			for (let i in this.sections[j].fields) {
				if (name === this.sections[j].fields[i].name) {
					this.sections[j].fields[i].showError = false;
				}

			}
		}
	}

	/**
	 * @description Method to remove errors
	 */
	removeError(element) {
		element.setCustomValidity("");
		element.reportValidity();
		for (let j in this.sections) {
			for (let i in this.sections[j].fields) {
				if (element.dataset.id === this.sections[j].fields[i].id) {
					this.sections[j].fields[i].showError = false;
				}

			}
		}
	}

	/**
	 * @description method to check if there are any unfilled fields
	 */
	checkForm() {
		let isValid = true;
		for (let j in this.sections) {
			for (let i in this.sections[j].fields) {
				this.sections[j].fields[i].showError = false;
				if (!this.sections[j].fields[i].isHidden && this.sections[j].fields[i].isRequired) {
					if (!this.formDetails[this.sections[j].fields[i].name]) {
						this.sections[j].fields[i].showError = true;
						isValid = false;
					}
				}
			}
		}
		if (this.template.querySelector('c-aob_internal_comp_tax')) {
			this.template.querySelector('c-aob_internal_comp_tax').triggerBlur();
		}
		return isValid;
	}

	isInputValid() {
		let isValid;

		let inputFields = this.template.querySelectorAll('.validate');

		if(inputFields.length == 0){

			isValid = true;

		}else if(inputFields.length !== 0){

			inputFields.forEach(inputField => {

				if(!inputField.checkValidity()) {

					inputField.reportValidity();

					isValid = false;

				}else{

					isValid = true;

				}

			});

		}
		return isValid;
	}
	updateCompanyDetailRan(){
		getInflight({appId:this.applicationId,screenName:'Company Detail Ran'})
		.then(res=>{
			if(res==null){
				this.callCompanyDetailsAPI();
			}
			else{
				this.showCompliance();
			}
		})
		.catch(error=>{
			this.logger.error('An error occurred while calling getInflight:', error)
		});
	}
	checkCompanyAPI(){
		isNewCompanyRan({applicationId:this.applicationId})
		.then(result=>{
		})
		.catch(error=>{
			this.logger.error('An error occurred while calling isNewCompanyRan:', error)
		})
	}
	showCompliance(){
		this.outstandingCompliance=false;
	}
	setApplicationData(){
		setApplicationData({
			'applicationId': this.applicationId,
			'appData': JSON.stringify(this.formDetails)
		}).then(result => {
			if (this.screenName == 'Employment Details') {
				this.callPersonalDetailsAPI();
			}
			else if (this.screenName == 'Marketing Consent'||this.screenName == 'Marketing Consent Internal') {
				this.updateCompanyDetailRan();
			}
			else{
				this.handleClicks();
			}
		}).catch(error => {
			this.logger.error('An error occurred while calling setApplicationData:', error)
			this.failing = true;
			this.errorMessage = getErrorMessage.call(this, error);
			window.fireErrorCodeEvent(this, this.errorMessage);
		});
	}
	/**
	 * @description method to move to next screen
	 */
	continueToNextPage() {
		if(this.isInputValid()){
			if (this.checkForm()) {
				if (this.validateForm()) {
					if (this.screenName == 'SnapScan') {
						if(this.validateImageCheckbox()){
							this.HandleSnapScan();
							this.isLoaded = false;
							this.updateScreen();
						}else{
							const message = `Please select "Receive payments in-store" or/and "Receive payments online" checkboxes`;
							this.showToast(message,'warning');

						}
					}else{
						this.isLoaded = false;
						this.updateScreen();
					}
				}
			}
		}
	}

	changeFromCompliance(event){
		this.handleClicks();
		this.applicationId=event.detail;
		this.screenName='Card Selection';
		this.previousScreen='Marketing Consent Internal';
		this.updateScreen();

	}

	handleProgressValueChange(event) {
		this.outstandingCompliance = event.detail;
	}

	showToast(message,variant) {
		const event = new ShowToastEvent({
			variant:variant,
			message:message
		});
		this.dispatchEvent(event);
	}

	cancelErrorPopup(event) {
		this.isLoaded = true;
		this.customerDataError = false;
	}
	callPersonalDetailsAPI() {
		updatePersonalDetails({
			'applicationId': this.applicationId
		}).then(result => {
			let res = JSON.parse(result);
			let response=res[0].message;

			if(response == 'SUCCESSFUL'){
				this.handleClicks();
				this.isLoaded=true;
				this.showToast(response,'success');
			}else{
				this.isLoaded=true;
				this.showToast(response,'error')
			}
		})
		.catch(error=>{
			this.logger.error('An error occurred while calling updatePersonalDetails API:', error)
			this.isLoaded=true;
			this.showToast('Unexpected Error, Please contact your administrator','error')
		});

	}

	callCompanyDetailsAPI() {
		updateCompanyDetails({
			'applicationId': this.applicationId
		}).then(result => {
			var response = JSON.parse(result);
			let success = response.find(item => item.responseCode == 200);
			if (success) {
				this.outstandingCompliance=false;
				this.isLoaded = true;
				this.checkCompanyAPI();
				this.callGetRPAndUpdateRP();
			}

		}).catch(error => {
			this.logger.error('An error occurred while calling updateCompanyDetails API:', error)
			this.failing = true;
			this.isLoaded = true;
			this.technicalerror = true;
			this.errorMessage = getErrorMessage.call(this, error);
			this.siteerror='service error | '+this.errorMessage;
		});

	}
	validateImageCheckbox() {
		let isReceiveInStoreSelected = this.formDetails['receiveInStore'];
		let isReceiveOnlineSelected = this.formDetails['receiveOnline'];
		return isReceiveInStoreSelected || isReceiveOnlineSelected;
	}

	HandleSnapScan () {
		updateinflight({
			'code': 'ZPSS',
			'json': JSON.stringify(this.formDetails),
			'applicationId': this.applicationId
		}).then(result => {
		}).catch(error => {
			this.logger.error('An error occurred while calling updateinflight:', error)
			this.failing = true;
			this.isLoaded = true;
			this.errorMessage = getErrorMessage.call(this, error);
		});
	}

	callGetRPAndUpdateRP() {
		CallGetApplication({
			'applicationId': this.applicationId
		}).then(result => {
		}).catch(error => {
			this.logger.error('An error occurred while calling CallGetApplication:', error)
			this.failing = true;
			this.isLoaded = true;
			this.technicalerror = true;
			this.errorMessage = getErrorMessage.call(this, error);
			this.siteerror='service error | '+this.errorMessage;
		});
	}

	/**
	 * @description method to move to previous screen
	 */
	backToPreviousPage(event) {
		this.handleBackClick();
		this.updatePreviousScreen();
	}

	/**
	 * @description method to redirect back to where the user is coming from
	 */
	backToHome(event) {
	}

	/**
	 * @description Method to check if all required fields are filled
	 */
	validateForm() {
		let isValid = true;
		this.template.querySelectorAll('lightning-input').forEach(element => {
			this.removeError(element);
			if (element.required && !element.value) {
				element.setCustomValidity(element.dataset.errorMessage);
				element.reportValidity();
				element.focus();
				isValid = false;
			} else if (!element.reportValidity()) {
				isValid = false;
			}
		});

		this.template.querySelectorAll('lightning-radio-group').forEach(element => {
			this.removeError(element);
			if (element.required && !element.value) {
				element.setCustomValidity(element.dataset.errorMessage);
				element.reportValidity();
				element.focus();
				isValid = false;
			} else if (!element.reportValidity()) {
				isValid = false;
			}
		});

		this.template.querySelectorAll('lightning-combobox').forEach(element => {
			this.removeError(element);
			if (element.required && !element.value) {
				element.setCustomValidity(element.dataset.errorMessage);
				element.reportValidity();
				element.focus();
				isValid = false;
			} else if (!element.reportValidity()) {
				isValid = false;
			}
		});

		this.template.querySelectorAll('input').forEach(element => {
			for (let j in this.sections) {
				for (let i in this.sections[j].fields) {
					if (element.dataset.id === this.sections[j].fields[i].id && !this.formDetails[element.dataset.name]) {
						this.sections[j].fields[i].showError = true;
						isValid = false;
					}

				}
			}
		});
		if (this.displayMSError) {
			this.getMsError = true;
			isValid = false;
		}
		return isValid;
	}
	updateScreen(){
		updateScreen({
			'applicationId': this.applicationId,
			'currentScreen': this.screenName,
			'previousScreen': this.previousScreen
		}).then(result => {
			this.setApplicationData();
		})
		.catch(error => {
			this.logger.error('An error occurred while calling updateScreen:', error)
			this.failing = true;
			this.errorMessage = getErrorMessage.call(this, error);
		});
	}
	updatePreviousScreen(){
		updatePreviousScreen({
			'applicationId': this.applicationId,
			'currentScreen': this.screenName,
			'previousScreen': this.previousScreen
		}).then(result => {
		})
		.catch(error => {
			this.logger.error('An error occurred while calling updatePreviousScreen:', error)
			this.failing = true;
			this.errorMessage = getErrorMessage.call(this, error);
		});
	}
	storeSelectedImagesData(event) {
		let name = event.detail.formName;
		let value = event.detail.checkboxc;
		this.formDetails[name] = value;
	}

}