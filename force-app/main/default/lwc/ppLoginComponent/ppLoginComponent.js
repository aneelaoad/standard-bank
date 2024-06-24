/**
* @description  : Partner Portal Login Page Component
* User Story : SFP-4844
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
import { api, LightningElement } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import login from '@salesforce/apex/PP_Authentication_CTRL.loginIntoCommunity';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class PpLoginComponent extends LightningElement {

  @api
  registrationPage;
  @api
  forgetPasswordPage;
  @api
  backgroundImage;
  logo;
  isValid;
  username;
  password;
  errorMsg;
  error;
  adobeEventFired = false;

  connectedCallback() {
    this.logo = Assets + '/logos/logo-wt.png';
    this.backgroundImage = Assets + '/images' + this.backgroundImage;
    let path = basePath.split('/s')[0];
    if (path == '') {
      this.registrationPage = '/s' + this.registrationPage;
      this.forgetPasswordPage = '/s' + this.forgetPasswordPage;
    } else {
      this.registrationPage = path + '/s' + this.registrationPage;
      this.forgetPasswordPage = path + '/s' + this.forgetPasswordPage;
    }

    //Adobe Analytics Event
    document.dispatchEvent(new CustomEvent('triggerInteraction', {
      'detail': {
        eventName: 'globalVirtualPageView',
        pageName: "Login",
        loginStatus: "guest",
        userLoginSuccess: "false",
        userRegistrationSuccess: "false",
        siteCountry: "South Africa",
        websiteName: "Partner Connect",
        siteBusinessUnit: "Group",
        websiteNameCode: "PC",
        siteLanguage: "English",
        pageCategory: "Personal",
        pageSubSection1: "Login"
      }
    }));

  }

  handleInputChange(event) {

    if (this.adobeEventFired === false) {
      document.dispatchEvent(new CustomEvent('triggerInteraction', {
        'detail': {
          eventName: 'globalFormStart',
          formName: "group | login to partner connect",
          formIsSubmitted: false,
          formStatus: ""
        }
      }));
      this.adobeEventFired = true;
    }

    if (event.target.name == 'registeredemail') {
      this.username = event.detail.value;
      let inputCmp = this.template.querySelector('.' + event.target.name);
      inputCmp.setCustomValidity("");
    }
    else if (event.target.name == 'password') {
      this.password = event.detail.value;
      let inputCmp = this.template.querySelector('.' + event.target.name);
      inputCmp.setCustomValidity("");
    }
  }

  handleLogin(event) {
    this.tracker(event);
    this.errorMsg = '';
    this.isValid = true;
    this.formValidation('lightning-input');
    if (this.isValid) {
      login({
        username: this.username,
        password: this.password,
        startUrl: "/s/dashboard"
      }).then(response => {
        if (response.includes('http')) {
          //Adobe Analytics Event
          document.dispatchEvent(new CustomEvent('triggerInteraction', {
            'detail': {
              eventName: 'globalFormComplete',
              formName: "group | login to partner connect",
              formIsSubmitted: true,
              formStatus: "submitted",
              userLoginSuccess: true,
              loginStatus: "logged in"
            }
          }));

          location.href = response;
        } else {
          this.errorMsg = response;
        }
      }).catch(error => {
        this.error = error;
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