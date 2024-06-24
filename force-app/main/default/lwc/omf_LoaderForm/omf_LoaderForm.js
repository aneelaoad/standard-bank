import { LightningElement, api, track } from "lwc";
import getRecordDetails from "@salesforce/apex/OMF_LoaderForm.getRecordDetails";
import submitLoaderForm from "@salesforce/apex/OMF_LoaderForm.submitLoaderForm";
import { CloseActionScreenEvent } from "lightning/actions";
import STATUS_FIELD from "@salesforce/schema/OMF_ManagedFund__c.Onboarding_Status__c";
import ID_FIELD from "@salesforce/schema/OMF_ManagedFund__c.Id";
import REJECTION_DETAILS from "@salesforce/schema/OMF_ManagedFund__c.RejectionDetails__c";
import REJECTION_REASON from "@salesforce/schema/OMF_ManagedFund__c.RejectionReason__c";
export default class Omf_LoaderForm extends LightningElement {
  @api recordId;
  @track showSpinner = false;
  @track fields;
  isFixedIncome;
  isForeignExchange;
  isMoneyMarket;
  isFormReady;
  stepOne;
  stepTwo;
  stepThree;
  stepFour;
  stepFive;
  stepSix;
  stepSeven;
  stepEight;
  stepReview;
  currentStep = "1";
  stepCount;
  lastStep;
  mainheader = "Complete and Submit Loader Form";
  isCompleted;
  masterFundValue;
  isDFA;
  isMMOrFE;
  loderFormData;
  isCommunication;
  isFxRequirements;
  isStdSettelements;
  lstHighAsset = [];
  renderedCallback() {
    if (!this.isFormReady && this.recordId) {
      getRecordDetails({ strRecordId: this.recordId })
        .then((result) => {
          this.stepOne = true;
          this.lstHighLevelAssetClass = result.lstHighLevelAssetClass;
          const lstHighLevelAssetClass = result.lstHighLevelAssetClass;

          if (lstHighLevelAssetClass && lstHighLevelAssetClass.length > 0) {
            for(var i=0;i<lstHighLevelAssetClass.length;i++){
              if (lstHighLevelAssetClass[i].includes("Fixed Income")) {
                this.isFixedIncome = true;
                this.lstHighAsset.push('Fixed Income');
              }
              if (lstHighLevelAssetClass[i].includes("Money Markets")) {
                this.isMoneyMarket = true;
                this.isMMOrFE = true;
                this.lstHighAsset.push('Money Markets');
              }
              if (lstHighLevelAssetClass[i].includes("Foreign Exchange")) {
                this.isForeignExchange = true;
                this.isMMOrFE = true;
                this.lstHighAsset.push('Foreign Exchange');
              }
            }
          }
          this.getSteps();
          delete result.lstHighLevelAssetClass;
          this.recordDetails = Object.assign(result, this.mapColumns);
          this.isFormReady = true; // Escape case from recursion
        })
        .catch((error) => {
          this.error = error;
        });
    }
  }
  //Fixed Income Default Values Map
  mapColumns = {
    FinancialInstitution: "Yes",
    DomesticTreasuryId: "",
    MasterFund: "DMA",
    MasterCode: "VFW380",
    UNEXCORCode: "",
    FixedIncome: "",
    EmailAddress1: "",
    SendClientConfirmationViaThisEmail1: false,
    EmailAddress2: "",
    SendClientConfirmationViaThisEmail2: false,
    Comments: "",
    Debit: "Debit",
    drCrOptionsChecked:"Both",
    Currency: "ZAR-South African Rand",
    Primary: "Primary",
    BloombergToms: true,
    ClientAccountManagment_CAMs: true,
    MurexCore: true,
    MurexEQDSA: true,
    MurexMoneyMarket: true,
    Xceptor: true,
    eMarketTrader: true,
    FinanaceREEngineering: true,  
    ForigenExchangeDealingSystem: true,
    MurexFXVersion3: true,
    CalypsoSouthAfrica: true,
    DomesticTreasury: true
  };

