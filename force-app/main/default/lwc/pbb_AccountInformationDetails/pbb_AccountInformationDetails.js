import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBalanceData from '@salesforce/apex/PBB_Lifestyle_AccountInformationCtrl.getBalanceData';
import getProactData from '@salesforce/apex/PBB_Lifestyle_AccountInformationCtrl.getProactData';
import CURRENT_BALANCE_HELPTEXT from '@salesforce/label/c.PBB_Account_Information_Details_Component_Current_Balance_Helptext';
import ACCOUNT_AGE_HELPTEXT from '@salesforce/label/c.PBB_Account_Information_Details_Component_Account_Age_Helptext';
import AVERAGE_CREDIT_TURNOVER_L12M_HELPTEXT from '@salesforce/label/c.PBB_Account_Information_Details_Component_Average_Credit_Turnover_L12M_Helptext';
import AVERAGE_CREDIT_TURNOVER_L3M_HELPTEXT from '@salesforce/label/c.PBB_Account_Information_Details_Component_Average_Credit_Turnover_L3M_Helptext';
import END_OF_MONTH_LIMIT_HELPTEXT from '@salesforce/label/c.PBB_Account_Information_Details_Component_End_of_Month_Limit_Helptext';
import ERI_HELPTEXT from '@salesforce/label/c.PBB_Account_Information_Details_Component_ERI_Helptext';
import ERL_HELPTEXT from '@salesforce/label/c.PBB_Account_Information_Details_Component_ERL_Helptext';

const INFORMATION_MISSING = 'Unable to get data';
const PROACT_ERROR_MESSAGE = 'Unable to get ProAct account information data.';
const BALANCE_ERROR_MESSAGE = 'Unable to get balance data.';
const NO_DATA_FOUND = 'No data found';

export default class PbbAccountInformationDetails extends LightningElement {
    initiallyActiveSections = ['Overview', 'Balances', 'Information'];
    helptext = {
        CURRENT_BALANCE_HELPTEXT,
        ACCOUNT_AGE_HELPTEXT,
        AVERAGE_CREDIT_TURNOVER_L12M_HELPTEXT,
        AVERAGE_CREDIT_TURNOVER_L3M_HELPTEXT,
        END_OF_MONTH_LIMIT_HELPTEXT,
        ERI_HELPTEXT,
        ERL_HELPTEXT
    };

    @api recordId;

    @track actualBalance;
    @track currentBalance;
    @track currency;
    @track showCurrency;
    @track eri;
    @track erl;
    @track accountAge;
    @track averageCreditTurnoverL12M;
    @track averageCreditTurnoverL3M;
    @track endOfMonthInstalment;
    @track endOfMonthLimit;
    @track totalDaysDishonourL6M;
    @track totalDaysInExcessL6M;
    @track proactDataLoading = false;
    @track balanceDataLoading = false;

    @wire(getBalanceData, { accountInformationId: '$recordId' })
    balanceDetails({ error, data }) {
        if (data) {
            this.balanceDataLoading = false;
            if (Object.keys(data).length > 0) {
                this.actualBalance = data[0].balance;
                this.currency = data[0].accountCurrency;
                this.currentBalance = data[1].balance;
                this.showCurrency = true;
                this.addNoDataFoundIfMissingBalanceFieldValue();
            } else {
                this.actualBalance = NO_DATA_FOUND;
                this.currency = NO_DATA_FOUND;
                this.currentBalance = NO_DATA_FOUND;
                this.showCurrency = false;
            }
        } else if (error) {
            this.balanceDataLoading = false;
            this.actualBalance = INFORMATION_MISSING;
            this.currency = INFORMATION_MISSING;
            this.currentBalance = INFORMATION_MISSING;
            this.showCurrency = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: BALANCE_ERROR_MESSAGE,
                variant: 'error',
                mode: 'dismissable'
            }));
        } else {
            this.balanceDataLoading = true;
            this.showCurrency = false;
        }
    }

    @wire(getProactData, { accountInformationId: '$recordId' })
    proactData({ error, data }) {
        if (data) {
            this.proactDataLoading = false;
            if (Object.keys(data).length > 0) { 
                this.eri = data.ERI;
                this.erl = data.ERL;
                this.accountAge = data.accountAge;
                this.averageCreditTurnoverL12M = data.averageCreditTurnoverL12M;
                this.averageCreditTurnoverL3M = data.averageCreditTurnoverL3M;
                this.endOfMonthInstalment = data.endOfMonthInstalment;
                this.endOfMonthLimit = data.endOfMonthLimit;
                this.totalDaysDishonourL6M = data.totalDaysDishonourL6M;
                this.totalDaysInExcessL6M = data.totalDaysInExcessL6M;
                this.addNoDataFoundIfMissingProactFieldValue();
            } else {
                this.eri = NO_DATA_FOUND;
                this.erl = NO_DATA_FOUND;
                this.accountAge = NO_DATA_FOUND;
                this.averageCreditTurnoverL12M = NO_DATA_FOUND;
                this.averageCreditTurnoverL3M = NO_DATA_FOUND;
                this.endOfMonthInstalment = NO_DATA_FOUND;
                this.endOfMonthLimit = NO_DATA_FOUND;
                this.totalDaysDishonourL6M = NO_DATA_FOUND;
                this.totalDaysInExcessL6M = NO_DATA_FOUND;
            }
        } else if (error) {
            this.proactDataLoading = false;
            this.eri = INFORMATION_MISSING;
            this.erl = INFORMATION_MISSING;
            this.accountAge = INFORMATION_MISSING;
            this.averageCreditTurnoverL12M = INFORMATION_MISSING;
            this.averageCreditTurnoverL3M = INFORMATION_MISSING;
            this.endOfMonthInstalment = INFORMATION_MISSING;
            this.endOfMonthLimit = INFORMATION_MISSING;
            this.totalDaysDishonourL6M = INFORMATION_MISSING;
            this.totalDaysInExcessL6M = INFORMATION_MISSING;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: PROACT_ERROR_MESSAGE,
                variant: 'error',
                mode: 'dismissable'
            }));
        } else {
            this.proactDataLoading = true;
        }
    }

    addNoDataFoundIfMissingBalanceFieldValue() {
        const balanceFields = ['actualBalance', 'currency', 'currentBalance'];
        balanceFields.forEach( field => {
            if(!this[field]) {
                field = NO_DATA_FOUND;
            }
        });
    }

    addNoDataFoundIfMissingProactFieldValue() {
        const proactFields = [
            'eri',
            'erl',
            'accountAge',
            'averageCreditTurnoverL12M',
            'averageCreditTurnoverL3M',
            'endOfMonthInstalment',
            'endOfMonthLimit',
            'totalDaysDishonourL6M',
            'totalDaysInExcessL6M'
        ];
        proactFields.forEach( field => {
            if(!this[field]) {
                this[field] = NO_DATA_FOUND;
            }
        });
    }
}