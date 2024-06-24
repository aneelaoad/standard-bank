import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { RETURN_LABEL_WHEN_CLICKED } from 'c/cmnButton';

export default class AcmPlanSelection extends LightningElement {
  // will contain the action (subscribe or cancel) selected by the user
  @api action;
  // list of plans received by the component
  @api serializedPlans;
  // id of the selected plan
  @api planId;

  // list of plans from the back-end (deserialized)
  plans;
  noPlanSelected = true;
  
  returnLabelWhenClicked = RETURN_LABEL_WHEN_CLICKED;
  
  connectedCallback() {
    // plans are received as serialised JSON
    this.plans = JSON.parse(this.serializedPlans);
  }

  onButtonClicked(event) {
    this.updateFlowVariable('action', event.detail);
    const navigateNextEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(navigateNextEvent);
  }

  onPlanSelected(event) {
    this.updateFlowVariable('planId', event.target.value);
    this.noPlanSelected = false;
  }

  updateFlowVariable(name, value) {
    const updateFlowVariable = new FlowAttributeChangeEvent(name, value);
    this.dispatchEvent(updateFlowVariable);
  }
}