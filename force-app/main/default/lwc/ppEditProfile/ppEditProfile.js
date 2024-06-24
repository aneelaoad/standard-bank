import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import PARTNERSHIP_OBJECT from '@salesforce/schema/PP_PartnerApplication__c';
import CAPABILITIES_FIELD from '@salesforce/schema/PP_PartnerApplication__c.PP_Capabilities__c';
import getPartnerDetails from '@salesforce/apex/PP_RegistrationForm_CTRL.getPartnerDetails';
import updatePartnerDetails from '@salesforce/apex/PP_RegistrationForm_CTRL.updatePartnerDetails';
import { trackLink } from 'c/ppEventUtils'

export default class PpEditProfile extends LightningElement {


  isValid;
  errorMsg;
  capabilitiesOptions = [];
  selectedCapabilities = [];
  partner = { 'sobjectType': 'PP_PartnerApplication__c' };
  industry;

  @wire(getObjectInfo, { objectApiName: PARTNERSHIP_OBJECT })
  partnershipObj;

  @wire(getPicklistValues, {
    recordTypeId: '$partnershipObj.data.defaultRecordTypeId',
    fieldApiName: CAPABILITIES_FIELD
  })
  getCapabilitiesPicklistValues({ error, data }) {
    if (data) {
      this.capabilitiesOptions = data.values;
    }
  }

  connectedCallback() {
    this.getPartner();
  }

  getPartner() {
    getPartnerDetails().then(response => {
      this.partner = response;
      this.selectedCapabilities = response.PP_Capabilities__c.split(';');
      this.industry = response.PP_Industry__c.replace(';', ',');
    });
  }



  handleInputChange(event) {
    if (event.target.name == 'Website') {
      this.partner.PP_Website__c = event.detail.value;
    }
    else if (event.target.name == 'LinkedIn') {
      this.partner.PP_LinkedInProfile__c = event.detail.value;
    }
    else if (event.target.name == 'Capabilities') {
      this.partner.PP_Capabilities__c = event.detail.value;
      let inputCmp = this.template.querySelector('.' + event.target.name);
      inputCmp.setCustomValidity("");
    }
  }

  handleUpdate(event) {
    this.isValid = true;
    this.formValidation('lightning-dual-listbox');
    if (this.isValid) {
      updatePartnerDetails({ partnerDetails: this.partner }).then(response => {
        this.toast('Profile Updated', 'Success');
        let modalCloseFlag = true;
        const closeModal = new CustomEvent('closemodal', {
          detail: { modalCloseFlag },
        });
        this.dispatchEvent(closeModal);
      }).catch(error => {
        this.toast('Server Error', 'error');
      });

    }
  }

  formValidation(inputType) {
    let fieldErrorMsg = "Please Enter";
    this.template.querySelectorAll(inputType).forEach(item => {
      let fieldValue = item.value;
      let fieldLabel = item.label;
      if (!fieldValue) {
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

  tracker(event) {
    trackLink(event);
  }
}