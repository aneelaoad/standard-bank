/**
 * Created by mpesko on 9/15/2021.
 */

import { LightningElement ,api, wire, track} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getRevenuesList from '@salesforce/apex/CRT_clientRelatedRevenues_CTRL.getRelatedRevenues';
import hasUserAccessToRevenues from '@salesforce/apex/CRT_clientRelatedRevenues_CTRL.hasUserAccessToRevenues';
export default class CrtClientRelatedRevenues extends LightningElement {
    @api recordId;
    @track columns = [{
            label: 'Department',
            fieldName: 'department',
            type: 'text',
            sortable: true
        },
        {
            label: 'Booking Country',
            fieldName: 'bookingCountry',
            type: 'text',
            sortable: true
        },
        {
             label: 'Average Credit Balance YTD (ZAR)',
             fieldName: 'averageCreditBalanceYTDZAR',
             type: 'Number',
             typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
             cellAttributes: { alignment: 'right' },
             sortable: true
        },
        {
             label: 'Average Debit Balance YTD (ZAR)',
             fieldName: 'averageDebitBalanceYTDZAR',
             type: 'Number',
             typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 },
             cellAttributes: { alignment: 'right' },
             sortable: true
        },
        {
             label: 'Actual Revenue YTD (ZAR)',
             fieldName: 'actualRevenueYTDZAR',
             type: 'Number',
             typeAttributes: { maximumFractionDigits: 2 },
             cellAttributes: { alignment: 'right'},
             sortable: true
        },
        {
             label: '',
             fieldName: 'nameUrl',
             type: 'url',
             typeAttributes: { label: { fieldName: 'gcrName' }, target: '_blank' },
             cellAttributes: { alignment: 'center' },
             sortable: true
        }
    ];

    @track error;
    @track revenueList ;
    @track hasUserAccess;
    @wire(getRevenuesList, {clientId: '$recordId'})
    wiredRevenues({
        error,
        data
    }) {
        if (data) {
            this.revenueList = data;
        } else if (error) {
            this.error = error;
        }
    }
    @wire(hasUserAccessToRevenues)
        wiredAccess({
            error,
            data
        }) {
            if (data) {
                this.hasUserAccess = data;
            } else if (error) {
                this.error = error;
            }
        }
}