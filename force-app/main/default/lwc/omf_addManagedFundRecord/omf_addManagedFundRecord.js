import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getFundMasterAgreementDetails from "@salesforce/apex/OMF_BulkOnboardMyFund.getFundMasterAgreementDetails";
import createRecords from "@salesforce/apex/OMF_BulkOnboardMyFund.createRecords";
import getExistingRecordDetails from "@salesforce/apex/OMF_BulkOnboardMyFund.getExistingRecordDetails";

import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import Client_Sector__c from "@salesforce/schema/Account.Client_Sector__c";
import Client_Sub_Sector__c from "@salesforce/schema/Account.Client_Sub_Sector__c";
import ISIC_C_ode__c from "@salesforce/schema/Account.ISIC_C_ode__c";
import FundType__c from "@salesforce/schema/Account.FundType__c";

export default class Omf_addManagedFundRecord extends LightningElement {
  //Table columns for Master Agreement
  columns = [
    {
      label: "Contract Name",
      fieldName: "ConName",
      type: "url",
      typeAttributes: { label: { fieldName: "Name" }, target: "_blank" }
    },
    { label: "Agreement Type", fieldName: "AgreementType__c" },
    { label: "Agreement Version", fieldName: "Agreement_Version__c" },
    { label: "Contract Start Date", fieldName: "StartDate" },
    { label: "High Level Asset Class", fieldName: "HighLevelAssetClass__c" }
  ];

  @api editRecordId;
  @api recordId;
  @api action;
  @track clientSectorOptions;
  @track clientSubSectorOptions;
  @track isicCodeOptions;
  @track fundTypeOptions;

  clientSubSectorData;
  isicData;

  blnModalSpinner;
  isModalOpen;
  blnEditModal = false;
  /*Edit + Add New Managed Fund */
  strNext;
  objFundRecord;

  /*Edit Mode Form*/
  list_selectedMasterAgreement;
  list_masterAgreement;
  list_selectedMasterAgreementId = [];
  list_otherProductSelected;

  /*Add New Managed Fund Record*/
  strShortName;
  strStep2Header;
  blnAddFundDetails;
  blnStep1;
  blnStep2;
  blnStep3;
  blnFormReadOnly;
  blnRequiredField;
  strfundRegistrationNumber;
  objNewFundRecord = [
    {
      Registration_Number__c: "",
      BillingStreet:"",
      BillingCity: "",
      BillingCountry: "",
      BillingPostalCode: "",
      BillingState: "",
      CIF__c: "",
      Client_Sector__c: "",
      Client_Sub_Sector__c: "",
      ISIC_C_ode__c: "",
      FundType__c: "",
      Name: "",
      Registered_Suburb__c: "",
      Fund_Assets_Under_Management__c: ""
    }
  ];

  connectedCallback() {
    //EDIT FUND RECORD
    if (this.action === "Edit Fund") {
      this.blnModalSpinner = true;
      this.isModalOpen = true;
      this.blnAddFundDetails = false;
      getExistingRecordDetails({ strRecordId: this.editRecordId })
        .then((result) => {
          this.objFundRecord = result.objFundDetails;
          this.strShortName = result.strShortName;

          //Put master agreement in list with name as URL
          let tempRecs = [];
          result.list_masterAgreement.forEach((record) => {
            let tempRec = Object.assign({}, record);
            tempRec.ConName = "/" + tempRec.Id;
            tempRecs.push(tempRec);
          });
          this.list_masterAgreement = tempRecs;
          this.list_selectedMasterAgreementId =
            result.list_selectedMasterAgreementId;
          this.list_otherProductSelected = result.list_OtherProducts;

          let clientSector =
            this.clientSubSectorData.controllerValues[
              this.objFundRecord.Client_Sector__c
            ];
          this.clientSubSectorOptions = this.clientSubSectorData.values.filter(
            (opt) => opt.validFor.includes(clientSector)
          );

          let clientSubSector =
            this.isicData.controllerValues[
              this.objFundRecord.Client_Sub_Sector__c
            ];
          this.isicCodeOptions = this.isicData.values.filter((opt) =>
            opt.validFor.includes(clientSubSector)
          );
          this.strNext = "Submit";
          this.blnStep2 = true;
          this.blnStep3 = true;
          this.blnModalSpinner = false;
        })
        .catch((error) => {});
    }

    //ADD FUND RECORD
    if (this.action === "Add Fund") {
          
      this.blnAddFundDetails = true;
      this.isModalOpen = true;
      this.blnStep1 = true;
      this.blnStep2 = false;
      this.blnStep3 = false;
      this.strNext = "Next";
    }
  }

