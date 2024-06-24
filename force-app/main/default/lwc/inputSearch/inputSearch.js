import { LightningElement, api, wire, track  } from 'lwc';
import getRecord  from '@salesforce/apex/UTL_LookupField_Ctrl.getRecord';
import getSuggestions  from '@salesforce/apex/UTL_LookupField_Ctrl.getSuggestedParents';

export default class inputSearch extends LightningElement {
    @wire (getRecord,{ recordId: '$value'}) record;
    @wire (getSuggestions, {sObjectName: '$objectName', fieldName: '$fieldName', name: '$searchText'}) suggestions;

    @api fieldName;
    @api fieldLabel;
    @api objectName;
    @api value;
    @api whereClause;
    @track isFocused = false;
    @track searchText;

    get inputDiv() {
        return this.value ? 'slds-hide': '';
    }

    handleFocus() {
        let el = this.template.querySelector('[data-id="dropdownContainer"]');
        el.classList.remove('slds-hide');
    }

    handleBlur() {
        let el = this.template.querySelector('[data-id="dropdownContainer"]');
        el.classList.add('slds-hide');
    }

    handleChange(event) {
        this.searchText = event.target.value;
    }

    handleRemove(event){
        this.value = null;
        let div = this.template.querySelector('[data-id="inputFieldDiv"]');
        div.classList.remove('slds-hide');
        let input = this.template.querySelector('[data-id="inputField"]');
        input.focus();
    }

    handleChangeValue(event) {
      const recordId = event.currentTarget.dataset.recordid;
      this.value = recordId;
      const valuechange = new CustomEvent('valuechange', { detail: this.value});
      this.dispatchEvent(valuechange);
      let el = this.template.querySelector('[data-id="inputFieldDiv"]');
      el.classList.add('slds-hide');
    }

}