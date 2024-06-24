/**
* @description  :  Custom Multiselct Combobox
* User Story : SFP-4881
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date OCT 2021
*/
import { LightningElement, api, wire, track } from 'lwc';

export default class CmnMultiSelectCombobox extends LightningElement {

    @api
    options = [];
    @api
    value = [];
    @api
    label;
    items = [];
    dropdownList = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta';
    error;
    dropdown = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    checkedStyle = 'slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-media_center slds-is-selected';
    dataList;
    selectedValue;
    selectedListOfValues = '';

    connectedCallback() {
        if (this.options) {
            this.refreshOptions(this.options);
        } 
    }


    @api
    refreshOptions(options) {
        this.options = options;
        this.selectedValue = 'Select ' + this.label;
        let count = 0;
        for (let i = 0; i < this.options.length; i++) {
            let match = false;
            if (this.value) {
                for (let j = 0; j < this.value.value.length; j++) {
                    if (this.value.value[j] == this.options[i].value) {
                        match = true;
                        count++;
                        this.items = [...this.items, { value: this.options[i].value, label: this.options[i].label, isChecked: true, class: this.checkedStyle }];
                    }
                }
                if(!match){
                    this.items = [...this.items, { value: this.options[i].value, label: this.options[i].label, isChecked: false, class: this.dropdownList }];
                }
            } else {
                this.items = [...this.items, { value: this.options[i].value, label: this.options[i].label, isChecked: false, class: this.dropdownList }];
            }

        }

        if (count === 1) {
            this.selectedValue = count + ' Option Selected';
        }
        else if (count > 1) {
            this.selectedValue = count + ' Options Selected';
        }
        else if (count === 0) {
            this.selectedValue = 'Select ' + this.label;
        }
    }

    openDropdown() {

        if (this.dropdown == 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open') {
            this.dropdown = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        } else {
            this.dropdown = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
        }
    }
    closeDropDown() {
        this.dropdown = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    }
    selectOption(event) {
        let inputbox = this.template.querySelector('input');
        inputbox.className = 'slds-input slds-combobox__input slds-combobox__input-value';
        let isCheck = event.currentTarget.dataset.id;
        let label = event.currentTarget.dataset.name;
        let selectedListData = [];
        let selectedOption = '';
        let allOptions = this.items;
        let count = 0;
        for (let i = 0; i < allOptions.length; i++) {
            if (allOptions[i].label === label) {
                if (isCheck === 'true') {
                    allOptions[i].isChecked = false;
                    allOptions[i].class = this.dropdownList;
                }
                else {
                    allOptions[i].isChecked = true;
                    allOptions[i].class = 'slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-media_center slds-is-selected';
                }
            }
            if (allOptions[i].isChecked) {
                selectedListData.push(allOptions[i].label);
                count++;
            }
        }
        if (count === 1) {
            selectedOption = count + ' Option Selected';
        }
        else if (count > 1) {
            selectedOption = count + ' Options Selected';
        }
        else if (count === 0) {
            selectedOption = 'Select ' + this.label;
            selectedListData = "";
            inputbox.className = 'slds-input slds-combobox__input slds-combobox__input-value placeholder-text';
        }

        this.items = allOptions;
        this.selectedValue = selectedOption;
        this.selectedListOfValues = selectedListData;
        this.setSelectedValues();
    }

    removeRecord(event) {
        let inputbox = this.template.querySelector('input');
        let value = event.detail.name;
        let removedOptions = this.items;
        let count = 0;
        let selectedListData = [];
        for (let i = 0; i < removedOptions.length; i++) {
            if (removedOptions[i].label === value) {
                removedOptions[i].isChecked = false;
                removedOptions[i].class = this.dropdownList;
            }
            if (removedOptions[i].isChecked) {
                selectedListData.push(removedOptions[i].label);
                count++;
            }
        }
        let selectedOption;
        if (count === 1) {
            selectedOption = count + ' Option Selected';
        }
        else if (count > 1) {
            selectedOption = count + ' Options Selected';
        }
        else if (count === 0) {
            selectedOption = 'Select ' + this.label;
            selectedListData = "";
            inputbox.className = 'slds-input slds-combobox__input slds-combobox__input-value placeholder-text';
        }
        this.selectedListOfValues = selectedListData;
        this.selectedValue = selectedOption;
        this.items = removedOptions;
        this.setSelectedValues();

    }

    setSelectedValues() {
        
        let value = [];
        for (let i = 0; i < this.items.length; i++) {
            if (this.items[i].isChecked) {
                value = [...value, this.items[i].value];
            }
        }
        const selectedValues = new CustomEvent('select', {
            detail: { value },
        });
        this.dispatchEvent(selectedValues);
    }

}