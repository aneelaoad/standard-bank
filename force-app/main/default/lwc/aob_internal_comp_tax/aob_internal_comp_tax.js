import { LightningElement, api, track } from 'lwc';
/**Static ressources */
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import AOB_ConfirmMissingMsg from '@salesforce/label/c.AOB_ConfirmMissingMsg';
import AOB_TaxNumberValidationError from '@salesforce/label/c.AOB_TaxNumberValidationError';
import loadData from '@salesforce/apex/AOB_CTRL_ACPicklist.loadData';
import AOB_ZA_CountryOfTaxResidency from '@salesforce/label/c.AOB_ZA_CountryOfTaxResidency';
import AOB_ZA_AddAdditionalCountry from '@salesforce/label/c.AOB_ZA_AddAdditionalCountry';
import AOB_ZA_ForeignTAXNumber from '@salesforce/label/c.AOB_ZA_ForeignTAXNumber';
import AOB_ZA_IDontHaveATaxNumber from '@salesforce/label/c.AOB_ZA_IDontHaveATaxNumber';
import AOB_ZA_ReasonForNotHavingAForeignTaxNumber from '@salesforce/label/c.AOB_ZA_ReasonForNotHavingAForeignTaxNumber';




export default class Aob_internal_comp_tax extends LightningElement {
    //Labels
    label = {
        AOB_ConfirmMissingMsg,
        AOB_TaxNumberValidationError,
        AOB_ZA_CountryOfTaxResidency,
        AOB_ZA_AddAdditionalCountry,
        AOB_ZA_ForeignTAXNumber,
        AOB_ZA_IDontHaveATaxNumber,
        AOB_ZA_ReasonForNotHavingAForeignTaxNumber,
        AOB_ZA_AddAdditionalCountry
    };
    addIMG = AOB_ThemeOverrides + '/assets/images/add_icon.png';
    closeMG = AOB_ThemeOverrides + '/assets/images/close_icon.png';
    @api taxInputData;
    options;
    hasSecondElem;
    hasNoTaxNumber;
    secondItemHasNoTaxNumber;
    pattern = "[0-9]{10}$";
    required;
    secondRequired;
    taxNumberValue;
    secondTaxNumberValue;
    inputsToDispatchFirst = { "firstCountry": "", "firstTaxNumber": "" };
    inputsToDispatchSecond = { "secondCountry": "", "secondTaxNumber": "" };
    validCompFirst = false;
    validCompSecond = false;
    /**
     * @description method to show tax fields
     */
    connectedCallback() {
    
       
        this.secondRequired = false;
        this.required = true;
        this.hasSecondElem = false;
        this.hasNoTaxNumber = false;
        this.secondItemHasNoTaxNumber = false;
       
        if(this.taxInputData){
            this.populateData();
        }
        else{
            this.initInputsToDispatch(); 
        }
    }

    populateData(){
        if(this.taxInputData){
            if(this.taxInputData.firstCountry) this.inputsToDispatchFirst.firstCountry = this.taxInputData.firstCountry;
            if(this.taxInputData.firstTaxNumber){
                this.inputsToDispatchFirst.firstTaxNumber = this.taxInputData.firstTaxNumber;
                this.taxNumberValue = this.taxInputData.firstTaxNumber;
            }
        if(this.taxInputData.firstReason){
            this.inputsToDispatchFirst.firstReason = this.taxInputData.firstReason;
             this.hasNoTaxNumber = true;
        }
        if(this.taxInputData.secondCountry){
            this.inputsToDispatchSecond.secondCountry = this.taxInputData.secondCountry;
            this.hasSecondElem = true;
            this.secondRequired = true;
            }
         if(this.taxInputData.secondTaxNumber){
            this.inputsToDispatchSecond.secondTaxNumber = this.taxInputData.secondTaxNumber;
            this.secondTaxNumberValue = this.taxInputData.secondTaxNumber;
        }
        if(this.taxInputData.secondReason){
            this.inputsToDispatchSecond.secondReason = this.taxInputData.secondReason;
              this.secondItemHasNoTaxNumber = true;
        }

        }
        
    }

    initInputsToDispatch() {
        this.inputsToDispatchFirst.firstCountry = "";
        this.inputsToDispatchFirst.firstTaxNumber = "";
        this.refreshAndDispatch();
    }

    addElemsToInputsToDispatch() {
        this.inputsToDispatchSecond.secondCountry = "";
        this.inputsToDispatchSecond.secondTaxNumber = "";
        this.refreshAndDispatch();
    }

    get taxNumberRequired() {
        return this.required && !this.hasNoTaxNumber;
    }

    get secondTaxNumberRequired() {
        return this.secondRequired && !this.secondItemHasNoTaxNumber;
    }

     get hasNoTaxAndSecondEle() {
        return this.hasNoTaxNumber || this.hasSecondElem;   // false  false
    }

