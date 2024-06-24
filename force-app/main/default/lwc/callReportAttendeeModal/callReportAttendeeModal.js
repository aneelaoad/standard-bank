import { api, track, wire } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor'
import { publish, MessageContext } from 'lightning/messageService';
import callReportModalEvent from '@salesforce/messageChannel/callReportModalEvent__c';
import LightningModal from 'lightning/modal';
import getAttendeeData from '@salesforce/apex/CallReportAttendeeModalController.getAttendeeData';
import getContactSuggestion from '@salesforce/apex/CallReportAttendeeModalController.getContactSuggestions';
import saveAttendees from '@salesforce/apex/CallReportAttendeeModalController.saveAttendees';
import isBCBUser from '@salesforce/apex/CallReportAttendeeModalController.isBCBUser';


export default class CallReportAttendeeModal extends LightningModal {

    @api recordId;
    @api isInternal;
    @api isQuickAction;

    showSpinner = true;
    showInputSpinner = false;
    statusValues = [];
    showAdditional = false;
    showNothingToSuggest = false;
    errorMessage = undefined;
    @track headerValue = '';
    @track roleOrTitle = '';
    @track distance ;
    dropdownStyle = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track data = [];
    @track suggestions = [];
    _timeout = null;
    _scrollIntoInput = false;
    _inputFocus = false;
    _isInternal;
    _isBCBUser= false;
    _distanceDisabled = false;
    _data = new Map();
    _suggestions = new Map();

    get modalBodyStyle() {
        let size = '85vh';
        if(this.showForDesktop) {
            size = 'auto';
        }
        return 'height: ' + size + '; width: 100%; overflow-y: auto; min-height: 30vh';
    }

    get showForDesktop() {
        return formFactorPropertyName === 'Large';
    }

    connectedCallback() {
            getAttendeeData({idEventReport: this.recordId, isInternal: this.isInternal})
            .then((response) => {
                this.errorMessage = undefined;
                if(this.isInternal === 'true') {
                    this.headerValue = 'Add Internal Attendees';
                    this.roleOrTitle = 'Client Team Role';
                    this.distance = '  Distance      ';
                    this._isInternal = true;

                }else {
                    this.headerValue = 'Add External Attendees';
                    this.roleOrTitle = 'Title';
                    this._isInternal = false;
                }

                isBCBUser()
                .then(result => {
                    this._isBCBUser= result;
                })
                .catch((error) => {
                    this.errorMessage = error;
                    this.showSpinner = false;
                });

                response.attendeeWrappers.forEach(value => {
                    this._data.set(value.contactId, {...value});
                });
                this.data = [...response.attendeeWrappers];
                let statusValues = [];
                response.statusValues.forEach( value => {
                    let temp = value.split('%%%');
                    statusValues.push({
                        value: temp[0],
                        label: temp[1]
                    });
                });
                this.statusValues = statusValues;
                this.showSpinner = false;

            })
            .catch((error) => {
                this.errorMessage = error;
                this.showSpinner = false;
            });
    }

    renderedCallback() {
        if (this._scrollIntoInput) {
            let inputField = this.template.querySelector('[data-id="combobox-input-id-1"]');
            if (inputField) {
                inputField.scrollIntoView();
                if (this._inputFocus) {
                    inputField.focus();
                    this._inputFocus = false;
                }
                this._scrollIntoInput = false;
                this.showInputSpinner = false;
            }
        }
    }

    @wire(MessageContext)
    messageContest;

    handleCancel(params) {
        let eventName = this.isQuickAction === 'true' ? 'handleFromCallReportQuickAction' : 'handleFromCallReportModal';
        let toastInfo = undefined;
        if(params && params.title && params.variant && params.message) {
            toastInfo = params;
        }
        let payload = {eventName: eventName, params: toastInfo};
        publish(this.messageContest, callReportModalEvent, payload);
    }

    handleAddRemove(event) {
        let recordId = event.currentTarget.dataset.item;
        let tempRecord = this._data.get(recordId);
        tempRecord.addRemove = !tempRecord.addRemove;
        this._data.set(recordId, tempRecord);
    }

    handleAddRow() {
        this.showAdditional = true;
        this._scrollIntoInput = true;
        this._inputFocus = true;
    }

