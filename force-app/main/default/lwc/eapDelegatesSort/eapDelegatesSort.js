import { LightningElement, api } from 'lwc';
import customIcons from '@salesforce/resourceUrl/EapCustomResourcers';
import VIEW_BY_LABEL from '@salesforce/label/c.Eap_ViewBy_Label';
import SORT_BY_LABEL from '@salesforce/label/c.Eap_SortBy_Label';
import COMPANY_LABEL from '@salesforce/label/c.Eap_Company_Label';
import NAME_LABEL from '@salesforce/label/c.Eap_Name_Label';
import SORT_A_Z_LABEL from '@salesforce/label/c.Eap_SortAZ_Label';
import SORT_Z_A_LABEL from '@salesforce/label/c.Eap_SortZA_Label';

export default class EapDelegatesSort extends LightningElement {
    labels = {ViewBy: VIEW_BY_LABEL, 
            SortByName: SORT_BY_LABEL+' '+NAME_LABEL,
            SortByCompany: SORT_BY_LABEL+' '+COMPANY_LABEL,
            SortAZ: SORT_A_Z_LABEL,
            SortZA: SORT_Z_A_LABEL}
    iconName = customIcons + '/userLogo.svg';
    iconBuilding = customIcons + '/iconBuilding.svg';
    iconAscending = customIcons + '/iconAscending.svg';
    iconDescending = customIcons + '/iconDescending.svg';

    @api isSortedByName;
    @api isSortedAscending;

    //Change type of sort
    sortBy(e){
        let sortName;
        if (e.target.tagName.toLowerCase() === 'button')
        {
            sortName = e.target.name;
        }else
        {
            sortName = e.target.parentElement.parentElement.name;
        }

        switch (sortName){
            case 'Name': 
                this.isSortedByName = true;
                break;
            case 'Company':
                this.isSortedByName = false;
                break;
            case 'Ascending': 
                this.isSortedAscending = true;
                break;
                
            case 'Descending':  
                this.isSortedAscending = false;
                break;
            default: break;
        }
    }
}