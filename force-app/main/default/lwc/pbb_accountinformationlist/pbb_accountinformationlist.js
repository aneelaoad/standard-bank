/**
 * Created by yibrahim on 30.07.2020.
 */

import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getAccountInfo from '@salesforce/apex/PBB_Lifestyle_AccountInformationCtrl.getAccountInformationSF';
import getAccountBalances from '@salesforce/apex/PBB_Lifestyle_AccountInformationCtrl.getAccountBalances';
import getAccountProactData from '@salesforce/apex/PBB_Lifestyle_AccountInformationCtrl.getAccountProactData';
import getAccountData from '@salesforce/apex/PBB_Lifestyle_AccountInformationCtrl.getAccountData';

const salesforceColumnsPart1 = [
        { label: 'Account Number', fieldName: 'LinkId', type: 'url', sortable: true,
            typeAttributes:
                {label: { fieldName: 'Name' }, target: '_parent'}
        }
    ];

const salesforceColumnsPart2 = [
        { label: 'Account Status', fieldName: 'AccountStatus', type: 'Text', sortable: true},
        { label: 'Product Category', fieldName: 'ProductCategory', type: 'Text', sortable: true},
        { label: 'Product Sub Category', fieldName: 'ProductSubCategory', type: 'Text', sortable: true},
    ];

const proactColumns = [
        { label: 'End of Month Limit', fieldName: 'EndMonthLimit', type: 'Text', sortable: true},
        { label: 'End of Month Instalment', fieldName: 'EndMonthInstalment', type: 'Text', sortable: true},
        { label: 'Average Credit Turnover L12M', fieldName: 'Turnover12M', type: 'Text', sortable: true},
        { label: 'Average Credit Turnover L3M', fieldName: 'Turnover3M', type: 'Text', sortable: true}
    ];

const balanceColumns = [
        { label: 'Current Balance', fieldName: 'CurrentBalance', type: 'Text', sortable: true, initialWidth: 150},
        { label: 'Actual Balance', fieldName: 'ActualBalance', type: 'Text', sortable: true, initialWidth: 150},
    ];

const columns = salesforceColumnsPart1.concat(balanceColumns, salesforceColumnsPart2, proactColumns);

const DATA_UNAVAILABLE = 'Unable to get data';
const LOADING = 'Loading...';
const NO_DATA_FOUND = 'No data found';

export default class Pbb_accountinformAtionlist extends NavigationMixin(LightningElement) {

    @api recordId;
    @api displayFullView = false;

    @track account;
    @track columns = columns;
    @track auraLink;
    @track listViewLink;
    @track accountName;
    @track accountLink;
    @track count = 0;
    @track accountData = [];
    @track noItems = false;
    @track tableLoadingState = true;

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    sfAccountInfoData;
    balancesAPIData;
    proactAPIData;

    @wire(getAccountInfo , { clientId : '$recordId' })
    wiringMethod({ error, data }) {
        if (data) {
            this.count = data.length;
            this.sfAccountInfoData = data;
            if (this.count == 0) {
                this.noItems = true;
            }
        } else {
            this.sfAccountInfoData = error? {dataError : error} : undefined;
        }
        this.fetchAccountData();
    }

    @wire(getAccountBalances , { clientId : '$recordId' })
    wiringBalancesMethod({ error, data }) {
        this.balancesAPIData = {};
        if (data) {
            this.balancesAPIData = data;
        } else {
            this.balancesAPIData = error? {dataError : error} : undefined;
            this.addErrorStylesToBalancesColumns();
        }
        this.fetchAccountData();
    }

    @wire(getAccountProactData, {clientId : '$recordId' })
    wiringProactMethod({ error, data }) {
        this.proactAPIData = {};
        if (data) {
            console.log('PROA DATA:: ' + JSON.stringify(data));
            this.proactAPIData = data;
        } else {
            this.addErrorStylesToProactColumns()
            this.proactAPIData = error? {dataError : error} : undefined;
        }
        this.fetchAccountData();
    }

    @wire(getAccountData, {clientId : '$recordId' })
        wiringAccountMethod({ error, data }) {
            if (data) {
                this.account = data;
                this.accountLink = '/lightning/r/Account/' + this.recordId + '/view';
                this.listViewLink = '/lightning/o/Account/home';
                this.auraLink = '/lightning/cmp/c__PBB_AccountInformationListContainer?c__recordId=' + this.recordId;
            } else {
                this.account = error? {dataError : error} : undefined;
            }
            this.loading = false;
        }