    onInput(event) {
        clearTimeout(this._timeout);
        this._timeout = setTimeout(() => {
            this.errorMessage = undefined;
            this.showNothingToSuggest = false;
            let input = this.template.querySelector('[data-id="combobox-input-id-1"]');
            if (input) {
                let searchValue = input.value;
                if(searchValue.length > 1) {
                    this.showInputSpinner = true;
                    getContactSuggestion({
                        searchValue: searchValue, isInternal: this.isInternal
                    }).then((result) => {
                        let tempArray = [];
                        Object.entries(result).forEach(([key, value]) => {
                            this._suggestions.set(key, value);
                            tempArray.push({Id: key, Name: value[0], AccountName: value[1]});
                        });
                        if (tempArray.length > 0) {
                            this.dropdownStyle = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
                            this.suggestions = tempArray;
                            this._scrollIntoInput = true;
                        }else {
                            this.showNothingToSuggest = true;
                            this._scrollIntoInput = true;
                            this.suggestions = [];
                            this._suggestions.clear();
                        }
                    }).catch((error) => {
                        this.errorMessage = error;
                        this.showInputSpinner = false;
                    });
                }else {
                    this.showNothingToSuggest = false;
                    this.suggestions = [];
                    this._suggestions.clear();
                    this.showInputSpinner = false;
                    this.dropdownStyle = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
                }
            }
        }, 1000);
    }

    handleSelectSuggestion(event) {
        let contactId = event.currentTarget.dataset.item;
        if(this._data.has(contactId)) {
            let tempRecord = this._data.get(contactId);
            tempRecord.addRemove = true;
            tempRecord.status = 'Attended';
            this._data.set(contactId, tempRecord);
            let newData = [];
            this.data.forEach(value => {
                if(value.contactId != contactId) {
                   newData.push(value);
                }
            });
            newData.push(tempRecord);
            this.data = newData;
        }else {
            let tempContact = this._suggestions.get(contactId);
            let newRecord = {
                addRemove: true,
                isOwner: false,
                contactName: tempContact[0],
                roleName: '',
                contactTitle: '',
                status: 'Attended',
                accountName: tempContact[1],
                contactId: contactId
            };
            this.data.push(newRecord);
            this._data.set(contactId, newRecord);
        }

        this.showAdditional = false;
        this.suggestions = [];
        this.showNothingToSuggest = false;
        this._suggestions.clear();
        this.dropdownStyle = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    }

    handleCloseSuggestion() {
        this.showAdditional = false;
        this.showNothingToSuggest = false;
        this.suggestions = [];
        this.dropdownStyle = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';

    }

    handleStatusChange(event) {
        let contactId = event.currentTarget.dataset.item;
        let value = event.detail.value;
        let tempRecord = this._data.get(contactId);        
        tempRecord.status = value;   
        if(this._isInternal){
         tempRecord.distance = value == 'Attended' ? tempRecord.distance : null; 
        }   
        this._data.set(contactId, tempRecord);  
        
        for(let x = 0; x < this.data.length; x++){
        if(this.data[x].contactId == contactId){          
            this.data[x].status = value;
            if(this._isInternal){
                this.data[x].disabledDistance = value == 'Attended' ? false : true;   
                this.data[x].distance =  value == 'Attended' ? this.distance[x].distance : null; 
            }
                           
         }   
        }    
    }

    handleDistanceInput(event) {
        let contactId = event.currentTarget.dataset.item;
        let value = event.detail.value;
        let tempRecord = this._data.get(contactId);
        tempRecord.distance = value;
        this._data.set(contactId, tempRecord);

    }

    handleSave() {
        this.showSpinner = true;
        let updatedData = [];

        for(let x = 0; x < this.data.length; x++){
            let attendee = this._data.get(this.data[x].contactId);
            if (attendee.status == 'Attended' && (attendee.distance == null || attendee.distance === '') && this._isBCBUser && this._isInternal) {
                let eventName = this.isQuickAction === 'true' ? 'handleFromCallReportQuickAction' : 'handleFromCallReportModal';
                let row = x + 1;
                let params = {
                    title: 'Warning',
                    variant: 'Warning', 
                    message: 'row ' + row + ' Status is Attended with no distance.'
                };
                let payload = {eventName: eventName, params: params};
                publish(this.messageContest, callReportModalEvent, payload);
                this.showSpinner = false;
                return null;
                
            }
        }

        for( const value of this._data.values()) {            
            updatedData.push(value);
        }
        saveAttendees({
            recordId: this.recordId,
            updatedData: JSON.stringify(updatedData),
            isInternal: this.isInternal
        }).then(result => {
            let title, variant, message;
            if (result.startsWith('An Error occurred')) {
                title = 'Error',
                variant = 'Error';
                message = result;
            }else if (result === 'SUCCESS' || result.startsWith('Internal core warning')) {
                title = 'Success';
                variant = 'Success';
                message = 'The list of the records was updated';
            }else {
                title = 'Warning';
                variant = 'Warning';
                message = result;
            }
            this.showSpinner = false;
            let params = {
                title: title,
                variant: variant,
                message: message
            };
            this.handleCancel(params);
        }).catch(error => {
            this.errorMessage = error;
            this.showSpinner = false;
        });
    }
}