import { LightningElement } from 'lwc';
import getCustomerAccountBalances from "@salesforce/apex/CTRL_MallAccountBalance.getCustomerAccountBalances";
import getCustomerAccountList from "@salesforce/apex/CTRL_MallAccountBalance.getCustomerAccountList";

export default class MallAccountBalance extends LightningElement {
    currentBalance = 238769;
    activeBalance = 987076;
    error;

    connectedCallback() {
        this.getCustomerAccountListInfo();
        this.getCustomerAccountBalanceInfo();
    }

    async getCustomerAccountBalanceInfo() {
        try {
            const customerBalanceInfoResponse = await getCustomerAccountBalances();
            const balances = customerBalanceInfoResponse.message.response.balances;
            console.log(JSON.stringify(balances));
        } catch(error) {
            this.error = error;
        }
    }

    async getCustomerAccountListInfo() {
        try {
            const customerAccountList = await getCustomerAccountList();
            const customerAccountListDetails = customerAccountList.customerAccountListDetails;
        } catch(error) {
            this.error = error;
        }
    }
}