import { LightningElement, api, track } from "lwc";
import checkboxicon from "@salesforce/resourceUrl/MAU_ThemeOverrides";

export default class Cmn_comp_multiSelectPicklistItem extends LightningElement {
  @api item;
  @track _itemClass;
  checkboxicon = checkboxicon + "/assets/images/checkboxicon.svg";

  connectedCallback() {}

  @api
  get itemClass() {
    return (
      "slds-listbox__item ms-list-item" +
      (this.item.Selected ? " slds-is-selected" : "")
    );
  }
  set itemClass(value) {
    this._itemClass = value;
  }

  get iconStyle() {
    return `
      border-radius: 50px;
      width: 16px;
      height: 16px;
      background-image: url(${this.item.icon});
      background-size: cover;
      background-position: center;
      ${this.item.Selected ? "border: 2px solid #0176d3" : ""}
    `;
  }

  get liItemStyle() {
    return this.item.Selected ? "background-color: #DFEEFD" : "";
  }

  @api
  onItemSelected(event) {
    const evt = new CustomEvent("items", {
      detail: {
        item: this.item,
        Selected: !this.item.Selected
      }
    });
    this.dispatchEvent(evt);
    event.stopPropagation();
    this._itemClass =
      "slds-listbox__item ms-list-item" +
      (this.item.Selected ? " slds-is-selected" : "");
  }

  onItemL(event) {
    this.template.querySelectorAll("input").forEach((li) => {
      if (li.dataset.value === event.target.dataset.value) {
        li.checked = true;
      }
    });
  }
}