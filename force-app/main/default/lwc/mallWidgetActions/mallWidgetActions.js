import { LightningElement, api } from "lwc";
const INVERSE_CONTRAST_CSS_CLASS = "inverse-contrast";

export default class MallWidgetActions extends LightningElement {
  @api actionsCollection;
  @api inverseContrast = false;
  actionsList;
  actionLists;
  widgetActionsCssClass = "widget-actions";
  defaultActions = [
    {
      name: "Remove",
      event: this.removeWidget
    },
    {
      name: "Sign out",
      event: this.signOutOfWidget
    }
  ];

  buildActionsList(array) {
    const mergedActions = [...array, ...this.defaultActions];
    return mergedActions;
  }

  connectedCallback() {
    this.inverseContrast &&
      (this.widgetActionsCssClass =
        this.widgetActionsCssClass + " " + INVERSE_CONTRAST_CSS_CLASS);
    this.actionsCollection
      ? this.buildActionsList(this.actionsCollection)
      : (this.actionsList = this.defaultActions);
  }

  toggleActionList(event) {
    let elem = event.target;
    elem.classList.toggle("open");
  }

  removeWidget(event) {
    window.dispatchEvent(new CustomEvent("removeWidget", event.target));
  }

  signOutOfWidget(event) {
    window.dispatchEvent(new CustomEvent("signoutOfWidget", event.target));
  }
}