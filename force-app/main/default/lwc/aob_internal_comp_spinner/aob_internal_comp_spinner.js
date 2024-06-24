import { LightningElement } from 'lwc';
import AOB_ThemeOverrides from '@salesforce/resourceUrl/AOB_ThemeOverrides';
import internal_spinner from '@salesforce/resourceUrl/aob_internal_spinner';

export default class Aob_internal_comp_spinner extends LightningElement {
    spinner = AOB_ThemeOverrides + '/assets/images/Spinner.svg';
    myResourceUrl = internal_spinner;
}