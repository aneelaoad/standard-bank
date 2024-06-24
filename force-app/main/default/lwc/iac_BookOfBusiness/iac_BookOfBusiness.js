import { LightningElement, track, wire } from 'lwc';
import getBookOfBusiness from '@salesforce/apex/IAC_HomePageController.getBookOfBusiness';
import {getRecord} from 'lightning/uiRecordApi'
import userCurrencyIsoCode from '@salesforce/schema/User.DefaultCurrencyIsoCode';
import userId from '@salesforce/user/Id';

import premiumOfPoliciesRenewed from '@salesforce/label/c.iacPremiumOfPoliciesRenewed';
import policiesRenewed from '@salesforce/label/c.iacPoliciesRenewed';
import opportunityConversionRatio from '@salesforce/label/c.iacOpportunityConversionRatio';
import bookOfBusiness from '@salesforce/label/c.iacBookOfBusiness';
import policiesIncepted from '@salesforce/label/c.iacPoliciesIncepted';
import premOfPoliciesIncepted from '@salesforce/label/c.iacPremOfPoliciesIncepted';

export default class IacBookOfBusiness extends LightningElement {
    timeFilterItems = [
        {
            label: 'MTD',
            value: 'MTD'
        },
        {
            label: 'QTD',
            value: 'QTD'
        },
        {
            label: 'YTD',
            value: 'YTD'
        }
    ];
    selectedTimeFilter = 'MTD';
    label = {
        policiesIncepted,
        premOfPoliciesIncepted,
        premiumOfPoliciesRenewed,
        policiesRenewed,
        opportunityConversionRatio,
        bookOfBusiness
    };
    @track error;
    @track showSpinner = true;
    @track userCurrency;
    @track actualPremOfPoliciesIncepted = 0;
    @track actualPremOfPoliciesRenewed = 0;
    @track actualPoliciesIncepted = 0;
    @track actualPoliciesRenewed = 0;
    @track oppConversionRatio = 0;

    @wire(getRecord, {recordId: userId, fields: [userCurrencyIsoCode]})
    wireUser({error, data}) {
        if(error) {
            this.error = error;
            this.userCurrency = undefined;
        }else if (data) {
            this.error = undefined;
            if(data.fields.DefaultCurrencyIsoCode && data.fields.DefaultCurrencyIsoCode.value) {
                this.userCurrency = data.fields.DefaultCurrencyIsoCode.value;
            }
        }
    }

    @wire (getBookOfBusiness, {timeFilter: '$selectedTimeFilter'})
    result({error, data}) {
        if(error) {
            this.error = error;
            this.showSpinner = false;
        }else if(data) {
            this.error = undefined;
            this.actualPremOfPoliciesIncepted = data.actualPremOfPoliciesIncepted;
            this.actualPremOfPoliciesRenewed = data.actualPremOfPoliciesRenewed;
            this.actualPoliciesIncepted = data.actualPoliciesIncepted;
            this.actualPoliciesRenewed = data.actualPoliciesRenewed;
            this.oppConversionRatio = data.oppConversionRatio;
            this.showSpinner = false;
        }
    }

    handleChangedFilter(event) {
        this.showSpinner = true;
        this.calculateForNewFilter(event.detail.value);
    }

    calculateForNewFilter(filter) {
        getBookOfBusiness({timeFilter: filter})
        .then(data => {
            this.error = undefined;
            this.actualPremOfPoliciesIncepted = data.actualPremOfPoliciesIncepted;
            this.actualPremOfPoliciesRenewed = data.actualPremOfPoliciesRenewed;
            this.actualPoliciesIncepted = data.actualPoliciesIncepted;
            this.actualPoliciesRenewed = data.actualPoliciesRenewed;
            this.oppConversionRatio = data.oppConversionRatio;
            this.showSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.showSpinner = false;
        });
    }

}