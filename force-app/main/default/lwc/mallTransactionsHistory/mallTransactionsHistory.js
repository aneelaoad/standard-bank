import { LightningElement, wire } from 'lwc';
import sbgIcons from "@salesforce/resourceUrl/sbgIcons";
import getCustomerTransactionHistory from "@salesforce/apex/CTRL_MallTransactionHistory.getCustomerTransactionHistory";

export default class MallTransactionsHistory extends LightningElement {
    overflowIcon = sbgIcons + "/NAVIGATIONVIEWS/icn_overflow_android.svg";

    
    @wire(getCustomerTransactionHistory)
    wiredCustomerTransactionHistory({ error, data }) {
        if (data) {
            console.log('@@ Transaction History Response:', data);
        } else if (error) {
            console.error('@@Error:',error);
        }
    }


}