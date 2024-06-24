/**
 * @description       :
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             :
 * @last modified on  : 08-17-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
 **/
import { LightningElement, api } from "lwc";
import sendEmail from "@salesforce/apex/PP_UserRegistration_CTRL.sendRegistrationInvitation";

export default class PpUserRegistrationInvite extends LightningElement {
    @api contactId;
    error;

    connectedCallback() {
        sendEmail({
            contactId: this.contactId,
        }).catch((error) => {
            this.error = error;
            this.isLoading = false;
        });
    }
}