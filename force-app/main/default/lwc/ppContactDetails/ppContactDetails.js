/**
* @description  : Partner Portal Home Page Contact Us Component
* User Story : SFP-5296
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date June 2021
*/
import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import Partner_Object from '@salesforce/schema/PP_PartnerApplication__c';
import OperatingCountry_Field from '@salesforce/schema/PP_PartnerApplication__c.PP_OperatingCountry__c';
import basePath from '@salesforce/community/basePath';
import { trackLink } from 'c/ppEventUtils'

export default class PpContactDetails extends LightningElement {

    @api
    leftSecHeading;
    @api
    leftSecText1;
    @api
    leftSecText2;
    email;
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

    @wire(getObjectInfo, { objectApiName: Partner_Object })
    partnershipObj;

    @wire(getPicklistValues, {
        recordTypeId: '$partnershipObj.data.defaultRecordTypeId',
        fieldApiName: OperatingCountry_Field
    })
    getIndustryPicklistValues({ error, data }) {
        if (data) {
            for(let i=0; i<data.values.length; i++){
                if(data.values[i].label === 'South Africa' ||
                 data.values[i].label === 'Uganda' || data.values[i].label === 'Ghana'){
                this.countryOptions = [...this.countryOptions, data.values[i]];
                }
            }
        }
    }

    connectedCallback() {
        this.breadcrumbArrowIcon = Assets + '/Icons/flechitaBreadcrumb.png';
        this.emailIcon = Assets + '/Icons/icn-mail@2x.png';
        this.phoneIcon = Assets + '/Icons/icn-phone-iphone@2x.png';
        this.countryFlag = Assets + '/Icons/SAFlag@3x.png';
        this.email = 'partners@standardbank.co.za';
        this.mailto = 'mailto:' + this.email;
        let path = basePath.split('/s')[0];
        if (path === '') {
            this.link = '/s' + this.link;
        } else {
            this.link = path + '/s' + this.link;
        }

    }

    handleInputChange(event){
        if (event.detail.value === 'South Africa') {
            this.email = 'partners@standardbank.co.za';
            this.countryFlag = Assets + '/Icons/SAFlag@3x.png';
        }else if(event.detail.value === 'Uganda'){
            this.email = 'partners@standardbank.co.ug';
            this.countryFlag = Assets + '/Icons/ugandaFlag.png';
        }else if(event.detail.value === 'Ghana'){
            this.email = 'partners@standardbank.com.gh';
            this.countryFlag = Assets + '/Icons/ghanaFlag.png';
        }
        this.mailto = 'mailto:' + this.email;
    }

    tracker(event) {
        trackLink(event);
    }
}