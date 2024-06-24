/**
* @description  : Partner Portal Contact Us Page Sub Component
* User Story : SFP-5296
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
import { LightningElement,wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import Partnership_Object from '@salesforce/schema/PP_PartnerApplication__c';
import OperatingCountry_Field from '@salesforce/schema/PP_PartnerApplication__c.PP_OperatingCountry__c';

export default class PpContactInformation extends LightningElement {

    breadcrumbArrowIcon
    countryFlag;
    emailIcon;
    phoneIcon;
    countryOptions = [];
    defaultCounty = "South Africa";

    @wire(getObjectInfo, { objectApiName: Partnership_Object })
    partnershipObj;

    @wire(getPicklistValues, {
        recordTypeId: '$partnershipObj.data.defaultRecordTypeId',
        fieldApiName: OperatingCountry_Field
    })
    getIndustryPicklistValues({ error, data }) {
        if (data) {

            console.log(data.values);
            this.countryOptions = data.values;
        }
    }

    connectedCallback() {
        this.breadcrumbArrowIcon = Assets + '/Icons/flechitaBreadcrumb.png';
        this.emailIcon = Assets + '/Icons/icn-mail@2x.png';
        this.phoneIcon = Assets + '/Icons/icn-phone-iphone@2x.png';
        this.countryFlag = Assets + '/Icons/SAFlag@3x.png';

    }
}