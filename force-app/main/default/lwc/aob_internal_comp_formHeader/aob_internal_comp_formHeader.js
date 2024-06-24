/**
 * @description       : Displays header for individual components
 * @author            : Mahlatse Tjale
 * @last modified on  : 07-20-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/
import { LightningElement, api } from 'lwc';
import AOB_PA_Title from '@salesforce/label/c.AOB_PA_Title';
import AOB_PA_SubTitle from '@salesforce/label/c.AOB_PA_SubTitle';
import AOB_PA_Content2 from '@salesforce/label/c.AOB_PA_Content2';

export default class Aob_internal_comp_formHeader extends LightningElement {
    label = {
        AOB_PA_Title,
        AOB_PA_SubTitle,
        AOB_PA_Content2,
    };

    @api title;
    @api subTitle;
    @api currentScreen;
    showBlock = false;

    connectedCallback() {
        if (this.currentScreen == 'PreApplication') this.showBlock = true;
    }
}