    fetchAccountData() {
        let accountData = [];
        if (this.sfAccountInfoData) {
            for (var i = 0; i < this.sfAccountInfoData.length; i++) {
                let accountInfoData = {
                    LinkId : LOADING,
                    Id : LOADING,
                    Name : LOADING,
                    ProductCategory : LOADING,
                    ProductSubCategory : LOADING,
                    AccountStatus : LOADING,
                    ActualBalance : LOADING,
                    CurrentBalance : LOADING,
                    ActualBalance : LOADING,
                    CurrentBalance : LOADING,
                    Turnover3M : LOADING,
                    Turnover12M : LOADING,
                    EndMonthInstalment : LOADING,
                    EndMonthLimit : LOADING
                };

                accountInfoData.LinkId = "/" + this.sfAccountInfoData[i].Id;
                accountInfoData.Id = this.sfAccountInfoData[i].Id;
                accountInfoData.Name = this.sfAccountInfoData[i].Name;
                accountInfoData.ProductCategory = this.sfAccountInfoData[i].Product_Category__c;
                accountInfoData.ProductSubCategory = this.sfAccountInfoData[i].Product_Sub_Category__c;
                accountInfoData.AccountStatus = this.sfAccountInfoData[i].Account_Status__c;

                if (this.balancesAPIData) {
                    if (this.balancesAPIData.dataError) {
                        accountInfoData.ActualBalance = DATA_UNAVAILABLE;
                        accountInfoData.CurrentBalance = DATA_UNAVAILABLE;
                    } else if (Object.keys(this.balancesAPIData).length != 0
                                && this.balancesAPIData[String(accountInfoData.Id)]) {
                            let data = this.balancesAPIData[String(accountInfoData.Id)].balances;
                            var formatter = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: data[0].accountCurrency
                            });
                            accountInfoData.ActualBalance = formatter.format(data[0].balance);
                            accountInfoData.CurrentBalance = formatter.format(data[1].balance);
                    } else {
                        accountInfoData.ActualBalance = NO_DATA_FOUND;
                        accountInfoData.CurrentBalance = NO_DATA_FOUND;
                    }
                }

                if (this.proactAPIData) {
                    if (this.proactAPIData.dataError) {
                        accountInfoData.Turnover3M = DATA_UNAVAILABLE;
                        accountInfoData.Turnover12M = DATA_UNAVAILABLE;
                        accountInfoData.EndMonthInstalment = DATA_UNAVAILABLE;
                        accountInfoData.EndMonthLimit = DATA_UNAVAILABLE;
                    }
                    if (Object.keys(this.proactAPIData).length != 0
                        && this.proactAPIData[String(accountInfoData.Name)]) {
                        let data = this.proactAPIData[String(accountInfoData.Name)];
                        accountInfoData.Turnover3M = data.averageCreditTurnoverL3M;
                        accountInfoData.Turnover12M = data.averageCreditTurnoverL12M;
                        accountInfoData.EndMonthInstalment = data.endOfMonthInstalment;
                        accountInfoData.EndMonthLimit = data.endOfMonthLimit;
                    } else {
                        accountInfoData.Turnover3M = NO_DATA_FOUND;
                        accountInfoData.Turnover12M = NO_DATA_FOUND;
                        accountInfoData.EndMonthInstalment = NO_DATA_FOUND;
                        accountInfoData.EndMonthLimit = NO_DATA_FOUND;
                    }
                }
                accountData.push(accountInfoData);
            }
        }
        this.tableLoadingState  = false; 
        this.accountData = accountData;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        }; 
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.accountData];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.accountData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    navigateToFullView() {
        this[NavigationMixin.Navigate]({
            "type": "standard__component",
            "attributes": {
                "componentName": "c__PBB_AccountInformationListContainer"
            },
            "state": {
                "c__recordId": this.recordId
            }
        });
    }

    addErrorStylesToProactColumns() {
        proactColumns.forEach(column => {
            column.cellAttributes = { class: 'slds-text-body_small slds-text-body--small slds-text-color_weak'}
        })
    }

    addErrorStylesToBalancesColumns() { 
        balanceColumns.forEach(column => {
            column.cellAttributes = { class: 'slds-text-body_small slds-text-body--small slds-text-color_weak'}
        })
    }
}