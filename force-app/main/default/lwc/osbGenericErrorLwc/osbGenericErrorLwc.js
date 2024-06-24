import { LightningElement, api } from 'lwc';
import OSB_iconEmail from '@salesforce/resourceUrl/OSB_iconEmail';
import { NavigationMixin } from 'lightning/navigation';
import getLogoutUrl from '@salesforce/apex/OSB_GenericError_CTRL.getLogoutUrl';
export default class OsbGenericErrorLwc extends NavigationMixin(LightningElement) {

    @api logoutURL;
    @api title;
    @api subtitle;
    @api context;
    response;
    @api primaryButtonText;
    @api primaryButtonLink;
    @api secondaryButtonText;
    @api secondaryButtonLink;
    @api navPage;
    @api imageName;
    @api requiresLogout = false;
    @api showMultiButtons = false;
    Logo2 = OSB_iconEmail + '/OSB_iconEmail/ms-icn-tick.png';

    connectedCallback() {
        this.requiresLogout = true;
        getLogoutUrl({}).then(result => {
            this.logoutURL = result;
        })
    }

    handleActionPrimary() {
        let context = this.context;
        if (context == "signUp") {
            window.close();
        }
        else if (context == "NoAccess" || context == "NearlyThere") {
            window.location.replace(this.logoutURL);
        }
        else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: "Home"
                },
            });
        }
    }
}