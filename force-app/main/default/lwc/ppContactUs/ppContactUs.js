/**
* @description  : Partner Portal Home Page Success Stories Component
* User Story : SFP-5296
*Test Comment
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date June 2021
*/
import { LightningElement, wire, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Assets from '@salesforce/resourceUrl/PP_Assets';
//import Partner_Object from '@salesforce/schema/PP_Partner__c';
//import OperatingCountry_Field from '@salesforce/schema/PP_Partner__c.PP_OperatingCountry__c';
import basePath from '@salesforce/community/basePath';

export default class PpSupport extends LightningElement {

    @api
    leftSecHeading;
    @api
    leftSecText1;
    @api
    leftSecText2;
    @api
    email;
    @api
    phone;
    @api
    rightSecHeading;
    @api
    rightSecText1;
    @api
    linkText;
    @api
    link;

    breadcrumbArrowIcon
    countryFlag;
    emailIcon;
    phoneIcon;
    countryOptions = [];
    defaultCounty = 'South Africa';
    mailto;

    //@wire(getObjectInfo, { objectApiName: Partner_Object })
    partnershipObj;

/*    @wire(getPicklistValues, {
        recordTypeId: '$partnershipObj.data.defaultRecordTypeId',
        fieldApiName: OperatingCountry_Field
    })
    getIndustryPicklistValues({ error, data }) {
        if (data) {
            this.countryOptions = data.values;
        }
    }
*/
    connectedCallback() {
        this.breadcrumbArrowIcon = Assets + '/Icons/flechitaBreadcrumb.png';
        this.emailIcon = Assets + '/Icons/icn-mail@2x.png';
        this.phoneIcon = Assets + '/Icons/icn-phone-iphone@2x.png';
        this.countryFlag = Assets + '/Icons/SAFlag@3x.png';
        this.mailto = 'mailto:' + this.email;
        let path = basePath.split('/s')[0];
        if (path === '') {
            this.link = '/s' + this.link;
        } else {
            this.link = path + '/s' + this.link;
        }

    }
}