  get yesNoValues() {
    return [
      {
        label: "Yes",
        value: "Yes",
        checked : true
      },
      {
        label: "No",
        value: "No",
        checked : false
      }
    ];
  }
  get currencyOptions() {
    return [
      { label: "YDD-Yemeni Dinar", value: "YDD-Yemeni Dinar" },
      { label: "YER-Yemeni Rial", value: "YER-Yemeni Rial" },
      { label: "YUD-Yugoslavian Dinar", value: "YUD-Yugoslavian Dinar" },
      { label: "ZAL-Financial Rand", value: "ZAL-Financial Rand" },
      { label: "ZAR-South African Rand", value: "ZAR-South African Rand" },
      { label: "ZMK-Zambian Kwacha", value: "ZMK-Zambian Kwacha" },
      { label: "ZMM-Zambian Kwacha", value: "ZMM-Zambian Kwacha" },
      { label: "ZWD-Zimbabwean Dollar", value: "ZWD-Zimbabwean Dollar" },
      { label: "ZWL-Zimbabwe Dollar", value: "ZWL-Zimbabwe Dollar" },
      { label: "ZWR-Zimbabwe Dollar Reva", value: "ZWR-Zimbabwe Dollar Reva" }
    ];
  }
  selectedvalue = "ZAR-South African Rand";
  get masterFundPicklistValue() {
    return [
      {
        label: "DMA",
        value: "DMA"
      },
      {
        label: "DFA",
        value: "DFA"
      }
    ];
  }

  get securityFlagOptions() {
    return [
      { label: "Cash", value: "Cash" },
      { label: "Security", value: "Security" },
      { label: "Both", value: "Both" },
      { label: "Primary", value: "Primary" }
    ];
  }
  get drCrOptions() {
    return [
      { label: "Debit", value: "Debit" },
      { label: "Credit", value: "Credit" },
      { label: "Both", value: "Both" },
      { label: "Secondary", value: "Secondary" }
    ];
  }

  handleMasterFundChange(event) {
    this.recordDetails["MasterFund"] = event.target.value;
    this.masterFundValue = event.target.value;
    if (event.target.value === "DFA") {
      this.isDFA = true;
    }
    if (event.target.value === "DMA") {
      this.isDFA = false;
    }
  }

