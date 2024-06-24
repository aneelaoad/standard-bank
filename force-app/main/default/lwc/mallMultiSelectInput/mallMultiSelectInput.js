import { LightningElement, api, track } from 'lwc';

export default class MallMultiSelectInput extends LightningElement {
    @api isRequired = false;
    @api inputLabel = "";
    @api showPlaceholder = false;
    @api inputPlaceholder = "";
    @api selectOptions = [];
    @api showSelectDropdown = false;
    @api toggleSelectDropdownCallback = null;
    @track selectOptionsList = [];
    selectedCount = 0;
    @api removeButtonClass = false;
    get buttonClass() {
        return this.removeButtonClass ? "" : "slds-button slds-button_neutral";
    } 

    toggleSelectDropdown() {
        this.showSelectDropdown = !this.showSelectDropdown;
    }

    handleCheckboxChange(event) {
        const value = event.target.value;
        const checked = event.target.checked;
        let selectOptions = [...this.selectOptions];
        
        for (let row = 0; row < selectOptions.length; row++) {
            let selectedOption = { ...selectOptions[row] };
            if (selectedOption.value == value) {
                selectedOption.selected = checked;
                selectOptions[row] = { ...selectedOption };
                this.selectOptions = [...selectOptions];
                if (selectedOption.selected) {
                    this.selectedCount += 1;
                } else {
                    this.selectedCount -= 1;
                }
                break;
            }
        }
        this.dispatchEvent(new CustomEvent('selection', { detail: this.selectOptions }));
        if (this.selectedCount > 0) {
            this.showPlaceholder = false;
        } else {
            this.showPlaceholder = true;
        }
    }
}