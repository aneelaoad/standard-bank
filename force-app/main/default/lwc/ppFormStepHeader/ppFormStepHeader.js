/**
 * @description       :
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             :
 * @last modified on  : 10-05-2023
 * @last modified by  : Peter Guest
 **/
import { LightningElement, api } from "lwc";
import assets from "@salesforce/resourceUrl/PP_Assets";

export default class PpFormStepHeader extends LightningElement {
	
    @api title;
    @api description;
    @api icon;
    iconLink;

    connectedCallback() {
        this.iconLink = assets + "/Icons/" + this.icon;
    }
}