import { LightningElement, api, track } from 'lwc';

export default class Aob_comp_picklistitem extends LightningElement {
  @api item;
  @api itemClass

  constructor() {
    super();
  }

  connectedCallback() {
  }

  get itemClass() {
    return (
      "slds-listbox__item ms-list-item" +
      (this.item.Selected ? " slds-is-selected" : "")
    );
  }

  @api
  onItemSelected(event) {
    const evt = new CustomEvent("items", {
      detail: { item: this.item, Selected: !this.item.Selected },
    });
    this.dispatchEvent(evt);
    event.stopPropagation();
    this.itemClass = "slds-listbox__item ms-list-item" + (this.item.Selected ? " slds-is-selected" : "");
  }
}