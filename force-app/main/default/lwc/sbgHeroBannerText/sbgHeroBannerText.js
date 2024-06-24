import { LightningElement, api } from "lwc";
import { NAVIGATE_TO_URL } from "c/cmnButton";

export default class SbgHeroBannerText extends LightningElement {
  @api heading;
  @api subText;
  @api includeButton;

  @api buttonLabel;
  @api buttonTitle;
  @api destinationUrl;

  @api action = NAVIGATE_TO_URL;
  @api variant;
  @api disabled;
  // buttons seem to come in various predefined widths
  @api wClass;

  @api showButton;

  handleClick() {
    const clickEvent = new CustomEvent("buttonclick", {
      detail: false
    });
    this.dispatchEvent(clickEvent);
  }
}