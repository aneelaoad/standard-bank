import { LightningElement, wire, track } from 'lwc';
import thisMonthActionItems from '@salesforce/label/c.iacThisMonthActionItems';
import policiesUpForRenewal from '@salesforce/label/c.iacPoliciesUpForRenewal';
import openClaims from '@salesforce/label/c.iacOpenClaims';
import openOpportunities from '@salesforce/label/c.iacOpenOpportunities';
import getMonthActions from '@salesforce/apex/IAC_HomePageController.getMonthActions'

export default class IacThisMonthActionItems extends LightningElement {

    label = {
        thisMonthActionItems,
        policiesUpForRenewal,
        openClaims,
        openOpportunities,
    };

    @track showSpinner = true;
    @track actualPolicies = 0;
    @track actualClaims = 0;
    @track actualOpp = 0;

    @wire (getMonthActions)
    result({error, data}) {
        if(error) {

            this.showSpinner = false;
        }else if (data) {
            this.actualPolicies = data.policiesUpForRenewal;
            this.actualClaims = data.openClaims;
            this.actualOpp = data.openOpp;
            this.showSpinner = false;
        }
    }
}