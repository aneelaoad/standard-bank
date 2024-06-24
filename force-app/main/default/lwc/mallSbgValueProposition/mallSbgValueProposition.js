import { LightningElement, api } from "lwc";

export default class MallSbgValueProposition extends LightningElement {
  @api headerText;
  @api unstyledVariant;
  @api shieldType;
  @api jsonCollection;

  get valuePropositionCssWrapperClass() {
    if (this.unstyledVariant === true || this.unstyledVariant === "true") {
      return "component value-proposition plain";
    }
    return "component value-proposition";
  }

  get mainHeaderText() {
    return this.headerText;
  }

  setValuePropositionArray() {
    const collection =
      this.jsonCollection && this.jsonCollection !== []
        ? JSON.parse(this.jsonCollection)
        : [];

    return collection;
  }

  get valuePropositionCollection() {
    return this.setValuePropositionArray();
  }
}