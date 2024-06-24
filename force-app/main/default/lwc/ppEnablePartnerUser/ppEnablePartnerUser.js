import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import enablePartnerUser from '@salesforce/apex/PP_EnablePartnerUser_CTRL.enablePartnerUser';
import checkPartnerUser from '@salesforce/apex/PP_EnablePartnerUser_CTRL.checkPartnerUser';
import getPartnerContact from '@salesforce/apex/PP_EnablePartnerUser_CTRL.getPartnerContact';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';

export default class PP_EnablePartnerUser extends LightningElement {

    @api recordId;
    isProcessing = false;
    alreadyUserExists = false;
    userRecordUrl;
    partnerContact = '';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            this.checkPartnerUser();
            this.getPartnerContact();
        }
    }

    getPartnerContact(){
        getPartnerContact({ partnerId: this.recordId }).then(result => {
           this.partnerContact = result;
        }).catch(error => {
          this.toast('Something went wrong', 'error');
        });
    }

    checkPartnerUser() {
        this.isProcessing = true;
        checkPartnerUser({ partnerId: this.recordId }).then(result => {
            if (result.Id) {
                this.alreadyUserExists = true;
                this.userRecordUrl = '/' + result.Id;
            }
            this.isProcessing = false;
        });
    }

    enablePartnerUser() {
        this.isProcessing = true;
        enablePartnerUser({ partnerId: this.recordId }).then(result => {
                this.alreadyUserExists = true;
                this.isProcessing = false;
                this.closeModal();
                this.dispatchEvent(new CloseActionScreenEvent());
                this.toast('Partner User has been enabled', 'success');
        }).catch(error => {
            this.isProcessing = false;
            this.closeModal();
            this.toast('Error occured while enabling a user', 'error');
        });
    }

    toast(title, toastVariant) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: toastVariant
        })
        this.dispatchEvent(toastEvent)
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}