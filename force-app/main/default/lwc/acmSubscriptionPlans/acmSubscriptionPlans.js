import { LightningElement, api,track} from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
const ACM_SUBSCRIPTION_PLAN_PRICE = "FREE";


export default class AcmSubscriptionPlans extends LightningElement {
  @api serializedPlans;
  @api selectedPlan;
  @api planNumber;
  @track selectedItem;
  formattedTime = "";
  planPrice;
  limits = {};

  connectedCallback() {
    this.planPrice = ACM_SUBSCRIPTION_PLAN_PRICE;
    if (this.serializedPlans) {
      this.limits.calls =
        this.serializedPlans[0].limitsByApi[0].limits[0].maximumRequests;
      this.limits.minutes = this.msToMinutes(
        this.serializedPlans[0].limitsByApi[0].limits[0]
          .timePeriodInMilliseconds
      );
    }
  }

  onRadioClicked(event) {
    this.selectedItem = event.target.value;
    this.flowStatus = event.detail;
    this.updateFlowVariable("selectedPlan", this.selectedItem);
  }

  updateFlowVariable(name, value) {
    const updateFlowVariable = new FlowAttributeChangeEvent(name, value);
    this.dispatchEvent(updateFlowVariable);
  }

  msToMinutes(duration) {
    let minutes = Math.floor((duration / (1000 * 60)) % 60);
    let hours = Math.floor((duration / (1000 * 60 * 60)) % 24);
    let overallDuration = minutes + hours * 60;

    if (overallDuration > 60) {
      overallDuration = hours + "h " + minutes + " minute(s)";
      return overallDuration;
    } else if (duration < 60000) {
      overallDuration = duration + " millisecond(s)";
      return overallDuration;
    } else {
      return minutes + " minute(s)";
    }
  }

  renderedCallback() {
    if (this.serializedPlans && this.planNumber) {
      this.serializedPlans.forEach((element) => {
        if (element.x === this.planNumber) 
          this.updateFlowVariable("selectedPlan", this.planNumber);
          this.template.querySelector('input[value="' + this.planNumber + '"]').checked = true;
      });
    }
  }
}