  renderedCallback() {
    const otherProductSelected = this.template.querySelectorAll(
      "[data-id='otherProductCheckbox']"
    );
    if (otherProductSelected.length > 0 && this.list_otherProductSelected) {
      otherProductSelected.forEach((key) => {
        if (this.list_otherProductSelected.includes(key.name)) {
          key.checked = true;
        }
      });
    }
  }

  handleNext() {
    if (this.action === "Edit Fund") {
      if (this.isInputValid()) {
        this.blnModalSpinner = true;
        //Get input values
        this.getInputValues();
        const otherProductSelected = [
          ...this.template.querySelectorAll("[data-id='otherProductCheckbox']")
        ].filter((input) => input.checked);

        if (otherProductSelected.length > 0) {
          const selectedOtherProducts = [];
          otherProductSelected.forEach((element) => {
            selectedOtherProducts.push(element.name);
          });
          this.strOtherProductSelected = selectedOtherProducts;
        }
        let strOtherProductSelected;
        if (this.strOtherProductSelected != undefined) {
          strOtherProductSelected = this.strOtherProductSelected.join(";");
        }
        var selectedRecords = this.template
          .querySelector("lightning-datatable")
          .getSelectedRows();
        const masterAgreementId = [];
        if (selectedRecords.length > 0) {
          let ids = "";
          selectedRecords.forEach((currentItem) => {
            ids = currentItem.Id;
            masterAgreementId.push(ids);
          });
        }
        
        const objRecords = {};
        (objRecords.objFundDetails = JSON.parse(
          JSON.stringify(this.objFundRecord)
        )),
          (objRecords.strShortName = this.template.querySelector(
            "[data-id='strShortName']"
          ).value),
          (objRecords.list_MasterAgreement = masterAgreementId),
          (objRecords.strOtherProducts = strOtherProductSelected);
        objRecords.strManagedFundParentRecordId = this.recordId;
        objRecords.blnEditModal = true;
        objRecords.strManagedFundId = this.editRecordId;

        createRecords({
          strRecordDetails: JSON.stringify(objRecords)
        })
          .then((result) => {
            this.blnModalSpinner = false;
            this.isModalOpen = false;
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "The record has been successfully saved.",
                variant: "success"
              })
            );
            window.location.reload();
          })
          .catch((error) => {
            this.blnModalSpinner = false;
            this.isModalOpen = false;
          });
      }
      else {
        if (this.blnStep3) {
          this.blnModalSpinner = false;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message:
                "Kindly select an active master agreement or Other Products",
              variant: "error"
            })
          );
        }
      }
    }

    if (this.action !== "Edit Fund") {
      if (this.isInputValid()) {
        this.blnModalSpinner = true;
        this.getInputValues();
        let objRecords = {
          objFundDetails: this.objFundRecord
            ? JSON.parse(JSON.stringify(this.objFundRecord))
            : null,
          strShortName: this.strShortName,
          list_MasterAgreement: this.list_selectedMasterAgreement,
          strOtherProducts: this.strOtherProductSelected?.join(";"),
          strManagedFundParentRecordId: this.recordId,
          blnEditModal: false
        };
        if (this.blnStep3) {
          createRecords({
            strRecordDetails: JSON.stringify(objRecords)
          })
            .then((result) => {
              this.blnModalSpinner = false;
              this.isModalOpen = false;
              const selectedEvent = new CustomEvent("recordcreated", {
                detail: result
              });
              this.dispatchEvent(selectedEvent);
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Success",
                  message: "The record has been successfully created.",
                  variant: "success"
                })
              );
            })
            .catch((error) => {
              this.blnModalSpinner = false;
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error",
                  message: "An error occurred, please try again.",
                  variant: "error"
                })
              );
            });
        } else if (this.blnStep2) {
          this.blnStep3 = true;
          this.blnStep2 = false;
          this.strNext = "Add Fund";
          this.strCurrentStep = "3";
          this.strShortName = this.template.querySelector(
            "[data-id='strShortName']"
          ).value;
          this.blnModalSpinner = false;
        } else if (this.blnStep1) {
          this.strfundRegistrationNumber = this.template.querySelector(
            "[data-id='strFundRegistrationNumber']"
          ).value;

          getFundMasterAgreementDetails({
            strfundRegistrationNumber: this.strfundRegistrationNumber,
            strRecordId: this.recordId
          })
            .then((result) => {
              if (result.objFundDetail) {
                this.strNext = "Confirm & Next";
                this.strStep2Header = " Step 1b: Confirm fund information";
                this.blnFormReadOnly = true;
                this.blnRequiredField = false;
                this.objFundRecord = result.objFundDetail;

                const clientSector =
                  this.clientSubSectorData.controllerValues[
                    this.objFundRecord.Client_Sector__c
                  ];
                this.clientSubSectorOptions =
                  this.clientSubSectorData.values.filter((opt) =>
                    opt.validFor.includes(clientSector)
                  );

                const clientSubSector =
                  this.isicData.controllerValues[
                    this.objFundRecord.Client_Sub_Sector__c
                  ];
                this.isicCodeOptions = this.isicData.values.filter((opt) =>
                  opt.validFor.includes(clientSubSector)
                );
              } else {
                this.strNext = "Save & Next";
                this.strStep2Header = " Step 1b: Enter fund information";
                this.blnRequiredField = true;
                this.objNewFundRecord[0].Registration_Number__c =
                  this.strfundRegistrationNumber;
                this.blnFormReadOnly = false;
                this.objFundRecord = this.objNewFundRecord[0];
                  //Prefixing client sector/client subsector/isic code fields.
                  let clientSector =
                    this.clientSubSectorData.controllerValues[
                      "Financial Institutions"
                    ];
                  this.clientSubSectorOptions = this.clientSubSectorData.values.filter(
                    (opt) => opt.validFor.includes(clientSector)
                  );
            
                  let clientSubSector =
                    this.isicData.controllerValues[
                      "Pension and Regulated Funds"
                    ];
                  this.isicCodeOptions = this.isicData.values.filter((opt) =>
                    opt.validFor.includes(clientSubSector)
                  );

                  let isicCode =
                  this.isicData.controllerValues[
                    "66020 - Pension Funding"
                  ];
                  this.isicCode = this.isicData.values.filter((opt) =>
                    opt.validFor.includes(isicCode)
                  );

                  
                this.objNewFundRecord[0].Client_Sector__c = 'Financial Institutions';
                this.objNewFundRecord[0].Client_Sub_Sector__c = 'Pension and Regulated Funds';
                this.objNewFundRecord[0].ISIC_C_ode__c	= '66020 - Pension Funding';

                let assetManagerDetails = result.objAssetManagerDetail;
                this.objNewFundRecord[0].BillingCity = assetManagerDetails.BillingCity;
                this.objNewFundRecord[0].BillingCountry = assetManagerDetails.BillingCountry;
                this.objNewFundRecord[0].BillingPostalCode = assetManagerDetails.BillingPostalCode;
                this.objNewFundRecord[0].BillingState = assetManagerDetails.BillingState;
                this.objNewFundRecord[0].BillingStreet = assetManagerDetails.BillingStreet;

              }
              this.blnFundRecordExist = Boolean(
                Object.keys(this.objFundRecord).length
              );

              this.list_masterAgreement = result.listContractDetails.map(
                (record) => ({ ...record, ConName: `/${record.Id}` })
              );

              this.blnStep1 = false;
              this.blnStep2 = true;
              this.strCurrentStep = "2";
            })
            .catch((error) => {
              this.error = error;
            })
            .finally(() => {
              this.blnModalSpinner = false;
            });
        }
      } else {
        if (this.blnStep3) {
          this.blnModalSpinner = false;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message:
                "Kindly select an active master agreement or Other Products",
              variant: "error"
            })
          );
        }
      }
    }
  }

  handleCloseModal() {
    this.isModalOpen = false;
    this.blnStep1 = false;
    this.blnStep2 = false;
    this.blnStep3 = false;
    const selectedEvent = new CustomEvent("closemodal", {
      detail: false
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  getInputValues() {
    const inputValues = Array.from(
      this.template.querySelectorAll("lightning-input, lightning-combobox")
    );
    const objNewFundRecord = { ...this.objFundRecord };
    inputValues.forEach((element) => {
      objNewFundRecord[element.name] = element.value;
    });
    this.objFundRecord = objNewFundRecord;
  }

  isInputValid() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll(
      "lightning-input, lightning-combobox"
    );
    inputFields.forEach((inputField) => {
      if (!inputField.checkValidity()) {
        inputField.reportValidity();
        isValid = false;
      }
    });

    if (this.blnStep3 == true) {
      const masterAgreementSelected = this.template
        .querySelector("lightning-datatable")
        .getSelectedRows()
        .map((row) => row.Id);
      const otherProductSelected = [
        ...this.template.querySelectorAll("[data-id='otherProductCheckbox']")
      ]
        .filter((input) => input.checked)
        .map((input) => input.name);

      if (
        masterAgreementSelected.length == 0 &&
        otherProductSelected.length == 0
      ) {
        isValid = false;
      }

      if (masterAgreementSelected.length > 0) {
        this.list_selectedMasterAgreement = masterAgreementSelected;
      }

      if (otherProductSelected.length > 0) {
        this.strOtherProductSelected = otherProductSelected;
      }
    }
    return isValid;
  }

  handlePrevious() {
    if (this.blnStep2 == true) {
      this.blnStep2 = false;
      this.blnStep1 = true;
      this.strCurrentStep = "1";
      this.strNext = "Next";
    }
    if (this.blnStep3 == true) {
      this.blnStep3 = false;
      this.blnStep2 = true;
      this.strCurrentStep = "2";
      this.strNext = "Confirm & Next";
    }
  }

  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
  accountInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$accountInfo.data.defaultRecordTypeId",
    fieldApiName: FundType__c
  })
  fundTypeInfo({ data, error }) {
    if (data) this.fundTypeOptions = data.values;
  }

  @wire(getPicklistValues, {
    recordTypeId: "$accountInfo.data.defaultRecordTypeId",
    fieldApiName: ISIC_C_ode__c
  })
  isicCodeInfo({ data, error }) {
    if (data) this.isicData = data;
  }

  @wire(getPicklistValues, {
    recordTypeId: "$accountInfo.data.defaultRecordTypeId",
    fieldApiName: Client_Sub_Sector__c
  })
  clientSubSectorInfo({ data, error }) {
    if (data) this.clientSubSectorData = data;
  }

  @wire(getPicklistValues, {
    recordTypeId: "$accountInfo.data.defaultRecordTypeId",
    fieldApiName: Client_Sector__c
  })
  clientSectorInfo({ data, error }) {
    if (data) this.clientSectorOptions = data.values;
  }

  handleClientSectorChange(event) {
    let key = this.clientSubSectorData.controllerValues[event.target.value];
    this.clientSubSectorOptions = this.clientSubSectorData.values.filter(
      (opt) => opt.validFor.includes(key)
    );
  }

  handleClientSubSectorChange(event) {
    let key = this.isicData.controllerValues[event.target.value];
    this.isicCodeOptions = this.isicData.values.filter((opt) =>
      opt.validFor.includes(key)
    );
  }
}