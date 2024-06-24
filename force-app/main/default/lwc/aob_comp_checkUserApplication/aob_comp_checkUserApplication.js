/*
 * ACTION      DATE       OWNER         COMMENT
 * Created   1-08-2023   Devi Ravuri   checkForOpenApplication
 *  @last modified on  : 19 APRIL 2024
 * @last modified by  : Narendra
 * @Modification Description : SFP-38348
 */
import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import {
    CurrentPageReference
} from 'lightning/navigation';
import checkForOpenApplication from '@salesforce/apex/AOB_FLOW_LinkAccountToApplicationMall.checkForOpenApplication';
export default class Aob_comp_checkUserApplication extends NavigationMixin(LightningElement) {
    @api teams = ["Self Assisted"];
    label = {};
    isLoading = true;
    failing;
    pricingOptToOpen;
    urlStateParameters;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.pricingOptToOpen = this.urlStateParameters.prOpt;
        }
    }

    connectedCallback() {
        checkForOpenApplication({ 'pricingOption': this.pricingOptToOpen })
            .then(result => {
                if (result) {
                    window.open(this.label.AOB_AO_Base_URL + result, '_self');
                }
                else {
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                }

            })
            .catch((error) => {
                this.failing = true;
                this.isLoaded = false;
            })

    }


    handleResultChange(event) {
        this.label = event.detail;
    }
}