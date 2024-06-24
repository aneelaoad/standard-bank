import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updatePassword from '@salesforce/apex/PP_Authentication_CTRL.updatePassword';

export default class PpUpdatePassword extends LightningElement {

    isValid;
    currentPassword;
    newPassword;
    newPassword2;
    errorMsg;

    handleInputChange(event) {
        if (event.target.name == 'currentPassword') {
            this.currentPassword = event.detail.value;
            let inputCmp = this.template.querySelector('.' + event.target.name);
            inputCmp.setCustomValidity("");
        }
        else if (event.target.name == 'newPassword') {
            this.newPassword = event.detail.value;
            let inputCmp = this.template.querySelector('.' + event.target.name);
            inputCmp.setCustomValidity("");
        }
        else if (event.target.name == 'confirmNewPassword') {
            this.newPassword2 = event.detail.value;
            let inputCmp = this.template.querySelector('.' + event.target.name);
            inputCmp.setCustomValidity("");
        }
    }

    handleUpdate() {
        this.isValid = true;
        this.formValidation('lightning-input');
        if (this.isValid) {
            updatePassword({
                currentPass: this.currentPassword,
                newPass: this.newPassword,
                newPass2: this.newPassword2
            }).then(response => {
                if (response === "Success") {
                   this.toast('Password Updated', 'Success');
                   this.currentPassword = '';
                   this.newPassword = '';
                   this.newPassword2 = '';
                } else {
                    this.errorMsg = response;
                }
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
}