import { LightningElement, api} from 'lwc';
import { Aob_comp_AddressHelper } from './aob_comp_addressHelper';
export default class Aob_comp_privateaddress extends LightningElement {

 @api teams = ["Self Assisted"];
    label = {};
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

    streetNameAndNumberRegex = Aob_comp_AddressHelper.streetNameAndNumberRegex;
    unitNumberRegex = Aob_comp_AddressHelper.unitNumberBuildingNameRegex;
    buildingNameRegex = Aob_comp_AddressHelper.unitNumberBuildingNameRegex;
    postalCodeRegex = Aob_comp_AddressHelper.postalCodeRegex;
    label = Aob_comp_AddressHelper.label;
    placeholder = Aob_comp_AddressHelper.placeholder;
    message = Aob_comp_AddressHelper.message;


    connectedCallback() {
        this.setAddressBlock(this.defaultData);
    }
    handleResultChange(event) {
        this.label = event.detail;
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