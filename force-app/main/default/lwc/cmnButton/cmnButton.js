import { LightningElement, api } from 'lwc';
import basePath from '@salesforce/community/basePath';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { addAnalyticsInteractions } from 'c/acm_AdobeAnalytics';

const NAVIGATE_TO_URL = 'navigateToUrl';
const RETURN_LABEL_WHEN_CLICKED = 'returnLabelWhenClicked';
const FLOW_NEXT_BUTTON = 'flowNextButton';

export default class CmnButton extends LightningElement {
  // we don't want to let flow devs to select another action than the flow one
  // so we need a way to detect we are in a flow, which we do thanks to availableActions
	@api availableActions = [];

  @api action = NAVIGATE_TO_URL;
  @api variant;
  @api destinationUrl;
  @api label = "label";
  @api title = "button";
  @api disabled;
  // buttons seem to come in various predefined widths
  @api wClass;
  @api customCssClasses;

  //Adobe tracking attribute variables
  @api interactionIntent;
  @api interactionScope;
  @api interactionType;

  classList = "slds-button slds-button_";

  renderedCallback(){
    addAnalyticsInteractions(this.template);
  }

  connectedCallback() {
    this.classList += this.variant + " " + this.wClass;
    // auto-detect flow (if there is not next screen, what's the purpose of a button anyway??)
		if (this.availableActions.find(action => action === 'NEXT')) this.action = FLOW_NEXT_BUTTON;
  }

  onClick(event) {

    switch (this.action) {
      case NAVIGATE_TO_URL:
        if(this.destinationUrl.startsWith("http")) document.location.href = this.destinationUrl;
        else if(this.destinationUrl.startsWith("/")) document.location.href = document.location.protocol + '//' + document.location.hostname + this.destinationUrl;
        else if(this.destinationUrl.startsWith("mailto")) document.location.href = this.destinationUrl;
        else document.location.href = `${basePath}/${this.destinationUrl}`;        
        break;
      case RETURN_LABEL_WHEN_CLICKED:
        this.dispatchEvent(new CustomEvent('clicked', { detail: this.label }));
        break;
      case FLOW_NEXT_BUTTON:
        event.preventDefault();
        this.dispatchEvent(new FlowNavigationNextEvent());
        break;
      default:
        break;
    }     
  }
}

export {
  NAVIGATE_TO_URL, RETURN_LABEL_WHEN_CLICKED, FLOW_NEXT_BUTTON
}