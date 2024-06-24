import { LightningElement, api } from 'lwc';
import ADDR from '@salesforce/resourceUrl/AOB_ThemeOverrides';

export default class Aob_comp_companyaddress extends LightningElement {
    ADDRICON = ADDR + '/assets/images/Home.svg';
    @api address;

}