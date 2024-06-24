/**
* @description  :  Partner Portal Support Form Component
* User Story : SFP-5296
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import createCase from '@salesforce/apex/PP_Support_CTRL.createCase';
import { getRecord } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import Partner_Object from '@salesforce/schema/PP_PartnerApplication__c';
import OperatingCountry_Field from '@salesforce/schema/PP_PartnerApplication__c.PP_OperatingCountry__c';
import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation'
import { trackLink } from 'c/ppEventUtils'

const FIELDS = [
    'User.ContactId',
    'User.AccountId',
];

export default class PpCustomerSupport extends NavigationMixin(LightningElement){

    @api
    breadcrumbOneUrl;
    @api
    breadcrumbTwoUrl;
    @api
    redirectUrl;
    supportImage;
    thankYouScreenImage;
    breadcrumbArrowIcon;
    message;
    isValid = true;
    validationError = "";
    textAreaStyle = "textarea";
    isModalOpen = false;
    firstName = '';
    lastName = '';
    case = { 'sobjectType': 'Case' };
    usrId = userId;
    isProcessing = false;
    countryOptions = [];
    adobeEventFired = false;

    @wire(getRecord, { recordId: userId, fields: FIELDS })
    wiredUserRecord({ error, data }) {
        if (data) {
            this.case.ContactId = data.fields.ContactId.value;
            this.case.AccountId = data.fields.AccountId.value;
        }
    }

    @wire(getObjectInfo, { objectApiName: Partner_Object })
    partnershipObj;

    @wire(getPicklistValues, {
        recordTypeId: '$partnershipObj.data.defaultRecordTypeId',
        fieldApiName: OperatingCountry_Field
    })
    getIndustryPicklistValues({ error, data }) {
        if (data) {
            for(let i=0; i<data.values.length; i++){
                if(data.values[i].label === 'South Africa' ||
                 data.values[i].label === 'Uganda' || data.values[i].label === 'Ghana'){
                this.countryOptions = [...this.countryOptions, data.values[i]];
                }
            }
        }
    }


    connectedCallback() {
        this.case.Type = 'Service Request';
        this.case.Origin = "Partner Portal";
        this.breadcrumbArrowIcon = Assets + '/Icons/flechitaBreadcrumb.png';
        this.supportImage = Assets + '/images/group-10@3x.png';
        this.thankYouScreenImage = Assets + '/images/group-11@3x.png';
        let path = basePath.split('/s')[0];
        if(path === ''){
          this.breadcrumbOneUrl = '/s'+this.breadcrumbOneUrl;
          this.breadcrumbTwoUrl = '/s'+this.breadcrumbTwoUrl;
          this.redirectUrl = '/s'+this.redirectUrl;
        }else{
          this.breadcrumbOneUrl = path+'/s'+this.breadcrumbOneUrl;
          this.breadcrumbTwoUrl = path+'/s'+this.breadcrumbTwoUrl;
          this.redirectUrl = path+'/s'+this.redirectUrl;
        }

    }

    handleInputChange(event) {
       
        if (this.adobeEventFired === false) {
            document.dispatchEvent(new CustomEvent('triggerInteraction', {
                'detail': {
                    eventName: 'globalFormStart',
                    formName: "group | Customer Support Form",
                    formIsSubmitted: false,
                    formStatus: ""
                }
            }));
            this.adobeEventFired = true;
        }

        if (event.target.name === 'supportType') {

            if (event.target.value == 'Support') {
                this.case.Type = 'Service Request';
            } else {
                this.case.Type = event.target.value;
            }
        } else if (event.target.name === 'firstName') {
            this.firstName = event.target.value;
            let inputCmp = this.template.querySelector('.' + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name === 'lastName') {
            this.lastName = event.target.value;
            let inputCmp = this.template.querySelector('.' + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name === 'email') {
            this.case.SuppliedEmail = event.target.value;
            let inputCmp = this.template.querySelector('.' + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name === 'phone') {
            this.case.SuppliedPhone = event.target.value;
            let inputCmp = this.template.querySelector('.' + event.target.name);
            inputCmp.setCustomValidity("");
        } else if (event.target.name === 'messegeSubject') {
            this.case.Subject = event.target.value;
            let inputCmp = this.template.querySelector('.' + event.target.name);
            inputCmp.setCustomValidity("");
        }else if (event.target.name === 'Country') {
            this.case.Case_Country__c = event.detail.value;
            let inputCmp = this.template.querySelector('.' + event.target.name);
            inputCmp.setCustomValidity("");
        }
    }

    messageHandleChange() {
        let msg = this.template.querySelector('textarea');
        this.case.Description = msg.value;
        this.textAreaStyle = "textarea";
        this.validationError = "";
    }

    handleSubmit() {
        this.isValid = true;
        this.formValidation('lightning-input');
        this.formValidation('textarea');
        this.formValidation('lightning-combobox');

        if (this.isValid) {
            this.case.SuppliedName = this.firstName + ' ' + this.lastName;
            this.createSupportCase();
        }
    }

    createSupportCase() {
        this.isProcessing = true;
        createCase({ newCase: this.case }).then(response => {
            this.isProcessing = false;
            this.isModalOpen = true;
            
            //Adobe Analytics Event
             document.dispatchEvent(new CustomEvent('triggerInteraction', {
                'detail': {
                  eventName: 'globalFormComplete',
                  formName: "group | Customer Support Form",
                  formIsSubmitted : true,
                  formStatus : "submitted"
                }
              }));

        }).catch(error => {
            this.isProcessing = false;
            this.toast('Server Error', 'error');
        });
    }


    formValidation(inputType) {
        let fieldErrorMsg = "Please Enter";
        this.template.querySelectorAll(inputType).forEach(item => {
            let fieldValue = item.value;
            let fieldLabel = item.label;

            if (inputType == 'textarea') {
                if (!fieldValue) {
                    this.validationError = fieldErrorMsg + ' ' + item.name;
                    this.isValid = false;
                    this.textAreaStyle += " error";
                } else {
                    this.validationError = "";
                    this.textAreaStyle = "textarea";
                }
            }
            else if (!fieldValue) {
                item.setCustomValidity(fieldErrorMsg + ' ' + fieldLabel);
                this.isValid = false;
            }
            else {
                item.setCustomValidity("");
            }
            item.reportValidity();
        });
    }

    toast(title, toastVariant) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: toastVariant
        })
        this.dispatchEvent(toastEvent)
    }

    navigateToConnect() {
        this.isModalOpen = false;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

    tracker(event) {
        trackLink(event);
    }
}