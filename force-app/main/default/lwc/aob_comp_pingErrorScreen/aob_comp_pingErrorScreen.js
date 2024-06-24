import { LightningElement, api,
    wire } from 'lwc';

// Import Custom Labels

import logoutUser from '@salesforce/apex/AOB_API_BusinessLead_CTRL.logoutUser';
import AOB_AO_Base_URL from '@salesforce/label/c.AOB_AO_Base_URL';
import AOB_AO_LogoutURL from '@salesforce/label/c.AOB_AO_LogoutURL';


export default class Aob_comp_pingErrorScreen extends LightningElement {
    @api applicationId;
    isLoaded = false;
     @api teams = ["Self Assisted"];
    label = {};
    
    handleResultChange(event) {
        this.label = event.detail;
    }

    handleBackToBrowsing(event) {
        this.isLoaded = true;
        window.fireButtonClickEvent(this, event);
        logoutUser({}).then(result => {
            this.isLoaded = false;
            var launchURL= AOB_AO_LogoutURL+AOB_AO_Base_URL+this.applicationId;
            window.open(launchURL,"__self");
        }).catch(error => {
            this.isLoaded = false;
        });
    }
}