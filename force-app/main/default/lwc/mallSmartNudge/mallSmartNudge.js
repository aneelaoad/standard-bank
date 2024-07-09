import { LightningElement, wire } from 'lwc';

import sbgIcons from "@salesforce/resourceUrl/sbgIcons";
import sbgVisualAssets from "@salesforce/resourceUrl/sbgVisualAssets";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME from "@salesforce/schema/User.Name";

export default class MallSmartNudge extends LightningElement {

    crossIcon = sbgIcons + "/OTHER/icn_cross.svg";
    powerAvatar = sbgVisualAssets+ "/poweravatar.png";
    hideSmartNudge = false;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME]
      })
      user;


    get contactName() {
        return getFieldValue(this.user.data, NAME);
    }

    closeAction(){
        this.hideSmartNudge = true;
    }

}