import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import name from "@salesforce/schema/User.Name";
import USER_ID from "@salesforce/user/Id";

import IS_GUEST from '@salesforce/user/isGuest';

export default class MallFaqIntroText extends LightningElement {
    @api supportingText;
    @api introHeadingOutput = "FAQs";
    @api introTextDefault;
    @api introText;
    @api recordId;
    result;
    
    @wire(getRecord, { recordId: USER_ID, fields: [name] })
    user;

    get introTextOutput() {
        return this.introTextDefault;
        // if (IS_GUEST) {
        // } 

        // let firstName = "there";
        // if (this.user.data !== undefined) {
        //     // We grab just the first name from the field
        //     firstName =  getFieldValue(this.user.data, name).split(" ")[0];
        // }
        // this.result = "Hi " + firstName + ", " +  this.introText ;
        // return this.result;
    }
}