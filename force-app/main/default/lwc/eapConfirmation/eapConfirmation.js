import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import CLOSE_LABEL from '@salesforce/label/c.Eap_Close_Label';

export default class EapConfirmation extends NavigationMixin(LightningElement) {
    labels = {Close: CLOSE_LABEL};
    blueShield = customIcons + '/blueShield.svg';
    greenShield = customIcons + '/greenShield.svg';
    orangeShield = customIcons + '/orangeShield.svg';
    checkIcon = customIcons + '/check.svg';
    xIcon = customIcons + '/close.svg';

    @api shield = this.greenShield;
    @api icon = this.checkIcon;
    @api message;
    @api destination;
    @api eventId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.message = this.urlStateParameters.message.replace('+', ' ') || '';
        this.destination = this.urlStateParameters.destination || 'Home';
        this.eventId = this.urlStateParameters.eventId || null;

        let type = this.urlStateParameters.type || null;
        switch (type)
        {
            case 'Error': 
                this.shield = this.orangeShield;
                this.icon = this.xIcon;
                break;
            case 'Success':
                this.shield = this.greenShield;
                this.icon = this.checkIcon;
                break;
            case 'Info':
                this.shield = this.blueShield;
                this.icon = this.checkIcon;
                break;

            default: break;
        }
    }

    showAccommodation(){
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: this.destination
            },state: {
                eventId:  this.eventId
            }
        });
    }
}