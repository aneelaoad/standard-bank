import { LightningElement, api } from 'lwc';

export default class OsbContactUsInfoBoxLwc extends LightningElement {
    @api title;
    @api email;
    @api addtionaltitle;
    @api phonenumber;
}