/**
 * @description       : provides checkboxes to individual components
 * @author            : Mahlatse Tjale
 * @last modified on  : 07-20-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/
import { LightningElement, api } from 'lwc';
import AOB_Payments_Instore from '@salesforce/label/c.AOB_Snapscan_Receive_payments_in_store';
import AOB_Payments_Online from '@salesforce/label/c.AOB_Snapscan_Receive_payments_online';


export default class Aob_internal_comp_imageCheckbox extends LightningElement {
    @api imageHeading;
    @api imageName;
    @api formDetails = {};
    @api totalArray = [];
    @api imagedata;
    disablecheck=false;

    Label = {
        AOB_Payments_Instore,
        AOB_Payments_Online
    }
    selectedCheckHandler(event){
        let name = event.target.name;
        let value = event.target.checked;
        if(name=='receiveInStore'){
        }
        this.formDetails[name] = value;
        this.totalArray.push(this.formDetails);
     
        const bundleClick = new CustomEvent('send', 
            {detail: {formName: name, checkboxc:event.target.checked}}
        );
        this.dispatchEvent(bundleClick);
    }


}