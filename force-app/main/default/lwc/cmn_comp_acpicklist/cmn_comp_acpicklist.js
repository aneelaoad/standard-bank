/**
 * @description       :
 * @author            : Chibuye Kunda
 * @group             :
 * @last modified on  : 11-07-2023
 * @last modified by  : silva.macaneta@standardbank.co.za
 **/
import { LightningElement, api, track } from "lwc";
import loadData from "@salesforce/apex/CIB_CTRL_ACPicklist.loadData";
import countryMapping from "./countryMapping";
import MAU_ThemeOverrides from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class Cmn_comp_acpicklist extends LightningElement {
  @api helpText;
  @track _values;
  @track _name;
  @api label;
  @api sObjectName;
  @api sObjectFieldName;
  setCustomError = false;
  @track _value;
  @api missingValueMessage;
  @api isCountryPicklist = false;
  @api isCurrency = false;

  @api get name() {
    return this._name;
  }
  set name(value) {
    this._name = value;
  }

  @api get value() {
    return this._value;
  }
  set value(value) {
    this._value = value;
  }

  @api get values() {
    return this._values;
  }
  set values(values) {
    this._values = values;
  }

  get inputClass() {
    return this.isCountryPicklist || this.isCurrency
      ? "inputcss icon-spaced-input"
      : "inputcss";
  }

  get currentIcon() {
    if (this.isCountryPicklist || this.isCurrency) {
      let item = this.currentValues.find((_item) => {
        return _item.value === this._value;
      });
      return item ? `--flag-icon-url: url(${item.icon})` : "";
    }
    return undefined;
  }

  @track _picklistError;
  @api get picklistError() {
    return this._picklistError;
  }
  set picklistError(value) {
    this._picklistError = value;
    if (value) {
      this.template.querySelectorAll("lightning-input").forEach((element) => {
        element.setCustomValidity("Please select a value");
        element.reportValidity();
      });
    }
  }

  @api placeholder;
  @api required;
  licenseTypeSelected;
  @api disableField;
  @api index;

  soleOwner;
  businessReg;
  currentValues = [];
  code = "";
  navigationIndex = 0;
  tempCounter = 0;
  navigationItem;
  arrowup;
  checkStatusOfPicklist = false;
  arrowdown = true;
  currentValuesExist = false;

  
  cityList = [
    { label: "CITY OF JOHANNESBURG", value: "CITY OF JOHANNESBURG" },
    { label: "CITY OF TSHWANE", value: "CITY OF TSHWANE" },
    { label: "EKURHULENI", value: "EKURHULENI" },
    { label: "METWEDING DISTRICT", value: "METWEDING DISTRICT" },
    { label: "SEDIBENG DISTRICT", value: "SEDIBENG DISTRICT" },
    { label: "WEST RAND DISTRICT", value: "WEST RAND DISTRICT" }
  ];

  businessType = [
    { Name: "SOLE PROPRIETOR", AOB_Code__c: "SOLE PROPRIETOR" },
    { Name: "PRIVATE COMPANY", AOB_Code__c: "PRIVATE COMPANY" },
    { Name: "CLOSE CORPORATION", AOB_Code__c: "CLOSE CORPORATION" },
    { Name: "OTHER", AOB_Code__c: "OTHER" }
  ];

  enquiryFormHelpCategories = [
    { Name: "Enquiry", AOB_Code__c: "Enquiry" },
    { Name: "Open A Business Account", AOB_Code__c: "Open A Business Account" }
  ];

  connectedCallback() {
    this._picklistError = false;
    if (this._value === undefined) {
      this.checkStatusOfPicklist = true;
    }
    if (this.sObjectName && this.sObjectFieldName) {
      loadData({
        sObjectName: this.sObjectName,
        sFieldName: this.sObjectFieldName
      })
        .then((result) => {
          this._values = result;
          if (this.values) {
            this.currentValues = [...this.values];

            if (this.isCountryPicklist || this.isCurrency) {
              this.currentValues = this.currentValues.map((item) => {
                let countryCode = this.isCountryPicklist
                  ? (countryMapping[item.value] || "").toLowerCase()
                  : item.value.split(" - ")[0].toLowerCase();
                let icon =
                  MAU_ThemeOverrides +
                  "/assets/images/countries/" +
                  countryCode +
                  ".svg";
                return {
                  ...item,
                  icon: icon,
                  iconStyle: `
                      border-radius: 50px;
                      width: 16px;
                      height: 16px;
                      background-image: url(${icon});
                      background-repeat: no-repeat;
                      background-position: center;
                      background-size: cover;
                  `
                };
              });
            }

            this.currentValuesExist =
              this.currentValues.length > 0 ? true : false;
            this.setExistingData();
          }
        })
        .catch(() => {
          this.currentValues = [];
        });
    } else {
      this._name = "businessCity";
      this.setStaticPicklist();
    }
  }

  setExistingData() {
    if (this._value) {
      let loadedValue = this.values.find((item) => item.value === this._value);
      this._value = loadedValue.label;
      this.code = loadedValue.value;
    }
  }

  setStaticPicklist() {
    if (this.name === "businessCity") {
      this._values = [...this.cityList];
      this.currentValues = [...this._values];
    }
    if (this.name === "businessType") {
      this._values = [...this.businessType];
      this.currentValues = [...this._values];
    }
    if (this.name === "helpCategories") {
      this._values = [...this.enquiryFormHelpCategories];
      this.currentValues = [...this._values];
    }
  }

  /**
   * This will fire handle change
   * @param {*} event
   */
  handleChange(event) {
    this.navigationIndex = 0;
    this.tempCounter = 0;
    this.currentValues = this.values.filter((elem) =>
      elem.label.toLowerCase().includes(event.target.value.toLowerCase())
    );
    this._value = event.target.value;
    this.code = event.target.dataset.code;
    this.fireChangeEvent(event.target.dataset.code);
  }

  /**
   * This will be called on focus
   */
  handleFocus() {
    this.navigationIndex = 0;
    this.tempCounter = 0;
    const datalistElem = this.template.querySelector(".aob_datalist");
    const inputElem = this.template.querySelector("lightning-input");
    datalistElem.style.width = inputElem.offsetWidth + "px";
    datalistElem.style.left = inputElem.offsetLeft + "px";
    datalistElem.style.top =
      inputElem.offsetTop + inputElem.offsetHeight + "px";
    datalistElem.style.display = "block";
    if (this.navigationIndex)
      this.navigationItem.style.backgroundColor = "white";
  }

  /**
   * This will be called on blur
   */
  @api handleBlur() {
    this.template.querySelector(".aob_datalist").style.display = "none";
    this.fireBlurEvent(this.code);
  }

  /**
   * This will handle mouse down
   * @param {*} event
   */
  handleMouseDown(event) {
    const newValue = event.target.dataset.value;
    this.code = event.target.dataset.code;
    this.template.querySelector(".aob_datalist").style.display = "none";
    this._value = newValue;
    this.fireChangeEvent(this.code);
    const selectedEvent = new CustomEvent("selected", {
      detail: this._value
    });
    this._picklistError = false;
    this.template.querySelectorAll("lightning-input").forEach((element) => {
      this.removeError(element);
      if (!this.code) {
        this._picklistError = true;
      }
      element.reportValidity();
    });
    this.dispatchEvent(selectedEvent);
  }
  /**
   *@description validity check
   */
  removeError(element) {
    element.setCustomValidity("");
    element.reportValidity();
  }
  handlekeyPress(event) {
    if (this.navigationItem)
      this.navigationItem.style.backgroundColor = "white";
    if (event.keyCode === 40) {
      event.preventDefault();
      if (this.tempCounter === 0) {
        this.navigationIndex = 0;
        this.tempCounter++;
      } else if (this.navigationIndex < this.currentValues.length - 1) {
        this.navigationIndex++;
      }
      const currentName = this.currentValues[this.navigationIndex].label;
      this.navigationItem = this.template.querySelector(
        'li[data-value="' + currentName + '"]'
      );
      this.navigationItem.style.backgroundColor = "lightGrey";
      if (this.navigationIndex > 6) {
        this.template.querySelector(".aob_datalist").scrollTop += 26;
      }
    }

    if (event.keyCode === 38) {
      if (this.navigationIndex !== 0) {
        this.navigationIndex--;
        const currentName = this.currentValues[this.navigationIndex].label;
        this.navigationItem = this.template.querySelector(
          'li[data-value="' + currentName + '"]'
        );
        this.navigationItem.style.backgroundColor = "lightGrey";
        this.template.querySelector(".aob_datalist").scrollTop -= 26;
      }
      if (this.navigationIndex === 0)
        this.navigationItem.style.backgroundColor = "lightGrey";
    }

    if (event.keyCode === 13) {
      event.preventDefault();
      const selectedItem = this.currentValues[this.navigationIndex];
      this.template.querySelector(".aob_datalist").style.display = "none";
      if (selectedItem) {
        const newValue = selectedItem.label;
        this.code = selectedItem.value;
        this._value = newValue;
        this.fireChangeEvent(this.code);
        this.template.querySelector("lightning-input").blur();
      }
    }
  }

  /**
   * This will handle the change event
   * @param {*} newValue
   */
  fireChangeEvent(newValue) {
    this.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: newValue,
          target: this.name,
          index: this.index
        }
      })
    );
  }

  /**
   * This will handle the blur event
   * @param {*} newValue
   */
  @api fireBlurEvent(newValue) {
    this.dispatchEvent(
      new CustomEvent("blur", {
        bubbles: true,
        detail: {
          value: newValue,
          target: this.name,
          index: this.index
        }
      })
    );
  }

  @api triggerInsideBlur() {
    this.template.querySelectorAll("lightning-input").forEach((element) => {
      if (!this.code) {
        element.value = "";
        element.setCustomValidity("Please select a value");
        element.reportValidity();
        element.focus();
        this.currentValues = [...this.values];
      }
      element.reportValidity();
    });
  }
}