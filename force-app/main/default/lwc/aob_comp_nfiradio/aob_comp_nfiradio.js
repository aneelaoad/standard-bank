import { LightningElement, api, track } from 'lwc';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';


export default class Aob_comp_nfiradio extends LightningElement {

 @api teams = ["Self Assisted"];
    label = {};

  ExcIcon = AOB_ThemeOverrides + '/assets/images/icon_info_circle.svg';
  listArrow = AOB_ThemeOverrides + '/assets/images/list-arrow.svg';
  @api value;
  @api name;

  constructor() {
    super();
  }

  connectedCallback() {
    
  }
   handleResultChange(event) {
        this.label = event.detail;
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