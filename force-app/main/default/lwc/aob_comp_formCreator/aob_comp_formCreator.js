import { LightningElement, track, api, wire } from 'lwc';
/*Apex Actions */
import getFields from '@salesforce/apex/AOB_CTRL_FormCreator.getFields';
import setApplicationData from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationData';
import setApplicationStep from '@salesforce/apex/AOB_CTRL_FormCreator.setApplicationStep';
import goBacktoPreviousStep from '@salesforce/apex/AOB_CTRL_FormCreator.goBacktoPreviousStep';
import FireAdobeEvents from '@salesforce/resourceUrl/FireAdobeEvents';
import { NavigationMixin } from "lightning/navigation";
import loadInflightData from '@salesforce/apex/AOB_CTRL_FormCreator.setExistingData';
import updateinfilght from '@salesforce/apex/AOB_CTRL_FormCreator.updateinfilght';
import createExternalLead from "@salesforce/apex/AOB_API_BusinessLead_CTRL.callBusinessLead";
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import { getErrorMessage } from 'c/aob_comp_utils';
import { loadScript } from 'lightning/platformResourceLoader';
import isSACitizen from '@salesforce/apex/AOB_CTRL_FormCreator.isSACitizen';
import incrementRetryApplication from '@salesforce/apex/AOB_CTRL_FindApplications.incrementRetryApplication';
import updatePersonalDetails from '@salesforce/apex/AOB_CTRL_FormCreator.updatePersonalDetails';
import updateCompanyDetails from '@salesforce/apex/AOB_CTRL_FormCreator.updateCompanyDetails';
import CallGetRPDetails from '@salesforce/apex/AOB_SRV_GetRPconfig.callGetRP';
import CallUpdateRPDetails from '@salesforce/apex/AOB_SRV_UpdateRPConfig.callUpdateRP';
import getApplicantDataForAdobe from '@salesforce/apex/AOB_CTRL_FormCreator.getApplicantDataForAdobe';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import getCustomerBeforeMarketing from '@salesforce/apex/AOB_CTRL_GetCustomer.getCustomerBeforeMarketing';

const RETRY_NUMBER = 1;
export default class Aob_comp_formCreator extends NavigationMixin(LightningElement) {
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
    //Adobe Tagging
    isEventFired;
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    @api productName;
    adobeDataScopeApp;
    adobeDataTextBack;
    retryValue;
    siteErrorCode;
    leadReason = 'PIP status true'
    adobeDataTextContinue;
    showBackButton;
    showNextButton;
    @api applicationId;
    @api screenName;
    @api previousScreen;
    @api nextScreen;
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
    isSACitizenship;
    selectedPicklistValue;
    showBackB = true;
    customerDataError;
    customerErrorMessage;
    @track isSoleOwnership;
    @track isBusinessReg;
    isCompanyAPISucess = false;
    adobeformName;
    application = {
        applicationProduct: this.adobeDataScope,
        applicationMethod: "Online",
        applicationID: "",
        applicationName: "",
        applicationStep: this.adobeDataScope,
        applicationStart: true,
        applicationComplete: false,
    }
    userInfo = {
        bpguid: "",
        encryptedUsername: ""
    }

    renderedCallback() {
        if (this.isAtScreenLoad) {
            this.isAtScreenLoad = false;
            // Default radio buttons as per reference data on screen load only            
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

        // Adobe screen load event called
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
        if (this.availableActions.find(action => action === this.constants.NEXT)) { this.showNextButton = true; }
        if (this.availableActions.find(action => action === this.constants.BACK)) { this.showBackButton = true; }

        this.productName = this.productName.toLowerCase();
        this.adobeDataTextBack = this.adobePageName + ' | back button click';
        this.adobeDataTextContinue = this.adobePageName + ' | continue button click';
        this.adobeformName = "apply now " + this.productName + " business account ";
        if (this.screenName == 'Personal Details') {
            this.showBackB = false;
            isSACitizen({
                'appId': this.applicationId
            }).then(result => {
                this.isSACitizenship = result;
            }).catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                window.fireErrorCodeEvent(this, this.errorMessage);
            });

        }
        if (this.screenName == 'Card Delivery') {
            this.showBackB = false;

        }

