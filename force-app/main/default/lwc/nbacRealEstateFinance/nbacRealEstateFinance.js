import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";
import getRefData from "@salesforce/apex/NBACRealEstateFinanceController.getRefData";
import saveRefData from "@salesforce/apex/NBACRealEstateFinanceController.saveRefData";
import deleteRefMetric from "@salesforce/apex/NBACRealEstateFinanceController.deleteRefMetric";
import getFieldSetValues from "@salesforce/apex/NBACRealEstateFinanceController.getFieldSetValues";

export default class NbacRealEstateFinance extends LightningElement {
  @track refDataList = [];
  @api recordId;
  @track error;
  @track addButton;
  @track removeButton;
  @track isLoading = false;
  @track showRefFields = false
  @track fieldSetValues1;
  @track fieldSetValues2;
  @track fieldSetValues3;
  @track fieldSetValuesList;
  @track hasRefAccess;
  @track isLocked;

  lockedMilstones = ['Supported','Submitted','Approval']

  @track editMode = false;
  @track showTick = false

  @track baData = {
    Development_Funding_Loan__c	: ""
  };

  @track milestone
  @track nbacState

  @track showAdditionalForm = false;
  @track showError = false;

  loanOptions = [
    { label: 'Yes', value: 'Yes'},
    { label: 'No', value: 'No' }
  ];

    /** Edit/Read Methods Start*/
    get isReadOnly() {
      return !this.editMode;
    }

    get inputClass() {
        return this.isReadOnly ? 'custom-input test-input' : 'custom-input';
    }

    get inputContainerClass() {
      return this.isReadOnly ? 'input-container-inactive' : 'input-container-active';
  }

    handleSelectionChange(event) {
      const fieldName = event.target.name;
      if(fieldName === 'Development_Funding_Loan__c') {
          const selectedValue = event.detail.value;
          this.baData = { ...this.baData, [fieldName]: selectedValue };
          this.handleRefSectionDisplay(selectedValue)

      }
  }

  handleRefSectionDisplay(selectedValue){
    this.showError = false; 
    if(selectedValue === 'Yes'|| selectedValue === 'No'){
      this.showTick = true
    }else{
      this.showTick = false
    }

    if (selectedValue === 'Yes') {
        this.showAdditionalForm = true;
    } else {
        this.showAdditionalForm = false;
    }
  }

    activateEditMode() {
      if(this.isLocked ){
        this.editMode = false;
        const editEvent = new CustomEvent('editmodeactivated', {
          bubbles: true,
          composed: true,
          detail: { name: 'lock' }
      });
      this.dispatchEvent(editEvent);

      this.showToast(
        "Cannot Activate Edit Mode", 
        "No more updates can be made as support has been received.", 
        "error",
        "sticky"
        );
    
      return
      }

        this.editMode = true;
        const editEvent = new CustomEvent('editmodeactivated', {
          bubbles: true,
          composed: true,
          detail: { name: 'edit' }
      });
      this.dispatchEvent(editEvent);


    }

    @api
    actionRecived({data}){  
      this.nbacState = data
      if( data === 'edit' || data ==='lock' ){

        if(this.isLocked){
          this.editMode = false
        }else{
          this.editMode = true
        }

      } else if(data === 'save'){
        this.editMode = false
        if(this.hasRefAccess){
          this.saveRecords()
        }
      } else if(data === 'cancel'){
        this.editMode = false
        this.cancelSave()
      }else{
          return
      }
    }
  /** Edit/Read Ends */

  connectedCallback() {
    this.retrieveRefDataList();
  }

  retrieveRefDataList() {
    this.isLoading = true;
    getRefData({ baId: this.recordId })
        .then(result => {
            this.initialiseRefData(result);
            this.retrieveFieldSetValues();
            this.hasRefAccess = true
            this.error = false 
        })
        .catch(error => {
            this.isLoading = false;
            let errorMsg = error.body?.message
            if(error.statusCode === 500 || errorMsg.includes('denied') ){
              this.hasRefAccess = false;
            }
           this.error = true
        });
    }

    retrieveFieldSetValues() {
      this.isLoading = true;
        getFieldSetValues({objectName: 'NBAC_Real_Estate_Finance__c', fieldSetNames: ['RefLabelSectionOne','RefLabelSectionTwo','RefLabelSectionThree'] })
            .then(res => {              
              if(res){

                let result = res.map((d) => {
                  let newData = [];
                    d.forEach(el =>{
                       
                      let newEl = { ...el }; // Create a shallow copy of the object
                      if (el.apiName === 'Total_Budgeted_Development_Cost__c') {
                          newEl.class = 'ref-label bold';
                      } else {
                          newEl.class = 'ref-label';
                      }
                      newData.push(newEl); // Push the modified object to the new array
                  })

                  return newData
                })

                this.fieldSetValues1 = result[0];
                this.fieldSetValues2 = result[1];
                this.fieldSetValues3 = result[2];

                this.fieldSetValuesList = [
                  { key: '1', values: result[0] },
                  { key: '2', values: result[1] },
                  { key: '3', values: result[2] }
              ];
              }

              this.isLoading = false;

            })
            .catch(error => {
              this.isLoading = false;
                this.showToast(
                  "Problem Occured",
                  "Error retrieving fieldSetValues:: "+JSON.stringify(error),
                  "error"
                );
            });
    }

