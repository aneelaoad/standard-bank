/**
 * @description       : Provides radio buttons for individual components
 * @author            : Mahlatse Tjale
 * @last modified on  : 07-20-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import AOB_ZA_DoesYourCompany from '@salesforce/label/c.AOB_ZA_DoesYourCompany';  
import AOB_ZA_EarnMoreThan from '@salesforce/label/c.AOB_ZA_EarnMoreThan';  
import AOB_ZA_HoldMoreThan from '@salesforce/label/c.AOB_ZA_HoldMoreThan';  	
import AOB_Yes from '@salesforce/label/c.AOB_Yes';
import AOB_No from '@salesforce/label/c.AOB_No';    
import AOB_ZA_or from '@salesforce/label/c.AOB_ZA_or';

export default class Aob_internal_comp_nfiradio extends LightningElement {

  label={
    AOB_ZA_DoesYourCompany,
    AOB_ZA_EarnMoreThan,
    AOB_ZA_HoldMoreThan,
    AOB_Yes,
    AOB_No,
    AOB_ZA_or
  };

  ExcIcon = AOB_ThemeOverrides + '/assets/images/icon_info_circle.svg';
  listArrow = AOB_ThemeOverrides + '/assets/images/list-arrow.svg';
  @api value;
  @api name;

  constructor() {
    super();
  }

  connectedCallback() {
    
  }
  renderedCallback(){
   
    this.template.querySelectorAll('[type="radio"]').forEach(element => {
    
      if(this.value && element.dataset.value == this.value){
        element.checked = true;
      }
    });
  }
  genericRadioChange(event){
    const selectedEvent = new CustomEvent("change", {
      detail: {
        target: event.target.dataset.name,
        value: event.target.dataset.value
      }
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

}