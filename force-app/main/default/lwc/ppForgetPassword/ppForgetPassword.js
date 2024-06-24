/**
* @description  : Partner Portal Forget Password Page
* User Story : SFP-4844
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
import { api, LightningElement } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import forgotPassword from '@salesforce/apex/PP_Authentication_CTRL.forgotPasswordUsingUsername';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class PpForgetPassword extends LightningElement {

  @api
  backgroundImage;
  @api
  getInTouchPage;
  @api
  backUrl;
  backIcon;
  logo;
  isValid;
  username;
  passwordResetEmailSent = false;
  errorMsg;

  connectedCallback() {
    this.logo = Assets + '/logos/logo-wt.png';
    this.backgroundImage = Assets + '/images' + this.backgroundImage;
    this.backIcon = Assets + '/Icons/backIcon.png';
    let path = basePath.split('/s')[0];
    if (path === '') {
      this.getInTouchPage = '/s' + this.getInTouchPage;
      this.backUrl = '/s' + this.backUrl;
    } else {
      this.getInTouchPage = path + '/s' + this.getInTouchPage;
      this.backUrl = path + '/s' + this.backUrl;
    }
  }

  handleInputChange(event) {
    if (event.target.name == 'registeredemail') {
      this.username = event.detail.value;
      console.log(this.username);
      let inputCmp = this.template.querySelector('.' + event.target.name);
      inputCmp.setCustomValidity("");
    }
  }

  handleSubmit(event) {
    this.tracker(event);
    this.errorMsg = '';
    this.isValid = true;
    this.formValidation('lightning-input');
    if (this.isValid) {
      forgotPassword({
        username: this.username
      }).then(response => {
        if (!response) {
          this.passwordResetEmailSent = true;
        } else {
          this.errorMsg = response;
        }
      }).catch(error => {
        this.errorMsg = error;
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

  tracker(event) {
    trackLink(event);
  }
}