        this.fireAllAdobeEvents();

        setApplicationStep({
            'applicationId': this.applicationId,
            'currentScreen': this.screenName,
            'previousScreen': this.previousScreen
        }).then(result => {
            this.failing = false;
        })
            .catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                window.fireErrorCodeEvent(this, this.errorMessage);
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
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                window.fireErrorCodeEvent(this, this.errorMessage);
            });
    }

    /**
     * @description handles changes to tax section
     */
    handleTaxValueChange(event) {
        let value = event.detail.value;
        let name = event.detail.target;
        this.formDetails[name] = value;
        this.formDetails[event.detail.inputsKey] = JSON.parse(event.detail.taxDetails);
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
                        //Level 1 : Hide also this field's children
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
        this.removeFieldErrors(name);
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
            if (JSON.parse(selection).length == 0 && trueValuesLength.length == 0) {
                truth = false;
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
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                window.fireErrorCodeEvent(this, this.errorMessage);
            });

    }

    /**
     * @description handles pre-populate default values into current screen
     */
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
                        //Level 1 : Hide also this field's children
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

    storeSelectedImagesData(event) {
        let name = event.detail.formName;
        let value = event.detail.checkboxc;
        this.formDetails[name] = value;
        this.checkImagesSelectedMethod();
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
        if (this.template.querySelector('c-aob_comp_tax')) {
            this.template.querySelector('c-aob_comp_tax').triggerBlur();
        }
        return isValid;
    }

    /**
     * @description method used to tag the landing on the page
     */
    fireAllAdobeEvents() {

        getApplicantDataForAdobe({
            'applicationId': this.applicationId
        }).then(result => {
            let Response = JSON.parse(result);
            this.userInfo.encryptedUsername = Response['customerEmail'];
            this.userInfo.bpguid = Response['customerGUID'];
            this.userInfo.bpguid = this.userInfo.bpguid.split('-').join('');
            this.userInfo.bpguid = this.userInfo.bpguid.toUpperCase();
            window.fireUserInfoEvent(this, this.userInfo);
        }).catch(error => {
            this.failing = true;
            this.isLoaded = true;
            this.technicalerror = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.siteErrorCode = 'service error | ' + this.errorMessage;
            window.fireErrorCodeEvent(this, this.siteErrorCode);
        });
        this.adobeDataScopeApp = this.productName + ' application';
        this.adobePageTag = 'business:' + 'products and services:bank with us:business bank accounts:' + this.productName + ' account origination ' + this.adobeDataScope + " " + this.adobePageName + " form";
        this.application.applicationID = this.applicationId;

        this.adobeDataScopeApp = this.adobeDataScopeApp;
        this.application.applicationName = 'Application:' + this.productName + ' business account';

        this.application.applicationProduct = this.productName + ' business account';
        this.application.applicationStep = this.adobeDataScope;

        this.adobeformName = "apply now " + 'business bank account ' + this.productName + ' account origination ' + this.adobeDataScope + ' ' + this.screenName.toLowerCase() + " form";
        this.adobePageTag = this.adobePageTag.toLowerCase();
        loadScript(this, FireAdobeEvents).then(() => {
            if (!this.isEventFired) {
                this.isEventFired = true;
                window.fireScreenLoadEvent(this, this.adobePageTag);
                window.fireFormStart(this, this.adobeformName);
                window.fireFormStartEvent(this, this.application);
            }
        });

    }
    adobeAnalyticsPageView() {
        document.dispatchEvent(new CustomEvent('screenload', {
            'detail': {
                formName: this.screenName
            }
        }));
    }

    /**
     * @description method to move to next screen
     */
    continueToNextPage(event) {
        window.fireButtonClickEvent(this, event);
        Object.keys(this.formDetails).forEach(key => {
            if (key == 'undefined') delete this.formDetails[key];
        });
        if (this.checkForm()) {
            if (this.validateForm()) {
                this.isLoaded = false;

                if (this.screenName == 'SnapScan') {
                    this.handleSnapScan();
                } else if (this.screenName == 'Personal Details' && (this.formDetails['PublicOfficial'] === 'true' || this.formDetails['Related'] === 'true')) {
                    this.createLead('PIP status true');

                } else {
                    setApplicationData({
                        'applicationId': this.applicationId,
                        'appData': JSON.stringify(this.formDetails)
                    }).then(result => {

                        if (this.screenName == 'Employment Details') {
                            this.callPersonalDetailsAPI();
                        }
                        else if (this.screenName == 'Marketing Consent') {
                            this.callCompanyDetailsAPI();
                        }
                        else if (this.screenName == 'Residential Address') {
                            this.callGetCustomerAPI();
                        }
                        else {
                            this.continueToNextScreen();
                        }
                    }).catch(error => {
                        this.failing = true;
                        this.isLoaded = true;
                        this.errorMessage = getErrorMessage.call(this, error);
                        window.fireErrorCodeEvent(this, this.errorMessage);
                    });
                }
            } else {
                this.siteErrorCode = 'Client Side | please complete the fields';
                window.fireErrorEvent(this, this.siteErrorCode);
            }
        } else {
            this.siteErrorCode = 'Client Side | please complete the fields';
            window.fireErrorEvent(this, this.siteErrorCode);
        }
    }


    createLeadForAPI(leadReason) {
        createExternalLead({
            applicationId: this.applicationId,
            leadReason: leadReason
        }).then((result) => {
            this.isLoaded = false;
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'PreApplication_Automatic_Lead__c'
                }
            });
        }).catch((error) => {
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.adobePageTag.siteErrorCode = 'service error | ' + this.errorMessage;
            window.fireErrorCodeEvent(this, this.adobePageTag.siteErrorCode);
        });
    }



    createLead(leadReason) {
        createExternalLead({
            applicationId: this.applicationId,
            leadReason: leadReason
        }).then((result) => {
            this.siteErrorCode = 'business error | automatic lead creation';
            window.fireErrorEvent(this, this.siteErrorCode);
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'PreApplication_Automatic_Lead__c'
                }
            });
        }).catch((error) => {
            this.isLoaded = true;
            this.errorMessage = getErrorMessage.call(this, error);
            this.adobePageTag.siteErrorCode = this.errorMessage;
            window.fireErrorEvent(this, this.adobePageTag.siteErrorCode);
        });
    }


    continueToNextScreen() {
        if (this.availableActions.find(action => action === this.constants.NEXT)) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
            window.fireFormCompleteEvent(this, this.adobeformName);
        }
    }

    closeErrorPopup(event){
        this.technicalerror = false;
    }

    retryInitiateAPI(event) {
        this.technicalerror = false;
        this.isLoaded = false;
        incrementRetryApplication({
            'applicationId': this.applicationId
        }).then(response => {
            this.retryValue = parseInt(response);
            if (this.retryValue <= RETRY_NUMBER) {
                if (this.screenName == 'Employment Details') {
                    this.callPersonalDetailsAPI();
                }
                else if (this.screenName == 'Marketing Consent') {
                    if (!this.isCompanyAPISucess) {
                        this.callCompanyDetailsAPI();
                    } else {
                        this.callGetRP();
                    }
                }
                else if (this.screenName == 'Residential Address') {
                    this.callGetCustomerAPI();
                }
            }
            else {
                this[NavigationMixin.Navigate]({
                    "type": "comm__namedPage",
                    attributes: {
                        name: 'retryExceeded__c'
                    }
                });
            }
        }).catch(error => {
            this.isLoaded = true;
        });
    }
    cancelErrorPopup(event) {
        this.isLoaded = true;
        this.customerDataError = false;
    }
    callPersonalDetailsAPI() {
        updatePersonalDetails({
            'applicationId': this.applicationId
        }).then(result => {
            var response = JSON.parse(result);
            let custError = response.find(item => item.responseCode == 200 && item.message != null);
            if (custError) {
                if (this.retryValue === RETRY_NUMBER) {
                    let leadReason = 'Personal Detail API Validation Error: ' + custError.message;
                    this.createLeadForAPI(leadReason);
                } else {
                    this.isLoaded = true;
                    this.customerDataError = true;
                    this.customerErrorMessage = custError.message;
                    this.siteErrorCode = 'business error | ' + this.customerErrorMessage;
                    window.fireErrorEvent(this, this.siteErrorCode);
                }
            }
            else {
                let checkError = response.find(item => item.responseCode != 200 && item.message == null);
                if (checkError) {
                    if (this.retryValue === RETRY_NUMBER) {
                        let leadReason = 'Personal Detail API failed: '+checkError.responseCode;
                        this.createLeadForAPI(leadReason);
                    } else {
                        this.isLoaded = true;
                        this.technicalerror = true;
                        this.siteErrorCode = 'service error | ' + checkError.responseCode;
                        window.fireErrorEvent(this, this.siteErrorCode);
                    }
                }
                else {
                    this.continueToNextScreen();
                }
            }

        }).catch(error => {
            if (this.retryValue === RETRY_NUMBER) {
                let leadReason = 'Personal Detail API failed';
                this.createLeadForAPI(leadReason);
            } else {
                this.failing = true;
                this.isLoaded = true;
                this.technicalerror = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.siteErrorCode = 'service error | ' + this.errorMessage;
                window.fireErrorEvent(this, this.siteErrorCode);
            }
        });

    }

    callCompanyDetailsAPI() {
        updateCompanyDetails({
            'applicationId': this.applicationId
        }).then(result => {
            var response = JSON.parse(result);
            let custError = response.find(item => item.responseCode == 200 && item.message != null);
            if (custError) {
                if (this.retryValue === RETRY_NUMBER) {
                    let leadReason = 'Company Detail API Validation Error: ' + custError.message;
                    this.createLeadForAPI(leadReason);
                } else {
                    this.isLoaded = true;
                    this.customerDataError = true;
                    this.customerErrorMessage = custError.message;
                    this.siteErrorCode = 'business error | ' + this.customerErrorMessage;
                    window.fireErrorEvent(this, this.siteErrorCode);
                }
            }
            else {
                let checkError = response.find(item => item.responseCode != 200 && item.message == null);
                if (checkError) {
                    if (this.retryValue === RETRY_NUMBER) {
                        let leadReason = 'Company Detail API failed: '+checkError.responseCode;
                        this.createLeadForAPI(leadReason);
                    } else {
                        this.isLoaded = true;
                        this.technicalerror = true;
                        this.siteErrorCode = 'service error | ' + checkError.responseCode;
                        window.fireErrorEvent(this, this.siteErrorCode);
                    }
                }
                else {
                    this.isCompanyAPISucess = true;
                    this.callGetRP();
                }
            }

        }).catch(error => {
            if (this.retryValue === RETRY_NUMBER) {
                let leadReason = 'Company Detail API failed ';
                this.createLeadForAPI(leadReason);
            }
            else {
                this.failing = true;
                this.isLoaded = true;
                this.technicalerror = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.siteErrorCode = 'service error | ' + this.errorMessage;
                window.fireErrorEvent(this, this.siteErrorCode);
            }
        });

    }

    callGetCustomerAPI() {
        getCustomerBeforeMarketing({
            'applicationID': this.applicationId
        }).then(result => {
            var response = JSON.parse(result);
            if (response == 200) {
                this.continueToNextScreen();
            }
            else {
                if (this.retryValue === RETRY_NUMBER) {
                    let leadReason = 'Get Customer API Failed In Residential Screen ';
                    this.createLeadForAPI(leadReason);
                }
                else {
                    this.isLoaded = true;
                    this.technicalerror = true;
                    this.siteErrorCode = 'service error | ' + response;
                    window.fireErrorEvent(this, this.siteErrorCode);
                }
            }

        }).catch(error => {
            if (this.retryValue === RETRY_NUMBER) {
                let leadReason = 'Get Customer API Failed In Residential Screen ';
                this.createLeadForAPI(leadReason);
            }
            else {
                this.failing = true;
                this.isLoaded = true;
                this.technicalerror = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.siteErrorCode = 'service error | ' + this.errorMessage;
                window.fireErrorEvent(this, this.siteErrorCode);
            }
        });

    }

    imageCheckBoxError = false;
    handleSnapScan() {
        this.checkImagesSelectedMethod();
        if (this.imageCheckBoxError === false) {
            updateinfilght({
                'code': 'ZPSS',
                'json': JSON.stringify(this.formDetails),
                'applicationId': this.applicationId
            }).then(result => {
                this.continueToNextScreen();
            }).catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
            });
        }
    }
    checkImagesSelectedMethod() {
        let isNoError = [];
        for (let j in this.sections) {
            for (let i in this.sections[j].fields) {
                if (this.sections[j].fields[i].isImageCheckbox) {
                    if (this.formDetails[this.sections[j].fields[i].name]) {
                        isNoError.push(this.sections[j].fields[i].name)
                    }
                }
            }
        }
        if (!(isNoError.length >= 1)) {
            this.imageCheckBoxError = true;
            this.siteErrorCode = 'client side | please select atleast one option';
            window.fireErrorEvent(this, this.siteErrorCode);
            this.isLoaded = true;
        } else {
            this.imageCheckBoxError = false;
        }
    }


    callGetRP() {
        CallGetRPDetails({
            'applicationId': this.applicationId
        }).then(result => {
            let response = JSON.parse(result);
            if (response.statusCode == 200) {
                this.CallUpdateRP(response);
            }
            else {
                if (this.retryValue === RETRY_NUMBER) {
                    let leadReason = 'Get RP API Failed';
                    this.createLeadForAPI(leadReason);
                } else {
                    this.isLoaded = true;
                    this.technicalerror = true;
                    this.siteErrorCode = 'service error | ' + response;
                    window.fireErrorEvent(this, this.siteErrorCode);
                }
            }
        }).catch(error => {
            if (this.retryValue === RETRY_NUMBER) {
                let leadReason = 'Get RP API Failed';
                this.createLeadForAPI(leadReason);
            } else {
                this.failing = true;
                this.isLoaded = true;
                this.technicalerror = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.siteErrorCode = 'service error | ' + this.errorMessage;
                window.fireErrorEvent(this, this.errorMessage);
            }
        });
    }

    CallUpdateRP(response) {
        CallUpdateRPDetails({
            'relparty': response.totalRelPartys,
            'applicationId': this.applicationId,
            'uuid': response.uuid
        }).then(result => {
            if (result == 200) {
                this.continueToNextScreen();
            }
            else {
                if (this.retryValue === RETRY_NUMBER) {
                    let leadReason = 'Updated RP API Failed';
                    this.createLeadForAPI(leadReason);
                } else {
                    this.isLoaded = true;
                    this.technicalerror = true;
                    this.siteErrorCode = 'service error | ' + response;
                    window.fireErrorEvent(this, this.siteErrorCode);
                }
            }
        }).catch(error => {
            if (this.retryValue === RETRY_NUMBER) {
                let leadReason = 'Updated RP API Failed';
                this.createLeadForAPI(leadReason);
            } else {
                this.failing = true;
                this.isLoaded = true;
                this.technicalerror = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.siteErrorCode = 'service error | ' + this.errorMessage;
                window.fireErrorEvent(this, this.errorMessage);
            }
        });
    }

    /**
     * @description method to move to previous screen
     */
    backToPreviousPage(event) {
        window.fireButtonClickEvent(this, event);
        goBacktoPreviousStep({
            'applicationId': this.applicationId
        }).then(result => {
            window.location.reload();

        })
            .catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                this.siteErrorCode = 'service error | ' + this.errorMessage;
                window.fireErrorEvent(this, this.siteErrorCode);

            });
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
}