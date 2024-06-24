import deleteApplicationLineItem from "@salesforce/apex/CIB_CTRL_ApplicationLineItem.deleteApplicationLineItem";
import getApplicationLineItems from "@salesforce/apex/CIB_CTRL_ApplicationLineItem.getApplicationLineItems";
import saveApplicationLineItems from "@salesforce/apex/CIB_CTRL_ApplicationLineItem.saveApplicationLineItems";
import { track } from "lwc";

const Cib_comp_ApplicationLineItemMixin = (superclass) =>
  class extends superclass {
    @track lineItems = [{ CIB_Sequence__c: 1 }];

    async getApplicationLineItems(recordTypeName) {
      try {
        let lineitems = await getApplicationLineItems({
          recordTypeName: recordTypeName,
          applicationId: this.recordId
        });
        if (lineitems.length) {
          lineitems = lineitems.map((lineitem, index) => ({
            ...lineitem,
            CIB_Sequence__c: index + 1
          }));
          this.lineItems = lineitems;
          this.onLineItemsLoaded(lineitems);
          this.isLoaded = true;
          return lineitems;
        }
      } catch (error) {
        this.handleError(error);
      }
      this.isLoaded = true;
      return [];
    }

    async connectedCallback() {
      await this.getApplicationLineItems(this.RECORD_TYPE);
      super.connectedCallback();
    }

    onLineItemsLoaded(lineItems) {
      lineItems.forEach((lineItem) => {
        this.template
          .querySelectorAll("[data-line-item-sequence='" + lineItem.CIB_Sequence__c + "']")
          .forEach((element) => {
            element.value = lineItem[element.dataset.fieldname];
          });
      });
    }

    normalizeLineItems() {
      this.lineItems = this.lineItems.map((lineitem, index) => {
        lineitem.CIB_Sequence__c = index + 1;
        return lineitem;
      });
    }

    addLineItem() {
      this.lineItems = [
        ...this.lineItems,
        { CIB_Sequence__c: this.lineItems.length + 1 }
      ];
      this.normalizeLineItems();
    }

    deleteLineItem(event) {
      const lineItemSequence = event.target.dataset.lineItemSequence;
      const lineitemIndex = this.lineItems.findIndex(
        (lineitem) => lineitem.CIB_Sequence__c === +lineItemSequence
      );
      const [lineItem] = this.lineItems.splice(lineitemIndex, 1);
      this.deleteApplicationLineItem(lineItem);
      this.normalizeLineItems();
    }

    async deleteApplicationLineItem(lineItem) {
      return deleteApplicationLineItem({ lineItem });
    }

    async saveApplicationLineItems(recordTypeName, lineitems) {
      return saveApplicationLineItems({
        recordTypeName: recordTypeName,
        lineitems: lineitems
      });
    }

    async updateApplicationRecord() {
      return this.saveApplicationLineItems(
        this.RECORD_TYPE,
        this.lineItems.map((lineitem) => {
          const item = {
            ...(this.collectValues ? this.collectValues(lineitem) : {}),
            Id: lineitem.Id,
            Application__c: this.recordId,
            CIB_Sequence__c: lineitem.CIB_Sequence__c
          };
          this.template
            .querySelectorAll(
              "[data-line-item-sequence='" + lineitem.CIB_Sequence__c + "']"
            )
            .forEach((element) => {
              item[element.dataset.fieldname] = element.value;
            });
          return item;
        })
      );
    }
  };

export default Cib_comp_ApplicationLineItemMixin;