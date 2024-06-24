import { LightningElement, api } from 'lwc';

import sbgIcons from "@salesforce/resourceUrl/sbgIcons";

export default class MallAuthSolutionsCard extends LightningElement {

    @api
    mySolution;

    redirectionAction(){
        const redirectEvent = new CustomEvent('redirect',{detail:{redirectUrl: this.mySolution.redirectUrl}});
        this.dispatchEvent(redirectEvent);
    }

}