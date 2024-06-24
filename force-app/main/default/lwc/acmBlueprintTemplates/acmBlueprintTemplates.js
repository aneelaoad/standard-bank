import { LightningElement, api } from 'lwc';
import { NAVIGATE_TO_URL } from 'c/cmnButton';
import { FlowNavigationNextEvent } from "lightning/flowSupport";


export default class AcmBlueprintTemplates extends LightningElement {
  @api isRecommended = false;
  @api heading;
  @api description;
  @api buttonLabel;
  @api buttonUrl;
  navigateToUrl = NAVIGATE_TO_URL;
  @api availableActions = [];

  navigateToNextPage() {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
  }
}