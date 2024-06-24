import { LightningElement, api } from 'lwc';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';

export default class EapShieldMessage extends LightningElement {
    iconShield = customIcons + '/blueShield.svg';
    @api icon = customIcons + '/document.svg';
    @api message;
    @api isOverButton = false;
    @api isOverTwoButtons = false;

    get noButtons() {
        if (!this.isOverButton && !this.isOverTwoButtons)
            return true;
        else
            return false;
    }
}