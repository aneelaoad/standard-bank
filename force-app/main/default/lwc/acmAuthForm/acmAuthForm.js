import { api, LightningElement, wire, track } from "lwc";

export default class InputForm extends LightningElement {
  @api applicationName;
  @api description;
  @api redirectUri;
  @api appId;
  @track isEditing = false;
  @track isNotValid = false;
  @track message = "";
  @track isSaving = false;
  @track editButtonClick = false;
  @track btnvariant = "brand";

  @track mockApp = {
    applicationName: this.applicationName,
    description: this.description,
    redirectUri: this.redirectUri
  };

  appName;
  appDescription;
  appRedirectUri;
  appCredentials;

  get isSave() {
    if (this.isEditing && !this.cancelBtn) {
      return true;
    }

    return false
  }
  get editBtnLabel() {
    return this.isEditing ? "SAVE CHANGES" : "EDIT APPLICATION";
  }
  get cancelBtn() {
   if (
     this.appName === this.mockApp.applicationName &&
     this.appDescription === this.mockApp.description &&
     this.appRedirectUri === this.mockApp.redirectUri &&
     this.isEditing
   ) {
     return true;
   }
    return false
  }

  formValidation(params) {
    if (
      params.paramAppName === "" ||
      params.paramAppDescription === "" 
    ) {
      this.isNotValid = true;
      this.message = "One of the fields is empty";
      return false;
    } else if (
      params.paramAppName === undefined ||
      params.paramAppDescription === undefined ||
      params.paramAppRedirectUri === undefined
    ) {
      this.isNotValid = true;
      this.message = "Invalid value inputs";
      return false;
    }

    this.message = "Saved";
    return true;
  }

  getFormValues() {
    this.appName = this.template.querySelector(
      "[data-id=applicationName]"
    ).value;
    this.appDescription = this.template.querySelector(
      "[data-id=description]"
    ).value;
    this.appRedirectUri = this.template.querySelector(
      "[data-id=redirectUri]"
    ).value;
  }

  handleInputChange() {
    //assign params for record update
    this.appName = this.template.querySelector(
      "[data-id=applicationName]"
    ).value;
    this.appDescription = this.template.querySelector(
      "[data-id=description]"
    ).value;
    this.appRedirectUri = this.template.querySelector(
      "[data-id=redirectUri]"
    ).value;

    //update display field values with input changes
    this.applicationName = this.appName;
    this.description = this.appDescription;
    this.redirectUri = this.appRedirectUri;
  }

  revertForm() {
    this.isEditing = false;
    this.isNotValid = false;
    this.template.querySelectorAll(".auth-input-field").forEach((field) => {
      field.disabled = true;
      field.classList.remove("edit-form");
    });
  }

  handleEditClick() {
    if (this.isEditing) {
      this.getFormValues();
      let appCredential_params = {
        paramAppName: this.appName,
        paramAppDescription: this.appDescription,
        paramAppRedirectUri: this.appRedirectUri
      };

      if (!this.formValidation(appCredential_params)) {
        this.template.querySelector("c-cmn-button").disabled = true;
        setTimeout(() => {
          this.template.querySelector("c-cmn-button").disabled = false;
          this.isNotValid = false;
        }, 2500);
      } else {   
        this.formValidation(appCredential_params);
        this.isNotValid = true;
        setTimeout(() => {
                        
            //update binded values
            this.mockApp.applicationName = appCredential_params.paramAppName;
            this.mockApp.description = appCredential_params.paramAppDescription;
            this.mockApp.redirectUri = appCredential_params.paramAppRedirectUri;

            const valueSelectedEvent = new CustomEvent('updateapplication', {
              detail: { 
                appName : appCredential_params.paramAppName,
                appDesc : appCredential_params.paramAppDescription, 
                redirectUri: appCredential_params.paramAppRedirectUri,
                appId: this.appId
              } 
            });
            // Dispatches the event.
            this.dispatchEvent(valueSelectedEvent);

            this.isNotValid = false;
            this.revertForm();
          }, 1500);
       
      }
    } else {
      //form on edit mode
      this.isEditing = true;
      this.template.querySelectorAll(".auth-input-field").forEach((field) => {
        field.removeAttribute("disabled");
        field.classList.add("edit-form");
      });
    }
  }

  handleCancelClick() {
    this.revertForm();
  }

}