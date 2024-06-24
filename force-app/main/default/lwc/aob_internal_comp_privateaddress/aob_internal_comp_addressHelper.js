/**
 * @description       : 
 * @author            : Mahlatse
 * @group             : 
 * @last modified on  : 10-10-2023
 * @last modified by  : Mahlatse Tjale
**/
/**Imports */
import { LightningElement} from 'lwc';

/**Labels */
/**Company Trading Address Label*/
import AOB_StreetNumberAndName from '@salesforce/label/c.AOB_StreetNumber_Name'
import AOB_UnitNumber from '@salesforce/label/c.AOB_UnitNumber';
import AOB_ComplexBuildingName from '@salesforce/label/c.AOB_ComplexBuildingName';
import AOB_Suburb from '@salesforce/label/c.AOB_Suburb';
import AOB_CityTown from '@salesforce/label/c.AOB_City_Town';
import AOB_Province from '@salesforce/label/c.AOB_Province';
import AOB_PostalCode from '@salesforce/label/c.AOB_PostalCode';
import AOB_SelectionLabel from '@salesforce/label/c.AOB_SelectPlaceHolder';

/**Company Trading Address Placeholder*/
import AOB_StreetNumberAndName_Placeholder from '@salesforce/label/c.AOB_StreetNumber_Name_Placeholder'
import AOB_UnitNumber_Placeholder from '@salesforce/label/c.AOB_UnitNumber_Placeholder';
import AOB_ComplexBuildingName_Placeholder from '@salesforce/label/c.AOB_ComplexBuildingName_Placeholder';
import AOB_Suburb_Placeholder from '@salesforce/label/c.AOB_Suburb_Placeholder';
import AOB_CityTown_Placeholder from '@salesforce/label/c.AOB_City_Town_Placeholder';
import AOB_Province_Placeholder from '@salesforce/label/c.AOB_Province_Placeholder';
import AOB_PostalCode_Placeholder from '@salesforce/label/c.AOB_PostalCode_Placeholder';

/**Company Trading Address Input Validation*/
        /**Pattern Mismatch*/
import AOB_StreetNumberAndName_Message_Pattern_Mismatch from '@salesforce/label/c.AOB_StreetNumberAndName_Message_Pattern_Mismatch';
import AOB_UnitNumber_Message_Pattern_Mismatch from '@salesforce/label/c.AOB_UnitNumber_Message_Pattern_Mismatch';
import AOB_ComplexBuildingName_Message_Pattern_Mismatch from '@salesforce/label/c.AOB_ComplexBuildingName_Message_Pattern_Mismatch';
import AOB_PostalCode_Message_Pattern_Mismatch from '@salesforce/label/c.AOB_PostalCode_Message_Pattern_Mismatch';
        /**Value Missing*/
import AOB_StreetNumberAndName_Message_Value_Missing from '@salesforce/label/c.AOB_StreetNumberAndName_Message_Value_Missing';
import AOB_Suburb_Message_Value_Missing from '@salesforce/label/c.AOB_Suburb_Message_Value_Missing';
import AOB_CityTown_Message_Value_Missing from '@salesforce/label/c.AOB_City_Town_Message_Value_Missing';
import AOB_Province_Message_Value_Missing from '@salesforce/label/c.AOB_Province_Message_Value_Missing';
import AOB_PostalCode_Message_Value_Missing from '@salesforce/label/c.AOB_PostalCode_Message_Value_Missing';
        /**Min Value*/
import AOB_PostalCode_Message_Min_Value from '@salesforce/label/c.AOB_PostalCode_Message_Min_Value';


export default class Aob_internal_comp_AddressHelper extends LightningElement {

    /** these are the Labels for the addresses*/
    static label = {
        AOB_StreetNumberAndName,
        AOB_UnitNumber,
        AOB_ComplexBuildingName,
        AOB_Suburb,
        AOB_CityTown,
        AOB_Province,
        AOB_PostalCode,
        AOB_SelectionLabel
    }

    /** these are the Placeholders for the addresses*/
    static placeholder = {
        AOB_StreetNumberAndName_Placeholder,
        AOB_UnitNumber_Placeholder,
        AOB_ComplexBuildingName_Placeholder,
        AOB_Suburb_Placeholder,
        AOB_CityTown_Placeholder,
        AOB_Province_Placeholder,
        AOB_PostalCode_Placeholder
    }

    /** these are the Messages used for the addresses*/
    static message = {
        AOB_StreetNumberAndName_Message_Pattern_Mismatch,
        AOB_StreetNumberAndName_Message_Value_Missing,
        AOB_UnitNumber_Message_Pattern_Mismatch,
        AOB_ComplexBuildingName_Message_Pattern_Mismatch,
        AOB_Suburb_Message_Value_Missing,
        AOB_CityTown_Message_Value_Missing,
        AOB_Province_Message_Value_Missing,
        AOB_PostalCode_Message_Value_Missing,
        AOB_PostalCode_Message_Pattern_Mismatch,
        AOB_PostalCode_Message_Min_Value
    }

    /** this is the regex for street name and number */
    static streetNameAndNumberRegex = "^[0-9]{1,10} [a-zA-Z ;-]{2,50}$";

    /** this is the unit number regex */
    static unitNumberBuildingNameRegex = "^[a-zA-Z0-9- ]+$";

    /** this is the postal code and complex/building regex */
    static postalCodeRegex = "^[0-9]+$";

}

export {Aob_internal_comp_AddressHelper};