    refreshAndDispatch() {
        let taxInputs = { ...this.inputsToDispatchFirst, ...this.inputsToDispatchSecond };
        Object.keys(taxInputs).forEach(key => {
            if (taxInputs[key] === '') {
                delete taxInputs[key];
            }
        });
    
        this.validateTaxComp();
        if (!this.hasSecondElem) this.validCompSecond = true;
    
        const taxDetails = Object.keys(taxInputs).length ? JSON.stringify(taxInputs) : "{}";
        console.log('from comp tax'+taxDetails);
        const selectedEvent = new CustomEvent("change", {
            detail: {
                taxDetails: taxDetails,
                value: (this.validCompFirst && this.validCompSecond),
                target: "taxCountries",
                inputsKey: "taxInputs"
            }
        });
    
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    

    validateTaxComp() {
        this.validCompFirst = true;
        let tempArrFirst = Object.values(this.inputsToDispatchFirst);
        let tempArrSecond = Object.values(this.inputsToDispatchSecond);
   
        // first div
        for (let j = 0; j < tempArrFirst.length; j++) {
         
            if (tempArrFirst.length <= 2) {
                if (tempArrFirst[j] === "" || tempArrFirst[j] === null || tempArrFirst[j] === "null" || tempArrFirst[j] === undefined) this.validCompFirst = false;
            }
            if (tempArrFirst.length > 2) {
                tempArrFirst[1] = "null";
                if (tempArrFirst[j] === "" || tempArrFirst[j] === null || tempArrFirst[j] === undefined) this.validCompFirst = false;
            }
        }

        // second div
        this.validCompSecond = true;
        for (let j = 0; j < tempArrSecond.length; j++) {
           
            if (tempArrSecond.length <= 2) {
                if (tempArrSecond[j] === "" || tempArrSecond[j] === null || tempArrSecond[j] === "null" || tempArrSecond[j] === undefined) this.validCompSecond = false;
            }
            if (tempArrSecond.length > 2) {
                tempArrSecond[1] = "null";
                if (tempArrSecond[j] === "" || tempArrSecond[j] === null || tempArrSecond[j] === undefined) this.validCompSecond = false;
            }
        }

    }

    /**
     * @description method to handle default tax input changes ( if the user pays taxes in SA Only)
     */
    firstTaxNumberOnChange(event) {
        let re = new RegExp("[0-9]{10}$");
        if (event.detail) {
            if (event.target.dataset.type === "firstTaxNumber" && re.test(event.detail.value) && (event.detail.value.length == 10)) {
                this.inputsToDispatchFirst.firstTaxNumber = event.detail.value;
            } else {
                this.inputsToDispatchFirst.firstTaxNumber = "";
            }
        }
        this.refreshAndDispatch();
    }

    secondTaxNumberOnChange(event) {
        let re = new RegExp("[0-9]{10}$");
        if (event.detail) {
            if (event.target.dataset.type === "secondTaxNumber" && re.test(event.detail.value) && (event.detail.value.length == 10)) {
                this.inputsToDispatchSecond.secondTaxNumber = event.detail.value;
            } else {
                this.inputsToDispatchSecond.secondTaxNumber = "";
            }
        }
        this.refreshAndDispatch();
    }

    /**
     * @description method to handle default tax input changes ( if the user pays taxes in SA Only)
     */
    firstGenericTaxOnChange(event) {
        if (event.detail) {
            if (event.target.dataset.type === "firstCountry") {
                if (event.detail.value === "") {
                    this.inputsToDispatchFirst.firstCountry = "";
                } else {
                    this.inputsToDispatchFirst.firstCountry = event.detail.value;
                }
            }

            if (event.target.dataset.type === "firstReason") {
                if (event.detail.value === "") {
                    this.inputsToDispatchFirst.firstReason = "";
                } else {
                    this.inputsToDispatchFirst.firstReason = event.detail.value;
                }
            }
        }
        this.refreshAndDispatch();
    }

    /**
     * @description method to handle default tax input changes ( if the user pays taxes in SA Only)
     */
    secondGenericTaxOnChange(event) {
        if (event.detail) {
            this.inputsToDispatchSecond[event.target.dataset.type] = event.detail.value;
        }
        this.refreshAndDispatch();
    }

    secondItemDeleteReasonInput() {
        this.secondItemHasNoTaxNumber = false;
        delete this.inputsToDispatchSecond.secondReason;
        // init taxNumber
        this.inputsToDispatchSecond.secondTaxNumber = "";
        this.template.querySelector('[name="taxNumber"]').value = "";
        this.refreshAndDispatch();
    }

    secondItemNoTaxNumber() {
        this.inputsToDispatchSecond.secondReason = "";
         this.inputsToDispatchSecond.secondTaxNumber="";
        this.secondItemHasNoTaxNumber = true;
        this.secondTaxNumberValue = null;
        window.setTimeout(() => {
            this.template.querySelectorAll('lightning-input').forEach((element) => {
                element.reportValidity();
            });
        }, 10);
        this.refreshAndDispatch();
    }

    deleteReasonInput() {
        this.hasNoTaxNumber = false;
        delete this.inputsToDispatchFirst.firstReason;
        // init taxNumber
        this.inputsToDispatchFirst.firstTaxNumber = "";
        this.template.querySelector('[name="taxNumber"]').value = "";
        this.refreshAndDispatch();
    }

    noTaxNumber() {
        this.inputsToDispatchFirst.firstReason = "";
        this.inputsToDispatchFirst.firstTaxNumber="";
        this.hasNoTaxNumber = true;
        this.taxNumberValue = null;
        window.setTimeout(() => {
            this.template.querySelectorAll('lightning-input').forEach((element) => {
                element.reportValidity();
            });
        }, 10);
        this.refreshAndDispatch();
    }

    addTaxCountry() {
        this.hasSecondElem = true;
        this.secondRequired = true;
        this.addElemsToInputsToDispatch();
    }

    deleteTaxInput() {
        this.hasSecondElem = false;
        this.secondRequired = false;
        delete this.inputsToDispatchSecond.secondCountry;
        delete this.inputsToDispatchSecond.secondTaxNumber;
        this.secondTaxNumberValue='';
        if (this.inputsToDispatchFirst.secondReason)
            delete this.inputsToDispatchFirst.secondReason;
        this.refreshAndDispatch();
    }

    @api triggerBlur() {
      
        this.template.querySelectorAll('c-aob_internal_comp_acpicklist').forEach((element) => {
            element.triggerInsideBlur();
        });
        this.template.querySelectorAll('lightning-input').forEach((element) => {
          
            element.reportValidity();
        });
        this.refreshAndDispatch();
    }
}