  initialiseRefData(data) {
    const lg = data.length + 1;
    this.refDataList =
      data && data.length > 0
        ? data
        : [{ Id: "tempId" + lg, Metric__c: "Metric " + lg }];

    this.baData =
    data.length > 0
      ? data[0].Business_Assessment__r
      : { Development_Funding_Loan__c: ""};

    this.milestone =
    data.length > 0
      ? data[0].Business_Assessment__r.Milestone__c
      : null

    this.isLocked =  this.lockedMilstones.indexOf(this.milestone) !== -1 ? true: false;

    this.handleRefSectionDisplay(this.baData.Development_Funding_Loan__c)
    this.addButton = this.refDataList.length < 3;
    this.removeButton = this.refDataList.length > 1;
    this.isLoading = false;
  }


  handleInputChange(event) {
    const refId = event.currentTarget.dataset.id;
    const fieldName = event.target.name;
    let value = event.target.value;

     if (isNaN(value) || isNaN(parseFloat(value))) {
        if(!event.currentTarget.reportValidity() || value === ''){
          event.target.value = 0;
          value =  event.target.value
        }
     }

    if (value) {
      this.refDataList = this.refDataList.map((ref) => {
        if (ref.Id === refId) {
          // If refId matches or refId is not defined (new record), update the field
          return { ...ref, [fieldName]: value };
        }
        return ref;
      });
    }
  }

  addRef() {
    try {
      if (this.refDataList.length < 3) {
        const lg = this.refDataList.length + 1;
        const newRecord = { Id: "tempId" + lg, Metric__c: "Metric " + lg };
        this.refDataList = [...this.refDataList, newRecord];
      }
      this.addButton = this.refDataList.length < 3;
      this.removeButton = this.refDataList.length > 1;
    } catch (error) {
      this.showToast(
        "Problem Occured",
        "Error adding Ref Column: "+error,
        "error"
      );
    }
  }

  removeRef(event) {
    try {
      const refId = event.currentTarget.dataset.id;
      const index = this.refDataList.findIndex((ref) => ref.Id === refId);
      if (index !== -1) {
        this.refDataList = this.refDataList.filter((_, i) => i !== index);
      }
    } catch (error) {
      this.showToast(
        "Problem Occured",
        "Error saving ref Data records: "+error,
        "error"
      );
    }
  }

  saveRecords() {
    this.isLoading = true;
    let recordsToSave = this.refCleanUp(this.refDataList);
    recordsToSave = recordsToSave.map(
      ({ Id, Total_Budgeted_Development_Cost__c, ...rest }) =>
        Id && typeof Id === "string" && Id.startsWith("temp")
          ? { ...rest }
          : { Id, ...rest }
    );

    const baRecordToUpdate = {
      Id: this.recordId,
      Development_Funding_Loan__c: this.baData.Development_Funding_Loan__c
    };
    

    saveRefData({
      refDataList: recordsToSave,
      baRec: baRecordToUpdate,
      baId: this.recordId
    })
    .then((data) => {
      
      if (data) {
        this.initialiseRefData(data)
        this.showToast(
          "Success",
          "Ref Data records saved successfully",
          "success"
        );
      }
      this.isLoading = false;
    })
    .catch((error) => {
      this.isLoading = false;

      let errorMsg = error.body?.message

      if(error.statusCode === 500 || errorMsg.includes('denied') ){
        console.info('Error:', error.body?.message)
        return
      }

      this.showToast(
        "Error saving ref Data records: " + JSON.stringify(error),
        "error"
      );

      
    });



    this.addButton = this.refDataList.length < 3;
    this.removeButton = this.refDataList.length > 1;
  }

  cancelSave() {
    this.retrieveRefDataList();
  }

  async handleDeleteRecord(event) {
    const refId = event.currentTarget.dataset.id;
    const index = this.refDataList.findIndex((ref) => ref.Id === refId);

    if (!refId.startsWith("tempId")) {
      const result = await LightningConfirm.open({
        message:
          "This will permantly delete this REF metric record and this action is not reversible.",
        label: "Confirm Delete"
      });
      if (result) {
        deleteRefMetric({ refId: refId })
          .then(() => {
            this.refDataList = this.refDataList.filter((_, i) => i !== index);
            this.showToast("Success", "Record deleted successfully", "success");
            this.activateEditMode()
            this.retrieveRefDataList();
            this.addButton = this.refDataList.length < 3;
            this.removeButton = this.refDataList.length > 1;
          })
          .catch((error) => {
            this.showToast("Error", "Error deleting record", "error");
          });
      }
    } else {
      // If the record doesn't have an Id, it's a new record and can be removed from the array directly
      if (index !== -1) {
        this.refDataList = [
          ...this.refDataList.slice(0, index),
          ...this.refDataList.slice(index + 1)
        ];
      }

      this.addButton = this.refDataList.length < 3;
      this.removeButton = this.refDataList.length > 1;
    }
  }

  /** helper funtions */
  showToast(title, message, variant, mode) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: typeof(mode) == 'undefined'?'dismissible':mode
    });
    this.dispatchEvent(toastEvent);
  }

  refCleanUp(array) {
    //Make sure metric data are unique
    /** to be refactored and promp the user to make a change */
    let nameSet = new Set();
    let lastIndex = 0;

    for (let i = 0; i < array.length; i++) {
      let obj = array[i];
      if (nameSet.has(obj.Metric__c)) {
        array.splice(lastIndex, 1);
        i--;
      } else {
        nameSet.add(obj.Metric__c);
      }

      lastIndex = i;
    }
    return array;
  }
}