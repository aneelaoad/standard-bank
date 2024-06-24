import { LightningElement, api } from 'lwc';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';

export default class EapSpinner extends LightningElement {
    iconSpinner = customIcons + '/customSpinner.svg';
}