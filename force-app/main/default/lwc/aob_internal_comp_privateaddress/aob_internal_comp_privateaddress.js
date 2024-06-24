import { LightningElement, api, wire } from 'lwc';
import loadData from '@salesforce/apex/AOB_CTRL_ACPicklist.loadData';
import fetchPrefferedBranch from '@salesforce/apex/AOB_CTRL_FormCreator.fetchPrefferedData';
import { Aob_internal_comp_AddressHelper } from './aob_internal_comp_addressHelper';
import AOB_ZA_Mypersonal from '@salesforce/label/c.AOB_ZA_Mypersonal';
import AOB_ZA_Mycompany from '@salesforce/label/c.AOB_ZA_Mycompany';
import AOB_ZA_Pleaseenter from '@salesforce/label/c.AOB_ZA_Pleaseenter';

export default class Aob_internal_comp_privateaddress extends LightningElement {


    label={
        AOB_ZA_Mypersonal,
        AOB_ZA_Mycompany,
        AOB_ZA_Pleaseenter
    }
    @api helpText;
    @api values;
    @api label;
    @api sapfield;
    @api name;
    @api value;
    selectedPicklistValue;
    @api missingValueMessage;
    @api placeholder;
    @api required;
    @api index;
    @api resaddress;
    @api companytradingdata;
    @api applicationId;
    @api defaultData;
    currentValues;
    newAddress = false;
    personalResidentialAddress = false;
    companyTradingAddress = false;
    @api picklistobj = {};
    formdetails1 = {};
    streetNumber;
    unitNumber;
    complexBuildingName;
    city;
    suburb;
    province;
    postalCode;

    streetNameAndNumberRegex = Aob_internal_comp_AddressHelper.streetNameAndNumberRegex;
    unitNumberRegex = Aob_internal_comp_AddressHelper.unitNumberBuildingNameRegex;
    buildingNameRegex = Aob_internal_comp_AddressHelper.unitNumberBuildingNameRegex;
    postalCodeRegex = Aob_internal_comp_AddressHelper.postalCodeRegex;
    label = Aob_internal_comp_AddressHelper.label;
    placeholder = Aob_internal_comp_AddressHelper.placeholder;
    message = Aob_internal_comp_AddressHelper.message;


    connectedCallback() {
        this.setAddressBlock(this.defaultData);
    }
   

    /**
     * This will fire handle change 
     * @param {*} event 
     */

    genericComponentChangeBlur(event){
        let value = event.detail.value;
        let name = event.detail.target;
        this.setAddressBlock(value);
        this.dispatchEvent(new CustomEvent('addressblur', {
            
            bubbles: false,
            detail: {
                value: value,
                target: name,
            }
        }));
    }

    setAddressBlock(value){
        if(value){
            if(value == 'Residential'){
                this.personalResidentialAddress = true;
                this.companyTradingAddress = false;
            }
            if(value == 'Company'){
                this.companyTradingAddress = true;
                this.personalResidentialAddress = false;
            }
            if(value == 'New'){
                this.personalResidentialAddress = false;
                this.companyTradingAddress = false;
            }
        }else{
            this.personalResidentialAddress = false;
            this.companyTradingAddress = false;
        }
    }

}