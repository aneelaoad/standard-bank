import { LightningElement, api } from 'lwc';
/**Static ressources */
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
export default class Aob_comp_tax extends LightningElement {
    //Labels
    @api teams = ["Self Assisted", "Self & Staff"];
    label = {};
    addIMG = AOB_ThemeOverrides + '/assets/images/add_icon.png';
    closeMG = AOB_ThemeOverrides + '/assets/images/close_icon.png';
    @api taxInputData;
    options;
    hasSecondElem;
    hasNoTaxNumber;
    secondItemHasNoTaxNumber;
    adobeDataScopeApp;
    adobeDataTextBack;
    adobeDataTextContinue;
    //pattern = "[0-9]{10}$";
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
        this.adobeDataScopeApp = 'mymobiz application';
        this.adobeDataTextBack = 'company financial details | add additional  country link click';
        this.adobeDataTextContinue = 'company financial details | ' + this.label.AOB_ZA_IDontHaveATaxNumber + ' link click';
        this.secondRequired = false;
        this.required = true;
        this.hasSecondElem = false;
        this.hasNoTaxNumber = false;
        this.secondItemHasNoTaxNumber = false;

        if (this.taxInputData) {
            this.populateData();
        }
        else {
            this.initInputsToDispatch();
        }
    }
    handleResultChange(event) {
        this.label = event.detail;
    }

    populateData() {
        if (this.taxInputData) {
            if (this.taxInputData.firstCountry) this.inputsToDispatchFirst.firstCountry = this.taxInputData.firstCountry;
            if (this.taxInputData.firstTaxNumber) {
                this.inputsToDispatchFirst.firstTaxNumber = this.taxInputData.firstTaxNumber;
                this.taxNumberValue = this.taxInputData.firstTaxNumber;
            }
            if (this.taxInputData.firstReason) {
                this.inputsToDispatchFirst.firstReason = this.taxInputData.firstReason;
                this.hasNoTaxNumber = true;
            }
            if (this.taxInputData.secondCountry) {
                this.inputsToDispatchSecond.secondCountry = this.taxInputData.secondCountry;
                this.hasSecondElem = true;
                this.secondRequired = true;
            }
            if (this.taxInputData.secondTaxNumber) {
                this.inputsToDispatchSecond.secondTaxNumber = this.taxInputData.secondTaxNumber;
                this.secondTaxNumberValue = this.taxInputData.secondTaxNumber;
            }
            if (this.taxInputData.secondReason) {
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
        console.log('taxInputs ', JSON.stringify(this.taxInputs));


        this.validateTaxComp();
        if (!this.hasSecondElem) this.validCompSecond = true;

        const selectedEvent = new CustomEvent("change", {
            detail: {
                taxDetails: JSON.stringify(taxInputs),
                value: (this.validCompFirst && this.validCompSecond),
                target: "taxCountries",
                inputsKey: "taxInputs"
            }
        });
        // Dispatches the event.
        console.log('tax valid ', this.validCompFirst && this.validCompSecond);
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
        // let re = new RegExp("[0-9]{10}$");
        // if (event.detail) {
        //     if (event.target.dataset.type === "firstTaxNumber" && re.test(event.detail.value) && (event.detail.value.length == 10)) {
        //         this.inputsToDispatchFirst.firstTaxNumber = event.detail.value;
        //     } else {
        //         this.inputsToDispatchFirst.firstTaxNumber = "";
        //     }
        // }
        this.inputsToDispatchFirst.firstTaxNumber = event.detail.value;
        this.refreshAndDispatch();
    }

    secondTaxNumberOnChange(event) {
        // let re = new RegExp("[0-9]{10}$");
        // if (event.detail) {
        //     if (event.target.dataset.type === "secondTaxNumber" && re.test(event.detail.value) && (event.detail.value.length == 10)) {
        //         this.inputsToDispatchSecond.secondTaxNumber = event.detail.value;
        //     } else {
        //         this.inputsToDispatchSecond.secondTaxNumber = "";
        //     }
        // }
        this.inputsToDispatchSecond.secondTaxNumber = event.detail.value;
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
        this.inputsToDispatchSecond.secondTaxNumber = "";
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

    noTaxNumber(event) {
        window.fireButtonClickEvent(this, event);
        this.inputsToDispatchFirst.firstReason = "";
        this.inputsToDispatchFirst.firstTaxNumber = "";
        this.hasNoTaxNumber = true;
        this.taxNumberValue = null;
        window.setTimeout(() => {
            this.template.querySelectorAll('lightning-input').forEach((element) => {
                element.reportValidity();
            });
        }, 10);
        this.refreshAndDispatch();
    }

    addTaxCountry(event) {
        this.hasSecondElem = true;
        this.secondRequired = true;
        this.addElemsToInputsToDispatch();
        window.fireButtonClickEvent(this, event);
    }

    deleteTaxInput() {
        this.hasSecondElem = false;
        this.secondRequired = false;
        delete this.inputsToDispatchSecond.secondCountry;
        delete this.inputsToDispatchSecond.secondTaxNumber;
        this.secondTaxNumberValue = '';
        if (this.inputsToDispatchFirst.secondReason)
            delete this.inputsToDispatchFirst.secondReason;
        this.refreshAndDispatch();
    }

    @api triggerBlur() {

        this.template.querySelectorAll('c-aob_comp_acpicklist').forEach((element) => {
            element.triggerInsideBlur();
        });
        this.template.querySelectorAll('lightning-input').forEach((element) => {

            element.reportValidity();
        });
        this.refreshAndDispatch();
    }
}