import { LightningElement, api, track } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import getFields from '@salesforce/apex/AOB_CTRL_FormCreator.getFields';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import { getErrorMessage } from 'c/aob_comp_utils';
import getInflight from '@salesforce/apex/AOB_CTRL_FormCreator.getInflightFromLineItem';
import updateinfilght from '@salesforce/apex/AOB_CTRL_FormCreator.updateinfilght';


export default class Aob_comp_cardDelivery extends LightningElement {
   @api teams = ["Self Assisted"];
    label = {};
    isLoaded = false;
    @api adobeDataScope;
    @api adobePageName;
    @api productCategory;
    @api isModalOpen;
    @api screenName;
    @api applicationId;
    @api adobeformName;
    @api productName;
    siteErrorCode;
    @track form;
    screenTitle;
    screenSubtitle;
    @track sections;
    gridClass;
    isAtScreenLoad;
    @api price;
    @api isNew;
    isLoaded;
     @track iconSize ="medium";
    @track formDetails = {};
    selectedPicklistValue;
    isRendered;
    infoIMG = AOB_ThemeOverrides + '/assets/images/info.png';
    constants = {
        NEXT: 'NEXT',
        BACK: 'BACK'
    }

    closeModal(event) {
        window.fireButtonClickEvent(this, event);
        this.isModalOpen = false;
        const selectedEvent = new CustomEvent("cancel", {
            detail: 'cancel'
        });
        this.dispatchEvent(selectedEvent);
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
    }

    connectedCallback() {
        this.prepopulateExistingData();
        if (window.matchMedia("(max-width: 768px)").matches) {
            this.iconSize ="x-small";
        }
        this.isLoaded = false;
        this.adobeDataTextBack =  ' Card delivery | Close button click';
        this.adobeDataTextContinue =  ' Card delivery | Continue button click';
        this.adobeDataScopeApp = this.productName + ' application';
        this.adobeformName = "apply now " +'business bank account '+ this.productName + ' account origination '+'step 10 ' + "card delivery form";
        this.getFieldsF();

    }
    handleResultChange(event) {
        this.label = event.detail;
    }

    prepopulateExistingData() {
        getInflight({
            'prodCode': 'ZBCH',
            'appId': this.applicationId,
        })
            .then(result => {
                if (result) {
                    this.formDetails = JSON.parse(result);
                }
            }).catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                window.fireErrorEvent(this, this.errorMessage);
            });
    }

    getFieldsF() {
        getFields({
            'applicationId': this.applicationId,
            'screenName': this.screenName
        })
            .then(result => {
                this.form = result;
                this.screenTitle = result.title;
                this.screenSubtitle = result.subtitle;
                this.sections = result.sections.sort((a, b) => (a.rank > b.rank) ? 1 : -1);
                this.gridClass = 'aob_form_input slds-col slds-m-top_small slds-small-size_1-of-' + this.smallDeviceColumns + ' slds-medium-size_1-of-' + this.mediumDeviceColumns + ' slds-large-size_1-of-' + this.largeDeviceColumns;
                this.loadExisitngData();
                this.isAtScreenLoad = true;
                this.isLoaded = true;
            })
            .catch(error => {
                this.failing = true;
                this.isLoaded = true;
                this.errorMessage = getErrorMessage.call(this, error);
                window.fireErrorEvent(this, this.errorMessage);
            });
    }

    loadExisitngData() {
        if (this.formDetails) {
            for (let j in this.sections) {
                let fields = this.sections[j].fields;
                for (let i in fields) {

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

    genericRadioChange(event) {
        this.isRadionBtn = true;
        let name = event.target.dataset.name;
        let value = event.target.dataset.value;
        this.formDetails[name] = value;
        let id = event.target.dataset.id;
        this.removeFieldErrors(name);
        for (let j in this.sections) {
            let fields = this.sections[j].fields;
            for (let i in fields) {
                if (fields[i].parent == id) {
                    if (value == fields[i].parentControllingValue) {
                        fields[i].isHidden = false;
                    } else {
                        fields[i].isHidden = true;
                        var fieldId = fields[i].id;
                        fields[i].defaultValue = '';
                        delete this.formDetails[fields[i].name];

                        for (let j in this.sections) {
                            let fields = this.sections[j].fields;
                            for (let i in fields) {
                                if (fields[i].parent == fieldId) {
                                    if (value == fields[i].parentControllingValue) {
                                        fields[i].isHidden = false;
                                    } else {
                                        fields[i].isHidden = true;
                                        fields[i].defaultValue = '';
                                        delete this.formDetails[fields[i].name];
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

    /**
     * @description handles changes to input fields
     */
    genericFieldChange(event) {
        let value = event.target.value;
        let name = event.target.dataset.name;
        this.formDetails[name] = value;
        this.removeFieldErrors(name);
    }

    removeFieldErrors(name) {
        for (let j in this.sections) {
            for (let i in this.sections[j].fields) {
                if (name === this.sections[j].fields[i].name) {
                    this.sections[j].fields[i].showError = false;
                }

            }
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
                        fields[i].defaultValue = '';
                        delete this.formDetails[fields[i].name];
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


    /**
     * @description handles changes to child components
     */
    genericComponentChange(event) {
        let value = event.detail.value;
        let name = event.detail.target;
        this.formDetails[name] = value;
        this.removeFieldErrors(name);
    }
    removeFieldErrors(name) {
        for (let j in this.sections) {
            for (let i in this.sections[j].fields) {
                if (name === this.sections[j].fields[i].name) {
                    this.sections[j].fields[i].showError = false;
                }

            }
        }
    }

    continueToNextPage(event) {
        Object.keys(this.formDetails).forEach(key => {
            if (key == 'undefined') delete this.formDetails[key];
        });
        window.fireButtonClickEvent(this, event);
        if (this.checkForm()) {
            if (this.validateForm()) {
                updateinfilght({
                    'code': 'ZBCH',
                    'json': JSON.stringify(this.formDetails),
                    'applicationId': this.applicationId
                }).then(result => {
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                    window.fireFormCompleteEvent(this, this.adobeformName);
                }).catch(error => {
                    this.failing = true;
                    this.errorMessage = getErrorMessage.call(this, error);
                    window.fireErrorEvent(this, this.errorMessage);
                });
            }else{
                this.siteErrorCode='Client Side | please complete the fields';
                window.fireErrorEvent(this, this.siteErrorCode);
            }
        }else{
                this.siteErrorCode='Client Side | please complete the fields';
                window.fireErrorEvent(this, this.siteErrorCode);
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
        return isValid;
    }

    validateForm() {
        let isValid = true;
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
        return isValid;
    }
}