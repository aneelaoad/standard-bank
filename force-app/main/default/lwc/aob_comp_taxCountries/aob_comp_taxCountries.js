import { LightningElement,api,track } from 'lwc';
/**Static ressources */
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import AOB_ConfirmMissingMsg from '@salesforce/label/c.AOB_ConfirmMissingMsg';
import AOB_TaxNumberValidationError from '@salesforce/label/c.AOB_TaxNumberValidationError';

export default class Aob_comp_taxCountries extends LightningElement {
    //Labels
    label = {
        AOB_ConfirmMissingMsg,
        AOB_TaxNumberValidationError
    };

    addIMG = AOB_ThemeOverrides + '/assets/images/add_icon.png';
    closeMG = AOB_ThemeOverrides + '/assets/images/close_icon.png';
    @api nonSATax;
    @api maxLenght=2;
    reachedMax=false;
    countries=[{'label':'South Africa','value':'SA'}];
    @track taxInputs=[];

    /**
     * @description method to show tax fields
     */
     connectedCallback(){
            this.taxInputs=[{'country':'','taxNumber':'','isFirst': true,'isLast':true,'hasTaxNumber':false}];
    }

    /**
     * @description Method to remove errors
     */
    removeError(element) {
        element.setCustomValidity("");
        element.reportValidity();
    }

    /**
     * @description Method to check if all required fields are filled
     */
    validateForm() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            this.removeError(element);
            element.setCustomValidity(this.label.AOB_TaxNumberValidationError);
            element.reportValidity();
            element.focus();
            isValid = false;
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            this.removeError(element);
            element.setCustomValidity(this.label.AOB_ConfirmMissingMsg);
            element.reportValidity();
            element.focus();
            isValid = false;
        });
    }

     /**
     * @description method to add tax input fields
     */
    addTaxCountry() {
        this.validateForm();
        let allTaxInputsAreFilled = true;
        /*for (let i in this.taxInputs) {
            this.taxInputs[i].isLast=false;
            allTaxInputsAreFilled= allTaxInputsAreFilled && (this.taxInputs[i].country && (this.taxInputs[i].taxNumber || this.taxInputs[i].taxReason));
        }
            console.log(allTaxInputsAreFilled);
            console.log('jere');
        if (allTaxInputsAreFilled) {*/
            if (this.taxInputs.length === 0)
                this.taxInputs.push({
                    country: '',
                    taxNumber: '',
                    isFirst: true,
                    taxReason:'',
                    hasTaxNumber:false,
                    isLast:true
                });
            else
                this.taxInputs.push({
                    country: '',
                    taxNumber: '',
                    isFirst: false,
                    taxReason:'',
                    hasTaxNumber:false,
                    isLast:true
                });
        /*}
        else{
            this.taxInputs[this.taxInputs.length-1].isLast=true;
        }
        console.log(this.taxInputs.length>=this.maxLenght);
        if( this.taxInputs.length>=this.maxLenght){
            this.reachedMax=true;
        }*/
        if( this.taxInputs.length>=this.maxLenght){
            this.reachedMax=true;
        }
    }
    /**
     * @description method to show no Tax reason picklist
     */
    noTaxNumber(event){
        const index = event.target.dataset.index;
        const type = event.target.dataset.type;
        this.taxInputs[index][type] = true;
    }

    /**
     * @description method to handle default tax input changes ( if the user pays taxes in SA Only)
     */
     genericTaxOnChange(event) {
        const index = event.target.dataset.index;
        const value = event.target.value;
        const type = event.target.dataset.type;
        this.taxInputs[index][type] = value;
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("taxvaluechange", {
            detail: {value:this.taxInputs,target:'Tax'}
        });
    
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    /**
     * @description method to delete tax input fields
     */
     deleteTaxInput(event) {
        const index = event.target.dataset.index;
        this.reachedMax=false;
        this.taxInputs.splice(index, 1);
    }
    
}