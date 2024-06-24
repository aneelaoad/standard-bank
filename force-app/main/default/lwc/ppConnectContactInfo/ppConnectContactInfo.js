import { LightningElement, api, wire } from 'lwc';
import Assets from '@salesforce/resourceUrl/PP_Assets';
import userId from '@salesforce/user/Id';
import { getRecord } from "lightning/uiRecordApi";
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';
import getParnerRecordOnwer from '@salesforce/apex/PP_Support_CTRL.getParnerRecordOnwer';

export default class PpConnectContactInfo extends LightningElement {
    @api
    heading;
    @api
    textOne
    @api
    textTwo;
    @api
    imgUrl;
    @api
    email;
    @api
    phone;
    user = '';
    emailIcon;
    phoneIcon;
    userImgUrl;

    @wire(getRecord, { recordId: userId, fields: [USER_CONTACT_ID] })
    wiredUserRecord({ error, data }) {
         if (data) {
            getParnerRecordOnwer({ contactId: data.fields.ContactId.value }).then(result => {
                this.user = result;
                this.userImgUrl = result.FullPhotoUrl;
            });
        }
    }

    connectedCallback() {
        this.imgUrl = Assets + '/images' + this.imgUrl;
        this.emailIcon = Assets + '/Icons/em-Icon.png';
        this.phoneIcon = Assets + '/Icons/ph-Icon.png';

    }
}