/**
 * @description       : 
 * @author            : Chibuye Kunda
 * @group             : 
 * @last modified on  : 10-14-2021
 * @last modified by  : Chibuye Kunda
**/
import { LightningElement } from 'lwc';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';

export default class Aob_comp_spinner extends LightningElement {
    spinner = AOB_ThemeOverrides + '/assets/images/Spinner.svg';
}