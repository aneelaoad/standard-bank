import { LightningElement, api, wire ,track} from "lwc";
import inititateKYC from "@salesforce/apex/OMF_UploadDocumentsController.inititateKYC";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getExistingRecordDetails from "@salesforce/apex/OMF_BulkOnboardMyFund.getExistingRecordDetails";
import updateFundRecords from "@salesforce/apex/OMF_BulkOnboardMyFund.updateFundRecords";


import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import Client_Sector__c from "@salesforce/schema/Account.Client_Sector__c";
import Client_Sub_Sector__c from "@salesforce/schema/Account.Client_Sub_Sector__c";
import ISIC_C_ode__c from "@salesforce/schema/Account.ISIC_C_ode__c";
import FundType__c from "@salesforce/schema/Account.FundType__c";

export default class Omf_editFundDetailsUploadDocument extends LightningElement {
  @api recordId; //Get the current record id
  retrievedRecordId;
  blnStep1;
  blnStep2;
 
  blnSpinner;
  @track objFundRecord;
  @track clientSectorOptions;
  @track clientSubSectorOptions;
  @track isicCodeOptions;
  @track fundTypeOptions;

  //Get the current record id.

  renderedCallback() {
    if (!this.retrievedRecordId && this.recordId) {
      this.blnSpinner = true;
      this.retrievedRecordId = true;
     
      getExistingRecordDetails({ strRecordId: this.recordId })
      .then((result) => {
        this.objFundRecord = result.objFundDetails;
        this.strShortName = result.strShortName;
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
          this.blnStep1 = true;
          this.blnSpinner = false;
        })
        
        .catch((error) => {});
    }
  }

  connectedCallback() {

  }

  handleNext() {
    if(this.blnStep2 === true){
      this.handleUploadSubmit();
    }
    if (this.blnStep1 === true) {
      this.blnSpinner = true;
      const inputValues = Array.from(
        this.template.querySelectorAll("lightning-input, lightning-combobox")
      );
      const objNewFundRecord = { ...this.objFundRecord };
      inputValues.forEach((element) => {
        objNewFundRecord[element.name] = element.value;
      });
      this.objFundRecord = objNewFundRecord;
      
      const objRecords = {};
        (objRecords.objFundDetails = JSON.parse(
          JSON.stringify(this.objFundRecord)
        )),
          (objRecords.strShortName = this.template.querySelector(
            "[data-id='strShortName']"
          ).value),
        objRecords.blnEditModal = true;
        objRecords.strManagedFundId = this.recordId;

        updateFundRecords({
          strRecordDetails: JSON.stringify(objRecords)
        })
        .then((result) => {
          this.blnStep2 = true;
          this.blnStep1 = false;
          this.blnSpinner = false;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "The record has been successfully saved.",
              variant: "success"
            })
            
          );
        })
        .catch((error) => {
          this.blnModalSpinner = false;
        });
      
    }
  }

  handlePrevious() {
    if (this.blnStep2 == true) {
      this.blnSpinner = true;
      this.blnStep2 = false;
      this.blnStep1 = true;
      this.blnSpinner = false;
    }
  }

  async handleUploadSubmit() {
    this.blnSpinner = true;
    try {
      const result = await inititateKYC({ list_ManagedFundId: this.recordId });
      if (result) {
        this.blnSpinner = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "The record has been successfully saved.",
            variant: "success"
          })
        );
        this.handleUploadClose();
      }
    } catch (error) {
      this.blnSpinner = false;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "The record has been successfully saved.",
          variant: "success"
        })
      );
    }
  }

  handleUploadClose() {
    this.dispatchEvent(new CloseActionScreenEvent());
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