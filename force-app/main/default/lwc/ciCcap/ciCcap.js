import { LightningElement, track, api } from 'lwc';

import getCcapValue from '@salesforce/apex/CiCcap_Controller.getCcapValue';

import CCAP_Label        from '@salesforce/label/c.CCAP_Label';
import CCAP_HelpText     from '@salesforce/label/c.CCAP_HelpText';
import CCAP_NotAvailable from '@salesforce/label/c.CCAP_NotAvailable';
import CCAP_DataNotFound from '@salesforce/label/c.CCAP_DataNotFound';

export default class CiCcap extends LightningElement {
    @api recordId;
    @track ccapList    = [];
    @track cardClasses = 'card_with_shadow';
    showSpinner        = false;

    label = {
        CCAP_Label,
        CCAP_HelpText,
        CCAP_NotAvailable,
        CCAP_DataNotFound
    };

    connectedCallback() {
        this.showSpinner = true;
        if (!this.recordId.startsWith('001')) {
            this.cardClasses = 'card_with_shadow margin_nbac';
        }
        getCcapValue({recordId: this.recordId})
        .then((result) => {
            if (result.isUserAllowedToViewCcap !== true) {
                result.errorMessage ? this.ccapList.push(result.errorMessage) : this.ccapList.push(CCAP_NotAvailable);
            } else {
                for (let [key, value] of Object.entries(result.accountName2Ccap)) {
                    let ccapValue = value ? `ZAR ${value}` : CCAP_DataNotFound;
                    this.ccapList.push(this.recordId.startsWith('001') ? ccapValue :`${key}, ${ccapValue}`);
                }
            }
            this.showSpinner = false;
        })
        .catch((error) => console.error(error));
    }
}