  handleInputChange() {
    let record = this.recordDetails;
    this.template.querySelectorAll("lightning-input").forEach((element) => {
      if (element.type === "text") {
        record[element.dataset.name] = element.value;
      }
      if (element.type === "date") {
        record[element.dataset.name] = element.value;
      }
      if (element.type === "checkbox") {
        if (element.checked) {
          record[element.dataset.name] = true;
        } else {
          record[element.dataset.name] = false;
        }
      }
    });
    this.template.querySelectorAll("input").forEach((element) => {

      if (element.type === "text") {
        record[element.dataset.name] = element.value;
      }
      if (element.type === "checkbox") {

        if (element.checked) {
          record[element.dataset.name] = true;
        } else {
          record[element.dataset.name] = false;
        }
      }
    });

    this.template.querySelectorAll("lightning-checkbox-group").forEach((element) => {

      record[element.dataset.name] = element.value;
    });
    this.template.querySelectorAll("lightning-combobox").forEach((element) => {

      record[element.dataset.name] = element.value;
    });
    let checkedValue;
    this.template.querySelectorAll("[data-name='FinancialInstitution']").forEach((element) => {

      if (element.checked === true) {
        record["FinancialInstitution"] = element.value;
        checkedValue = "[data-value = " + element.value + "]";
      }

    });

    if (checkedValue) {
      this.template.querySelector(checkedValue).checked = true;
    }

    this.recordDetails = record;
  }
  closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  handlePrevious() {
    let step = Number(this.lastStep) - 1;

    this.stepOne = false;
    this.stepTwo = false;
    this.stepThree = false;
    this.stepFour = false;
    this.stepFive = false;
    this.stepSix = false;
    this.stepSeven = false;
    this.stepEight = false;
    if (this.currentStep == this.lastStep) {
      if (step === 4)
        this.stepFour = true;
      else if (step === 5)
        this.stepFive = true;
      else if (step === 6)
        this.stepSix = true;
      else if (step === 7)
        this.stepSeven = true;
      else if (step === 8)
        this.stepEight = true;
      this.stepReview = false;
      this.isCompleted = false;
      this.currentStep = step + '';
    }
    else if (this.currentStep == "2") {
      this.currentStep = "1";
      this.stepTwo = false;
      this.stepOne = true;
    } else if (this.currentStep == "3") {
      this.currentStep = "2";
      this.stepThree = false;
      this.stepTwo = true;
    } else if (this.currentStep == "4") {
      this.currentStep = "3";
      this.stepFour = false;
      this.stepThree = true;
    } else if (this.currentStep == "5") {
      console.log('Back to steo 4');
      this.currentStep = "4";
      this.stepFive = false;
      this.stepFour = true;
    } else if (this.currentStep == "6") {
      this.currentStep = "5";
      this.stepSix = false;
      this.stepFive = true;
    } else if (this.currentStep == "7") {
      this.currentStep = "6";
      this.stepSeven = false;
      this.stepSix = true;
    } else if (this.currentStep == "8") {
      this.currentStep = "7";
      this.stepEight = false;
      this.stepSeven = true;
    }
    this.isCommunication = (this.stepThree && !this.isFixedIncome && this.isMMOrFE) || (this.stepFour && this.isFixedIncome);
    this.isFxRequirements = (this.stepFour &&
      !this.isFixedIncome &&
      this.isForeignExchange &&
      this.isMoneyMarket) || (
        this.stepFour &&
        this.isForeignExchange &&
        !this.isFixedIncome &&
        !this.isMoneyMarket
      ) ||
      (
        this.stepFive &&
        this.isFixedIncome &&
        this.isForeignExchange &&
        this.isMoneyMarket
      ) || (this.stepFive && this.isFixedIncome && this.isForeignExchange);
    this.isStdSettelements = (
      this.stepFour &&
      this.isMoneyMarket &&
      !this.isForeignExchange &&
      !this.isFixedIncome
    ) ||
      (
        this.stepSix &&
        this.isMoneyMarket &&
        this.isForeignExchange &&
        this.isFixedIncome
      ) ||
      (
        this.stepFive &&
        this.isMoneyMarket &&
        this.isFixedIncome &&
        !this.isForeignExchange
      ) ||
      (
        this.stepFive &&
        this.isMoneyMarket &&
        this.isForeignExchange &&
        !this.isFixedIncome
      );
  }
  handleNext() {
    let isValid = this.isInputValid();
    if (isValid) {
      let reviewBeforeStep = Number(this.lastStep) - 1;
      if (this.currentStep == this.lastStep) {
        this.mainheader = "Success: Loader Form Submitted";
        let fieldList = this.template.querySelectorAll(".loaderForm");
        let fields = {};
        for (let i = 0; i < fieldList.length; i++) {
          if (fieldList[i].type == 'radio' || fieldList[i].type == 'checkbox') {
            let value = fieldList[i].checked === true ? 'Yes' : 'No';
            fields[fieldList[i].name] = value;
          }
          else {
            let value2 = fieldList[i].value != 'undefined' && fieldList[i].value != undefined ? fieldList[i].value : '';
            fields[fieldList[i].name] = value2;
          }
        }
        this.loderFormData = fieldList;
        this.fields = fields;
        this.stepOne = false;
        this.stepTwo = false;
        this.stepThree = false;
        this.stepFour = false;
        this.stepFive = false;
        this.stepSix = false;
        this.stepSeven = false;
        this.stepReview = false;
        this.isCompleted = true;
      } else if (Number(this.currentStep) == reviewBeforeStep) {
        this.stepOne = true;
        this.stepTwo = true;
        this.stepThree = true;
        this.stepFour = true;
        this.stepFive = true;
        this.stepSix = true;
        this.stepSeven = true;
        this.stepReview = true;
        this.sectionHeader =
          "Step " +
          this.lastStep +
          ": Review information and submit loader form";
        this.currentStep = this.lastStep;
      } else if (this.currentStep == "7") {
        this.currentStep = "8";
        this.stepSeven = false;
        this.stepEight = true;
      } else if (this.currentStep == "6") {
        this.currentStep = "7";
        this.stepSix = false;
        this.stepSeven = true;
      } else if (this.currentStep == "5") {
        this.currentStep = "6";
        this.stepFive = false;
        this.stepSix = true;
      } else if (this.currentStep == "4") {
        this.currentStep = "5";
        this.stepFour = false;
        this.stepFive = true;
      } else if (this.currentStep == "3") {
        this.currentStep = "4";
        this.stepThree = false;
        this.stepFour = true;
      } else if (this.currentStep == "2") {
        this.currentStep = "3";
        this.stepTwo = false;
        this.stepThree = true;
      } else if (this.currentStep == "1") {
        this.currentStep = "2";
        this.stepTwo = true;
        this.stepOne = false;
      }
      this.isCommunication = (this.stepThree && !this.isFixedIncome && this.isMMOrFE) || (this.stepFour && this.isFixedIncome);
      this.isFxRequirements = (this.stepFour &&
        !this.isFixedIncome &&
        this.isForeignExchange &&
        this.isMoneyMarket) || (
          this.stepFour &&
          this.isForeignExchange &&
          !this.isFixedIncome &&
          !this.isMoneyMarket
        ) ||
        (
          this.stepFive &&
          this.isFixedIncome &&
          this.isForeignExchange &&
          this.isMoneyMarket
        ) || (this.stepFive && this.isFixedIncome && this.isForeignExchange);
      this.isStdSettelements = (
        this.stepFour &&
        this.isMoneyMarket &&
        !this.isForeignExchange &&
        !this.isFixedIncome
      ) ||
        (
          this.stepSix &&
          this.isMoneyMarket &&
          this.isForeignExchange &&
          this.isFixedIncome
        ) ||
        (
          this.stepFive &&
          this.isMoneyMarket &&
          this.isFixedIncome &&
          !this.isForeignExchange
        ) ||
        (
          this.stepFive &&
          this.isMoneyMarket &&
          this.isForeignExchange &&
          !this.isFixedIncome
        );
      this.handleInputChange();
    }
  }
  getSteps() {
    if (this.isFixedIncome && this.isForeignExchange && this.isMoneyMarket) {
      this.lastStep = "8";
      this.stepCount = "9";
      return;
    }
    if (
      (this.isFixedIncome && this.isForeignExchange) ||
      (this.isFixedIncome && this.isMoneyMarket)
    ) {
      this.lastStep = "7";
      this.stepCount = "8";
      return;
    }
    if ((this.isForeignExchange && this.isMoneyMarket) || this.isFixedIncome) {
      this.lastStep = "6";
      this.stepCount = 7;
      return;
    }
    if (this.isForeignExchange || this.isMoneyMarket) {
      this.lastStep = "5";
      this.stepCount = "6";
    }
  }
  handleComplete() {
    this.showSpinner = true; // show the spinner
    const strManagedFund = {};
    strManagedFund[ID_FIELD.fieldApiName] = this.recordId;
    strManagedFund[STATUS_FIELD.fieldApiName] = 'OSD';
    strManagedFund[REJECTION_DETAILS.fieldApiName] = '';
    strManagedFund[REJECTION_REASON.fieldApiName] = '';
    const recordInput = JSON.stringify(strManagedFund);
    const fields = JSON.stringify(this.fields);
    submitLoaderForm({ fields: fields, strManagedFund: recordInput, lst_HighestAssetClass: this.lstHighAsset })
      .then(() => {
        this.showSpinner = false; // hide the spinner
        this.closeQuickAction();
      })
      .catch((error) => {

        this.showSpinner = false; // hide the spinner
        this.closeQuickAction();
      });
  }
  isInputValid() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll('lightning-input');
    inputFields.forEach(inputField => {
      if (!inputField.checkValidity()) {
        inputField.reportValidity();
        isValid = false;
      }
    });
    let checkBoxes = this.template.querySelectorAll('lightning-checkbox-group');
    checkBoxes.forEach(inputField => {
      if (!inputField.checkValidity()) {
        inputField.reportValidity();
        isValid = false;
      }
    });
    return isValid;
  }
}