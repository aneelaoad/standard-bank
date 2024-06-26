import { LightningElement, track, api } from 'lwc';

export default class MultiSelectCombobox extends LightningElement {
  
  @api disabled = false;
  @api label = '';
  @api name;
  @api options = [];
  @api placeholder = 'Select operating country/countries';
  @api readOnly = false;
  @api required = false;
  @api singleSelect = false;
  @api showPills = false;
  @track currentOptions = [];
  selectedItems = [];
  selectedOptions = [];
  isInitialized = false;
  isLoaded = false;
  isVisible = false;
  isDisabled = false;

  @api
  validationComboBox(boolValidation) {
    if(!boolValidation){
      this.template.querySelector('.multi-select-combobox__input').style = 'border: 0.0625rem solid red !important;';
    }else{
      this.template.querySelector('.multi-select-combobox__input').style = 'border: 0.0625rem solid grey !important;';
    }
  }


  connectedCallback() {
    this.isDisabled = this.disabled || this.readOnly;
    this.hasPillsEnabled = this.showPills && !this.singleSelect;
  }
  renderedCallback() {
    let prePopulatedValues = JSON.parse(JSON.stringify(this.options)).filter((values) => values.selected);

    if (!this.isInitialized) {
      this.template.querySelector('.multi-select-combobox__input').addEventListener('click', (event) => {
        this.handleClick(event.target);
        event.stopPropagation();
      });
      this.template.addEventListener('click', (event) => {
        event.stopPropagation();
      });
      document.addEventListener('click', () => {
        this.close();
      });
      this.isInitialized = true;
      if(prePopulatedValues){
        this.setSelection(prePopulatedValues);
      }else{
        this.setSelection();
      }
    }
  }
  handleChange(event) {
    this.change(event);
  }
  handleRemove(event) {
    this.selectedOptions.splice(event.detail.index, 1);
    this.change(event);
  }
  handleClick() {
    if (this.isLoaded === false) {
      this.template.querySelector('.multi-select-combobox__input').style = 'border: 0.0625rem solid grey !important;';
      this.currentOptions = JSON.parse(JSON.stringify(this.options));
      this.isLoaded = true;
    }
    if (this.template.querySelector('.slds-is-open')) {
      this.close();
    } else {
      this.template.querySelectorAll('.multi-select-combobox__dropdown').forEach((node) => {
        node.classList.add('slds-is-open');
      });
    }
  }
  change(event) {
    if (this.singleSelect) {
      this.currentOptions.forEach((item) => (item.selected = false));
    }

    this.currentOptions
      .filter((item) => item.value === event.detail.item.value)
      .forEach((item) => (item.selected = event.detail.selected));
    this.setSelection();
    const selection = this.getSelectedItems();
    this.dispatchEvent(new CustomEvent('change', { detail: this.singleSelect ? selection[0] : selection }));

    if (this.singleSelect) {
      this.close();
    }
  }

  close() {
    this.template.querySelectorAll('.multi-select-combobox__dropdown').forEach((node) => {
      node.classList.remove('slds-is-open');
    });
    this.dispatchEvent(new CustomEvent('close'));
  }

  setSelection(values) {
    let selectedItems;
    if(!values){
        selectedItems = this.getSelectedItems();
    }else{
        selectedItems = values;
    }
    let selection = '';
    if (selectedItems.length < 1) {
      selection = this.placeholder;
      this.selectedOptions = [];
    } else if (selectedItems.length > 4) {
      selection = `${selectedItems.length} Options Selected`;
      this.selectedOptions = this.getSelectedItems();
    } else {
      selection = selectedItems.map((selected) => selected.label).join(', ');
      this.selectedOptions = this.getSelectedItems();
    }
    this.selectedItems = selection;
    this.isVisible = this.selectedOptions && this.selectedOptions.length > 0;
  }

  getSelectedItems() {
    return this.currentOptions.filter((item) => item.selected);
  }
}